import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Utility for computing deterministic SHA-256 hashes of document data.
class DocumentHash {
  /// Compute SHA-256 of a deterministic JSON representation of the data.
  /// 
  /// The JSON is sorted recursively to ensure the same data always produces
  /// the same hash, regardless of key order in the original Map.
  static String compute(Map<String, dynamic> data) {
    final sortedJson = _stableJsonEncode(data);
    final bytes = utf8.encode(sortedJson);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Recursively encode JSON with sorted keys for deterministic output.
  static String _stableJsonEncode(dynamic obj) {
    if (obj is Map) {
      final sortedKeys = obj.keys.toList()..sort();
      final entries = sortedKeys.map((k) => '"$k":${_stableJsonEncode(obj[k])}');
      return '{${entries.join(',')}}';
    } else if (obj is List) {
      return '[${obj.map(_stableJsonEncode).join(',')}]';
    } else {
      return jsonEncode(obj);
    }
  }
}
