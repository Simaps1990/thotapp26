import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

Platform _platform({String id = 'p1'}) => Platform(
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


Session _session({String id = 's1'}) => Session(
      id: id,
      name: 'Session $id',
      date: DateTime(2026, 1, 15),
      location: 'Stand',
    );

Diagnostic _diagnostic({String id = 'd1', String platformId = 'w1'}) => Diagnostic(
      incidentKey: 'none',
      suspectedIssueKey: 'none',
      riskLevelKey: 'low',
      probabilities: const {'none': 100},
      id: id,
      date: DateTime(2026, 1, 10),
      platformId: platformId,
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
  // NOTE: Skipped while `_kFreeLimitsDisabled = true` in ThotProvider.
  group('ThotProvider — verrouillage plan gratuit (helpers UI)', skip: 'Freemium limits disabled via _kFreeLimitsDisabled flag', () {
    test('isPlatformLockedForFree : index 0 libre, index 1+ verrouillé', () async {
      final p = await _makeProvider();
      final w = _platform();
      expect(p.isPlatformLockedForFree(w, 0), false);
      expect(p.isPlatformLockedForFree(w, 1), true);
      expect(p.isPlatformLockedForFree(w, 5), true);
    });

    test('isAmmoLockedForFree : index 0 libre, index 1+ verrouillé', () async {
      final p = await _makeProvider();
      final a = _ammo();
      expect(p.isAmmoLockedForFree(a, 0), false);
      expect(p.isAmmoLockedForFree(a, 1), true);
    });

    test('isSessionLockedForFree : toujours false (sessions illimitées)', () async {
      final p = await _makeProvider();
      final s = _session();
      // Sessions are unlimited on the free plan.
      expect(p.isSessionLockedForFree(s, 0), false);
      expect(p.isSessionLockedForFree(s, 5), false);
      expect(p.isSessionLockedForFree(s, 100), false);
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

  // NOTE: Skipped while `_kFreeLimitsDisabled = true` in ThotProvider.
  group('ThotProvider — duplicate', skip: 'Freemium limits disabled via _kFreeLimitsDisabled flag', () {
    test('duplicatePlatform retourne false quand limite atteinte', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      final result = p.duplicatePlatform(_platform(id: 'w2'));
      expect(result, false);
      expect(p.platforms.length, 1);
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

    test('duplicateSession réussit toujours (sessions illimitées)', () async {
      final p = await _makeProvider();
      for (var i = 0; i < 5; i++) {
        p.addSession(_session(id: 's$i'));
      }
      final result = p.duplicateSession(_session(id: 'sExtra'));
      expect(result, true);
      expect(p.sessions.length, 6);
    });
  });

  group('ThotProvider — diagnostics', () {
    test('addDiagnostic insère en tête de liste', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));

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

  group('ThotProvider — getPlatformById / getAmmoById', () {
    test('getPlatformById retourne null si absent', () async {
      final p = await _makeProvider();
      expect(p.getPlatformById('inexistant'), isNull);
    });

    test('getPlatformById retourne la plateforme même si cachée', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));
      p.deletePlatform('w1'); // soft delete → isHidden = true
      // getPlatformById cherche dans _platforms (incluant cachés)
      expect(p.getPlatformById('w1'), isNotNull);
    });

    test('getAmmoById retourne null si absent', () async {
      final p = await _makeProvider();
      expect(p.getAmmoById('inexistant'), isNull);
    });
  });

  group('ThotProvider — recordPlatformPartChange', () {
    test('ajoute une entrée historique de type piece', () async {
      final p = await _makeProvider();
      p.addPlatform(_platform(id: 'w1'));

      p.recordPlatformPartChange(
        platformId: 'w1',
        partName: 'Percuteur',
        date: DateTime(2026, 3, 1),
        comment: 'Remplacement préventif',
      );

      final w = p.getPlatformById('w1')!;
      expect(w.history.length, 1);
      expect(w.history.first.type, 'piece');
      expect(w.history.first.label, contains('Percuteur'));
    });

    test("ne fait rien si la plateforme n'existe pas", () async {
      final p = await _makeProvider();
      expect(
        () => p.recordPlatformPartChange(
          platformId: 'inexistant',
          partName: 'Test',
          date: DateTime(2026, 1, 1),
        ),
        returnsNormally,
      );
    });
  });
}