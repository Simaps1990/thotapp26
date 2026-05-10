part of 'app_strings.dart';

extension AppStringsCommon on AppStrings {
  // --- Common UI Strings ---

  String get homeVersionProLabel => _pick(
        fr: 'Version PRO',
        en: 'Pro version',
        de: 'PRO-Version',
        it: 'Versione PRO',
        es: 'Versión PRO',
      );

  String get homeVersionFreeLabel => _pick(
        fr: 'Version gratuite',
        en: 'Free version',
        de: 'Kostenlose Version',
        it: 'Versione gratuita',
        es: 'Versión gratuita',
      );

  String get shortcutsGroupTitle => _pick(
        fr: 'RACCOURCIS ACCUEIL (MAX 4)',
        en: 'HOME SHORTCUTS (MAX 4)',
        de: 'STARTSEITENKÜRZEL (MAX 4)',
        it: 'SCORCIATOIE HOME (MAX 4)',
        es: 'ATAJOS INICIO (MÁX 4)',
      );

  String get shortcutNewSession => _pick(
        fr: 'Nouvelle session',
        en: 'New session',
        de: 'Neue Trainingseinheit',
        it: 'Nuova sessione',
        es: 'Nueva sesión',
      );

  String get shortcutNewPlatform => _pick(
        fr: 'Nouvelle plateforme',
        en: 'New platform',
        de: 'Neue Plattform',
        it: 'Nuova piattaforma',
        es: 'Nueva plataforma',
      );

  String get shortcutNewAmmo => _pick(
        fr: 'Nouveau consommable',
        en: 'New ammo',
        de: 'Neues Verbrauchsmaterial',
        it: 'Nuovo consumabile',
        es: 'Nuevo consumible',
      );

  String get shortcutNewAccessory => _pick(
        fr: 'Nouvel accessoire',
        en: 'New accessory',
        de: 'Neues Zubehör',
        it: 'Nuovo accessorio',
        es: 'Nuevo accesorio',
      );

  String get shortcutToggleTheme => _pick(
        fr: 'Basculer Mode Nuit',
        en: 'Toggle dark mode',
        de: 'Dunkelmodus umschalten',
        it: 'Attiva/disattiva tema scuro',
        es: 'Alternar modo oscuro',
      );

  String get shortcutTimer => _pick(
fr: 'Timer',
en: 'Shot Timer',
de: 'Schuss-Timer',
it: 'Timer colpi',
es: 'Temporizador de disparos',
      );

  String get quickActionLabelTheme => _pick(
        fr: 'Mode nuit',
        en: 'Dark mode',
        de: 'Dunkelmodus',
        it: 'Modalità scura',
        es: 'Modo oscuro',
      );

  String get securityGroupTitle => _pick(
        fr: 'SÉCURITÉ',
        en: 'SECURITY',
        de: 'SICHERHEIT',
        it: 'SICUREZZA',
        es: 'SEGURIDAD',
      );

  String get pinCodeLabel => _pick(
        fr: 'Code PIN',
        en: 'PIN code',
        de: 'PIN-Code',
        it: 'Codice PIN',
        es: 'Código PIN',
      );

  String get biometricLabel => _pick(
        fr: 'Face ID / Touch ID',
        en: 'Face ID / Touch ID',
        de: 'Face ID / Touch ID',
        it: 'Face ID / Touch ID',
        es: 'Face ID / Touch ID',
      );

  String get statusEnabled => _pick(
        fr: 'Activé',
        en: 'Enabled',
        de: 'Aktiviert',
        it: 'Attivato',
        es: 'Activado',
      );

  String get statusDisabled => _pick(
        fr: 'Désactivé',
        en: 'Disabled',
        de: 'Deaktiviert',
        it: 'Disattivato',
        es: 'Desactivado',
      );

  String get pinDisabledSnack => _pick(
        fr: 'Code PIN désactivé',
        en: 'PIN code disabled',
        de: 'PIN-Code deaktiviert',
        it: 'Codice PIN disattivato',
        es: 'Código PIN desactivado',
      );

  String get biometricRequiresPinSnack => _pick(
        fr: "Veuillez d'abord configurer un code PIN",
        en: 'Please configure a PIN code first',
        de: 'Bitte richte zuerst einen PIN-Code ein',
        it: 'Configura prima un codice PIN',
        es: 'Configura primero un código PIN',
      );

  String biometricStatusChangedSnack(bool enabled) => enabled
      ? _pick(
          fr: 'Authentification biométrique activée',
          en: 'Biometric authentication enabled',
          de: 'Biometrische Authentifizierung aktiviert',
          it: 'Autenticazione biometrica attivata',
          es: 'Autenticación biométrica activada',
        )
      : _pick(
          fr: 'Authentification biométrique désactivée',
          en: 'Biometric authentication disabled',
          de: 'Biometrische Authentifizierung deaktiviert',
          it: 'Autenticazione biometrica disattivata',
          es: 'Autenticación biométrica desactivada',
        );

  String get biometricAuthReason => _pick(
      fr: 'Authentifiez-vous pour accéder à THOT',
      en: 'Authenticate to access THOT',
      de: 'Authentifizieren Sie sich, um auf THOT zuzugreifen',
      it: 'Autenticati per accedere a THOT',
      es: 'Autentícate para acceder a THOT',
    );

  String get supportGroupTitle => _pick(
        fr: 'SUPPORT & SÉCURITÉ',
        en: 'SUPPORT & SECURITY',
        de: 'SUPPORT & SICHERHEIT',
        it: 'SUPPORTO & SICUREZZA',
        es: 'SOPORTE Y SEGURIDAD',
      );

  String get supportAndContactLabel => _pick(
        fr: 'Assistance & Contact',
        en: 'Support & Contact',
        de: 'Support & Kontakt',
        it: 'Assistenza & Contatti',
        es: 'Soporte y Contacto',
      );

