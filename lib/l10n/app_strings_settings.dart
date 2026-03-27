part of 'app_strings.dart';

extension AppStringsSettings on AppStrings {
  String get settingsTitle => _pick(
        fr: 'PARAMÈTRES',
        en: 'SETTINGS',
        de: 'EINSTELLUNGEN',
        it: 'IMPOSTAZIONI',
        es: 'AJUSTES',
      );

  String get profileGroupTitle => _pick(
        fr: 'PROFIL TIREUR',
        en: 'SHOOTER PROFILE',
        de: 'SCHÜTZENPROFIL',
        it: 'PROFILO TIRATORE',
        es: 'PERFIL DE TIRADOR',
      );

  String get documentsLabel => _pick(
        fr: 'Documents',
        en: 'Documents',
        de: 'Dokumente',
        it: 'Documenti',
        es: 'Documentos',
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
        en: 'Automatic appearance adjustment',
        de: 'Automatische Anzeigeanpassung',
        it: 'Adattamento automatico dell’aspetto',
        es: 'Ajuste automático de la apariencia',
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
        de: 'Am vorteilhaftesten',
        it: 'Il più vantaggioso',
        es: 'La opción más ventajosa',
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

  String get premiumFeatureWeapons => _pick(
        fr: 'Armes illimitées',
        en: 'Unlimited weapons',
        de: 'Unbegrenzte Waffen',
        it: 'Armi illimitate',
        es: 'Armas ilimitadas',
      );

  String get premiumFeatureAmmos => _pick(
        fr: 'Munitions illimitées',
        en: 'Unlimited ammo',
        de: 'Unbegrenzte Munition',
        it: 'Munizioni illimitate',
        es: 'Munición ilimitada',
      );

  String get premiumFeatureSessions => _pick(
        fr: 'Séances illimitées',
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
        fr: 'Microphone et timer de tir',
        en: 'Microphone and shooting timer',
        de: 'Mikrofon und Schieß-Timer',
        it: 'Microfono e timer di tiro',
        es: 'Micrófono y temporizador de tiro',
      );

  String get legalMicTimerDisclaimerBody => _pick(
        fr: 'Lorsque vous utilisez le mode « Départ + micro », le microphone peut être activé uniquement pendant le déclenchement du timer afin d’écouter une éventuelle détonation. Aucun son n’est enregistré ni transmis. La détection est indicative et peut être imparfaite selon le stand, l’environnement et l’arme utilisée.',
        en: 'When you use the “Start + mic” mode, the microphone may be enabled only while the timer is running to listen for a potential shot. No audio is recorded or transmitted. Detection is indicative and may be imperfect depending on the range, environment, and firearm.',
        de: 'Wenn Sie den Modus „Start + Mikro“ verwenden, kann das Mikrofon nur während des Timers aktiviert werden, um einen möglichen Schuss zu erkennen. Es wird kein Audio aufgezeichnet oder übertragen. Die Erkennung ist indikativ und kann je nach Schießstand, Umgebung und Waffe ungenau sein.',
        it: 'Quando usi la modalità “Partenza + microfono”, il microfono può essere attivato solo mentre il timer è in esecuzione per ascoltare un eventuale sparo. Nessun audio viene registrato o trasmesso. Il rilevamento è indicativo e può essere impreciso a seconda del poligono, dell’ambiente e dell’arma.',
        es: 'Cuando usas el modo “Salida + micrófono”, el micrófono puede activarse solo mientras el temporizador está en marcha para escuchar un posible disparo. No se graba ni se transmite audio. La detección es orientativa y puede ser imperfecta según el campo, el entorno y el arma.',
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
fr: 'Timer de tir Pro',
en: 'Pro shooting timer',
de: 'Pro Schieß-Timer',
it: 'Timer di tiro Pro',
es: 'Temporizador de tiro Pro',
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
        fr: 'Export du carnet de tir',
        en: 'Logbook export',
        de: 'Schießbuch-Export',
        it: 'Export registro di tiro',
        es: 'Exportación cuaderno de tiro',
      );

  String get proBenefitLogbookExportSubtitle => _pick(
fr: 'Idéal pour imprimer son carnet de tir.',
en: 'Ideal for printing your shooting logbook.',
de: 'Ideal zum Ausdrucken deines Schießbuchs.',
it: 'Ideale per stampare il tuo registro di tiro.',
es: 'Ideal para imprimir tu cuaderno de tiro.',      );

  String get proBenefitUnlimitedDocumentsTitle => _pick(
fr: 'Ajout de documents illimité',
en: 'Unlimited document addition',
de: 'Unbegrenztes Hinzufügen von Dokumenten',
it: 'Aggiunta illimitata di documenti',
es: 'Adición ilimitada de documentos',
      );

  String get proBenefitUnlimitedSessionsSubtitle => _pick(
fr: 'Création de séances et matériel sans restriction.',
en: 'Unlimited sessions and equipment creation.',
de: 'Unbegrenzte Erstellung von Sitzungen und Ausrüstung.',
it: 'Creazione illimitata di sessioni e attrezzatura.',
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
fr: "Aide à l'identification d'incidents de tir.",
en: 'Assistance in identifying shooting incidents.',
de: 'Unterstützung bei der Identifizierung von Schießstörungen.',
it: 'Aiuto nell’identificazione degli incidenti di tiro.',
es: 'Ayuda para identificar incidentes de tiro.',
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
        fr: 'Rapport PDF complet de votre carnet de tir.',
        en: 'Full PDF report of your shooting logbook.',
        de: 'Vollständiger PDF‑Bericht deines Schießbuchs.',
        it: 'Genera un rapporto PDF strutturato.',
        es: 'Genera un informe PDF estructurado.',
      );

  String get proSubscriptionDisclaimer => _pick(
        fr:
            "L’abonnement est géré sur l’App Store / Play Store. Vous pouvez l’annuler à tout moment. En cas de fin, l’app revient automatiquement en mode gratuit (1 arme / 1 munition / 1 accessoire, 5 séances, 1 PDF par fiche).",
        en:
            'Subscription is managed in the App Store / Play Store. You can cancel at any time. If the subscription ends, the app automatically returns to free mode (1 weapon / 1 ammo / 1 accessory, 5 sessions, 1 PDF per item).',
        de:
            'Das Abo wird im App Store / Play Store verwaltet. Du kannst jederzeit kündigen. Wenn das Abo endet, wechselt die App automatisch in den Gratis-Modus zurück (1 Waffe / 1 Munition / 1 Zubehör, 5 Sitzungen, 1 PDF pro Karte).',
        it:
            "L’abbonamento si gestisce su App Store / Play Store. Puoi annullarlo in qualsiasi momento. Se termina, l’app torna automaticamente alla modalità gratuita (1 arma / 1 munizione / 1 accessorio, 5 sessioni, 1 PDF per scheda).",
        es:
            'La suscripción se gestiona en App Store / Play Store. Puedes cancelarla en cualquier momento. Si termina, la app vuelve automáticamente al modo gratuito (1 arma / 1 munición / 1 accesorio, 5 sesiones, 1 PDF por ficha).',
      );

  String get proActiveOnAccount => _pick(
        fr: 'Pro est actif sur ce compte.',
        en: 'Pro is active on this account.',
        de: 'Pro ist auf diesem Konto aktiv.',
        it: 'Pro è attivo su questo account.',
        es: 'Pro está activo en esta cuenta.',
      );

  String get proHeroUnlockTitle => _pick(
        fr: 'Débloque THOT Pro',
        en: 'Unlock THOT Pro',
        de: 'THOT Pro freischalten',
        it: 'Sblocca THOT Pro',
        es: 'Desbloquea THOT Pro',
      );

  String get proHeroUnlockSubtitle => _pick(
fr: 'Zéro limite.',
en: 'No limits.',
de: 'Keine Grenzen.',
it: 'Nessun limite.',
es: 'Sin límites.',
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

  String get settingsProfileEmailLabel => _pick(
        fr: 'Email',
        en: 'Email',
        de: 'E-Mail',
        it: 'Email',
        es: 'Correo electrónico',
      );

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
        fr:
            "THOT est votre carnet de tir numérique incontournable, offrant aux forces de l'ordre et aux tireurs sportifs une gestion intuitive et complète.",
        en:
            'THOT is your essential digital shooting logbook, offering law enforcement and sport shooters intuitive, complete management.',
        de:
            'THOT ist Ihr unverzichtbares digitales Schießbuch und bietet Polizei und Sportschützen eine intuitive und umfassende Verwaltung.',
        it:
            'THOT è il tuo registro di tiro digitale essenziale, che offre a forze dell\'ordine e tiratori sportivi una gestione intuitiva e completa.',
        es:
            'THOT es tu cuaderno de tiro digital imprescindible, que ofrece a las fuerzas del orden y tiradores deportivos una gestión intuitiva y completa.',
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
        de: 'Fügen Sie Ihre offiziellen Dokumente hinzu\n(Lizenzen, Genehmigungen usw.)',
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

  String get settingsAddDocument => _pick(
        fr: 'Nouveau document',
        en: 'New document',
        de: 'Neues Dokument',
        it: 'Nuovo documento',
        es: 'Nuevo documento',
      );

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

  String get settingsDocumentTypeWeaponPermit => _pick(
        fr: "Autorisation de port d'arme",
        en: 'Weapon carry permit',
        de: 'Waffentragegenehmigung',
        it: "Autorizzazione al porto d'armi",
        es: 'Permiso de porte de armas',
      );

  String get settingsDocumentTypeMedicalCertificate => _pick(
        fr: 'Certificat médical',
        en: 'Medical certificate',
        de: 'Ärztliches Attest',
        it: 'Certificato medico',
        es: 'Certificado médico',
      );

  String get settingsDocumentTypeOther => _pick(
        fr: 'Autre',
        en: 'Other',
        de: 'Andere',
        it: 'Altro',
        es: 'Otro',
      );
}
