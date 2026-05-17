part of 'app_strings.dart';

extension AppStringsHomeScreen on AppStrings {
  // --- Home screen ---

  String get statisticsPageTitle => _pick(
    fr: 'STATISTIQUES',
    en: 'STATISTICS',
    de: 'STATISTIKEN',
    it: 'STATISTICHE',
    es: 'ESTADÍSTICAS',
  );

  String get statisticsPageSubtitle => _pick(
    fr: 'VUE GLOBALE',
    en: 'OVERVIEW',
    de: 'GESAMTANSICHT',
    it: 'PANORAMICA',
    es: 'VISTA GENERAL',
  );

  String get statisticsGlobalSummaryTitle => _pick(
    fr: 'RÉSUMÉ GLOBAL',
    en: 'GLOBAL SUMMARY',
    de: 'GESAMTZUSAMMENFASSUNG',
    it: 'RIEPILOGO GENERALE',
    es: 'RESUMEN GLOBAL',
  );

  String get statisticsMyEquipmentTitle => _pick(
    fr: 'MON MATERIEL',
    en: 'MY EQUIPMENT',
    de: 'MEINE AUSRÜSTUNG',
    it: 'LA MIA ATTREZZATURA',
    es: 'MI EQUIPO',
  );

  String get statisticsSessionsLabel => _pick(
    fr: 'Sessions',
    en: 'Sessions',
    de: 'Sitzungen',
    it: 'Sessioni',
    es: 'Sesiones',
  );

  String get statisticsShotsFiredLabel => _pick(
    fr: 'Coups tirés',
    en: 'Rounds',
    de: 'Schüsse',
    it: 'Colpi sparati',
    es: 'Disparos',
  );

  String get statisticsPlatformsLabel => _pick(
    fr: 'Plateformes',
    en: 'Platforms',
    de: 'Plattformen',
    it: 'Piattaforme',
    es: 'Plataformas',
  );

  String get statisticsAmmosLabel => _pick(
    fr: 'Consommables',
    en: 'Consumables',
    de: 'Verbrauchsmaterial',
    it: 'Consumabili',
    es: 'Consumibles',
  );

  String get statisticsAccessoriesLabel => _pick(
    fr: 'Accessoires',
    en: 'Accessories',
    de: 'Zubehör',
    it: 'Accessori',
    es: 'Accesorios',
  );

  String get statisticsShotsPerSessionLabel => _pick(
    fr: 'Cps / session',
    en: 'Shots / sess.',
    de: 'Sch. / Serie',
    it: 'Colpi / sess.',
    es: 'Disp. / sesión',
  );

  String get statisticsPrecisionTitle => _pick(
    fr: 'PRÉCISION',
    en: 'PRECISION',
    de: 'PRÄZISION',
    it: 'PRECISIONE',
    es: 'PRECISIÓN',
  );

  String get statisticsAveragePrecisionLabel => _pick(
    fr: 'Précision moyenne',
    en: 'Average precision',
    de: 'Durchschnittliche Präzision',
    it: 'Precisione media',
    es: 'Precisión media',
  );

  String get statisticsPerfectSessionsLabel => _pick(
    fr: 'Sessions à 100%',
    en: '100% sessions',
    de: '100%-Sitzungen',
    it: 'Sessioni al 100%',
    es: 'Sesiones al 100%',
  );

  String get statisticsBestSessionLabel => _pick(
    fr: 'Meilleure session',
    en: 'Best session',
    de: 'Beste Sitzung',
    it: 'Migliore sessione',
    es: 'Mejor sesión',
  );

  String get statisticsBestSessionDateLabel => _pick(
    fr: 'Date meilleure',
    en: 'Best date',
    de: 'Bestes Datum',
    it: 'Data migliore',
    es: 'Mejor fecha',
  );

  String get statisticsRhythmTitle =>
      _pick(fr: 'RYTHME', en: 'PACE', de: 'RHYTHMUS', it: 'RITMO', es: 'RITMO');

  String get statisticsThisWeekLabel => _pick(
    fr: 'Cette semaine',
    en: 'This week',
    de: 'Diese Woche',
    it: 'Questa settimana',
    es: 'Esta semana',
  );

  String get statisticsThisMonthLabel => _pick(
    fr: 'Ce mois',
    en: 'This month',
    de: 'Diesen Monat',
    it: 'Questo mese',
    es: 'Este mes',
  );

  String get statisticsExercisesPerSessionLabel => _pick(
    fr: 'Exercices / session',
    en: 'Exercises / session',
    de: 'Übungen / Sitzung',
    it: 'Esercizi / sessione',
    es: 'Ejercicios / sesión',
  );

