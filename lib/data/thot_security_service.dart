import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'
    show VoidCallback, debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart' as pc_hmac;
import 'package:pointycastle/digests/sha256.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/thresholds.dart';

class ThotSecurityService {
  ThotSecurityService({
    required FlutterSecureStorage secureStorage,
    required LocalAuthentication localAuth,
    required VoidCallback onChanged,
  }) : _secureStorage = secureStorage,
       _localAuth = localAuth,
       _onChanged = onChanged;

  static const int pinLength = 6;
  static const int maxPinAttempts = Thresholds.pinMaxAttempts;
  static const Duration pinLockDuration = Duration(minutes: Thresholds.pinLockoutMinutes);
  static const int _pbkdf2Iterations = 100000;
  static const int _pbkdf2KeyLength = 32;
  // Storage keys for the PBKDF2-derived hash. Old SHA-256 hash uses
  // 'user_pin_hash' / 'user_pin_salt' and is migrated transparently on
  // first successful PIN entry.
  static const String _pinHashKey = 'user_pin_hash_v2';
  static const String _pinSaltKey = 'user_pin_salt_v2';
  static const String _legacyPinHashKey = 'user_pin_hash';
  static const String _legacyPinSaltKey = 'user_pin_salt';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;
  final VoidCallback _onChanged;

  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _isAuthenticated = false;

  bool get pinEnabled => _pinEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pinEnabled = prefs.getBool('pinEnabled') ?? false;
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;

      if (_pinEnabled) {
        final v2Hash = await _secureStorage.read(key: _pinHashKey);
        final v1Hash = await _secureStorage.read(key: _legacyPinHashKey);
        if ((v2Hash == null || v2Hash.isEmpty) &&
            (v1Hash == null || v1Hash.isEmpty)) {
          if (kDebugMode) {
            debugPrint(
              'PIN enabled without stored hash; disabling local PIN state.',
            );
          }
          _pinEnabled = false;
          await prefs.setBool('pinEnabled', false);
        }
      }

      if (_biometricEnabled) {
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        if (!canCheckBiometrics || !isDeviceSupported) {
          _biometricEnabled = false;
          await prefs.setBool('biometricEnabled', false);
        }
      }

