import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

Platform _platform({String id = 'w1', int totalRounds = 0, int roundsAtLastCleaning = 0}) =>
    Platform(
      id: id,
      name: 'Glock 17',
      model: 'Gen 5',
      caliber: '9mm',
      serialNumber: 'SN-$id',
      weight: 0.63,
      totalRounds: totalRounds,
      lastCleaned: DateTime(2026, 1, 1),
      lastUsed: DateTime(2026, 1, 1),
      roundsAtLastCleaning: roundsAtLastCleaning,
    );

Ammo _ammo({String id = 'a1', int quantity = 500}) => Ammo(
      id: id,
      name: 'FMJ 124gr',
      brand: 'Fiocchi',
      caliber: '9mm',
      quantity: quantity,
      lastUsed: DateTime(2026, 1, 1),
    );

Accessory _accessory({String id = 'acc1', int totalRounds = 0}) => Accessory(
      id: id,
      name: 'Eotech 512',
      type: 'Optique',
      lastUsed: DateTime(2026, 1, 1),
      lastCleaned: DateTime(2026, 1, 1),
      totalRounds: totalRounds,
    );

Exercise _exercise({
  String id = 'e1',
  String platformId = 'w1',
  String ammoId = 'a1',
  List<String> equipmentIds = const [],
  int shotsFired = 50,
}) =>
    Exercise(
      id: id,
      platformId: platformId,
      ammoId: ammoId,
      equipmentIds: equipmentIds,
      shotsFired: shotsFired,
      distance: 25,
    );

Session _session({
  String id = 's1',
  List<Exercise>? exercises,
}) =>
    Session(
      id: id,
      name: 'Session $id',
      date: DateTime(2026, 1, 15),
      location: 'Stand',
      exercises: exercises ?? [_exercise()],
    );

