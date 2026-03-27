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

Les données principales (inventaire, séances, diagnostics, documents utilisateur) sont stockées en local sur l'appareil dans un fichier chiffré.

- Mobile : fichier chiffré avec écriture atomique + backup local (`.bak`) et compatibilité de restauration via backup système.
- Web : fallback via `SharedPreferences`.
