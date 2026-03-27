import 'package:flutter_test/flutter_test.dart';
import 'package:thot/data/models.dart';

void main() {
  group('ItemDocument', () {
    test('fromJson supports legacy string path', () {
      final doc = ItemDocument.fromJson('C:/tmp/manual.pdf');
      expect(doc.path, 'C:/tmp/manual.pdf');
      expect(doc.name.toLowerCase(), contains('manual.pdf'));
      expect(doc.type, isNotEmpty);
    });

    test('fromJson supports legacy map filePath + empty name/type inference', () {
      final doc = ItemDocument.fromJson({
        'filePath': 'C:/tmp/notice.pdf',
        'name': '',
        'type': '',
      });

      expect(doc.path, 'C:/tmp/notice.pdf');
      expect(doc.name.toLowerCase(), contains('notice.pdf'));
      expect(doc.type, 'Document');
    });

    test('toJson/fromJson roundtrip', () {
      const original = ItemDocument(
        path: '/a/b/c.pdf',
        name: 'Facture',
        type: 'Facture',
      );

      final decoded = ItemDocument.fromJson(original.toJson());
      expect(decoded.path, original.path);
      expect(decoded.name, original.name);
      expect(decoded.type, original.type);
    });
  });

  group('WeaponHistoryEntry', () {
    test('toJson/fromJson roundtrip', () {
      final original = WeaponHistoryEntry(
        id: 'h1',
        date: DateTime.parse('2026-01-02T03:04:05.000Z'),
        type: 'tir',
        label: 'Séance',
        details: '10 coups',
      );

      final decoded = WeaponHistoryEntry.fromJson(original.toJson());
      expect(decoded.id, original.id);
      expect(decoded.date.toIso8601String(), original.date.toIso8601String());
      expect(decoded.type, original.type);
      expect(decoded.label, original.label);
      expect(decoded.details, original.details);
    });
  });
}
