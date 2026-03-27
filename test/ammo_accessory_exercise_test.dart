import 'package:flutter_test/flutter_test.dart';
import 'package:thot/data/models.dart';

void main() {
  group('Ammo', () {
    test('initialQuantity defaults to quantity', () {
      final a = Ammo(
        id: 'a',
        name: 'A',
        brand: 'B',
        caliber: '9',
        quantity: 123,
        lastUsed: DateTime.parse('2026-01-01T00:00:00.000Z'),
      );

      expect(a.initialQuantity, 123);
    });

    test('copyWith keeps initialQuantity by default', () {
      final a = Ammo(
        id: 'a',
        name: 'A',
        brand: 'B',
        caliber: '9',
        quantity: 10,
        lastUsed: DateTime.parse('2026-01-01T00:00:00.000Z'),
      );

      final updated = a.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.initialQuantity, 10);
    });
  });

  group('Accessory', () {
    test('copyWith updates batteryChangedAt', () {
      final a = Accessory(
        id: 'ac',
        name: 'Acc',
        type: 'Optique',
        lastUsed: DateTime.parse('2026-01-01T00:00:00.000Z'),
      );

      final date = DateTime.parse('2026-02-01T00:00:00.000Z');
      final updated = a.copyWith(batteryChangedAt: date, trackBattery: true);
      expect(updated.batteryChangedAt, date);
      expect(updated.trackBattery, true);
    });
  });

  group('ExercisePhoto', () {
    test('fromJson defaults name to Photo', () {
      final p = ExercisePhoto.fromJson({'id': '1', 'path': '/tmp/a.png'});
      expect(p.name, 'Photo');
    });
  });

  group('Exercise', () {
    test('isPrecisionCounted depends on precision and enabled flag', () {
      final e1 = Exercise(
        id: 'e',
        weaponId: 'w',
        ammoId: 'a',
        shotsFired: 1,
        distance: 1,
        precision: 50,
        precisionEnabled: true,
      );
      expect(e1.isPrecisionCounted, true);

      final e2 = e1.copyWith(precisionEnabled: false);
      expect(e2.isPrecisionCounted, false);

      final e3 = Exercise(
        id: 'e',
        weaponId: 'w',
        ammoId: 'a',
        shotsFired: 1,
        distance: 1,
        precision: null,
        precisionEnabled: true,
      );
      expect(e3.isPrecisionCounted, false);
    });
  });
}