  String get statisticsSessionsWithPrecisionLabel => _pick(
    fr: 'Sessions avec précision',
    en: 'Sessions with precision',
    de: 'Sitzungen mit Präzision',
    it: 'Sessioni con precisione',
    es: 'Sesiones con precisión',
  );

  String get statisticsMaintenanceTitle => _pick(
    fr: 'MAINTENANCE',
    en: 'MAINTENANCE',
    de: 'WARTUNG',
    it: 'MANUTENZIONE',
    es: 'MANTENIMIENTO',
  );

  String get statisticsCleaningsLabel => _pick(
    fr: 'Entretiens',
    en: 'Cleanings',
    de: 'Reinigungen',
    it: 'Pulizie',
    es: 'Limpiezas',
  );

  String get statisticsRevisionsLabel => _pick(
    fr: 'Révisions',
    en: 'Revisions',
    de: 'Revisionen',
    it: 'Revisioni',
    es: 'Revisiones',
  );

  String get statisticsClosestRevisionPlatformLabel => _pick(
    fr: 'Plateforme la plus proche d\'une révision',
    en: 'Platform closest to revision',
    de: 'Plattform am nächsten an einer Revision',
    it: 'Piattaforma più vicina alla revisione',
    es: 'Plataforma más cercana a revisión',
  );

  String get statisticsClosestCleaningPlatformLabel => _pick(
    fr: 'Plateforme la plus proche d\'un entretien',
    en: 'Platform closest to cleaning',
    de: 'Plattform am nächsten an einer Reinigung',
    it: 'Piattaforma più vicina alla pulizia',
    es: 'Plataforma más cercana al mantenimiento',
  );

  String get statisticsSmartIndicatorsTitle => _pick(
    fr: 'INDICATEURS INTELLIGENTS',
    en: 'SMART INDICATORS',
    de: 'INTELLIGENTE INDIKATOREN',
    it: 'INDICATORI INTELLIGENTI',
    es: 'INDICADORES INTELIGENTES',
  );

  String get statisticsMostUsedPlatformLabel => _pick(
    fr: 'Plateforme la plus utilisée',
    en: 'Most used platform',
    de: 'Am häufigsten verwendete Plattform',
    it: 'Piattaforma più usata',
    es: 'Plataforma más usada',
  );

  String get statisticsMostCriticalAmmoLabel => _pick(
    fr: 'Consommable le plus critique',
    en: 'Most critical ammo',
    de: 'Kritischstes Verbrauchsmaterial',
    it: 'Consumabile più critico',
    es: 'Consumible más crítico',
  );

  String get statisticsLongestSessionLabel => _pick(
    fr: 'Session la plus dense',
    en: 'Most intense session',
    de: 'Intensivste Sitzung',
    it: 'Sessione più intensa',
    es: 'Sesión más intensa',
  );

  String get statisticsLastSessionLabel => _pick(
    fr: 'Dernière session',
    en: 'Last session',
    de: 'Letzte Sitzung',
    it: 'Ultima sessione',
    es: 'Última sesión',
  );

  String get statisticsRegularityLabel => _pick(
    fr: 'Régularité',
    en: 'Regularity',
    de: 'Regelmäßigkeit',
    it: 'Regolarità',
    es: 'Regularidad',
  );

  String get statisticsSessionsStabilityLabel => _pick(
    fr: 'Stabilité des séances',
    en: 'Session stability',
    de: 'Stabilität der Sitzungen',
    it: 'Stabilità delle sessioni',
    es: 'Estabilidad de las sesiones',
  );

  String get statisticsTrendStableLabel => _pick(
    fr: 'Stable',
    en: 'Stable',
    de: 'Stabil',
    it: 'Stabile',
    es: 'Estable',
  );

  String statisticsTrendPointsLabel(String points) => _pick(
    fr: '$points pts',
    en: '$points pts',
    de: '$points Pkt',
    it: '$points pti',
    es: '$points pts',
  );

  String statisticsRegularityScoreValue(int score) => _pick(
    fr: 'Régularité $score/100',
    en: 'Regularity $score/100',
    de: 'Regelmäßigkeit $score/100',
    it: 'Regolarità $score/100',
    es: 'Regularidad $score/100',
  );

  String get statisticsRecentPaceTitle => _pick(
    fr: 'Cadence récente',
    en: 'Recent pace',
    de: 'Aktueller Rhythmus',
    it: 'Ritmo recente',
    es: 'Ritmo reciente',
  );

