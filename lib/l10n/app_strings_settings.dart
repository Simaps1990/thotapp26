part of 'app_strings.dart';

extension AppStringsSettings on AppStrings {
  String get settingsTitle => _pick(
    fr: 'PARAMÈTRES',
    en: 'SETTINGS',
    de: 'EINSTELLUNGEN',
    it: 'IMPOSTAZIONI',
    es: 'AJUSTES',
  );

  String get settingsInfo =>
      _pick(fr: 'Info', en: 'Info', de: 'Info', it: 'Info', es: 'Info');

  String get profileGroupTitle => _pick(
    fr: 'PROFIL DU TIREUR',
    en: 'SHOOTER PROFILE',
    de: 'SCHÜTZENPROFIL',
    it: 'PROFILO TIRATORE',
    es: 'PERFIL DE TIRADOR',
  );

  String get documentsLabel => _pick(
    fr: 'DOCUMENTS',
    en: 'DOCUMENTS',
    de: 'DOKUMENTE',
    it: 'DOCUMENTI',
    es: 'DOCUMENTOS',
  );

  String get liaisonsLabel => _pick(
    fr: 'LIAISONS',
    en: 'LINKS',
    de: 'VERKNÜPFUNGEN',
    it: 'COLLEGAMENTI',
    es: 'ENLACES',
  );

  String documentsCountLabel(int count) {
    if (_isFr) {
      return '$count document${count > 1 ? 's' : ''}';
    }
    if (_isEn) {
      return '$count document${count == 1 ? '' : 's'}';
    }
    if (_isDe) {
      return '$count ${count == 1 ? 'Dokument' : 'Dokumente'}';
    }
    if (_isIt) {
      return '$count ${count == 1 ? 'documento' : 'documenti'}';
    }
    if (_isEs) {
      return '$count ${count == 1 ? 'documento' : 'documentos'}';
    }
    return '$count document${count > 1 ? 's' : ''}';
  }

  String get upgradeToProLabel => _pick(
    fr: 'Passer à Pro',
    en: 'Go Pro',
    de: 'Pro freischalten',
    it: 'Passa a Pro',
    es: 'Pasar a Pro',
  );

  String get preferencesGroupTitle => _pick(
    fr: 'PRÉFÉRENCES',
    en: 'PREFERENCES',
    de: 'VOREINSTELLUNGEN',
    it: 'PREFERENZE',
    es: 'PREFERENCIAS',
  );

  String get darkModeLabel => _pick(
    fr: 'Mode Nuit',
    en: 'Dark Mode',
    de: 'Dunkelmodus',
    it: 'Modalità scura',
    es: 'Modo oscuro',
  );

  String get darkModeSubtitle => _pick(
    fr: 'Adaptation visuelle automatique',
    en: 'Auto appearance',
    de: 'Automatische Anzeigeanpassung',
    it: 'Adattamento visivo automatico',
    es: 'Adaptación visual automática',
  );

  String get appLanguageLabel => _pick(
    fr: 'Langue',
    en: 'Language',
    de: 'Sprache',
    it: 'Lingua',
    es: 'Idioma',
  );

  String get appLanguageSystem => _pick(
    fr: 'Langue du système',
    en: 'System language',
    de: 'Systemsprache',
    it: 'Lingua di sistema',
    es: 'Idioma del sistema',
  );

  String get appLanguageFrench => _pick(
    fr: 'Français',
    en: 'French',
    de: 'Französisch',
    it: 'Francese',
    es: 'Francés',
  );

  String get appLanguageEnglish => _pick(
    fr: 'Anglais',
    en: 'English',
    de: 'Englisch',
    it: 'Inglese',
    es: 'Inglés',
  );

  String get appLanguageGerman => _pick(
    fr: 'Allemand',
    en: 'German',
    de: 'Deutsch',
    it: 'Tedesco',
    es: 'Alemán',
  );

  String get appLanguageItalian => _pick(
    fr: 'Italien',
    en: 'Italian',
    de: 'Italienisch',
    it: 'Italiano',
    es: 'Italiano',
  );

  String get appLanguageSpanish => _pick(
    fr: 'Espagnol',
    en: 'Spanish',
    de: 'Spanisch',
    it: 'Spagnolo',
    es: 'Español',
  );

  String get unitsLabel => _pick(
    fr: 'Unités de mesure',
    en: 'Units',
    de: 'Einheiten',
    it: 'Unità di misura',
    es: 'Unidades de medida',
  );

  String get unitsMetric => _pick(
    fr: 'Métrique',
    en: 'Metric',
    de: 'Metrisch',
    it: 'Metrico',
    es: 'Métrico',
  );

  String get unitsImperial => _pick(
    fr: 'Impérial',
    en: 'Imperial',
    de: 'Imperial',
    it: 'Imperiale',
    es: 'Imperial',
  );

  String get unitProfileLabel => _pick(
    fr: "Profil d'unités",
    en: 'Unit profile',
    de: 'Einheitenprofil',
    it: 'Profilo unità',
    es: 'Perfil de unidades',
  );

  String get unitsCustom => _pick(
    fr: 'Personnalisé',
    en: 'Custom',
    de: 'Benutzerdefiniert',
    it: 'Personalizzato',
    es: 'Personalizado',
  );

  String get unitsWeightLabel => _pick(
    fr: 'Poids projectile',
    en: 'Projectile weight',
    de: 'Geschossgewicht',
    it: 'Peso del proiettile',
    es: 'Peso del proyectil',
  );

  String get unitsDistanceLabel => _pick(
    fr: 'Distance',
    en: 'Distance',
    de: 'Distanz',
    it: 'Distanza',
    es: 'Distancia',
  );