Future<ThotProvider> _makeProvider() async {
  SharedPreferences.setMockInitialValues({});
  final p = ThotProvider();
  // Bypass full init (no file system in unit tests) — inject state directly.
  return p;
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // NOTE: These tests validate the active freemium enforcement.
  // They are skipped while `_kFreeLimitsDisabled = true` in ThotProvider.
  // Re-enable when the freemium flag is flipped to `false`.
  group('ThotProvider — limites plan gratuit', skip: 'Freemium limits disabled via _kFreeLimitsDisabled flag', () {
    test('canAddPlatform retourne false quand limite atteinte (free)', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      // 1 plateforme = limite free atteinte
      expect(p.canAddPlatform(), false);
    });

    test('canAddAmmo retourne false quand limite atteinte (free)', () async {
      final p = await _makeProvider();
      p.addAmmo(_ammo(id: 'a1'));
      expect(p.canAddAmmo(), false);
    });

    test('canAddAccessory retourne false quand limite atteinte (free)', () async {
      final p = await _makeProvider();
      p.addAccessory(_accessory(id: 'acc1'));
      expect(p.canAddAccessory(), false);
    });

    test('canAddSession retourne false après 5 sessions (free)', () async {
      final p = await _makeProvider();
      for (var i = 0; i < 5; i++) {
        p.addSession(_session(id: 's$i', exercises: []));
      }
      expect(p.canAddSession(), false);
    });

    test('addPlatform est silencieux quand limite atteinte', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addPlatform(_platform(id: 'w2')); // doit être ignoré
      expect(p.platforms.length, 1);
    });
  });

  group('ThotProvider — addSession + impact matériel', () {
    test('addSession incrémente totalRounds de la plateforme', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1', totalRounds: 100));
      p.addAmmo(_ammo(id: 'a1', quantity: 500));
      p.addSession(_session(exercises: [_exercise(shotsFired: 50)]));

      expect(p.platforms.first.totalRounds, 150);
    });

    test('addSession décrémente le stock de consommables', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1', quantity: 200));
      p.addSession(_session(exercises: [_exercise(shotsFired: 80)]));

      expect(p.ammos.first.quantity, 120);
    });

    test('stock consommables ne descend pas en négatif', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1', quantity: 10));
      p.addSession(_session(exercises: [_exercise(shotsFired: 999)]));

      expect(p.ammos.first.quantity, 0);
    });

    test('addSession incrémente totalRounds de l accessoire', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1'));
      p.addAccessory(_accessory(id: 'acc1', totalRounds: 0));
      p.addSession(_session(exercises: [
        _exercise(equipmentIds: ['acc1'], shotsFired: 30),
      ]));

      // Accessory.totalRounds est mutable directement dans _applyMaterial
      final acc = p.accessories.first;
      expect(acc.totalRounds, 30);
    });

    test('addSession ajoute une entrée dans l historique de la plateforme', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1'));
      p.addSession(_session(id: 's1', exercises: [_exercise()]));

      // La plateforme doit avoir 1 entrée d'historique de type 'tir'
      final platform = p.getPlatformById('w1')!;
      expect(platform.history.any((h) => h.type == 'tir'), true);
    });
  });

  group('ThotProvider — deleteSession + inversion matériel', () {
    test('deleteSession restaure les rounds de la plateforme', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1', totalRounds: 0));
      p.addAmmo(_ammo(id: 'a1', quantity: 500));
      p.addSession(_session(id: 's1', exercises: [_exercise(shotsFired: 50)]));
      expect(p.platforms.first.totalRounds, 50);

      p.deleteSession('s1');
      expect(p.platforms.first.totalRounds, 0);
    });

    test('deleteSession restaure le stock de consommables', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1', quantity: 500));
      p.addSession(_session(id: 's1', exercises: [_exercise(shotsFired: 100)]));
      expect(p.ammos.first.quantity, 400);

      p.deleteSession('s1');
      expect(p.ammos.first.quantity, 500);
    });

    test('deleteSession supprime les entrées d historique liées', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1'));
      p.addSession(_session(id: 's1', exercises: [_exercise()]));

      final beforeDelete = p.getPlatformById('w1')!.history.length;
      expect(beforeDelete, 1);

      p.deleteSession('s1');
      final afterDelete = p.getPlatformById('w1')!.history.length;
      expect(afterDelete, 0);
    });
  });

  group('ThotProvider — updateSession', () {
    test('updateSession recalcule correctement les impacts', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1', quantity: 500));

      final original = _session(id: 's1', exercises: [_exercise(shotsFired: 50)]);
      p.addSession(original);
      expect(p.platforms.first.totalRounds, 50);
      expect(p.ammos.first.quantity, 450);

      // Modifie la session : 80 coups au lieu de 50
      final updated = Session(
        id: 's1',
        name: original.name,
        date: original.date,
        location: original.location,
        exercises: [_exercise(shotsFired: 80)],
      );
      p.updateSession(updated);

      expect(p.platforms.first.totalRounds, 80);
      expect(p.ammos.first.quantity, 420);
    });
  });

  group('ThotProvider — recordPlatformCleaning / recordPlatformRevision', () {
    test('recordPlatformCleaning remet roundsAtLastCleaning à totalRounds', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1', totalRounds: 300, roundsAtLastCleaning: 0));
      p.addAmmo(_ammo());

      p.recordPlatformCleaning('w1');

      final w = p.getPlatformById('w1')!;
      expect(w.roundsAtLastCleaning, 300);
      expect(w.cleaningProgress, 0.0);
    });

    test('recordPlatformCleaning ne touche pas roundsAtLastRevision', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1', totalRounds: 300)..copyWith(roundsAtLastRevision: 100));
      // On vérifie que la révision n'est pas perturbée
      final before = p.getPlatformById('w1')!.roundsAtLastRevision;
      p.recordPlatformCleaning('w1');
      final after = p.getPlatformById('w1')!.roundsAtLastRevision;
      expect(after, before);
    });

    test('recordPlatformRevision ajoute une entrée historique de type revision', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));

      p.recordPlatformRevision('w1');

      final w = p.getPlatformById('w1')!;
      expect(w.history.any((h) => h.type == 'revision'), true);
    });
  });

  group('ThotProvider — totalRoundsFired', () {
    test('retourne 0 sans sessions', () async {
      final p = await _makeProvider();
      expect(p.totalRoundsFired, 0);
    });

    test('somme tous les coups de toutes les sessions', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.addAmmo(_ammo(id: 'a1', quantity: 9999));
      p.addSession(_session(id: 's1', exercises: [_exercise(shotsFired: 100)]));
      p.addSession(_session(id: 's2', exercises: [_exercise(id: 'e2', shotsFired: 200)]));
      expect(p.totalRoundsFired, 300);
    });
  });

  group('ThotProvider — deletePlatform (soft delete)', () {
    test('deletePlatform cache la plateforme sans la supprimer des données', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      expect(p.platforms.length, 1);

      p.deletePlatform('w1');
      // platforms (getter) filtre les isHidden
      expect(p.platforms.length, 0);
      // mais la plateforme existe toujours en interne (pour la cohérence historique)
      expect(p.getPlatformById('w1'), isNotNull);
    });
  });
}