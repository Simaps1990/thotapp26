part of 'app_strings.dart';

extension AppStringsHome on AppStrings {
  String get homeSubtitle => _pick(
        fr: 'CARNET DE TIR',
        en: 'SHOOTING LOGBOOK',
        de: 'SCHIESSBUCH',
        it: 'DIARIO DI TIRO',
        es: 'CUADERNO DE TIRO',
      );

  String get homeRewardsSectionTitle => _pick(
        fr: 'MES RÉCOMPENSES',
        en: 'MY REWARDS',
        de: 'MEINE BELOHNUNGEN',
        it: 'LE MIE RICOMPENSE',
        es: 'MIS RECOMPENSAS',
      );

  String get homeToolsSectionTitle => _pick(
        fr: 'MES OUTILS',
        en: 'MY TOOLS',
        de: 'MEINE WERKZEUGE',
        it: 'I MIEI STRUMENTI',
        es: 'MIS HERRAMIENTAS',
      );

  String get homeTrophiesTitle => _pick(
        fr: 'TROPHÉES & OBJECTIFS',
        en: 'TROPHIES & GOALS',
        de: 'TROPHÄEN & ZIELE',
        it: 'TROFEI & OBIETTIVI',
        es: 'TROFEOS Y OBJETIVOS',
      );

  String get homeTrophiesSubtitle => _pick(
        fr: 'OBJECTIFS & DÉBLOCAGES',
        en: 'GOALS & UNLOCKS',
        de: 'ZIELE & FREISCHALTUNGEN',
        it: 'OBIETTIVI & SBLOCCHI',
        es: 'OBJETIVOS Y DESBLOQUEOS',
      );

  String homeTrophiesUnlocked(int count) {
    if (_isFr) {
      return '$count trophée${count > 1 ? 's' : ''} débloqué${count > 1 ? 's' : ''}';
    }
    if (_isEn) {
      return '$count unlocked ${count == 1 ? 'trophy' : 'trophies'}';
    }
    if (_isDe) {
      return '$count freigeschaltete${count == 1 ? ' Trophäe' : ' Trophäen'}';
    }
    if (_isIt) {
      return '$count ${count == 1 ? 'trofeo sbloccato' : 'trofei sbloccati'}';
    }
    if (_isEs) {
      return '$count trofeo${count == 1 ? '' : 's'} desbloqueado${count == 1 ? '' : 's'}';
    }
    return '$count trophée${count > 1 ? 's' : ''} débloqué${count > 1 ? 's' : ''}';
  }

  String get homeTrophiesEmpty => _pick(
        fr: 'Aucun trophée débloqué pour le moment',
        en: 'No trophies unlocked yet',
        de: 'Noch keine Trophäen freigeschaltet',
        it: 'Nessun trofeo sbloccato al momento',
        es: 'Aún no hay trofeos desbloqueados',
      );

  String get achievementUnlockedToastTitle => _pick(
        fr: 'Trophée débloqué !',
        en: 'Trophy unlocked!',
        de: 'Trophäe freigeschaltet!',
        it: 'Trofeo sbloccato!',
        es: '¡Trofeo desbloqueado!',
      );

  String get homeDiagnosticTitle => _pick(
        fr: 'DIAGNOSTIQUE',
        en: 'DIAGNOSTIC TOOL',
        de: 'DIAGNOSEWERKZEUG',
        it: 'DIAGNOSTICA',
        es: 'DIAGNÓSTICO',
      );

  String get homeDiagnosticSubtitle => _pick(
        fr: 'Identifiez un incident de tir',
        en: 'Identify a firing issue',
        de: 'Schießstörung erkennen',
        it: 'Identifica un problema di tiro',
        es: 'Identifica una incidencia de tiro',
      );

  String get homeQuickAccessTitle => _pick(
        fr: 'ACCÈS RAPIDE',
        en: 'QUICK ACCESS',
        de: 'SCHNELLZUGRIFF',
        it: 'ACCESSO RAPIDO',
        es: 'ACCESO RÁPIDO',
      );

  String get homeMaintenanceTitle => _pick(
        fr: 'INDICATEURS CRITIQUES',
        en: 'CRITICAL INDICATORS',
        de: 'KRITISCHE INDIKATOREN',
        it: 'INDICATORI CRITICI',
        es: 'INDICADORES CRÍTICOS',
      );

  String get homeMaintenanceEmpty => _pick(
        fr: 'Aucun indicateur critique.',
        en: 'No critical indicator.',
        de: 'Kein kritischer Indikator.',
        it: 'Nessun indicatore critico.',
        es: 'Ningún indicador crítico.',
      );

  String get homeMaintenanceRevisionLabel => _pick(
        fr: 'Révision: ',
        en: 'Revision: ',
        de: 'Revision: ',
        it: 'Revisione: ',
        es: 'Revisión: ',
      );