  String get unitsVelocityLabel => _pick(
    fr: 'Vitesse projectile',
    en: 'Projectile velocity',
    de: 'Geschossgeschwindigkeit',
    it: 'Velocità del proiettile',
    es: 'Velocidad del proyectil',
  );

  String get unitsWeatherLabel => _pick(
    fr: 'Météo et environnement',
    en: 'Weather and environment',
    de: 'Wetter und Umgebung',
    it: 'Meteo e ambiente',
    es: 'Tiempo y entorno',
  );

  String get unitsWeatherExampleMetric => _pick(
    fr: 'ex: 22°C, 12 km/h, 1013 hPa',
    en: 'e.g. 22°C, 12 km/h, 1013 hPa',
    de: 'z. B. 22°C, 12 km/h, 1013 hPa',
    it: 'es: 22°C, 12 km/h, 1013 hPa',
    es: 'ej. 22°C, 12 km/h, 1013 hPa',
  );

  String get unitsWeatherExampleImperial => _pick(
    fr: 'ex: 72°F, 7 mph, 29.92 inHg',
    en: 'e.g. 72°F, 7 mph, 29.92 inHg',
    de: 'z. B. 72°F, 7 mph, 29.92 inHg',
    it: 'es: 72°F, 7 mph, 29.92 inHg',
    es: 'ej. 72°F, 7 mph, 29.92 inHg',
  );

  String get backupLabel => _pick(
    fr: "Sauvegarde de l'appareil",
    en: 'Device backup',
    de: 'Gerätesicherung',
    it: 'Backup del dispositivo',
    es: 'Copia de seguridad del dispositivo',
  );

  String get backupSubtitle => _pick(
    fr: "Données stockées et sécurisées uniquement sur l'appareil. La sauvegarde cloud est possible via votre compte iOS/Android.",
    en: "Data is stored and secured only on the device. Cloud backup is available via your iOS/Android account.",
    de: "Daten werden ausschließlich auf dem Gerät gespeichert und gesichert. Cloud-Backups sind über Ihr iOS-/Android-Konto möglich.",
    it: "I dati sono archiviati e protetti esclusivamente sul dispositivo. Il backup cloud è disponibile tramite il tuo account iOS/Android.",
    es: "Los datos se almacenan y se protegen únicamente en el dispositivo. La copia de seguridad en la nube está disponible a través de tu cuenta iOS/Android.",
  );

  String get offlineModeLabel => _pick(
    fr: 'Mode hors connexion',
    en: 'Offline mode',
    de: 'Offline-Modus',
    it: 'Modalità offline',
    es: 'Modo sin conexión',
  );

  String get offlineModeSubtitle => _pick(
    fr: 'Vos données principales restent sur l’appareil. Les services réseau ne sont utilisés que pour les fonctions explicites comme les achats, la météo ou les liens externes.',
    en: 'Your main data stays on the device. Network services are only used for explicit features such as purchases, weather or external links.',
    de: 'Ihre wichtigsten Daten bleiben auf dem Gerät. Netzwerkdienste werden nur für ausdrückliche Funktionen wie Käufe, Wetter oder externe Links verwendet.',
    it: 'I dati principali restano sul dispositivo. I servizi di rete vengono usati solo per funzioni esplicite come acquisti, meteo o link esterni.',
    es: 'Tus datos principales permanecen en el dispositivo. Los servicios de red solo se usan para funciones explícitas como compras, meteorología o enlaces externos.',
  );

  String get documentPushRemindersLabel => _pick(
    fr: 'Notifications documents',
    en: 'Document reminders',
    de: 'Dokument-Erinnerungen',
    it: 'Promemoria documenti',
    es: 'Recordatorios de documentos',
  );

  String get documentPushRemindersSubtitle => _pick(
    fr: 'Alerte locale à la date de rappel avant expiration d\'un document.',
    en: 'Local alert on the reminder date before a document expiry.',
    de: 'Lokale Erinnerung am gewählten Datum vor dem Ablauf eines Dokuments.',
    it: 'Avviso locale alla data di promemoria prima della scadenza di un documento.',
    es: 'Aviso local en la fecha de recordatorio antes del vencimiento de un documento.',
  );

  String get documentPushPermissionDenied => _pick(
    fr: 'Autorisation de notification refusée.',
    en: 'Notification permission denied.',
    de: 'Benachrichtigungsberechtigung verweigert.',
    it: 'Permesso notifiche negato.',
    es: 'Permiso de notificaciones denegado.',
  );

  String get premiumBannerTitle => _pick(
    fr: 'PASSER À PRO',
    en: 'UNLOCK PREMIUM',
    de: 'PREMIUM FREISCHALTEN',
    it: 'SBLOCCA PREMIUM',
    es: 'DESBLOQUEAR PREMIUM',
  );

  String get premiumBannerPrice => _pick(
    fr: 'Tarifs locaux selon votre store',
    en: 'Local pricing from your store',
    de: 'Lokale Preise aus deinem Store',
    it: 'Prezzi locali dal tuo store',
    es: 'Precios locales desde tu tienda',
  );

  String get proYearlyOfferTitle => _pick(
    fr: 'Abonnement annuel',
    en: 'Yearly subscription',
    de: 'Jahresabo',
    it: 'Abbonamento annuale',
    es: 'Suscripción anual',
  );

  String get proYearlyOfferSubtitle => _pick(
    fr: 'Le plus avantageux',
    en: 'Best value',
    de: 'Bestes Angebot',
    it: 'Il più vantaggioso',
    es: 'La más ventajosa',
  );

