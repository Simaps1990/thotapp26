import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show VoidCallback, debugPrint, kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThotSecurityService {
  ThotSecurityService({
    required FlutterSecureStorage secureStorage,
    required LocalAuthentication localAuth,
    required VoidCallback onChanged,
  })  : _secureStorage = secureStorage,
        _localAuth = localAuth,
        _onChanged = onChanged;

  static const int pinLength = 6;
  static const int maxPinAttempts = 5;
  static const Duration pinLockDuration = Duration(minutes: 30);

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
        final storedHash = await _secureStorage.read(key: 'user_pin_hash');
        if (storedHash == null || storedHash.isEmpty) {
          if (kDebugMode) {
            debugPrint('PIN enabled without stored hash; disabling local PIN state.');
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

      final storedHash = await _secureStorage.read(key: 'user_pin_hash');
      final salt = await _secureStorage.read(key: 'user_pin_salt');

      if (storedHash == null || salt == null) {
        return false;
      }

      final candidateHash = _hashPin(enteredPin, salt);

      if (candidateHash == storedHash) {
        await prefs.setInt('pin_failed_attempts', 0);
        await prefs.remove('pin_locked_until');
        _isAuthenticated = true;
        _onChanged();
        return true;
      }

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

  Future<bool> authenticateWithBiometric() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à THOT',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        _isAuthenticated = true;
        _onChanged();
      }

      return didAuthenticate;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error with biometric auth.');
      }
      return false;
    }
  }

  Future<void> setPinCode(String pin) async {
    try {
      final normalized = pin.trim();

      if (normalized.length != pinLength || int.tryParse(normalized) == null) {
        throw ArgumentError('Le PIN doit contenir exactement $pinLength chiffres.');
      }

      final salt = _generateSalt();
      final hashedPin = _hashPin(normalized, salt);

      await _secureStorage.write(key: 'user_pin_hash', value: hashedPin);
      await _secureStorage.write(key: 'user_pin_salt', value: salt);

      _pinEnabled = true;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pinEnabled', true);
      await prefs.setInt('pin_failed_attempts', 0);
      await prefs.remove('pin_locked_until');

      _onChanged();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting PIN.');
      }
    }
  }

  Future<void> togglePinEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!enabled) {
        await _secureStorage.delete(key: 'user_pin_hash');
        await _secureStorage.delete(key: 'user_pin_salt');
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

    await _secureStorage.delete(key: 'user_pin_hash');
    await _secureStorage.delete(key: 'user_pin_salt');
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

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt::$pin')).toString();
  }
}
