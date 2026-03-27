import 'package:flutter_test/flutter_test.dart';
import 'package:thot/data/models.dart';

void main() {
  group('Weapon', () {
    test('roundsSinceCleaning is clamped at 0', () {
      final w = Weapon(
        id: 'w',
        name: 'W',
        model: 'M',
        caliber: '9',
        serialNumber: 's',
        weight: 1,
        totalRounds: 50,
        lastCleaned: DateTime.parse('2026-01-01T00:00:00.000Z'),
        lastUsed: DateTime.parse('2026-01-02T00:00:00.000Z'),
        roundsAtLastCleaning: 80,
      );

      expect(w.roundsSinceCleaning, 0);
    });

    test('cleaningProgress respects threshold', () {
      final w = Weapon(
        id: 'w',
        name: 'W',
        model: 'M',
        caliber: '9',
        serialNumber: 's',
        weight: 1,
        totalRounds: 600,
        lastCleaned: DateTime.parse('2026-01-01T00:00:00.000Z'),
        lastUsed: DateTime.parse('2026-01-02T00:00:00.000Z'),
        roundsAtLastCleaning: 100,
        cleaningRoundsThreshold: 500,
      );

      expect(w.roundsSinceCleaning, 500);
      expect(w.cleaningProgress, 1.0);
    });

    test('cleaningProgress is 0 when tracking disabled', () {
      final w = Weapon(
        id: 'w',
        name: 'W',
        model: 'M',
        caliber: '9',
        serialNumber: 's',
        weight: 1,
        totalRounds: 600,
        lastCleaned: DateTime.parse('2026-01-01T00:00:00.000Z'),
        lastUsed: DateTime.parse('2026-01-02T00:00:00.000Z'),
        roundsAtLastCleaning: 100,
        cleaningRoundsThreshold: 500,
        trackCleanliness: false,
      );

      expect(w.cleaningProgress, 0.0);
    });
  });
}
