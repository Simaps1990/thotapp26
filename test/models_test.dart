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

    test(
      'fromJson supports legacy map filePath + empty name/type inference',
      () {
        final doc = ItemDocument.fromJson({
          'filePath': 'C:/tmp/notice.pdf',
          'name': '',
          'type': '',
        });

        expect(doc.path, 'C:/tmp/notice.pdf');
        expect(doc.name.toLowerCase(), contains('notice.pdf'));
        expect(doc.type, 'Document');
      },
    );

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

  group('PlatformHistoryEntry', () {
    test('toJson/fromJson roundtrip with structured data', () {
      final original = PlatformHistoryEntry(
        id: 'h1',
        date: DateTime.parse('2026-01-02T03:04:05.000Z'),
        type: PlatformHistoryType.shot,
        data: {
          PlatformHistoryDataKey.sessionName: 'My session',
          PlatformHistoryDataKey.shotCount: 10,
        },
      );

      final decoded = PlatformHistoryEntry.fromJson(original.toJson());
      expect(decoded.id, original.id);
      expect(decoded.date.toIso8601String(), original.date.toIso8601String());
      expect(decoded.type, original.type);
      expect(decoded.data[PlatformHistoryDataKey.sessionName], 'My session');
      expect(decoded.data[PlatformHistoryDataKey.shotCount], 10);
    });

    test('fromJson reads legacy label/details for pre-i18n entries', () {
      final legacyJson = {
        'id': 'h-legacy',
        'date': '2026-01-02T03:04:05.000Z',
        'type': 'tir',
        'label': 'Session : Old session',
        'details': '10 coups',
      };

      final decoded = PlatformHistoryEntry.fromJson(legacyJson);
      expect(decoded.id, 'h-legacy');
      expect(decoded.type, 'tir');
      expect(decoded.data, isEmpty);
      expect(decoded.legacyLabel, 'Session : Old session');
      expect(decoded.legacyDetails, '10 coups');
    });

    test('legacy entry without data map is readable via legacyLabel', () {
      final entry = PlatformHistoryEntry(
        id: 'h-legacy-2',
        date: DateTime(2025, 6, 1),
        type: PlatformHistoryType.shot,
        legacyLabel: 'Session : Tir de juin',
        legacyDetails: '20 coups à 25m',
      );
      expect(entry.legacyLabel, 'Session : Tir de juin');
      expect(entry.legacyDetails, '20 coups à 25m');
      expect(entry.data, isEmpty);
    });

    test('shot entry has correct type and structured data', () {
      final entry = PlatformHistoryEntry(
        id: 'h-shot-1',
        date: DateTime(2026, 3, 15),
        type: PlatformHistoryType.shot,
        data: {
          PlatformHistoryDataKey.sessionName: 'Séance mars',
          PlatformHistoryDataKey.shotCount: 50,
        },
      );
      expect(entry.type, PlatformHistoryType.shot);
      expect(entry.data[PlatformHistoryDataKey.shotCount], 50);
      expect(entry.legacyLabel, isEmpty);
    });
  });
}