  String get statisticsSessionsPerWeekLabel => _pick(
    fr: 'Séances par semaine',
    en: 'Sessions per week',
    de: 'Sitzungen pro Woche',
    it: 'Sessioni per settimana',
    es: 'Sesiones por semana',
  );

  String get statisticsPrecisionChartEmptyLabel => _pick(
    fr: 'Ajoute des séances avec précision pour afficher la courbe',
    en: 'Add sessions with precision to display the chart',
    de: 'Füge Sitzungen mit Präzision hinzu, um die Kurve anzuzeigen',
    it: 'Aggiungi sessioni con precisione per visualizzare il grafico',
    es: 'Añade sesiones con precisión para mostrar la curva',
  );

  String get statisticsRhythmChartEmptyLabel => _pick(
    fr: 'Aucune activité récente',
    en: 'No recent activity',
    de: 'Keine aktuelle Aktivität',
    it: 'Nessuna attività recente',
    es: 'Sin actividad reciente',
  );

  String statisticsActivityTooltipValue(
    String label,
    int sessions,
    int shots,
  ) => _pick(
    fr: '$label\n$sessions séance(s)\n$shots coups',
    en: '$label\n$sessions session(s)\n$shots impacts',
    de: '$label\n$sessions Sitzung(en)\n$shots Treffer',
    it: '$label\n$sessions sessione/i\n$shots impatti',
    es: '$label\n$sessions sesión(es)\n$shots impactos',
  );

  String get statisticsMaintenanceOverviewTitle => _pick(
    fr: 'Vue maintenance',
    en: 'Maintenance overview',
    de: 'Wartungsübersicht',
    it: 'Panoramica manutenzione',
    es: 'Vista de mantenimiento',
  );

  String get statisticsMaintenanceOverviewSubtitle => _pick(
    fr: 'Pilotage entretien et révision',
    en: 'Cleaning and revision tracking',
    de: 'Steuerung von Reinigung und Revision',
    it: 'Monitoraggio pulizia e revisione',
    es: 'Seguimiento de limpieza y revisión',
  );

  String get statisticsTypeDistributionLabel => _pick(
    fr: 'Répartition des types',
    en: 'Type distribution',
    de: 'Verteilung nach Typ',
    it: 'Distribuzione per tipo',
    es: 'Distribución por tipo',
  );

  String get statisticsTopPlatformsTitle => _pick(
    fr: 'Top plateformes',
    en: 'Top platforms',
    de: 'Top-Plattformen',
    it: 'Top piattaforme',
    es: 'Top plataformas',
  );

  String get statisticsPlatformVolumeLabel => _pick(
    fr: 'Volume par plateforme',
    en: 'Volume by platform',
    de: 'Volumen pro Plattform',
    it: 'Volume per piattaforma',
    es: 'Volumen por plataforma',
  );

  String get statisticsNoPlatformsToAnalyzeLabel => _pick(
    fr: 'Aucune plateforme à analyser',
    en: 'No platform to analyze',
    de: 'Keine Plattform zu analysieren',
    it: 'Nessuna piattaforma da analizzare',
    es: 'Ninguna plataforma para analizar',
  );

  String get statisticsTypesShortLabel =>
      _pick(fr: 'Types', en: 'Types', de: 'Typen', it: 'Tipi', es: 'Tipos');

  String statisticsSmartIndicatorShotsValue(int shots) => _pick(
    fr: '$shots ${shots > 1 ? 'coups' : 'coup'}',
    en: '$shots ${shots == 1 ? 'impact' : 'impacts'}',
    de: '$shots ${shots == 1 ? 'Treffer' : 'Treffer'}',
    it: '$shots ${shots == 1 ? 'impatto' : 'impatti'}',
    es: '$shots ${shots == 1 ? 'impacto' : 'impactos'}',
  );

  String statisticsSmartIndicatorAmmoValue(int remaining, int threshold) =>
      _pick(
        fr: '$remaining restantes / seuil $threshold',
        en: '$remaining remaining / threshold $threshold',
        de: '$remaining verbleibend / Schwelle $threshold',
        it: '$remaining rimanenti / soglia $threshold',
        es: '$remaining restantes / umbral $threshold',
      );

  String get statisticsShotsChartTitle => _pick(
    fr: 'Nombre de tirs',
    en: 'Number of rounds',
    de: 'Anzahl der Schüsse',
    it: 'Numero di colpi',
    es: 'Número de disparos',
  );

