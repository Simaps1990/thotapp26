import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, debugPrint, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart' show PlatformException;
import 'package:pointycastle/export.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThotFileStore {
  ThotFileStore({required FlutterSecureStorage secureStorage})
    : _legacyReader = _LegacyEncryptedReader(secureStorage: secureStorage);

  final _LegacyEncryptedReader _legacyReader;

  Future<Directory> _getAppDataDir() async {
    return getApplicationSupportDirectory();
  }

  Future<File> _getAppDataFile() async {
    final dir = await _getAppDataDir();
    return File('${dir.path}/thot_data_v1.dat');
  }

  Future<File> _getAppDataTempFile() async {
    final dir = await _getAppDataDir();
    return File('${dir.path}/thot_data_v1.tmp');
  }

  Future<File> _getAppDataBackupFile() async {
    final dir = await _getAppDataDir();
    return File('${dir.path}/thot_data_v1.bak');
  }

  Future<File> _getLegacyDocumentsDataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/thot_data.json');
  }

  Future<File> _getRecoveryFile() async {
    final dir = await _getAppDataDir();
    return File('${dir.path}/thot_recovery_v1.json');
  }

  Future<void> writeDomainData(String rawJson) async {
    if (kIsWeb) return;

    final file = await _getAppDataFile();
    final tempFile = await _getAppDataTempFile();
    final backupFile = await _getAppDataBackupFile();

    if (await file.exists()) {
      try {
        await file.copy(backupFile.path);
      } catch (_) {}
    }

    await tempFile.writeAsString(rawJson, flush: true);

    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }

    await tempFile.rename(file.path);

    try {
      final recoveryFile = await _getRecoveryFile();
      if (await recoveryFile.exists()) {
        await recoveryFile.delete();
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> readDomainData() async {
    if (kIsWeb) return null;

    final file = await _getAppDataFile();

    if (!await file.exists()) {
      final legacy = await _getLegacyDocumentsDataFile();
      if (await legacy.exists()) {
        try {
          final legacyRaw = await legacy.readAsString();
          if (legacyRaw.isNotEmpty) {
            final decoded = jsonDecode(legacyRaw);
            if (decoded is Map<String, dynamic>) {
              await writeDomainData(legacyRaw);
              await legacy.delete();
              return decoded;
            }
          }
        } catch (_) {}
      }
    }

    final backupFile = await _getAppDataBackupFile();

    for (final candidate in [file, backupFile]) {
      if (!await candidate.exists()) continue;
      final raw = await candidate.readAsString();
      if (raw.isEmpty) continue;

      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          if (candidate.path == backupFile.path) {
            await writeDomainData(raw);
          }
          return decoded;
        }
      } catch (_) {}

      final legacyDecoded = await _legacyReader.tryDecryptDomainData(raw);
      if (legacyDecoded != null) {
        await writeDomainData(jsonEncode(legacyDecoded));
        return legacyDecoded;
      }
    }

    try {
      final recoveryFile = await _getRecoveryFile();
      if (await recoveryFile.exists()) {
        final recoveryRaw = await recoveryFile.readAsString();
        if (recoveryRaw.isNotEmpty) {
          final decoded = jsonDecode(recoveryRaw);
          if (decoded is Map<String, dynamic>) {
            await writeDomainData(recoveryRaw);
            return decoded;
          }
        }
      }
    } catch (_) {}

    return null;
  }

  Future<void> clearDomainData() async {
    if (kIsWeb) return;

    final file = await _getAppDataFile();
    final tempFile = await _getAppDataTempFile();
    final backupFile = await _getAppDataBackupFile();
    final legacyFile = await _getLegacyDocumentsDataFile();
    final recoveryFile = await _getRecoveryFile();

    for (final candidate in [
      file,
      tempFile,
      backupFile,
      legacyFile,
      recoveryFile,
    ]) {
      if (await candidate.exists()) {
        try {
          await candidate.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> clearEncryptionKeys() async {
    await _legacyReader.clearEncryptionKeys();
  }
}

class _LegacyEncryptedReader {
  _LegacyEncryptedReader({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  static const String _masterKeySecureKey = 'thot_data_master_key_v2';
  static const String _masterKeyPrefsKey = 'thot_mk_ob_v3';

  static const List<int> _obfSalt = [
    0x4B,
    0x72,
    0x91,
    0xC3,
    0x5E,
    0xA7,
    0x28,
    0xF6,
    0x13,
    0x9D,
    0x64,
    0xB0,
    0x37,
    0xE2,
    0x8C,
    0x51,
    0xAA,
    0x7F,
    0xD4,
    0x06,
    0xBE,
    0x49,
    0x83,
    0xCC,
    0x12,
    0x5A,
    0xF1,
    0x3E,
    0x97,
    0x60,
    0xDB,
    0x24,
  ];

  static const _iosOpts = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    synchronizable: true,
  );

  static const _androidOpts = AndroidOptions(resetOnError: true);

  bool get _isApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  String _obfuscate(String b64) {
    final bytes = base64Decode(b64);
    final salt = _obfSalt;
    final out = Uint8List(bytes.length);
    for (var i = 0; i < bytes.length; i++) {
      out[i] = bytes[i] ^ salt[i % salt.length];
    }
    return base64Encode(out);
  }

  String _deobfuscate(String obfB64) => _obfuscate(obfB64);

  Future<String?> _secureRead(String key) async {
    try {
      if (_isApple) {
        return await _secureStorage.read(key: key, iOptions: _iosOpts);
      }
      if (_isAndroid) {
        return await _secureStorage.read(key: key, aOptions: _androidOpts);
      }
      return await _secureStorage.read(key: key);
    } on PlatformException catch (e) {
      debugPrint('[ThotStore] secureRead error: $e');
      return null;
    } catch (e) {
      debugPrint('[ThotStore] secureRead unexpected: $e');
      return null;
    }
  }

  Future<void> _secureWrite(String key, String value) async {
    try {
      if (_isApple) {
        await _secureStorage.write(key: key, value: value, iOptions: _iosOpts);
        return;
      }
      if (_isAndroid) {
        await _secureStorage.write(
          key: key,
          value: value,
          aOptions: _androidOpts,
        );
        return;
      }
      await _secureStorage.write(key: key, value: value);
    } on PlatformException catch (e) {
      debugPrint('[ThotStore] secureWrite error: $e');
    } catch (e) {
      debugPrint('[ThotStore] secureWrite unexpected: $e');
    }
  }

  Future<void> _secureDelete(String key) async {
    try {
      if (_isApple) {
        await _secureStorage.delete(key: key, iOptions: _iosOpts);
        return;
      }
      if (_isAndroid) {
        await _secureStorage.delete(key: key, aOptions: _androidOpts);
        return;
      }
      await _secureStorage.delete(key: key);
    } catch (_) {}
  }

  Future<String> _getOrCreateMasterKey() async {
    final prefs = await SharedPreferences.getInstance();

    final secureVal = await _secureRead(_masterKeySecureKey);
    if (secureVal != null && secureVal.isNotEmpty) {
      await prefs.setString(_masterKeyPrefsKey, _obfuscate(secureVal));
      return secureVal;
    }

    final obfVal = prefs.getString(_masterKeyPrefsKey);
    if (obfVal != null && obfVal.isNotEmpty) {
      try {
        final restored = _deobfuscate(obfVal);
        if (restored.isNotEmpty) {
          await _secureWrite(_masterKeySecureKey, restored);
          return restored;
        }
      } catch (_) {}
    }

    const legacyPrefsKey = 'thot_data_master_key_v1';
    const legacySecureKey = 'thot_data_master_key_v2';

    try {
      final legacySecure = await _secureStorage.read(key: legacySecureKey);
      if (legacySecure != null && legacySecure.isNotEmpty) {
        await _secureWrite(_masterKeySecureKey, legacySecure);
        await prefs.setString(_masterKeyPrefsKey, _obfuscate(legacySecure));
        await prefs.remove(legacyPrefsKey);
        return legacySecure;
      }
    } catch (_) {}

    final legacyPrefs = prefs.getString(legacyPrefsKey);
    if (legacyPrefs != null && legacyPrefs.isNotEmpty) {
      await _secureWrite(_masterKeySecureKey, legacyPrefs);
      await prefs.setString(_masterKeyPrefsKey, _obfuscate(legacyPrefs));
      await prefs.remove(legacyPrefsKey);
      return legacyPrefs;
    }

    const legacyDerivedSecureKey = 'thot_data_encryption_key_v1';

    try {
      final legacyDerived = await _secureStorage.read(
        key: legacyDerivedSecureKey,
      );
      if (legacyDerived != null && legacyDerived.isNotEmpty) {
        await _secureWrite(_masterKeySecureKey, legacyDerived);
        await prefs.setString(_masterKeyPrefsKey, _obfuscate(legacyDerived));
        return legacyDerived;
      }
    } catch (_) {}

    final legacyDerivedPrefs = prefs.getString(legacyDerivedSecureKey);
    if (legacyDerivedPrefs != null && legacyDerivedPrefs.isNotEmpty) {
      await _secureWrite(_masterKeySecureKey, legacyDerivedPrefs);
      await prefs.setString(_masterKeyPrefsKey, _obfuscate(legacyDerivedPrefs));
      return legacyDerivedPrefs;
    }

    throw Exception('Legacy encryption key unavailable');
  }

  Uint8List _deriveEncryptionKey(String masterKeyBase64) {
    final bytes = base64Decode(masterKeyBase64);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  Future<Uint8List> _getLegacyDataEncryptionKey() async {
    final master = await _getOrCreateMasterKey();
    return _deriveEncryptionKey(master);
  }

  bool _constantTimeBytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  String _computePayloadMac({
    required String ivBase64,
    required String dataBase64,
    required Uint8List key,
  }) {
    final macInput = utf8.encode('$ivBase64.$dataBase64');
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(macInput);
    return base64Encode(digest.bytes);
  }

  String _decryptAesCbcPkcs7({
    required Uint8List key,
    required Uint8List iv,
    required Uint8List cipherText,
  }) {
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );

    cipher.init(
      false,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
        null,
      ),
    );

    final plainBytes = cipher.process(cipherText);
    return utf8.decode(plainBytes);
  }

  Future<Map<String, dynamic>?> tryDecryptDomainData(
    String encryptedPayload,
  ) async {
    try {
      final decoded = jsonDecode(encryptedPayload);
      if (decoded is! Map<String, dynamic>) return null;

      final ivBase64 = decoded['iv'] as String?;
      final dataBase64 = decoded['data'] as String?;
      final macBase64 = decoded['mac'] as String?;
      final payloadVersion = (decoded['v'] as num?)?.toInt();

      if (ivBase64 == null || dataBase64 == null) return null;

      final key = await _getLegacyDataEncryptionKey();

      if (payloadVersion == 2) {
        if (macBase64 == null || macBase64.isEmpty) return null;

        final expected = _computePayloadMac(
          ivBase64: ivBase64,
          dataBase64: dataBase64,
          key: key,
        );

        final ok = _constantTimeBytesEqual(
          Uint8List.fromList(base64Decode(macBase64)),
          Uint8List.fromList(base64Decode(expected)),
        );

        if (!ok) {
          return null;
        }
      }

      final plain = _decryptAesCbcPkcs7(
        key: key,
        iv: Uint8List.fromList(base64Decode(ivBase64)),
        cipherText: Uint8List.fromList(base64Decode(dataBase64)),
      );

      final parsed = jsonDecode(plain);
      if (parsed is Map<String, dynamic>) return parsed;
    } catch (_) {}

    return null;
  }

  Future<void> clearEncryptionKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureDelete(_masterKeySecureKey);
    await prefs.remove(_masterKeyPrefsKey);
    await _secureStorage.delete(key: 'thot_data_master_key_v1');
    await _secureStorage.delete(key: 'thot_data_master_key_v2');
    await _secureStorage.delete(key: 'thot_data_encryption_key_v1');
    await prefs.remove('thot_data_master_key_v1');
    await prefs.remove('thot_data_encryption_key_v1');
  }
}