  String get proMonthlyOfferTitle => _pick(
    fr: 'Abonnement mensuel',
    en: 'Monthly subscription',
    de: 'Monatsabo',
    it: 'Abbonamento mensile',
    es: 'Suscripción mensual',
  );

  String get proMonthlyOfferSubtitle => _pick(
    fr: 'Sans engagement',
    en: 'No commitment',
    de: 'Ohne Verpflichtung',
    it: 'Senza impegno',
    es: 'Sin compromiso',
  );

  String get proRecommendedBadge => _pick(
    fr: 'Recommandé',
    en: 'Recommended',
    de: 'Empfohlen',
    it: 'Consigliato',
    es: 'Recomendado',
  );

  String get premiumFeaturePlatforms => _pick(
    fr: 'Plateformes illimitées',
    en: 'Unlimited platforms',
    de: 'Unbegrenzte Plattformen',
    it: 'Piattaforme illimitate',
    es: 'Plataformas ilimitadas',
  );

  String get premiumFeatureAmmos => _pick(
    fr: 'Consommables illimitées',
    en: 'Unlimited cartridges',
    de: 'Unbegrenzte Verbrauchsmaterial',
    it: 'Consumabili illimitati',
    es: 'Consumibles ilimitados',
  );

  String get premiumFeatureSessions => _pick(
    fr: 'Sessions illimitées',
    en: 'Unlimited sessions',
    de: 'Unbegrenzte Sitzungen',
    it: 'Sessioni illimitate',
    es: 'Sesiones ilimitadas',
  );

  String get premiumFeatureSecurity => _pick(
    fr: 'Protection locale renforcée',
    en: 'Enhanced local protection',
    de: 'Erweiterter lokaler Schutz',
    it: 'Protezione locale avanzata',
    es: 'Protección local mejorada',
  );

  String get premiumFeatureExport => _pick(
    fr: 'Export PDF complet de vos données',
    en: 'Full PDF export of your data',
    de: 'Vollständiger PDF-Export Ihrer Daten',
    it: 'Esportazione PDF completa dei tuoi dati',
    es: 'Exportación PDF completa de tus datos',
  );

  String get proGroupTitle => _pick(
    fr: 'ABONNEMENT PRO',
    en: 'PRO SUBSCRIPTION',
    de: 'PRO-ABO',
    it: 'ABBONAMENTO PRO',
    es: 'SUSCRIPCIÓN PRO',
  );

  String get legalMicTimerDisclaimerSectionTitle => _pick(
    fr: 'Microphone et timer',
    en: 'Microphone and Timer',
    de: 'Mikrofon und Timer',
    it: 'Microfono e timer',
    es: 'Micrófono y temporizador',
  );

  String get legalMicTimerDisclaimerBody => _pick(
    fr: 'Lorsque vous utilisez le mode « Départ + micro », le microphone peut être activé uniquement pendant le déclenchement du timer afin d\'écouter un éventuel tir. Aucun son n\'est enregistré ni transmis. La détection est indicative et peut être imparfaite selon le stand, l\'environnement et la plateforme utilisée.',
    en: 'When you use the "Start + mic" mode, the microphone may be enabled only while the timer is running to listen for a potential shot. No audio is recorded or transmitted. Detection is indicative and may be imperfect depending on the stand, environment, and platform.',
    de: 'Wenn Sie den Modus „Start + Mikro" verwenden, kann das Mikrofon nur während des Timers aktiviert werden, um einen möglichen Schuss zu erkennen. Es wird kein Audio aufgezeichnet oder übertragen. Die Erkennung ist indikativ und kann je nach Stand, Umgebung und Plattform ungenau sein.',
    it: 'Quando usi la modalità "Partenza + microfono", il microfono può essere attivato solo mentre il timer è in esecuzione per ascoltare un eventuale sparo. Nessun audio viene registrato o trasmesso. Il rilevamento è indicativo e può essere impreciso a seconda dello stand, dell\'ambiente e della piattaforma.',
    es: 'Cuando usas el modo "Salida + micrófono", el micrófono puede activarse solo mientras el temporizador está en marcha para escuchar un posible disparo. No se graba ni se transmite audio. La detección es orientativa y puede ser imperfecta según el stand, el entorno y la plataforma.',
  );

  String get proManageLabel => _pick(
    fr: 'Gérer mon abonnement',
    en: 'Manage my subscription',
    de: 'Mein Abo verwalten',
    it: 'Gestisci il mio abbonamento',
    es: 'Gestionar mi suscripción',
  );

  String get proManageSubtitle => _pick(
    fr: 'Accéder au Customer Center',
    en: 'Open Customer Center',
    de: 'Customer Center öffnen',
    it: 'Apri Customer Center',
    es: 'Abrir Customer Center',
  );

  String get proSubtitleActive => _pick(
    fr: 'PRO ACTIF',
    en: 'PRO ACTIVE',
    de: 'PRO AKTIV',
    it: 'PRO ATTIVO',
    es: 'PRO ACTIVO',
  );

  String get proSubtitleUpgrade => _pick(
    fr: 'PASSER À PRO',
    en: 'GO PRO',
    de: 'ZU PRO WECHSELN',
    it: 'PASSA A PRO',
    es: 'PASAR A PRO',
  );

  String get proBenefitUnlimitedEquipmentTitle => _pick(
    fr: 'Matériel illimité',
    en: 'Unlimited equipment',
    de: 'Unbegrenzte Ausrüstung',
    it: 'Attrezzatura illimitata',
    es: 'Equipo ilimitado',
  );