  String get statisticsSessionsChartTitle => _pick(
    fr: 'Nombre de sessions',
    en: 'Number of sessions',
    de: 'Anzahl der Sitzungen',
    it: 'Numero di sessioni',
    es: 'Número de sesiones',
  );

  String get statisticsPlatformsByTypeTitle => _pick(
    fr: 'RÉPARTITION PAR TYPE DE PLATEFORME',
    en: 'PLATFORMS BY TYPE',
    de: 'PLATTFORMEN NACH TYP',
    it: 'PIATTAFORME PER TIPO',
    es: 'PLATAFORMAS POR TIPO',
  );

  String get legalInfoTitle => _pick(
    fr: 'Documents & informations légales',
    en: 'Legal documents & information',
    de: 'Rechtliche Dokumente & Informationen',
    it: 'Documenti e informazioni legali',
    es: 'Documentos e información legal',
  );

  String get legalInfoSubtitle => _pick(
    fr: "Tout le contenu ci-dessous est affiché directement dans l'application.",
    en: 'All content below is displayed directly in the application.',
    de: 'Der gesamte untenstehende Inhalt wird direkt in der Anwendung angezeigt.',
    it: "Tutto il contenuto seguente è visualizzato direttamente nell'applicazione.",
    es: 'Todo el contenido a continuación se muestra directamente en la aplicación.',
  );

  String get legalAboutTitle => _pick(
    fr: 'À propos de THOT',
    en: 'About THOT',
    de: 'Über THOT',
    it: 'Informazioni su THOT',
    es: 'Acerca de THOT',
  );

  String get legalPresentationTitle => _pick(
    fr: 'Présentation',
    en: 'Overview',
    de: 'Vorstellung',
    it: 'Presentazione',
    es: 'Presentación',
  );

  String get legalSupportTitle => _pick(
    fr: 'Support',
    en: 'Support',
    de: 'Support',
    it: 'Supporto',
    es: 'Soporte',
  );

  String get legalCguTitle => _pick(
    fr: 'Conditions Générales d’Utilisation (CGU)',
    en: 'Terms of Use',
    de: 'Nutzungsbedingungen',
    it: 'Condizioni generali di utilizzo',
    es: 'Condiciones generales de uso',
  );

  String get legalDiagnosticDisclaimerSectionTitle => _pick(
    fr: 'Diagnostic et sécurité',
    en: 'Diagnostic and safety',
    de: 'Diagnose und Sicherheit',
    it: 'Diagnostica e sicurezza',
    es: 'Diagnóstico y seguridad',
  );

  String get legalPrivacyTitle => _pick(
    fr: 'Politique de confidentialité',
    en: 'Privacy Policy',
    de: 'Datenschutzrichtlinie',
    it: 'Informativa sulla privacy',
    es: 'Política de privacidad',
  );

  String get legalMentionsTitle => _pick(
    fr: 'Mentions légales',
    en: 'Legal notice',
    de: 'Impressum',
    it: 'Note legali',
    es: 'Aviso legal',
  );

  String get legalChaptersLabel => _pick(
    fr: 'Chapitres',
    en: 'Chapters',
    de: 'Kapitel',
    it: 'Capitoli',
    es: 'Capítulos',
  );

  String get quickActionLabelMillieme => _pick(
    fr: 'Formule du millième',
    en: 'Mil formula',
    de: 'Mil-Formel',
    it: 'Formula del mil',
    es: 'Fórmula del mil',
  );

  String get quickActionLabelTraining => _pick(
    fr: 'Aides pédagogiques',
    en: 'Pedagogical aids',
    de: 'Pädagogische Hilfen',
    it: 'Aiuti pedagogici',
    es: 'Ayudas pedagógicas',
  );

  String get quickActionLabelVisualStimuli => _pick(
    fr: 'Stimulis visuels',
    en: 'Visual stimuli',
    de: 'Visuelle Stimuli',
    it: 'Stimoli visivi',
    es: 'Estímulos visuales',
  );

  String get quickActionLabelCognitiveStimuli => _pick(
    fr: 'Stimulis cognitifs',
    en: 'Cognitive stimuli',
    de: 'Kognitive Stimuli',
    it: 'Stimoli cognitivi',
    es: 'Estímulos cognitivos',
  );

  String get quickActionLabelReactionExercises => _pick(
    fr: 'Exercices',
    en: 'Exercises',
    de: 'Übungen',
    it: 'Esercizi',
    es: 'Ejercicios',
  );

  String get quickActionLabelCalculationTools => _pick(
    fr: 'Outils de calcul',
    en: 'Calculation tools',
    de: 'Berechnungstools',
    it: 'Strumenti di calcolo',
    es: 'Herramientas de cálculo',
  );

