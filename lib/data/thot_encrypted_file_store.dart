import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThotEncryptedFileStore {
  ThotEncryptedFileStore({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  static const String _dataEncryptionKeyStorageKey = 'thot_data_encryption_key_v1';
  static const String _dataEncryptionMasterKeyPrefsKey = 'thot_data_master_key_v1';
  static const String _dataEncryptionMasterKeyStorageKey = 'thot_data_master_key_v2';

  final FlutterSecureStorage _secureStorage;

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

  Future<String> _getOrCreateDataEncryptionMasterKey() async {
    final secureExisting = await _secureStorage.read(
      key: _dataEncryptionMasterKeyStorageKey,
    );
    if (secureExisting != null && secureExisting.isNotEmpty) {
      return secureExisting;
    }

    final prefs = await SharedPreferences.getInstance();
    final migratedLegacy = prefs.getString(_dataEncryptionMasterKeyPrefsKey);
    if (migratedLegacy != null && migratedLegacy.isNotEmpty) {
      await _secureStorage.write(
        key: _dataEncryptionMasterKeyStorageKey,
        value: migratedLegacy,
      );
      await prefs.remove(_dataEncryptionMasterKeyPrefsKey);
      return migratedLegacy;
    }

    final randomKey = encrypt.Key.fromSecureRandom(32).base64;
    await _secureStorage.write(
      key: _dataEncryptionMasterKeyStorageKey,
      value: randomKey,
    );
    return randomKey;
  }

  encrypt.Key _deriveDataEncryptionKeyFromMaster(String masterKeyBase64) {
    final bytes = base64Decode(masterKeyBase64);
    final digest = sha256.convert(bytes);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  Future<encrypt.Key> _getOrCreateDataEncryptionKey() async {
    final existing = await _secureStorage.read(key: _dataEncryptionKeyStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return encrypt.Key.fromBase64(existing);
    }

    final master = await _getOrCreateDataEncryptionMasterKey();
    final derived = _deriveDataEncryptionKeyFromMaster(master);

    await _secureStorage.write(
      key: _dataEncryptionKeyStorageKey,
      value: derived.base64,
    );

    return derived;
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
    required encrypt.Key key,
  }) {
    final macInput = utf8.encode('$ivBase64.$dataBase64');
    final hmacSha256 = Hmac(sha256, key.bytes);
    final digest = hmacSha256.convert(macInput);
    return base64Encode(digest.bytes);
  }

  Future<String> _encryptDomainData(String plainText) async {
    final key = await _getOrCreateDataEncryptionKey();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final mac = _computePayloadMac(
      ivBase64: iv.base64,
      dataBase64: encrypted.base64,
      key: key,
    );

    final payload = {
      'iv': iv.base64,
      'data': encrypted.base64,
      'mac': mac,
      'v': 2,
    };

    return jsonEncode(payload);
  }

  Future<String> _decryptDomainData(String encryptedPayload) async {
    final decoded = jsonDecode(encryptedPayload);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid encrypted payload format');
    }

    final ivBase64 = decoded['iv'] as String?;
    final dataBase64 = decoded['data'] as String?;
    final macBase64 = decoded['mac'] as String?;
    final payloadVersion = (decoded['v'] as num?)?.toInt();

    if (ivBase64 == null || dataBase64 == null) {
      throw Exception('Missing encrypted payload fields');
    }

    final key = await _getOrCreateDataEncryptionKey();

    if (payloadVersion == 2) {
      if (macBase64 == null || macBase64.isEmpty) {
        throw Exception('Missing payload MAC');
      }

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
        throw Exception('Invalid payload MAC');
      }
    }

    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypted = encrypt.Encrypted.fromBase64(dataBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.decrypt(encrypted, iv: iv);
  }

  Future<void> writeDomainData(String rawJson) async {
    if (kIsWeb) return;

    final encryptedJson = await _encryptDomainData(rawJson);
    final file = await _getAppDataFile();
    final tempFile = await _getAppDataTempFile();
    final backupFile = await _getAppDataBackupFile();

    if (await file.exists()) {
      try {
        await file.copy(backupFile.path);
      } catch (_) {}
    }

    await tempFile.writeAsString(encryptedJson, flush: true);

    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }

    await tempFile.rename(file.path);
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
            await file.writeAsString(legacyRaw, flush: true);
            await legacy.delete();
          }
        } catch (_) {}
      }
    }

    final backupFile = await _getAppDataBackupFile();
    final candidates = <File>[file, backupFile];

    for (final candidate in candidates) {
      if (!await candidate.exists()) continue;
      final raw = await candidate.readAsString();
      if (raw.isEmpty) continue;

      try {
        final decrypted = await _decryptDomainData(raw);
        final decoded = jsonDecode(decrypted);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            await writeDomainData(jsonEncode(decoded));
            return decoded;
          }
        } catch (_) {}
      }
    }

    return null;
  }

  Future<void> clearDomainData() async {
    if (kIsWeb) return;

    final file = await _getAppDataFile();
    final tempFile = await _getAppDataTempFile();
    final backupFile = await _getAppDataBackupFile();
    final legacyFile = await _getLegacyDocumentsDataFile();

    for (final candidate in [file, tempFile, backupFile, legacyFile]) {
      if (await candidate.exists()) {
        try {
          await candidate.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> clearEncryptionKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _dataEncryptionKeyStorageKey);
    await _secureStorage.delete(key: _dataEncryptionMasterKeyStorageKey);
    await prefs.remove(_dataEncryptionMasterKeyPrefsKey);
  }
}
