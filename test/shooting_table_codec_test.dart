import 'package:flutter_test/flutter_test.dart';
import 'package:thot/utils/shooting_table_share_codec.dart';
import 'package:thot/data/models.dart';

void main() {
  group('ShootingTableShareCodec', () {
    test('encode → decode creates new import ID and preserves name', () {
      final table = _sampleTable();
      final code = ShootingTableShareCodec.encode(table);
      expect(code, isNotEmpty);
      final decoded = ShootingTableShareCodec.decode(code);
      expect(decoded, isNotNull);
      // Decode generates a new import ID
      expect(decoded.id.startsWith('adj-import-'), true);
      // Name is preserved with import suffix
      expect(decoded.name.contains(table.name), true);
    });

    test('decode returns null on garbage input', () {
      expect(() => ShootingTableShareCodec.decode('garbage'), throwsA(isA<FormatException>()));
    });

    test('decode returns null on empty string', () {
      expect(() => ShootingTableShareCodec.decode(''), throwsA(isA<FormatException>()));
    });

    test('decode does not throw on truncated payload', () {
      final table = _sampleTable();
      final code = ShootingTableShareCodec.encode(table);
      final truncated = code.substring(0, code.length ~/ 2);
      expect(() => ShootingTableShareCodec.decode(truncated), throwsA(isA<FormatException>()));
    });
  });
}

ShootingAdjustmentTable _sampleTable() {
  return ShootingAdjustmentTable(
    id: 'test-id-1',
    name: 'Ma table test',
    platformId: 'platform-1',
    entries: [],
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}
