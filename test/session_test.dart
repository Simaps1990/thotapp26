import 'package:flutter_test/flutter_test.dart';
import 'package:thot/data/models.dart';

// Helpers
Exercise _makeExercise({
  String id = 'e1',
  String platformId = 'w1',
  String ammoId = 'a1',
  List<String> equipmentIds = const [],
  int shotsFired = 10,
  int distance = 25,
  double? precision,
  bool precisionEnabled = true,
}) => Exercise(
  id: id,
  platformId: platformId,
  ammoId: ammoId,
  equipmentIds: equipmentIds,
  shotsFired: shotsFired,
  distance: distance,
  precision: precision,
  precisionEnabled: precisionEnabled,
);

Session _makeSession({String id = 's1', List<Exercise> exercises = const []}) =>
    Session(
      id: id,
      name: 'Session test',
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
      final s = _makeSession(
        exercises: [
          _makeExercise(),
          _makeExercise(id: 'e2', shotsFired: 25),
          _makeExercise(id: 'e3', shotsFired: 5),
        ],
      );
      expect(s.totalRounds, 40);
    });
  });

  group('Session.averagePrecision', () {
    test('returns 0 when no exercises', () {
      expect(_makeSession().averagePrecision, 0.0);
    });

    test('returns 0 when no exercise has counted precision', () {
      final s = _makeSession(
        exercises: [
          _makeExercise(),
          _makeExercise(id: 'e2', precision: 80, precisionEnabled: false),
        ],
      );
      expect(s.averagePrecision, 0.0);
    });

    test('averages only counted precisions', () {
      final s = _makeSession(
        exercises: [
          _makeExercise(precision: 80),
          _makeExercise(id: 'e2', precision: 60),
          _makeExercise(
            id: 'e3',
            precision: 90,
            precisionEnabled: false,
          ), // excluded
        ],
      );
      expect(s.averagePrecision, 70.0);
    });

    test('precision of 0 is counted when enabled', () {
      final s = _makeSession(exercises: [_makeExercise(precision: 0.0)]);
      expect(s.hasCountedPrecision, true);
      expect(s.averagePrecision, 0.0);
    });
  });

  group('Session.platformImpact', () {
    test('sums shots per platform, ignores none/borrowed', () {
      final s = _makeSession(
        exercises: [
          _makeExercise(),
          _makeExercise(id: 'e2', shotsFired: 5),
          _makeExercise(id: 'e3', platformId: 'w2', shotsFired: 20),
          _makeExercise(id: 'e4', platformId: 'none', shotsFired: 7),
          _makeExercise(id: 'e5', platformId: 'borrowed', shotsFired: 3),
        ],
      );
      expect(s.platformImpact['w1'], 15);
      expect(s.platformImpact['w2'], 20);
      expect(s.platformImpact.containsKey('none'), false);
      expect(s.platformImpact.containsKey('borrowed'), false);
    });
  });

  group('Session.ammoImpact', () {
    test('sums shots per ammo, ignores none/borrowed', () {
      final s = _makeSession(
        exercises: [
          _makeExercise(shotsFired: 50),
          _makeExercise(id: 'e2', shotsFired: 30),
          _makeExercise(id: 'e3', ammoId: 'none'),
        ],
      );
      expect(s.ammoImpact['a1'], 80);
      expect(s.ammoImpact.containsKey('none'), false);
    });
  });

  group('Session.equipmentImpact', () {
    test('sums shots per accessory across exercises', () {
      final s = _makeSession(
        exercises: [
          _makeExercise(equipmentIds: ['acc1', 'acc2']),
          _makeExercise(id: 'e2', equipmentIds: ['acc1'], shotsFired: 5),
        ],
      );
      expect(s.equipmentImpact['acc1'], 15);
      expect(s.equipmentImpact['acc2'], 10);
    });

    test('returns empty map when no equipment', () {
      expect(_makeSession().equipmentImpact, isEmpty);
    });
  });
}
