part of 'app_strings.dart';

extension AppStringsMisc on AppStrings {
  // --- Lock Screen ---
  String get biometricUnavailable => _pick(
    fr: "Impossible d'utiliser l'authentification biométrique. Vérifiez la configuration de votre empreinte ou de FaceID.",
    en: 'Unable to use biometric authentication. Check your fingerprint or FaceID configuration.',
    de: 'Biometrische Authentifizierung nicht verfügbar. Überprüfen Sie Ihre Fingerabdruck- oder FaceID-Konfiguration.',
    it: "Impossibile utilizzare l'autenticazione biometrica. Verifica la configurazione dell'impronta digitale o FaceID.",
    es: 'No se puede usar la autenticación biométrica. Verifica la configuración de tu huella digital o FaceID.',
  );
  String get pinEntryTitle => _pick(
    fr: 'Entrez votre code PIN à 6 chiffres',
    en: 'Enter your 6-digit PIN',
    de: 'Geben Sie Ihren 6-stelligen PIN ein',
    it: 'Inserisci il tuo PIN a 6 cifre',
    es: 'Ingresa tu PIN de 6 dígitos',
  );
  String get tooManyAttempts => _pick(
    fr: 'Trop de tentatives. Réessayez dans 30 minutes.',
    en: 'Too many attempts. Try again in 30 minutes.',
    de: 'Zu viele Versuche. Versuchen Sie es in 30 Minuten erneut.',
    it: 'Troppi tentativi. Riprova tra 30 minuti.',
    es: 'Demasiados intentos. Intenta de nuevo en 30 minutos.',
  );
  String get incorrectPin => _pick(
    fr: 'Code incorrect',
    en: 'Incorrect PIN',
    de: 'Falscher PIN',
    it: 'PIN errato',
    es: 'PIN incorrecto',
  );

  // --- Shooting Tables ---
  String get clicks =>
      _pick(fr: 'clics', en: 'clicks', de: 'Klicks', it: 'clic', es: 'clics');
  String get click =>
      _pick(fr: 'clic', en: 'click', de: 'Klick', it: 'clic', es: 'clic');

  // --- Diagnostic bridge ---

  String get diagnosticDisclaimerBody =>
      AppStringsDiagnostic.diagnosticDisclaimerBody;
  String get diagnosticDefaultFinal =>
      AppStringsDiagnostic.diagnosticDefaultFinal;

  String get diagnosticSafetyPhase =>
      AppStringsDiagnostic.diagnosticSafetyPhase;
  String get diagnosticClassification =>
      AppStringsDiagnostic.diagnosticClassification;

  String get diagnosticQuestion1 => AppStringsDiagnostic.diagnosticQuestion1;
  String get diagnosticQuestion2 => AppStringsDiagnostic.diagnosticQuestion2;
  String get diagnosticQuestion3 => AppStringsDiagnostic.diagnosticQuestion3;
  String get diagnosticQuestion4 => AppStringsDiagnostic.diagnosticQuestion4;
  String get diagnosticQuestion5 => AppStringsDiagnostic.diagnosticQuestion5;
  String get diagnosticQuestion6 => AppStringsDiagnostic.diagnosticQuestion6;
  String get diagnosticQuestion7 => AppStringsDiagnostic.diagnosticQuestion7;
  String get diagnosticQuestion8 => AppStringsDiagnostic.diagnosticQuestion8;
  String get diagnosticQuestion9 => AppStringsDiagnostic.diagnosticQuestion9;
  String get diagnosticQuestion10 => AppStringsDiagnostic.diagnosticQuestion10;
  String get diagnosticQuestion11 => AppStringsDiagnostic.diagnosticQuestion11;
  String get diagnosticQuestion12 => AppStringsDiagnostic.diagnosticQuestion12;
  String get diagnosticQuestion13 => AppStringsDiagnostic.diagnosticQuestion13;
  String get diagnosticQuestion14 => AppStringsDiagnostic.diagnosticQuestion14;
  String get diagnosticQuestion15 => AppStringsDiagnostic.diagnosticQuestion15;
  String get diagnosticQuestion16 => AppStringsDiagnostic.diagnosticQuestion16;
  String get diagnosticQuestion17 => AppStringsDiagnostic.diagnosticQuestion17;
  String get diagnosticQuestion18 => AppStringsDiagnostic.diagnosticQuestion18;
  String get diagnosticQuestion19 => AppStringsDiagnostic.diagnosticQuestion19;
  String get diagnosticQuestion23 => AppStringsDiagnostic.diagnosticQuestion23;
  String get diagnosticQuestion24 => AppStringsDiagnostic.diagnosticQuestion24;
  String get diagnosticQuestion25 => AppStringsDiagnostic.diagnosticQuestion25;
  String get diagnosticQuestion26 => AppStringsDiagnostic.diagnosticQuestion26;