  String get proBenefitUnlimitedEquipmentSubtitle => _pick(
    fr: 'Équipement et accessoires sans limite.',
    en: 'Unlimited equipment and accessories.',
    de: 'Unbegrenzte Ausrüstung und Zubehör.',
    it: 'Attrezzatura e accessori senza limiti.',
    es: 'Equipo y accesorios sin límite.',
  );

  String get proBenefitUnlimitedSessionsTitle => _pick(
    fr: 'Accès Pro illimité',
    en: 'Unlimited sessions',
    de: 'Unbegrenzte Sitzungen',
    it: 'Sessioni illimitate',
    es: 'Sesiones ilimitadas',
  );

  String get proBenefitTimerTitle => _pick(
    fr: 'Timer professionnel',
    en: 'Pro Timer',
    de: 'Profi-Timer',
    it: 'Timer Pro',
    es: 'Temporizador Pro',
  );

  String get proBenefitDiagnosticTitle => _pick(
    fr: 'Diagnostique d\'incidents',
    en: 'Incident diagnostic',
    de: 'Störungsdiagnose',
    it: 'Diagnostica incidenti',
    es: 'Diagnóstico de incidentes',
  );

  String get proBenefitMilliemeTitle => _pick(
    fr: 'Formule du millième',
    en: 'Mil formula',
    de: 'Mil-Formel',
    it: 'Formula mil',
    es: 'Fórmula mil',
  );

  String get proBenefitMilliemeSubtitle => _pick(
    fr: "Calculez la distance d'une cible.",
    en: 'Calculate the distance to a target.',
    de: 'Berechne die Entfernung zu einem Ziel.',
    it: 'Calcola la distanza di un bersaglio.',
    es: 'Calcula la distancia de un objetivo.',
  );

  String get proBenefitLogbookExportTitle => _pick(
    fr: 'Export du carnet',
    en: 'Logbook export',
    de: 'Heft-Export',
    it: 'Esportazione del registro',
    es: 'Exportación del cuaderno',
  );

  String get proBenefitLogbookExportSubtitle => _pick(
    fr: 'Idéal pour imprimer son carnet.',
    en: 'Ideal for printing your logbook.',
    de: 'Ideal zum Ausdrucken deines Hefts.',
    it: 'Ideale per stampare il tuo registro.',
    es: 'Ideal para imprimir tu cuaderno.',
  );

  String get proBenefitUnlimitedDocumentsTitle => _pick(
    fr: 'Ajout de documents illimité',
    en: 'Unlimited document addition',
    de: 'Unbegrenzte Dokumente',
    it: 'Documenti illimitati',
    es: 'Documentos ilimitados',
  );

  String get proBenefitUnlimitedSessionsSubtitle => _pick(
    fr: 'Création de sessions et matériel sans restriction.',
    en: 'Unlimited sessions and equipment creation.',
    de: 'Sitzungen und Ausrüstung ohne Limit.',
    it: 'Sessioni e attrezzatura senza limiti.',
    es: 'Creación ilimitada de sesiones y equipo.',
  );

  String get proBenefitTimerSubtitle => _pick(
    fr: 'Débloquez tous les modes de timer.',
    en: 'Unlock all timer modes.',
    de: 'Alle Timer-Modi freischalten.',
    it: 'Sblocca tutte le modalità del timer.',
    es: 'Desbloquea todos los modos de temporizador.',
  );

  String get proBenefitDiagnosticSubtitle => _pick(
    fr: "Aide à l'identification d'incidents.",
    en: 'Assistance in identifying incidents.',
    de: 'Hilfe bei der Identifizierung von Störungen.',
    it: "Aiuto nell'identificazione degli incidenti.",
    es: 'Ayuda para identificar incidentes.',
  );

  String get proBenefitUnlimitedDocumentsSubtitle => _pick(
    fr: 'Sécurisez vos documents importants.',
    en: 'Secure your important documents.',
    de: 'Sichern Sie Ihre wichtigen Dokumente.',
    it: 'Proteggi i tuoi documenti importanti.',
    es: 'Protege tus documentos importantes.',
  );

  String get proBenefitLocalProtectionSubtitle => _pick(
    fr: 'Protection locale par PIN et biométrie.',
    en: 'Local protection with PIN and biometrics.',
    de: 'Lokaler Schutz mit PIN und Biometrie.',
    it: 'PIN, biometria e protezione dei dati sul dispositivo.',
    es: 'PIN, biometría y protección de datos en el dispositivo.',
  );

  String get proBenefitUnlimitedPdfSubtitle => _pick(
    fr: 'PDF illimités sur chaque fiche.',
    en: 'Unlimited PDFs on each record.',
    de: 'Unbegrenzte PDFs pro Eintrag.',
    it: 'Aggiungi tutti i PDF necessari.',
    es: 'Añade todos los PDF que necesites.',
  );

  String get proBenefitFullPdfExportSubtitle => _pick(
    fr: 'Rapport PDF complet de votre carnet.',
    en: 'Full PDF report of your logbook.',
    de: 'Vollständiger PDF-Bericht deines Hefts.',
    it: 'Rapporto PDF completo del tuo registro.',
    es: 'Informe PDF completo de tu cuaderno.',
  );