      _onChanged();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading security settings.');
      }
    }
  }

  Future<void> lockSession() async {
    if (!_pinEnabled) return;
    if (_isAuthenticated) {
      _isAuthenticated = false;
      _onChanged();
    }
  }

  /// Returns true if the PIN is currently locked out due to too many failed attempts.
  Future<bool> isCurrentlyLocked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockedUntilRaw = prefs.getString('pin_locked_until');
      if (lockedUntilRaw == null) return false;

      final lockedUntil = DateTime.tryParse(lockedUntilRaw);
      if (lockedUntil == null) return false;

      return DateTime.now().isBefore(lockedUntil);
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyPin(String enteredPin) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lockedUntilRaw = prefs.getString('pin_locked_until');
      if (lockedUntilRaw != null) {
        final lockedUntil = DateTime.tryParse(lockedUntilRaw);
        if (lockedUntil != null && DateTime.now().isBefore(lockedUntil)) {
          return false;
        }
        await prefs.remove('pin_locked_until');
      }

      // Try PBKDF2 (v2) first.
      final v2Hash = await _secureStorage.read(key: _pinHashKey);
      final v2Salt = await _secureStorage.read(key: _pinSaltKey);

      if (v2Hash != null && v2Salt != null) {
        final candidate = _hashPin(enteredPin, v2Salt);
        if (_constantTimeEquals(candidate, v2Hash)) {
          await prefs.setInt('pin_failed_attempts', 0);
          await prefs.remove('pin_locked_until');
          _isAuthenticated = true;
          _onChanged();
          return true;
        }
      } else {
        // Fall back to legacy SHA-256 (v1) and migrate transparently on success.
        final v1Hash = await _secureStorage.read(key: _legacyPinHashKey);
        final v1Salt = await _secureStorage.read(key: _legacyPinSaltKey);

        if (v1Hash != null && v1Salt != null) {
          final candidate = _legacyHashPin(enteredPin, v1Salt);
          if (_constantTimeEquals(candidate, v1Hash)) {
            // Migrate to PBKDF2 with a fresh salt.
            final newSalt = _generateSalt();
            final newHash = _hashPin(enteredPin, newSalt);
            await _secureStorage.write(key: _pinHashKey, value: newHash);
            await _secureStorage.write(key: _pinSaltKey, value: newSalt);
            await _secureStorage.delete(key: _legacyPinHashKey);
            await _secureStorage.delete(key: _legacyPinSaltKey);

            await prefs.setInt('pin_failed_attempts', 0);
            await prefs.remove('pin_locked_until');
            _isAuthenticated = true;
            _onChanged();
            return true;
          }
        }
      }

      // Failed attempt counter logic, identical to before.
      final attempts = (prefs.getInt('pin_failed_attempts') ?? 0) + 1;
      if (attempts >= maxPinAttempts) {
        await prefs.setInt('pin_failed_attempts', 0);
        await prefs.setString(
          'pin_locked_until',
          DateTime.now().add(pinLockDuration).toIso8601String(),
        );
      } else {
        await prefs.setInt('pin_failed_attempts', attempts);
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error verifying PIN.');
      }
      return false;
    }
  }

  Future<bool> authenticateWithBiometric({String? localizedReason}) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason ?? 'Authenticate to access THOT',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        _isAuthenticated = true;
        _onChanged();
      }

      return didAuthenticate;
    } on LocalAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('Biometric auth error: ${e.code} - ${e.toString()}');
      }

      // Handle specific error codes for better UX
      switch (e.code) {
        case LocalAuthExceptionCode.biometricLockout:
        case LocalAuthExceptionCode.temporaryLockout:
          // User is temporarily locked out
          break;
        case LocalAuthExceptionCode.noBiometricHardware:
          // No biometric hardware available
          break;
        default:
          // Other errors
          break;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error with biometric auth: $e');
      }
      return false;
    }
  }

  /// Atomically persist a new PIN. The order matters:
  ///
  /// 1. Validate input.
  /// 2. Write the new hash + salt to secure storage. If either write
  ///    fails, the state is unchanged (no half-broken PIN).
  /// 3. Flip `pinEnabled = true` in plain prefs LAST so that, if the
  ///    process dies between steps 2 and 3, the user is not locked out:
  ///    the legacy/v2 hash may exist on disk but `pinEnabled` will still
  ///    read false at next launch → user lands on the normal app flow,
  ///    not a lock screen that demands a hash we can't verify.
  /// 4. Clean up the legacy v1 hash AFTER the new one is fully active.
  ///
  /// Throws [PinSetupException] on failure so the UI can show a real
  /// error instead of silently accepting an invalid state.
  Future<void> setPinCode(String pin) async {
    final normalized = pin.trim();

    if (normalized.length != pinLength || int.tryParse(normalized) == null) {
      throw PinSetupException(PinSetupError.invalidFormat);
    }

    final salt = _generateSalt();
    final hashedPin = _hashPin(normalized, salt);

    // Snapshot what's on disk so we can roll back if step 3 fails.
    final previousHash = await _secureStorage.read(key: _pinHashKey);
    final previousSalt = await _secureStorage.read(key: _pinSaltKey);

    try {
      // Step 2: write new credentials. If one of these throws, the catch
      // block below restores the previous state.
      await _secureStorage.write(key: _pinHashKey, value: hashedPin);
      await _secureStorage.write(key: _pinSaltKey, value: salt);

      // Step 3: flip the enabled flag and reset lockout counters.
      // This is the "commit" line — after this, the PIN is officially set.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pinEnabled', true);
      await prefs.setInt('pin_failed_attempts', 0);
      await prefs.remove('pin_locked_until');

      _pinEnabled = true;
      _isAuthenticated = true;

      // Step 4: best-effort cleanup of legacy v1 hash. Failures here are
      // non-fatal (worst case: a stale legacy key sits in keychain and
      // gets ignored by verifyPin which prefers v2 anyway).
      try {
        await _secureStorage.delete(key: _legacyPinHashKey);
        await _secureStorage.delete(key: _legacyPinSaltKey);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Non-fatal: failed to clean legacy PIN hash: $e');
        }
      }

      _onChanged();
    } catch (e) {
      // Roll back step 2 writes so we don't leave a half-written PIN.
      try {
        if (previousHash != null) {
          await _secureStorage.write(key: _pinHashKey, value: previousHash);
        } else {
          await _secureStorage.delete(key: _pinHashKey);
        }
        if (previousSalt != null) {
          await _secureStorage.write(key: _pinSaltKey, value: previousSalt);
        } else {
          await _secureStorage.delete(key: _pinSaltKey);
        }
      } catch (_) {
        // If rollback itself fails there's not much we can do — the
        // user's next launch will fall through to the "no PIN" path
        // because pinEnabled was never set to true.
      }
      if (kDebugMode) {
        debugPrint('Error setting PIN: $e');
      }
      throw PinSetupException(PinSetupError.storageFailure, cause: e);
    }
  }

  Future<void> togglePinEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!enabled) {
        await _secureStorage.delete(key: _pinHashKey);
        await _secureStorage.delete(key: _pinSaltKey);
        await _secureStorage.delete(key: _legacyPinHashKey);
        await _secureStorage.delete(key: _legacyPinSaltKey);
        await prefs.remove('pin_failed_attempts');
        await prefs.remove('pin_locked_until');
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }

      _pinEnabled = enabled;
      await prefs.setBool('pinEnabled', enabled);

      _onChanged();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error toggling PIN.');
      }
    }
  }

  Future<void> toggleBiometricEnabled(bool enabled) async {
    try {
      if (enabled) {
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();

        if (!canCheckBiometrics || !isDeviceSupported) {
          if (kDebugMode) {
            debugPrint('Biometric authentication unavailable on this device.');
          }
          return;
        }
      }

      _biometricEnabled = enabled;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometricEnabled', enabled);

      _onChanged();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error toggling biometric.');
      }
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _onChanged();
  }

  Future<void> clearAllSecurityData() async {
    final prefs = await SharedPreferences.getInstance();

    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _legacyPinHashKey);
    await _secureStorage.delete(key: _legacyPinSaltKey);
    await prefs.remove('pinEnabled');
    await prefs.remove('biometricEnabled');
    await prefs.remove('pin_failed_attempts');
    await prefs.remove('pin_locked_until');

    _pinEnabled = false;
    _biometricEnabled = false;
    _isAuthenticated = false;
    _onChanged();
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  /// Constant-time string comparison to prevent timing side-channel attacks.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Legacy SHA-256 PIN hash. Kept for transparent migration to PBKDF2.
  String _legacyHashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt::$pin')).toString();
  }

  /// PBKDF2-HMAC-SHA256 PIN hash. 100k iterations, 32 bytes output.
  /// Returns a base64 string suitable for secure storage.
  String _hashPin(String pin, String saltBase64) {
    final saltBytes = base64Decode(saltBase64);
    final pinBytes = utf8.encode(pin);

    final pbkdf2 = PBKDF2KeyDerivator(pc_hmac.HMac(SHA256Digest(), 64))
      ..init(
        Pbkdf2Parameters(
          Uint8List.fromList(saltBytes),
          _pbkdf2Iterations,
          _pbkdf2KeyLength,
        ),
      );

    final derived = pbkdf2.process(Uint8List.fromList(pinBytes));
    return base64Encode(derived);
  }
}

/// Reason a PIN setup attempt failed. Use this in the UI to show a
/// localized message instead of a generic "something went wrong".
enum PinSetupError {
  invalidFormat,
  storageFailure,
}

class PinSetupException implements Exception {
  PinSetupException(this.error, {this.cause});
  final PinSetupError error;
  final Object? cause;

  @override
  String toString() => 'PinSetupException($error${cause == null ? '' : ', cause: $cause'})';
}