  String get diagnosticQuestion6Description =>
      AppStringsDiagnostic.diagnosticQuestion6Description;
  String get diagnosticQuestion7Description =>
      AppStringsDiagnostic.diagnosticQuestion7Description;
  String get diagnosticQuestion8Description =>
      AppStringsDiagnostic.diagnosticQuestion8Description;
  String get diagnosticQuestion10Description =>
      AppStringsDiagnostic.diagnosticQuestion10Description;
  String get diagnosticQuestion12Description =>
      AppStringsDiagnostic.diagnosticQuestion12Description;
  String get diagnosticQuestion18Description =>
      AppStringsDiagnostic.diagnosticQuestion18Description;
  String get diagnosticQuestion23Description =>
      AppStringsDiagnostic.diagnosticQuestion23Description;

  String get diagnosticPlatformPossiblyLoaded =>
      AppStringsDiagnostic.diagnosticPlatformPossiblyLoaded;
  String get diagnosticPlatformOpenedSafe =>
      AppStringsDiagnostic.diagnosticPlatformOpenedSafe;
  String get diagnosticUnknownState =>
      AppStringsDiagnostic.diagnosticUnknownState;

  String get diagnosticIncidentNoFire =>
      AppStringsDiagnostic.diagnosticIncidentNoFire;
  String get diagnosticIncidentHangfire =>
      AppStringsDiagnostic.diagnosticIncidentHangfire;
  String get diagnosticIncidentUnintendedDischarge =>
      AppStringsDiagnostic.diagnosticIncidentUnintendedDischarge;
  String get diagnosticIncidentJam =>
      AppStringsDiagnostic.diagnosticIncidentJam;
  String get diagnosticIncidentAccuracyDrop =>
      AppStringsDiagnostic.diagnosticIncidentAccuracyDrop;

  String get diagnosticNoFireLabel =>
      AppStringsDiagnostic.diagnosticNoFireLabel;
  String get diagnosticHangfireLabel =>
      AppStringsDiagnostic.diagnosticHangfireLabel;
  String get diagnosticUnintendedDischargeLabel =>
      AppStringsDiagnostic.diagnosticUnintendedDischargeLabel;
  String get diagnosticJamLabel => AppStringsDiagnostic.diagnosticJamLabel;
  String get diagnosticAccuracyDropLabel =>
      AppStringsDiagnostic.diagnosticAccuracyDropLabel;

  String get diagnosticNoOrUnknown =>
      AppStringsDiagnostic.diagnosticNoOrUnknown;
  String get diagnosticNoOrDoubt => AppStringsDiagnostic.diagnosticNoOrDoubt;
  String get diagnosticNoOrSeveral =>
      AppStringsDiagnostic.diagnosticNoOrSeveral;

  String get diagnosticJamFeeding => AppStringsDiagnostic.diagnosticJamFeeding;
  String get diagnosticJamReturnToBattery =>
      AppStringsDiagnostic.diagnosticJamReturnToBattery;
  String get diagnosticJamExtractionEjection =>
      AppStringsDiagnostic.diagnosticJamExtractionEjection;
}