  String get proSubscriptionDisclaimer => _pick(
    fr: "L'abonnement est géré sur l'App Store / Play Store. Vous pouvez l'annuler à tout moment. En cas de fin, l'app revient automatiquement en mode gratuit (1 plateforme / 1 consommable / 1 accessoire, 5 sessions, 1 PDF par fiche).",
    en: 'Subscription is managed in the App Store / Play Store. You can cancel at any time. If the subscription ends, the app automatically returns to free mode (1 platform / 1 consumable / 1 accessory, 5 sessions, 1 PDF per item).',
    de: 'Das Abo wird im App Store / Play Store verwaltet. Du kannst jederzeit kündigen. Wenn das Abo endet, wechselt die App automatisch in den Gratis-Modus zurück (1 Plattform / 1 Verbrauchsmaterial / 1 Zubehör, 5 Sitzungen, 1 PDF pro Karte).',
    it: 'L\'abbonamento è gestito sull\'App Store / Play Store. Puoi annullarlo in qualsiasi momento. Se l\'abbonamento termina, l\'app torna automaticamente in modalità gratuita (1 piattaforma / 1 consumabile / 1 accessorio, 5 sessioni, 1 PDF per scheda).',
    es: 'La suscripción se gestiona en el App Store / Play Store. Puedes cancelarla en cualquier momento. Si la suscripción termina, la app vuelve automáticamente al modo gratuito (1 plataforma / 1 consumable / 1 accesorio, 5 sesiones, 1 PDF por elemento).',
  );

  String get proPurchaseUnavailable => _pick(
    fr: 'Paiement indisponible pour le moment.',
    en: 'Payment is currently unavailable.',
    de: 'Zahlung ist derzeit nicht verfügbar.',
    it: 'Il pagamento non è disponibile al momento.',
    es: 'El pago no está disponible por el momento.',
  );

  String get proRestorePurchases => _pick(
    fr: 'Restaurer mes achats',
    en: 'Restore purchases',
    de: 'Käufe wiederherstellen',
    it: 'Ripristina acquisti',
    es: 'Restaurar compras',
  );

  String get proRestorePurchasesSuccess => _pick(
    fr: 'Achats restaurés.',
    en: 'Purchases restored.',
    de: 'Käufe wiederhergestellt.',
    it: 'Acquisti ripristinati.',
    es: 'Compras restauradas.',
  );

  String get proRestorePurchasesNoActiveSubscription => _pick(
    fr: 'Aucun achat actif à restaurer sur ce compte.',
    en: 'No active purchase to restore on this account.',
    de: 'Kein aktiver Kauf zum Wiederherstellen für dieses Konto.',
    it: 'Nessun acquisto attivo da ripristinare su questo account.',
    es: 'No hay compras activas para restaurar en esta cuenta.',
  );

  String get proRestorePurchasesError => _pick(
    fr: 'Impossible de restaurer les achats pour le moment.',
    en: 'Unable to restore purchases right now.',
    de: 'Käufe können derzeit nicht wiederhergestellt werden.',
    it: 'Impossibile ripristinare gli acquisti al momento.',
    es: 'No se pueden restaurar las compras en este momento.',
  );

  String get proActiveOnAccount => _pick(
    fr: 'Pro est actif sur ce compte.',
    en: 'Pro is active on this account.',
    de: 'Pro ist auf diesem Konto aktiv.',
    it: 'Pro è attivo su questo account.',
    es: 'Pro está activo en esta cuenta.',
  );

  String get proHeroUnlockTitle => _pick(
    fr: 'Tout ton arsenal, sans limite',
    en: 'Your full arsenal, no limits',
    de: 'Dein gesamtes Arsenal, ohne Grenzen',
    it: 'Tutto il tuo arsenale, senza limiti',
    es: 'Todo tu arsenal, sin límites',
  );

  String get proHeroUnlockSubtitle => _pick(
    fr: 'Le carnet de tir conçu pour les professionnels.',
    en: 'The shooting log designed for professionals.',
    de: 'Das Schießbuch, entwickelt für Profis.',
    it: 'Il registro di tiro progettato per i professionisti.',
    es: 'El registro de tiro diseñado para profesionales.',
  );

  String proSavingsBadge(int percent) => _pick(
    fr: 'ÉCONOMIE $percent%',
    en: 'SAVE $percent%',
    de: 'SPAREN SIE $percent%',
    it: 'RISPARMIA $percent%',
    es: 'AHORRA $percent%',
  );

  String proPerMonthEquivalent(String price) => _pick(
    fr: '≈ $price /mois',
    en: '≈ $price /month',
    de: '≈ $price /Monat',
    it: '≈ $price /mese',
    es: '≈ $price /mes',
  );

  String get proHeroActiveTitle => _pick(
    fr: 'THOT Pro',
    en: 'THOT Pro',
    de: 'THOT Pro',
    it: 'THOT Pro',
    es: 'THOT Pro',
  );

  String get proHeroActiveSubtitle => _pick(
    fr: 'Toutes les fonctionnalités sont actives.',
    en: 'All features are active.',
    de: 'Alle Funktionen sind aktiv.',
    it: 'Tutte le funzionalità sono attive.',
    es: 'Todas las funciones están activas.',
  );

  String get settingsProfileTitle => _pick(
    fr: 'Modifier le profil',
    en: 'Edit profile',
    de: 'Profil bearbeiten',
    it: 'Modifica profilo',
    es: 'Editar perfil',
  );

  String get settingsProfileNameLabel => _pick(
    fr: 'Nom complet',
    en: 'Full name',
    de: 'Vollständiger Name',
    it: 'Nome completo',
    es: 'Nombre completo',
  );

  String get settingsProfileLicenseLabel => _pick(
    fr: 'Numéro de licence',
    en: 'License number',
    de: 'Lizenznummer',
    it: 'Numero di licenza',
    es: 'Número de licencia',
  );

  String get settingsProfileEmailLabel =>
      _pick(fr: 'Email', en: 'Email', de: 'E-Mail', it: 'Email', es: 'Email');

