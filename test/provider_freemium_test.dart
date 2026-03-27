import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

Weapon _weapon({String id = 'w1'}) => Weapon(
      id: id,
      name: 'SIG P320',
      model: 'M17',
      caliber: '9mm',
      serialNumber: 'SN-$id',
      weight: 0.83,
      totalRounds: 0,
      lastCleaned: DateTime(2026, 1, 1),
      lastUsed: DateTime(2026, 1, 1),
    );

Ammo _ammo({String id = 'a1', int quantity = 100}) => Ammo(
      id: id,
      name: 'FMJ',
      brand: 'Winchester',
      caliber: '9mm',
      quantity: quantity,
      lastUsed: DateTime(2026, 1, 1),
    );

Accessory _accessory({String id = 'acc1'}) => Accessory(
      id: id,
      name: 'Lampe',
      type: 'Lampe tactique',
      lastUsed: DateTime(2026, 1, 1),
    );

Session _session({String id = 's1'}) => Session(
      id: id,
      name: 'Séance $id',
      date: DateTime(2026, 1, 15),
      location: 'Stand',
    );

Diagnostic _diagnostic({String id = 'd1', String weaponId = 'w1'}) => Diagnostic(
      id: id,
      date: DateTime(2026, 1, 10),
      weaponId: weaponId,
      responses: {'q1': 'ok', 'q2': 'nok'},
      finalDecision: 'Révision recommandée',
      summary: 'Usure détectée sur percuteur',
    );

Future<ThotProvider> _makeProvider() async {
  SharedPreferences.setMockInitialValues({});
  return ThotProvider();
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('ThotProvider — verrouillage plan gratuit (helpers UI)', () {
    test('isWeaponLockedForFree : index 0 libre, index 1+ verrouillé', () async {
      final p = await _makeProvider();
      final w = _weapon();
      expect(p.isWeaponLockedForFree(w, 0), false);
      expect(p.isWeaponLockedForFree(w, 1), true);
      expect(p.isWeaponLockedForFree(w, 5), true);
    });

    test('isAmmoLockedForFree : index 0 libre, index 1+ verrouillé', () async {
      final p = await _makeProvider();
      final a = _ammo();
      expect(p.isAmmoLockedForFree(a, 0), false);
      expect(p.isAmmoLockedForFree(a, 1), true);
    });

    test('isSessionLockedForFree : index 0-4 libre, index 5+ verrouillé', () async {
      final p = await _makeProvider();
      final s = _session();
      for (var i = 0; i < ThotProvider.maxSessionsFree; i++) {
        expect(p.isSessionLockedForFree(s, i), false);
      }
      expect(p.isSessionLockedForFree(s, ThotProvider.maxSessionsFree), true);
    });

    test('isItemDocumentLockedForFree : index 0 libre, index 1+ verrouillé', () async {
      final p = await _makeProvider();
      expect(p.isItemDocumentLockedForFree(documentIndex: 0), false);
      expect(p.isItemDocumentLockedForFree(documentIndex: 1), true);
    });

    test('canAddDocumentToItem : faux quand déjà 1 doc (free)', () async {
      final p = await _makeProvider();
      expect(p.canAddDocumentToItem(currentDocumentsCount: 0), true);
      expect(p.canAddDocumentToItem(currentDocumentsCount: 1), false);
    });
  });

  group('ThotProvider — duplicate', () {
    test('duplicateWeapon retourne false quand limite atteinte', () async {
      final p = await _makeProvider();
      p.addWeapon(_weapon(id: 'w1'));
      final result = p.duplicateWeapon(_weapon(id: 'w2'));
      expect(result, false);
      expect(p.weapons.length, 1);
    });

    test('duplicateAmmo retourne false quand limite atteinte', () async {
      final p = await _makeProvider();
      p.addAmmo(_ammo(id: 'a1'));
      final result = p.duplicateAmmo(_ammo(id: 'a2'));
      expect(result, false);
      expect(p.ammos.length, 1);
    });

    test('duplicateSession crée une copie avec un nouvel id', () async {
      final p = await _makeProvider();
      final original = _session(id: 's1');
      p.addSession(original);
      expect(p.sessions.length, 1);

      final result = p.duplicateSession(original);
      expect(result, true);
      expect(p.sessions.length, 2);
      // Les deux sessions ont des IDs différents
      final ids = p.sessions.map((s) => s.id).toSet();
      expect(ids.length, 2);
    });

    test('duplicateSession retourne false après 5 séances (free)', () async {
      final p = await _makeProvider();
      for (var i = 0; i < 5; i++) {
        p.addSession(_session(id: 's$i'));
      }
      final result = p.duplicateSession(_session(id: 'sExtra'));
      expect(result, false);
      expect(p.sessions.length, 5);
    });
  });

  group('ThotProvider — diagnostics', () {
    test('addDiagnostic insère en tête de liste', () async {
      final p = await _makeProvider();
      p.addWeapon(_weapon(id: 'w1'));

      final d1 = _diagnostic(id: 'd1');
      final d2 = _diagnostic(id: 'd2');
      p.addDiagnostic(d1);
      p.addDiagnostic(d2);

      expect(p.diagnostics.first.id, 'd2');
      expect(p.diagnostics.length, 2);
    });

    test('deleteDiagnostic supprime le bon élément', () async {
      final p = await _makeProvider();
      p.addDiagnostic(_diagnostic(id: 'd1'));
      p.addDiagnostic(_diagnostic(id: 'd2'));
      expect(p.diagnostics.length, 2);

      p.deleteDiagnostic('d1');
      expect(p.diagnostics.length, 1);
      expect(p.diagnostics.first.id, 'd2');
    });

    test('deleteDiagnostic sur id inexistant ne crash pas', () async {
      final p = await _makeProvider();
      p.addDiagnostic(_diagnostic(id: 'd1'));
      expect(() => p.deleteDiagnostic('inexistant'), returnsNormally);
      expect(p.diagnostics.length, 1);
    });
  });

  group('ThotProvider — getWeaponById / getAmmoById', () {
    test('getWeaponById retourne null si absent', () async {
      final p = await _makeProvider();
      expect(p.getWeaponById('inexistant'), isNull);
    });

    test('getWeaponById retourne l arme même si cachée', () async {
      final p = await _makeProvider();
      p.addWeapon(_weapon(id: 'w1'));
      p.deleteWeapon('w1'); // soft delete → isHidden = true
      // getWeaponById cherche dans _weapons (incluant cachés)
      expect(p.getWeaponById('w1'), isNotNull);
    });

    test('getAmmoById retourne null si absent', () async {
      final p = await _makeProvider();
      expect(p.getAmmoById('inexistant'), isNull);
    });
  });

  group('ThotProvider — recordWeaponPartChange', () {
    test('ajoute une entrée historique de type piece', () async {
      final p = await _makeProvider();
      p.addWeapon(_weapon(id: 'w1'));

      p.recordWeaponPartChange(
        weaponId: 'w1',
        partName: 'Percuteur',
        date: DateTime(2026, 3, 1),
        comment: 'Remplacement préventif',
      );

      final w = p.getWeaponById('w1')!;
      expect(w.history.length, 1);
      expect(w.history.first.type, 'piece');
      expect(w.history.first.label, contains('Percuteur'));
    });

    test('ne fait rien si l arme n existe pas', () async {
      final p = await _makeProvider();
      expect(
        () => p.recordWeaponPartChange(
          weaponId: 'inexistant',
          partName: 'Test',
          date: DateTime(2026, 1, 1),
        ),
        returnsNormally,
      );
    });
  });
}