  // Contact / Support
  String get contactMeLabel => _pick(
        fr: 'Nous contacter',
        en: 'Contact us',
        de: 'Kontaktieren Sie uns',
        it: 'Contattaci',
        es: 'Contáctanos',
      );

  String get contactMeSubtitle => _pick(
        fr: 'Partenariat ou Support',
        en: 'Partnership or Support',
        de: 'Partnerschaft oder Support',
        it: 'Partnership o Supporto',
        es: 'Colaboración o Soporte',
      );

  String get contactPartnership => _pick(
        fr: 'Demande de partenariat',
        en: 'Partnership request',
        de: 'Partnerschaftsanfrage',
        it: 'Richiesta di partnership',
        es: 'Solicitud de colaboración',
      );

  String get contactSupport => _pick(
        fr: 'Contacter le support',
        en: 'Contact support',
        de: 'Support kontaktieren',
        it: 'Contatta il supporto',
        es: 'Contactar soporte',
      );

  String get contactSubjectPartnership => _pick(
        fr: 'Demande de partenariat - THOT',
        en: 'Partnership request - THOT',
        de: 'Partnerschaftsanfrage - THOT',
        it: 'Richiesta di partnership - THOT',
        es: 'Solicitud de colaboración - THOT',
      );

  String get contactSubjectSupport => _pick(
        fr: 'Support - THOT',
        en: 'Support - THOT',
        de: 'Support - THOT',
        it: 'Supporto - THOT',
        es: 'Soporte - THOT',
      );

  // Achievements sorting
  String get achievementsSortRecent => _pick(
        fr: 'Plus récents',
        en: 'Most recent',
        de: 'Neueste zuerst',
        it: 'Più recenti',
        es: 'Más recientes',
      );

  String get achievementsSortOldest => _pick(
        fr: 'Plus anciens',
        en: 'Oldest first',
        de: 'Älteste zuerst',
        it: 'Più vecchi',
        es: 'Más antiguos',
      );

  String get achievementsSortLevelHigh => _pick(
        fr: "Niveau élevé d'abord",
        en: 'Higher tier first',
        de: 'Höherer Rang zuerst',
        it: 'Livello alto prima',
        es: 'Nivel alto primero',
      );

  String get achievementsSortLevelLow => _pick(
        fr: "Niveau bas d'abord",
        en: 'Lower tier first',
        de: 'Niedriger Rang zuerst',
        it: 'Livello basso prima',
        es: 'Nivel bajo primero',
      );

  String get exportPdfLabel => _pick(
        fr: 'Exporter mes données (PDF)',
        en: 'Export my data (PDF)',
        de: 'Meine Daten exportieren (PDF)',
        it: 'Esporta i miei dati (PDF)',
        es: 'Exportar mis datos (PDF)',
      );

  String get exportPdfSubtitlePremium => _pick(
        fr: 'Export complet de votre carnet',
        en: 'Full export of your logbook',
        de: 'Vollständiger Export Ihres Schießbuchs',
        it: 'Esportazione completa del tuo registro',
        es: 'Exportación completa de tu cuaderno',
      );

  String get exportPdfSubtitleProOnly => _pick(
        fr: 'Fonctionnalité Pro',
        en: 'Pro feature',
        de: 'Pro-Funktion',
        it: 'Funzione Pro',
        es: 'Función Pro',
      );

  String get dataPrivacyLabel => _pick(
        fr: 'Données & confidentialité',
        en: 'Data & privacy',
        de: 'Daten & Datenschutz',
        it: 'Dati & privacy',
        es: 'Datos y privacidad',
      );

  String get dataPrivacySubtitle => _pick(
        fr: 'Données protégées · Zéro serveur · 100% local · PIN/biométrie',
        en: 'Protected data · Zero server · 100% local · PIN/biometrics',
        de: 'Geschützte Daten · Kein Server · 100% lokal · PIN/Biometrie',
        it: 'Dati protetti · Zero server · 100% locale · PIN/biometria',
        es: 'Datos protegidos · Sin servidor · 100% local · PIN/biometría',
      );

  String get aboutLabel => _pick(
        fr: 'À propos & confidentialité',
        en: 'About & privacy',
        de: 'Über & Datenschutz',
        it: 'Informazioni & privacy',
        es: 'Acerca de y privacidad',
      );

  String get aboutSubtitle => _pick(
        fr: 'Mentions légales, CGU, politique de confidentialité',
        en: 'Legal, Terms of Use, Privacy Policy',
        de: 'Impressum, Nutzungsbedingungen, Datenschutzrichtlinie',
        it: 'Note legali, Termini d\'uso, Informativa privacy',
        es: 'Aviso legal, Términos de uso, Política de privacidad',
      );

  // --- Native Picker Strings ---

  String get pickerActionTakePhoto => _pick(
        fr: 'Prendre une photo',
        en: 'Take a photo',
        de: 'Foto aufnehmen',
        it: 'Scatta una foto',
        es: 'Hacer una foto',
      );

  String get pickerActionChoosePhoto => _pick(
        fr: 'Choisir une photo',
        en: 'Choose a photo',
        de: 'Foto auswählen',
        it: 'Scegli una foto',
        es: 'Elegir una foto',
      );

  String get pickerActionChooseDocument => _pick(
        fr: 'Choisir un document',
        en: 'Choose a document',
        de: 'Dokument auswählen',
        it: 'Scegli un documento',
        es: 'Elegir un documento',
      );

  String get pickerActionCancel => _pick(
        fr: 'Annuler',
        en: 'Cancel',
        de: 'Abbrechen',
        it: 'Annulla',
        es: 'Cancelar',
      );
}