  String get settingsProfileUpdatedSnack => _pick(
    fr: 'Profil mis à jour',
    en: 'Profile updated',
    de: 'Profil aktualisiert',
    it: 'Profilo aggiornato',
    es: 'Perfil actualizado',
  );

  String get settingsDialogCancel => cancel;

  String get settingsDialogSave => _pick(
    fr: 'Enregistrer',
    en: 'Save',
    de: 'Speichern',
    it: 'Salva',
    es: 'Guardar',
  );

  String get settingsExportPdfProOnly => _pick(
    fr: "L'export PDF est une fonctionnalité Pro.",
    en: 'PDF export is a Pro feature.',
    de: 'PDF-Export ist eine Pro-Funktion.',
    it: 'L\'esportazione PDF è una funzione Pro.',
    es: 'La exportación en PDF es una función Pro.',
  );

  String get settingsViewPro => _pick(
    fr: 'Voir Pro',
    en: 'View Pro',
    de: 'Pro ansehen',
    it: 'Vedi Pro',
    es: 'Ver Pro',
  );

  String settingsExportError(Object e) => _pick(
    fr: "Erreur lors de l'export : $e",
    en: 'Error during export: $e',
    de: 'Fehler beim Export: $e',
    it: "Errore durante l'esportazione: $e",
    es: 'Error durante la exportación: $e',
  );

  String get settingsAboutDescription => _pick(
    fr: "THOT est votre carnet de tir numérique incontournable, offrant aux forces de l'ordre et aux tireurs sportifs une gestion intuitive et complète.",
    en: 'THOT is your essential digital shooting logbook, offering law enforcement and sport shooters intuitive, complete management.',
    de: 'THOT ist Ihr unverzichtbares digitales Schießbuch und bietet Polizei und Sportschützen eine intuitive und umfassende Verwaltung.',
    it: 'THOT è il tuo registro di tiro digitale essenziale, che offre a forze dell\'ordine e tiratori sportivi una gestione intuitiva e completa.',
    es: 'THOT es tu cuaderno de tiro digital imprescindible, que ofrece a las fuerzas del orden y tiradores deportivos una gestión intuitiva y completa.',
  );

  String get settingsAboutTos => _pick(
    fr: "Conditions Générales d'Utilisation",
    en: 'Terms of Use',
    de: 'Nutzungsbedingungen',
    it: 'Condizioni d\'uso',
    es: 'Términos de uso',
  );

  String get settingsAboutPrivacy => _pick(
    fr: 'Politique de confidentialité',
    en: 'Privacy policy',
    de: 'Datenschutzrichtlinie',
    it: 'Informativa sulla privacy',
    es: 'Política de privacidad',
  );

  String get legalAndPrivacyLabel => _pick(
    fr: 'Informations légales & confidentialité',
    en: 'Legal information & privacy',
    de: 'Rechtliche Informationen & Datenschutz',
    it: 'Informazioni legali & privacy',
    es: 'Información legal y privacidad',
  );

  String get settingsAboutCopyright => _pick(
    fr: '© 2026-2027 THOT. Tous droits réservés.',
    en: '© 2026-2027 THOT. All rights reserved.',
    de: '© 2026-2027 THOT. Alle Rechte vorbehalten.',
    it: '© 2026-2027 THOT. Tutti i diritti riservati.',
    es: '© 2026-2027 THOT. Todos los derechos reservados.',
  );

  String get settingsLogoutTitle => _pick(
    fr: 'Déconnexion',
    en: 'Log out',
    de: 'Abmelden',
    it: 'Disconnetti',
    es: 'Cerrar sesión',
  );

  String get settingsLogoutMessage => _pick(
    fr: 'Voulez-vous vraiment vous déconnecter ?',
    en: 'Do you really want to log out?',
    de: 'Möchten Sie sich wirklich abmelden?',
    it: 'Vuoi davvero disconnetterti?',
    es: '¿Realmente quieres cerrar sesión?',
  );

  String get settingsLogoutConfirm => _pick(
    fr: 'Se déconnecter',
    en: 'Log out',
    de: 'Abmelden',
    it: 'Disconnetti',
    es: 'Cerrar sesión',
  );

  String get settingsLogoutSuccess => _pick(
    fr: 'Déconnexion réussie',
    en: 'Logged out successfully',
    de: 'Erfolgreich abgemeldet',
    it: 'Disconnessione riuscita',
    es: 'Cierre de sesión correcto',
  );

  String get settingsDocumentsTitle => _pick(
    fr: 'Mes Documents',
    en: 'My documents',
    de: 'Meine Dokumente',
    it: 'I miei documenti',
    es: 'Mis documentos',
  );

  String get settingsDocumentsEmptyTitle => _pick(
    fr: 'Aucun document',
    en: 'No documents',
    de: 'Keine Dokumente',
    it: 'Nessun documento',
    es: 'Sin documentos',
  );

  String get settingsDocumentsEmptySubtitle => _pick(
    fr: 'Ajoutez vos documents officiels\n(permis, licences, etc.)',
    en: 'Add your official documents\n(licenses, permits, etc.)',
    de: 'Offizielle Dokumente hinzufügen\n(Lizenzen, Genehmigungen usw.)',
    it: 'Aggiungi i tuoi documenti ufficiali\n(licenze, permessi, ecc.)',
    es: 'Añade tus documentos oficiales\n(licencias, permisos, etc.)',
  );

  String settingsDocumentDeleted(String name) => _pick(
    fr: '"$name" supprimé',
    en: '"$name" deleted',
    de: '"$name" gelöscht',
    it: '"$name" eliminato',
    es: '"$name" eliminado',
  );

  String get settingsAddDocument =>
      _pick(fr: 'Nouveau', en: 'New', de: 'Neu', it: 'Nuovo', es: 'Nuevo');

