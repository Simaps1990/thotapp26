import 'package:flutter_test/flutter_test.dart';
import 'package:thot/data/models.dart';

// Helpers
Exercise _makeExercise({
  String id = 'e1',
  String weaponId = 'w1',
  String ammoId = 'a1',
  List<String> equipmentIds = const [],
  int shotsFired = 10,
  int distance = 25,
  double? precision,
  bool precisionEnabled = true,
}) =>
    Exercise(
      id: id,
      weaponId: weaponId,
      ammoId: ammoId,
      equipmentIds: equipmentIds,
      shotsFired: shotsFired,
      distance: distance,
      precision: precision,
      precisionEnabled: precisionEnabled,
    );

Session _makeSession({
  String id = 's1',
  List<Exercise> exercises = const [],
}) =>
    Session(
      id: id,
      name: 'Séance test',
      date: DateTime.parse('2026-01-01T10:00:00.000Z'),
      location: 'Stand',
      exercises: exercises,
    );

void main() {
  group('Session.totalRounds', () {
    test('returns 0 with no exercises', () {
      expect(_makeSession().totalRounds, 0);
    });

    test('sums shots across all exercises', () {
      final s = _makeSession(exercises: [
        _makeExercise(id: 'e1', shotsFired: 10),
        _makeExercise(id: 'e2', shotsFired: 25),
        _makeExercise(id: 'e3', shotsFired: 5),
      ]);
      expect(s.totalRounds, 40);
    });
  });

  group('Session.averagePrecision', () {
    test('returns 0 when no exercises', () {
      expect(_makeSession().averagePrecision, 0.0);
    });

    test('returns 0 when no exercise has counted precision', () {
      final s = _makeSession(exercises: [
        _makeExercise(precision: null),
        _makeExercise(id: 'e2', precision: 80, precisionEnabled: false),
      ]);
      expect(s.averagePrecision, 0.0);
    });

    test('averages only counted precisions', () {
      final s = _makeSession(exercises: [
        _makeExercise(id: 'e1', precision: 80, precisionEnabled: true),
        _makeExercise(id: 'e2', precision: 60, precisionEnabled: true),
        _makeExercise(id: 'e3', precision: 90, precisionEnabled: false), // excluded
      ]);
      expect(s.averagePrecision, 70.0);
    });

    test('precision of 0 is counted when enabled', () {
      final s = _makeSession(exercises: [
        _makeExercise(precision: 0.0, precisionEnabled: true),
      ]);
      expect(s.hasCountedPrecision, true);
      expect(s.averagePrecision, 0.0);
    });
  });

  group('Session.weaponImpact', () {
    test('sums shots per weapon, ignores none/borrowed', () {
      final s = _makeSession(exercises: [
        _makeExercise(id: 'e1', weaponId: 'w1', shotsFired: 10),
        _makeExercise(id: 'e2', weaponId: 'w1', shotsFired: 5),
        _makeExercise(id: 'e3', weaponId: 'w2', shotsFired: 20),
        _makeExercise(id: 'e4', weaponId: 'none', shotsFired: 7),
        _makeExercise(id: 'e5', weaponId: 'borrowed', shotsFired: 3),
      ]);
      expect(s.weaponImpact['w1'], 15);
      expect(s.weaponImpact['w2'], 20);
      expect(s.weaponImpact.containsKey('none'), false);
      expect(s.weaponImpact.containsKey('borrowed'), false);
    });
  });

  group('Session.ammoImpact', () {
    test('sums shots per ammo, ignores none/borrowed', () {
      final s = _makeSession(exercises: [
        _makeExercise(id: 'e1', ammoId: 'a1', shotsFired: 50),
        _makeExercise(id: 'e2', ammoId: 'a1', shotsFired: 30),
        _makeExercise(id: 'e3', ammoId: 'none', shotsFired: 10),
      ]);
      expect(s.ammoImpact['a1'], 80);
      expect(s.ammoImpact.containsKey('none'), false);
    });
  });

  group('Session.equipmentImpact', () {
    test('sums shots per accessory across exercises', () {
      final s = _makeSession(exercises: [
        _makeExercise(id: 'e1', equipmentIds: ['acc1', 'acc2'], shotsFired: 10),
        _makeExercise(id: 'e2', equipmentIds: ['acc1'], shotsFired: 5),
      ]);
      expect(s.equipmentImpact['acc1'], 15);
      expect(s.equipmentImpact['acc2'], 10);
    });

    test('returns empty map when no equipment', () {
      expect(_makeSession().equipmentImpact, isEmpty);
    });
  });
}