# Thot

Application Flutter — carnet de tir (`fr.thotbook.app`).

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