  String settingsPickFileError(Object e) => _pick(
    fr: 'Erreur lors de la sélection du fichier: $e',
    en: 'Error while selecting file: $e',
    de: 'Fehler bei der Dateiauswahl: $e',
    it: 'Errore durante la selezione del file: $e',
    es: 'Error al seleccionar el archivo: $e',
  );

  String get settingsDocumentDetailsTitle => _pick(
    fr: 'Détails du document',
    en: 'Document details',
    de: 'Dokumentdetails',
    it: 'Dettagli documento',
    es: 'Detalles del documento',
  );

  String get settingsDocumentNameLabel => _pick(
    fr: 'Nom du document',
    en: 'Document name',
    de: 'Dokumentname',
    it: 'Nome del documento',
    es: 'Nombre del documento',
  );

  String get settingsDocumentNameHint => _pick(
    fr: 'Ex: Permis de chasse 2024',
    en: 'Ex: Hunting license 2024',
    de: 'Bsp.: Jagdschein 2024',
    it: 'Es: Licenza di caccia 2024',
    es: 'Ej: Licencia de caza 2024',
  );

  String get settingsDocumentTypeLabel => _pick(
    fr: 'Type de document',
    en: 'Document type',
    de: 'Dokumenttyp',
    it: 'Tipo di documento',
    es: 'Tipo de documento',
  );

  String get settingsDocumentTypeHuntingPermit => _pick(
    fr: 'Permis de chasse',
    en: 'Hunting permit',
    de: 'Jagdschein',
    it: 'Permesso di caccia',
    es: 'Permiso de caza',
  );

  String get settingsDocumentTypeFftLicense => _pick(
    fr: 'Licence FFT',
    en: 'FFT license',
    de: 'FFT-Lizenz',
    it: 'Licenza FFT',
    es: 'Licencia FFT',
  );

  String get settingsDocumentTypeIdCard => _pick(
    fr: "Carte d'identité",
    en: 'ID card',
    de: 'Personalausweis',
    it: "Carta d'identità",
    es: 'Documento de identidad',
  );

  String get settingsDocumentTypePlatformPermit => _pick(
    fr: "Autorisation de port de plateforme",
    en: 'Platform carry permit',
    de: 'Konfigurationsmitführungsgenehmigung',
    it: "Autorizzazione al porto di configurazione",
    es: 'Permiso de porte de configuración',
  );

  String get settingsDocumentTypeMedicalCertificate => _pick(
    fr: 'Certificat médical',
    en: 'Medical certificate',
    de: 'Ärztliches Attest',
    it: 'Certificato medico',
    es: 'Certificado médico',
  );

  String get settingsDocumentTypeOther =>
      _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro');

  // --- Crash Log ---

  String get exportCrashLogLabel => _pick(
    fr: 'Exporter le journal de crash',
    en: 'Export crash log',
    de: 'Crash-Log exportieren',
    it: 'Esporta il log dei crash',
    es: 'Exportar el registro de fallos',
  );

  String get exportCrashLogSubtitle => _pick(
    fr: "Pour signaler un bug à l'équipe THOT",
    en: 'To report a bug to the THOT team',
    de: 'Um einen Bug an das THOT-Team zu melden',
    it: 'Per segnalare un bug al team THOT',
    es: 'Para reportar un error al equipo THOT',
  );

  String get exportCrashLogEmpty => _pick(
    fr: 'Aucun crash enregistré',
    en: 'No crash recorded',
    de: 'Keine Abstürze aufgezeichnet',
    it: 'Nessun crash registrato',
    es: 'Ningún fallo registrado',
  );

  // --- PIN disable confirmation ---

  String get pinDisableConfirmTitle => _pick(
    fr: 'Désactiver le code PIN ?',
    en: 'Disable PIN code?',
    de: 'PIN-Code deaktivieren?',
    it: 'Disattivare il codice PIN?',
    es: '¿Desactivar el código PIN?',
  );

  String get pinDisableConfirmMessage => _pick(
    fr: "Vos données ne seront plus protégées par un PIN à l'ouverture de l'application.",
    en: 'Your data will no longer be protected by a PIN when opening the app.',
    de: 'Ihre Daten werden beim Öffnen der App nicht mehr durch einen PIN geschützt.',
    it: "I tuoi dati non saranno più protetti da un PIN all'apertura dell'app.",
    es: 'Tus datos ya no estarán protegidos por un PIN al abrir la aplicación.',
  );

  String get pinDisableConfirmAction => _pick(
    fr: 'Désactiver',
    en: 'Disable',
    de: 'Deaktivieren',
    it: 'Disattiva',
    es: 'Desactivar',
  );

  // --- JSON Backup ---

  String get jsonExportLabel => _pick(
    fr: 'Exporter les données (JSON)',
    en: 'Export data (JSON)',
    de: 'Daten exportieren (JSON)',
    it: 'Esporta dati (JSON)',
    es: 'Exportar datos (JSON)',
  );

  String get jsonExportSubtitle => _pick(
    fr: 'Sauvegarde complète de votre carnet',
    en: 'Full backup of your logbook',
    de: 'Vollständige Sicherung Ihres Hefts',
    it: 'Backup completo del tuo registro',
    es: 'Copia de seguridad complète de tu cuaderno',
  );

  String get dataManagementLabel => _pick(
    fr: 'Import & Export (JSON)',
    en: 'Import & Export (JSON)',
    de: 'Import & Export (JSON)',
    it: 'Importa & Esporta (JSON)',
    es: 'Importar y Exportar (JSON)',
  );