  String get homeMaintenanceCleaningLabel => _pick(
        fr: 'Entretien: ',
        en: 'Cleaning: ',
        de: 'Reinigung: ',
        it: 'Pulizia: ',
        es: 'Limpieza: ',
      );

  String get homeMaintenanceStockLabel => _pick(
        fr: 'Stock: ',
        en: 'Stock: ',
        de: 'Bestand: ',
        it: 'Scorta: ',
        es: 'Stock: ',
      );

  String get homeLastSessionTitle => _pick(
        fr: 'DERNIÈRE SÉANCE',
        en: 'LAST SESSION',
        de: 'LETZTE SITZUNG',
        it: 'ULTIMA SESSIONE',
        es: 'ÚLTIMA SESIÓN',
      );

  String get homeSeeAll => _pick(
        fr: 'Voir tout',
        en: 'See all',
        de: 'Alle anzeigen',
        it: 'Vedi tutto',
        es: 'Ver todo',
      );

  String get homeStatsTitle => _pick(
        fr: 'MES STATISTIQUES',
        en: 'MY STATISTICS',
        de: 'MEINE STATISTIKEN',
        it: 'LE MIE STATISTICHE',
        es: 'MIS ESTADÍSTICAS',
      );

  String get homeStatSessions => _pick(
        fr: 'SÉANCES',
        en: 'SESSIONS',
        de: 'SITZUNGEN',
        it: 'SESSIONI',
        es: 'SESIONES',
      );

  String get homeStatShotsFired => _pick(
        fr: 'CPS TIRES',
        en: 'SHOTS FIRED',
        de: 'SCHÜSSE',
        it: 'COLPI SPARATI',
        es: 'DISPAROS',
      );

  String get homeStatWeapons => _pick(
        fr: 'ARMES',
        en: 'WEAPONS',
        de: 'WAFFEN',
        it: 'ARMI',
        es: 'ARMAS',
      );

  String get homeStatAvgPrecision => _pick(
        fr: 'PRÉC. MOY',
        en: 'AVG PREC.',
        de: 'DURCHSCHN. PRÄZ.',
        it: 'PREC. MEDIA',
        es: 'PREC. MEDIA',
      );

  String get homeStatPerfectSessions => _pick(
        fr: '100%',
        en: '100%',
        de: '100%',
        it: '100%',
        es: '100%',
      );

  String get homeStatBestSession => _pick(
        fr: 'MEILLEURE',
        en: 'BEST',
        de: 'BESTE',
        it: 'MIGLIORE',
        es: 'MEJOR',
      );

  String get homePrecisionTitle => _pick(
        fr: 'PRÉCISION DE TIR',
        en: 'SHOOTING PRECISION',
        de: 'TREFFSICHERHEIT',
        it: 'PRECISIONE DI TIRO',
        es: 'PRECISIÓN DE TIRO',
      );

  String get homePrecisionFilterTooltip => _pick(
        fr: 'Filtrer',
        en: 'Filter',
        de: 'Filtern',
        it: 'Filtra',
        es: 'Filtrar',
      );

  String get precisionFilterDayLong => _pick(
        fr: '1 jour',
        en: '1 day',
        de: '1 Tag',
        it: '1 giorno',
        es: '1 día',
      );

  String get precisionFilterWeekLong => _pick(
        fr: '1 semaine',
        en: '1 week',
        de: '1 Woche',
        it: '1 settimana',
        es: '1 semana',
      );

  String get precisionFilterMonthLong => _pick(
        fr: '1 mois',
        en: '1 month',
        de: '1 Monat',
        it: '1 mese',
        es: '1 mes',
      );

  String get precisionFilterYearLong => _pick(
        fr: '1 année',
        en: '1 year',
        de: '1 Jahr',
        it: '1 anno',
        es: '1 año',
      );

  String get precisionFilterTotalLong => _pick(
        fr: 'Total',
        en: 'Total',
        de: 'Gesamt',
        it: 'Totale',
        es: 'Total',
      );

  String get precisionFilterDayShort => _pick(
        fr: '1 JOUR',
        en: '1 DAY',
        de: '1 TAG',
        it: '1 GIORNO',
        es: '1 DÍA',
      );

  String get precisionFilterWeekShort => _pick(
        fr: '1 SEMAINE',
        en: '1 WEEK',
        de: '1 WOCHE',
        it: '1 SETT.',
        es: '1 SEMANA',
      );

  String get precisionFilterMonthShort => _pick(
        fr: '1 MOIS',
        en: '1 MONTH',
        de: '1 MONAT',
        it: '1 MESE',
        es: '1 MES',
      );

