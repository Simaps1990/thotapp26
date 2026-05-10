part of 'app_strings.dart';

extension AppStringsNavigation on AppStrings {
  // --- Navigation & Routing ---

  String get navHomeLabel => _pick(
        fr: 'Accueil',
        en: 'Home',
        de: 'Startseite',
        it: 'Home',
        es: 'Inicio',
      );

  String get navSessionsLabel => _pick(
        fr: 'Sessions',
        en: 'Sessions',
        de: 'Sitzungen',
        it: 'Sessioni',
        es: 'Sesiones',
      );

  String get navInventoryLabel => _pick(
        fr: 'Matériel',
        en: 'Equipment',
        de: 'Ausrüstung',
        it: 'Materiale',
        es: 'Material',
      );

  String get navToolsLabel => _pick(
        fr: 'Outils',
        en: 'Tools',
        de: 'Werkzeuge',
        it: 'Strumenti',
        es: 'Herramientas',
      );

  String get navSettingsLabel => _pick(
        fr: 'Paramètres',
        en: 'Settings',
        de: 'Einstellungen',
        it: 'Impostazioni',
        es: 'Ajustes',
      );

  String get routeNotFoundTitle => _pick(
      fr: 'Page introuvable',
      en: 'Page not found',
      de: 'Seite nicht gefunden',
      it: 'Pagina non trovata',
      es: 'Página no encontrada',
    );

  String get routeNotFoundMessage => _pick(
      fr: "La page demandée n'existe pas.",
      en: 'The requested page does not exist.',
      de: 'Die angeforderte Seite existiert nicht.',
      it: 'La pagina richiesta non esiste.',
      es: 'La página solicitada no existe.',
    );

  String get backToHomeLabel => _pick(
      fr: 'Retour à l\'accueil',
      en: 'Back to home',
      de: 'Zurück zur Startseite',
      it: 'Torna alla home',
      es: 'Volver al inicio',
    );
}