  String get dataManagementSubtitle => _pick(
    fr: 'Sauvegarde et restauration manuelle',
    en: 'Manual backup and restore',
    de: 'Manuelle Sicherung und Wiederherstellung',
    it: 'Backup e ripristino manuale',
    es: 'Copia de seguridad y restauración manual',
  );

  String get jsonImportLabel => _pick(
    fr: 'Importer des données (JSON)',
    en: 'Import data (JSON)',
    de: 'Daten importieren (JSON)',
    it: 'Importa dati (JSON)',
    es: 'Importar datos (JSON)',
  );

  String get jsonImportSubtitle => _pick(
    fr: 'Restaurer à partir d\'un fichier .json',
    en: 'Restore from a .json file',
    de: 'Aus einer .json-Datei wiederherstellen',
    it: 'Ripristina da un file .json',
    es: 'Restaurar desde un archivo .json',
  );

  String get jsonImportSuccessSnack => _pick(
    fr: 'Données importées avec succès',
    en: 'Data imported successfully',
    de: 'Daten erfolgreich importiert',
    it: 'Dati importati con successo',
    es: 'Datos importados con éxito',
  );

  String jsonImportErrorSnack(Object e) => _pick(
    fr: 'Erreur lors de l\'import : $e',
    en: 'Error during import: $e',
    de: 'Fehler beim Import: $e',
    it: 'Errore durante l\'importazione: $e',
    es: 'Error durante la importación: $e',
  );

  String get jsonImportConfirmTitle => _pick(
    fr: 'Remplacer les données ?',
    en: 'Replace data?',
    de: 'Daten ersetzen?',
    it: 'Sostituire i dati?',
    es: '¿Reemplazar los datos?',
  );

  String get jsonImportConfirmMessage => _pick(
    fr: 'L\'import remplacera toutes vos données actuelles par celles du fichier. Cette action est irréversible.',
    en: 'Import will replace all your current data with the file contents. This action cannot be undone.',
    de: 'Der Import ersetzt alle aktuellen Daten durch den Dateiinhalt. Diese Aktion kann nicht rückgängig gemacht werden.',
    it: 'L\'importazione sostituirà tutti i dati attuali con quelli del file. Questa azione è irreversibile.',
    es: 'La importación reemplazará todos tus datos actuales con los del archivo. Esta acción es irreversible.',
  );

  String get jsonImportConfirmAction => _pick(
    fr: 'Remplacer',
    en: 'Replace',
    de: 'Ersetzen',
    it: 'Sostituisci',
    es: 'Reemplazar',
  );

  String get jsonImportPreviewDetectedContent => _pick(
    fr: 'Contenu détecté :',
    en: 'Detected content:',
    de: 'Erkannter Inhalt:',
    it: 'Contenuto rilevato:',
    es: 'Contenido detectado:',
  );

  String jsonImportPreviewPlatforms(int count) => _pick(
    fr: '• $count plateforme${count > 1 ? 's' : ''}',
    en: '• $count platform${count == 1 ? '' : 's'}',
    de: '• $count ${count == 1 ? 'Plattform' : 'Plattformen'}',
    it: '• $count ${count == 1 ? 'piattaforma' : 'piattaforme'}',
    es: '• $count ${count == 1 ? 'plataforma' : 'plataformas'}',
  );

  String jsonImportPreviewAmmos(int count) => _pick(
    fr: '• $count consommable${count > 1 ? 's' : ''}',
    en: '• $count consumable${count == 1 ? '' : 's'}',
    de: '• $count Verbrauchsmaterial${count == 1 ? '' : 'ien'}',
    it: '• $count ${count == 1 ? 'consumabile' : 'consumabili'}',
    es: '• $count ${count == 1 ? 'consumible' : 'consumibles'}',
  );

  String jsonImportPreviewAccessories(int count) => _pick(
    fr: '• $count accessoire${count > 1 ? 's' : ''}',
    en: '• $count accessor${count == 1 ? 'y' : 'ies'}',
    de: '• $count Zubehör',
    it: '• $count ${count == 1 ? 'accessorio' : 'accessori'}',
    es: '• $count ${count == 1 ? 'accesorio' : 'accesorios'}',
  );

  String jsonImportPreviewSessions(int count) => _pick(
    fr: '• $count session${count > 1 ? 's' : ''}',
    en: '• $count session${count == 1 ? '' : 's'}',
    de: '• $count ${count == 1 ? 'Sitzung' : 'Sitzungen'}',
    it: '• $count ${count == 1 ? 'sessione' : 'sessioni'}',
    es: '• $count ${count == 1 ? 'sesión' : 'sesiones'}',
  );

  String jsonImportPreviewDiagnostics(int count) => _pick(
    fr: '• $count diagnostic${count > 1 ? 's' : ''}',
    en: '• $count diagnostic${count == 1 ? '' : 's'}',
    de: '• $count ${count == 1 ? 'Diagnose' : 'Diagnosen'}',
    it: '• $count ${count == 1 ? 'diagnostica' : 'diagnostiche'}',
    es: '• $count ${count == 1 ? 'diagnóstico' : 'diagnósticos'}',
  );

  String jsonImportPreviewShootingTables(int count) => _pick(
    fr: '• $count table${count > 1 ? 's' : ''} de tir',
    en: '• $count shooting table${count == 1 ? '' : 's'}',
    de: '• $count ${count == 1 ? 'Schusstabelle' : 'Schusstabellen'}',
    it: '• $count ${count == 1 ? 'tabella di tiro' : 'tabelle di tiro'}',
    es: '• $count ${count == 1 ? 'tabla de tiro' : 'tablas de tiro'}',
  );
}