  String get precisionFilterYearShort => _pick(
        fr: '1 ANNÉE',
        en: '1 YEAR',
        de: '1 JAHR',
        it: '1 ANNO',
        es: '1 AÑO',
      );

  String get precisionFilterTotalShort => _pick(
        fr: 'TOTAL',
        en: 'TOTAL',
        de: 'GESAMT',
        it: 'TOTALE',
        es: 'TOTAL',
      );

  String get homePrecisionEmpty => _pick(
        fr: 'Aucune donnée de précision sur la période sélectionnée',
        en: 'No precision data for the selected period',
        de: 'Keine Präzisionsdaten für den gewählten Zeitraum',
        it: 'Nessun dato di precisione per il periodo selezionato',
        es: 'No hay datos de precisión para el período seleccionado',
      );

  String get homePrecisionAvgLabel => _pick(
        fr: 'MOY.',
        en: 'AVG',
        de: 'Ø',
        it: 'MEDIA',
        es: 'MED.',
      );

  String get homePrecisionMaxLabel => _pick(
        fr: 'MAX.',
        en: 'MAX.',
        de: 'MAX.',
        it: 'MAX.',
        es: 'MÁX.',
      );

  String get homeRemainingSuffix => _pick(
        fr: ' restant',
        en: ' remaining',
        de: ' übrig',
        it: ' rimanenti',
        es: ' restantes',
      );

  String get homeTimerTitle => _pick(
        fr: 'TIMER DE TIR',
        en: 'SHOOTING-TIMER',
        de: 'SCHIESS-TIMER',
        it: 'TIMER DI TIRO',
        es: 'TEMPORIZADOR DE TIRO',
      );

  String get homeTimerSubtitle => _pick(
        fr: 'Séquences de tir, bip, détection sonore',
        en: 'Shooting sequences, beep and sound detection',
        de: 'Schussserien, Signalton, Geräuscherkennung',
        it: 'Sequenze di tiro, bip, rilevamento sonoro',
        es: 'Secuencias de tiro, pitido, detección de sonido',
      );

  String get quickActionLabelSession => _pick(
        fr: 'Séance',
        en: 'Session',
        de: 'Sitzung',
        it: 'Sessione',
        es: 'Sesión',
      );

  String get quickActionLabelWeapon => _pick(
        fr: 'Arme',
        en: 'Weapon',
        de: 'Waffe',
        it: 'Arma',
        es: 'Arma',
      );

  String get quickActionLabelDiagnostic => _pick(
        fr: 'Diagnostique',
        en: 'Diagnostic',
        de: 'Diagnose',
        it: 'Diagnostica',
        es: 'Diagnóstico',
      );

  String get quickActionLabelAmmo => _pick(
        fr: 'Munition',
        en: 'Ammo',
        de: 'Munition',
        it: 'Munizione',
        es: 'Munición',
      );

  String get quickActionLabelAccessory => _pick(
        fr: 'Accessoire',
        en: 'Accessory',
        de: 'Zubehör',
        it: 'Accessorio',
        es: 'Accesorio',
      );

  String get quickActionLabelTimer => _pick(
        fr: 'Timer',
        en: 'Timer',
        de: 'Timer',
        it: 'Timer',
        es: 'Timer',
      );
// ── Notification panel ────────────────────────────────────────────────────

  String get notifPanelTitle => _pick(
fr: 'NOTIFICATIONS',
en: 'NOTIFICATIONS',
de: 'BENACHRICHTIGUNGEN',
it: 'NOTIFICHE',
es: 'NOTIFICACIONES',
      );

  String get notifPanelEmpty => _pick(
fr: 'Votre carnet de tir est à jour',
en: 'Your shooting logbook is up to date',
de: 'Ihr Schießbuch ist aktuell',
it: 'Il tuo registro di tiro è aggiornato',
es: 'Tu cuaderno de tiro está al día',
      );

  String get notifMarkRead => _pick(
        fr: 'Marquer comme lu',
        en: 'Mark as read',
        de: 'Als gelesen markieren',
        it: 'Segna come letto',
        es: 'Marcar como leído',
      );

  String get notifMarkAllRead => _pick(
        fr: 'Tout marquer comme lu',
        en: 'Mark all as read',
        de: 'Alle als gelesen markieren',
        it: 'Segna tutto come letto',
        es: 'Marcar todo como leído',
      );

  String get notifDelete => _pick(
        fr: 'Supprimer',
        en: 'Delete',
        de: 'Löschen',
        it: 'Elimina',
        es: 'Eliminar',
      );

  String get notifDeleteAll => _pick(
        fr: 'Tout supprimer',
        en: 'Delete all',
        de: 'Alle löschen',
        it: 'Elimina tutto',
        es: 'Eliminar todo',
      );

