import 'dart:convert';

import 'package:thot/data/models.dart';

class ShootingTableShareCodec {
  static const String prefix = 'THOT-TABLE-V1:';

  static String encode(ShootingAdjustmentTable table) {
    final payload = <String, dynamic>{'v': 1, 'table': table.toJson()};
    final json = jsonEncode(payload);
    final bytes = utf8.encode(json);
    return '$prefix${base64UrlEncode(bytes)}';
  }

  static ShootingAdjustmentTable decode(
    String input, {
    String importedSuffix = '(importée)',
  }) {
    final trimmed = input.trim();
    if (!trimmed.startsWith(prefix)) {
      throw const FormatException('Invalid THOT table prefix');
    }

    final encoded = trimmed.substring(prefix.length);
    final decoded = utf8.decode(base64Url.decode(encoded));
    final payload = jsonDecode(decoded);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid THOT table payload');
    }

    final tableRaw = payload['table'];
    if (tableRaw is! Map<String, dynamic>) {
      throw const FormatException('Invalid THOT table data');
    }

    final now = DateTime.now();
    final table = ShootingAdjustmentTable.fromJson(tableRaw);
    final baseName = table.name.trim().isEmpty ? 'Table' : table.name.trim();
    return table.copyWith(
      id: 'adj-import-${now.microsecondsSinceEpoch}',
      name: '$baseName $importedSuffix',
      createdAt: now,
      updatedAt: now,
    );
  }
}
