# Thot

Application Flutter — carnet de tir (`fr.thotbook.app`).

## Changelog

### v1.4.0+41

**Thresholds (E.2)**
- Créé `lib/utils/thresholds.dart` avec constantes centralisées pour la logique métier :
  - `maintenanceWarningRatio = 0.8`
  - `inactiveDays = 90`
  - `lowStockRatio = 0.2`
  - `pinLockoutMinutes = 30`
  - `pinMaxAttempts = 5`
- Remplacé les nombres magiques dans `thot_security_service.dart`, `inventory_screen.dart`, et `home_screen.dart`

**Performance (G)**
- Throttled ticker dans `tutorial_overlay.dart` à 10 FPS (100ms)

**Tests (H.1-H.5)**
- Ajouté tests JSON roundtrip dans `provider_test.dart`
- Créé `shooting_table_codec_test.dart` pour `ShootingTableShareCodec`
- Ajouté tests cascade replacement parts dans `provider_test.dart`
- Créé `document_hash_test.dart` pour `DocumentHash`
- Ajouté tests legacy `PlatformHistoryEntry` dans `models_test.dart`

**Correction QR Scanner**
- Fixé signature `errorBuilder` dans `shooting_table_qr_scanner_screen.dart` (2 params au lieu de 3)

**Localization**
- Fusionné `app_strings_dope_tables.dart` dans `app_strings_pin.dart`
- Ajouté `tableImportedSuffix` dans `app_strings_shooting_tables.dart`
- Supprimé 15 getters `cognitiveDrillDirection*` non utilisés dans `app_strings_training_tools.dart`

**Session Export**
- Ajouté export du type de session dans `session_text_exporter.dart`

**Shooting Table Import**
- Ajouté paramètre `importedSuffix` à `ShootingTableShareCodec.decode()` pour localisation du suffixe d'import

**Validators**
- Ajouté validator `ThotValidators.positiveDouble` pour le champ vent dans `new_session_screen.dart`

**Tests**
- Fixé `critical_flows_test.dart` avec `_wrap` helper et tests de rendu simples
- Fixé `golden_test.dart` avec `initializeDateFormatting()` et remplacement `pumpAndSettle` par `pump`
- Mocké connectivity_plus dans `golden_test.dart` pour éviter `MissingPluginException`

## Prérequis

- Flutter (SDK compatible avec le `environment.sdk` de `pubspec.yaml`)

## Lancer l'app

```bash
flutter pub get
flutter run
```

## Analyse & tests

```bash
flutter analyze
flutter test
```

## RevenueCat (mobile uniquement)

La clé RevenueCat est injectée via la configuration native (et non via
`--dart-define`).

### iOS

Crée le fichier `ios/Flutter/Secrets.xcconfig` (gitignoré) :

```
REVENUECAT_API_KEY=appl_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Le fichier est lu au build par `Info.plist` qui interpole `$(REVENUECAT_API_KEY)`,
puis exposé à Dart via le canal natif `thot/config` (méthode
`getRevenueCatApiKey`).

### Android

Crée le fichier `android/key.properties` (gitignoré) avec :

```
revenueCatApiKey=goog_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
storeFile=...
storePassword=...
keyAlias=...
keyPassword=...
```

La clé est exposée via `BuildConfig.REVENUECAT_API_KEY` puis lue par Dart
via le même canal natif `thot/config`.

### Comportement debug sans clé

Si la clé est absente, l'app continue de fonctionner mais les achats ne sont
pas configurés (un message d'avertissement s'affiche dans la console).

## Build release

### iOS

```bash
flutter build ipa --release
```

Avec deployment target iOS 17.0 minimum.

### Android

```bash
flutter build appbundle --release
```

R8 / ProGuard sont activés. Si le build échoue avec une
`ClassNotFoundException`, ajoute une règle `-keep` dans
`android/app/proguard-rules.pro`.

## Stockage des données

Les données principales (inventaire, sessions, diagnostics, documents
utilisateur) sont stockées en local sur l'appareil dans le sandbox isolé
de l'application.

- **Mobile** : fichier JSON avec écriture atomique (temp + rename) +
  backup local (`.bak`) + fichier de recovery + fallback SharedPreferences.
- **Web** : fallback via `SharedPreferences`.
- L'accès peut être protégé par un PIN (PBKDF2-HMAC-SHA256, 100 000
  itérations) et la biométrie système (Face ID / Touch ID / empreinte).
- Les versions antérieures qui chiffraient les données sont migrées
  automatiquement (déchiffrement transparent puis ré-écriture en JSON).