  String get notifTypeCleaning => _pick(
        fr: 'Entretien',
        en: 'Cleaning',
        de: 'Reinigung',
        it: 'Pulizia',
        es: 'Limpieza',
      );

  String get notifTypeRevision => _pick(
        fr: 'Révision',
        en: 'Revision',
        de: 'Revision',
        it: 'Revisione',
        es: 'Revisión',
      );

  String get notifViewWeapon => _pick(
        fr: 'Voir la fiche',
        en: 'View details',
        de: 'Fiche anzeigen',
        it: 'Vedi scheda',
        es: 'Ver ficha',
      );
// ── Alert types ───────────────────────────────────────────────────────────

  String get notifTypeWear => _pick(
        fr: 'Usure',
        en: 'Wear',
        de: 'Verschleiß',
        it: 'Usura',
        es: 'Desgaste',
      );

  String get notifTypeFouling => _pick(
        fr: 'Salissure',
        en: 'Fouling',
        de: 'Verschmutzung',
        it: 'Sporco',
        es: 'Suciedad',
      );

  String get notifTypeStock => _pick(
        fr: 'Stock bas',
        en: 'Low stock',
        de: 'Niedriger Bestand',
        it: 'Scorte basse',
        es: 'Stock bajo',
      );

  String get notifTypeDocument => _pick(
        fr: 'Document',
        en: 'Document',
        de: 'Dokument',
        it: 'Documento',
        es: 'Documento',
      );

  String get notifAlertWear => _pick(
        fr: 'Limite d\'usure atteinte',
        en: 'Wear limit reached',
        de: 'Verschleißgrenze erreicht',
        it: 'Limite di usura raggiunto',
        es: 'Límite de desgaste alcanzado',
      );

  String get notifAlertFouling => _pick(
        fr: 'Limite de salissure atteinte',
        en: 'Fouling limit reached',
        de: 'Verschmutzungsgrenze erreicht',
        it: 'Limite di sporco raggiunto',
        es: 'Límite de suciedad alcanzado',
      );

  String get notifAlertStock => _pick(
        fr: 'Limite de stock atteinte',
        en: 'Stock limit reached',
        de: 'Bestandsgrenze erreicht',
        it: 'Limite scorte raggiunto',
        es: 'Límite de stock alcanzado',
      );

  String get notifAlertDocument => _pick(
        fr: 'Document bientôt expiré',
        en: 'Document expiring soon',
        de: 'Dokument läuft bald ab',
        it: 'Documento in scadenza',
        es: 'Documento próximo a vencer',
      );

  String notifDocumentExpiresDays(int days) {
    if (_isFr) return 'Expire dans $days jour${days > 1 ? 's' : ''}';
    if (_isEn) return 'Expires in $days day${days == 1 ? '' : 's'}';
    if (_isDe) return 'Läuft in $days Tag${days == 1 ? '' : 'en'} ab';
    if (_isIt) return 'Scade tra $days giorno${days == 1 ? '' : 'i'}';
    if (_isEs) return 'Vence en $days día${days == 1 ? '' : 's'}';
    return 'Expires in $days day${days == 1 ? '' : 's'}';
  }

  String get notifDocumentExpiredToday => _pick(
        fr: 'Expire aujourd\'hui',
        en: 'Expires today',
        de: 'Läuft heute ab',
        it: 'Scade oggi',
        es: 'Vence hoy',
      );

  String get notifDocumentExpired => _pick(
        fr: 'Document expiré',
        en: 'Document expired',
        de: 'Dokument abgelaufen',
        it: 'Documento scaduto',
        es: 'Documento vencido',
      );

  // ── Document expiry form ──────────────────────────────────────────────────

  String get docExpiryDateLabel => _pick(
        fr: 'Date d\'expiration (optionnel)',
        en: 'Expiry date (optional)',
        de: 'Ablaufdatum (optional)',
        it: 'Data di scadenza (opzionale)',
        es: 'Fecha de vencimiento (opcional)',
      );

  String get docExpiryNotifyLabel => _pick(
        fr: 'Me notifier avant expiration',
        en: 'Notify me before expiry',
        de: 'Vor Ablauf benachrichtigen',
        it: 'Avvisami prima della scadenza',
        es: 'Notificarme antes del vencimiento',
      );

  String get docExpiryNotifyDaysLabel => _pick(
        fr: 'Jours avant expiration',
        en: 'Days before expiry',
        de: 'Tage vor Ablauf',
        it: 'Giorni prima della scadenza',
        es: 'Días antes del vencimiento',
      );

  String get docExpiryRemoveDate => _pick(
        fr: 'Supprimer la date',
        en: 'Remove date',
        de: 'Datum entfernen',
        it: 'Rimuovi data',
        es: 'Eliminar fecha',
      );
}
