# Thot

Application Flutter.

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

La clé RevenueCat est fournie via une variable de compilation.

```bash
flutter run --dart-define=REVENUECAT_API_KEY=YOUR_KEY
```

En `debug`, si la clé n'est pas fournie, l'app continue de fonctionner mais les achats ne seront pas configurés.

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