  String get quickActionLabelShootingTables => _pick(
    fr: 'Table de réglage',
    en: 'Adjustment table',
    de: 'Einstelltabelle',
    it: 'Tabella di regolazione',
    es: 'Tabla de ajuste',
  );

  String get quickActionLabelSaveConfigs => _pick(
    fr: 'Sauvegarder plateformes',
    en: 'Save platforms',
    de: 'Plattformen speichern',
    it: 'Salvare piattaforme',
    es: 'Guardar plataformas',
  );

  String get milliemeTitle => _pick(
    fr: 'Formule du millième',
    en: 'Mil formula',
    de: 'Mil-Formel',
    it: 'Formula del mil',
    es: 'Fórmula del mil',
  );

  String get milliemeSubtitle => _pick(
    fr: 'Calculez une distance ou un écart angulaire',
    en: 'Calculate a distance or an angular offset',
    de: 'Berechne eine Distanz oder eine Winkelabweichung',
    it: 'Calcola una distanza o uno scarto angolare',
    es: 'Calcula una distancia o una desviación angular',
  );

  String get milliemeLabelDistance => _pick(
    fr: 'Distance',
    en: 'Distance',
    de: 'Entfernung',
    it: 'Distanza',
    es: 'Distancia',
  );

  String get milliemeLabelHeight => _pick(
    fr: 'Hauteur',
    en: 'Height',
    de: 'Höhe',
    it: 'Altezza',
    es: 'Altura',
  );

  String get milliemeLabelMil =>
      _pick(fr: 'Mil', en: 'Mil', de: 'Mil', it: 'Mil', es: 'Mil');

  String get milliemeHelpText => _pick(
    fr: 'Entrez la distance et la hauteur pour obtenir la valeur en mil',
    en: 'Enter the distance and height to get the mil value',
    de: 'Geben Sie die Entfernung und Höhe ein, um den Mil-Wert zu erhalten',
    it: 'Inserisci la distanza e l\'altezza per ottenere il valore in mil',
    es: 'Ingrese la distancia y la altura para obtener el valor en mil',
  );

  String get milliemeResetLabel => _pick(
    fr: 'Réinitialiser',
    en: 'Reset',
    de: 'Zurücksetzen',
    it: 'Reimpostare',
    es: 'Reiniciar',
  );

  String get milliemeResetConfirmationLabel => _pick(
    fr: 'Voulez-vous réinitialiser les valeurs?',
    en: 'Do you want to reset the values?',
    de: 'Möchten Sie die Werte zurücksetzen?',
    it: 'Vuoi reimpostare i valori?',
    es: '¿Quiere reiniciar los valores?',
  );

  // --- Cost Statistics ---

  String get statisticsCostTitle =>
      _pick(fr: 'COÛTS', en: 'COSTS', de: 'KOSTEN', it: 'COSTI', es: 'COSTOS');

  String get statisticsMonthlyCostLabel => _pick(
    fr: 'Coût mensuel estimé',
    en: 'Estimated monthly cost',
    de: 'Geschätzte monatliche Kosten',
    it: 'Costo mensile stimato',
    es: 'Costo mensual estimado',
  );

  String get statisticsTotalCostLabel => _pick(
    fr: 'Coût total (6 mois)',
    en: 'Total cost (6 months)',
    de: 'Gesamtkosten (6 Monate)',
    it: 'Costo totale (6 mesi)',
    es: 'Costo total (6 meses)',
  );

  String get statisticsTopAmmoLabel => _pick(
    fr: 'Consommable le plus coûteux',
    en: 'Most expensive consumable',
    de: 'Teuerstes Verbrauchsmaterial',
    it: 'Consumabile più costoso',
    es: 'Consumible más costoso',
  );

  String get statisticsCostChartEmptyLabel => _pick(
    fr: 'Renseignez le prix unitaire de vos consommables pour activer le suivi',
    en: 'Set unit prices on your consumables to enable tracking',
    de: 'Setzen Sie Stückpreise bei Ihrem Verbrauchsmaterial, um die Verfolgung zu aktivieren',
    it: 'Imposta i prezzi unitari dei tuoi consumabili per attivare il monitoraggio',
    es: 'Establezca precios unitarios en sus consumibles para activar el seguimiento',
  );

  String get statisticsCostPerMonthSubtitle => _pick(
    fr: 'Évolution des dépenses',
    en: 'Spending trend',
    de: 'Ausgabenentwicklung',
    it: 'Andamento delle spese',
    es: 'Evolución de gastos',
  );
}
