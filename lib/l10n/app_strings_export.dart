part of 'app_strings.dart';

extension AppStringsExport on AppStrings {
  // --- Export & PDF Authentication ---

  String get exportNotebookTitle => _pick(
        fr: 'Exporter le carnet',
        en: 'Export notebook',
        de: 'Notizbuch exportieren',
        it: 'Esporta quaderno',
        es: 'Exportar cuaderno',
      );

  String get exportSectionsLabel => _pick(
        fr: 'Sections à inclure :',
        en: 'Sections to include:',
        de: 'Einzuschließende Abschnitte:',
        it: 'Sezioni da includere:',
        es: 'Secciones a incluir:',
      );

  String get exportPlatformsLabel => _pick(
        fr: 'Plateformes',
        en: 'Platforms',
        de: 'Plattformen',
        it: 'Piattaforme',
        es: 'Plataformas',
      );

  String get exportConsumablesLabel => _pick(
        fr: 'Consommables',
        en: 'Consumables',
        de: 'Verbrauchsmaterial',
        it: 'Consumabili',
        es: 'Consumibles',
      );

  String get exportEquipmentLabel => _pick(
        fr: 'Matériel',
        en: 'Equipment',
        de: 'Ausrüstung',
        it: 'Attrezzatura',
        es: 'Equipo',
      );

  String get exportSessionsLabel => _pick(
        fr: 'Sessions',
        en: 'Sessions',
        de: 'Sitzungen',
        it: 'Sessioni',
        es: 'Sesiones',
      );

  String get selectAllLabel => _pick(
        fr: 'Tout sélectionner',
        en: 'Select all',
        de: 'Alle auswählen',
        it: 'Seleziona tutto',
        es: 'Seleccionar todo',
      );

  String get selectAtLeastOneSection => _pick(
        fr: 'Sélectionnez au moins une section.',
        en: 'Select at least one section.',
        de: 'Wählen Sie mindestens einen Abschnitt aus.',
        it: 'Seleziona almeno una sezione.',
        es: 'Seleccione al menos una sección.',
      );

  String get pdfAuthBlockTitle => _pick(
        fr: 'Authentification du document',
        en: 'Document authentication',
        de: 'Dokumentenauthentifizierung',
        it: 'Autenticazione del documento',
        es: 'Autenticación del documento',
      );

  String get pdfAuthSerialLabel => _pick(
        fr: 'Numéro de série',
        en: 'Serial number',
        de: 'Seriennummer',
        it: 'Numero di serie',
        es: 'Número de serie',
      );

  String get pdfAuthHashLabel => _pick(
        fr: 'Empreinte SHA-256',
        en: 'SHA-256 fingerprint',
        de: 'SHA-256-Fingerabdruck',
        it: 'Impronta SHA-256',
        es: 'Huella SHA-256',
      );

  String get pdfAuthGeneratedOn => _pick(
        fr: 'Généré le',
        en: 'Generated on',
        de: 'Erzeugt am',
        it: 'Generato il',
        es: 'Generado el',
      );

  String get pdfAuthVerifyAt => _pick(
        fr: 'Vérifiable sur',
        en: 'Verifiable at',
        de: 'Überprüfbar unter',
        it: 'Verificabile su',
        es: 'Verificable en',
      );

  String get pdfFooterWatermark => _pick(
        fr: 'THOT — Document non-falsifiable',
        en: 'THOT — Non-tamperable document',
        de: 'THOT — Manipulationssicheres Dokument',
        it: 'THOT — Documento non falsificabile',
        es: 'THOT — Documento no falsificable',
      );

  String get pdfExportIncludeAuthOption => _pick(
        fr: 'Inclure l\'authentification du document',
        en: 'Include document authentication',
        de: 'Dokumentenauthentifizierung einschließen',
        it: 'Includere l\'autenticazione del documento',
        es: 'Incluir autenticación del documento',
      );

  String get pdfExportIncludeAuthDescription => _pick(
        fr: 'Ajoute un hash cryptographique vérifiable, recommandé pour usage administratif.',
        en: 'Adds a verifiable cryptographic hash, recommended for administrative use.',
        de: 'Fügt einen überprüfbaren kryptografischen Hash hinzu, empfohlen für die Verwaltung.',
        it: 'Aggiunge un hash crittografico verificabile, consigliato per uso amministrativo.',
        es: 'Añade un hash criptográfico verificable, recomendado para uso administrativo.',
      );

  // --- Text Export ---

  String get textExportTitle => _pick(
        fr: '📊 RAPPORT DE SESSION DE TIR',
        en: '📊 SHOOTING SESSION REPORT',
        de: '📊 SCHIEẞSITZUNGSBERICHT',
        it: '📊 RAPPORTO SESSIONE DI TIRO',
        es: '📊 INFORME DE SESIÓN DE TIRO',
      );

  String textExportType(String type) => _pick(
        fr: '🏷️  Type: $type',
        en: '🏷️  Type: $type',
        de: '🏷️  Typ: $type',
        it: '🏷️  Tipo: $type',
        es: '🏷️  Tipo: $type',
      );

  String get textExportWeatherHeader => _pick(
        fr: '🌤️  CONDITIONS MÉTÉOROLOGIQUES',
        en: '🌤️  WEATHER CONDITIONS',
        de: '🌤️  WETTERBEDINGUNGEN',
        it: '🌤️  CONDIZIONI METEO',
        es: '🌤️  CONDICIONES METEOROLÓGICAS',
      );

  String textExportTemperature(String v) => '🌡️  ${_pick(fr: 'Température', en: 'Temperature', de: 'Temperatur', it: 'Temperatura', es: 'Temperatura')}: $v';
  String textExportWind(String v) => '💨 ${_pick(fr: 'Vent', en: 'Wind', de: 'Wind', it: 'Vento', es: 'Viento')}: $v';
  String textExportHumidity(String v) => '💧 ${_pick(fr: 'Humidité', en: 'Humidity', de: 'Luftfeuchtigkeit', it: 'Umidità', es: 'Humedad')}: $v';
  String textExportPressure(String v) => '🔘 ${_pick(fr: 'Pression', en: 'Pressure', de: 'Druck', it: 'Pressione', es: 'Presión')}: $v';

  String get textExportStatsHeader => _pick(
        fr: '📈 STATISTIQUES GLOBALES',
        en: '📈 OVERALL STATISTICS',
        de: '📈 GESAMTSTATISTIKEN',
        it: '📈 STATISTICHE GLOBALI',
        es: '📈 ESTADÍSTICAS GLOBALES',
      );

  String textExportTotalShots(int n) => '🔫 ${_pick(fr: 'Total coups tirés', en: 'Total shots fired', de: 'Schüsse gesamt', it: 'Colpi totali sparati', es: 'Disparos totales')}: $n';

  String textExportAvgPrecision(String v) => '🎯 ${_pick(fr: 'Précision moyenne', en: 'Average accuracy', de: 'Durchschnittliche Genauigkeit', it: 'Precisione media', es: 'Precisión media')}: $v';

  String textExportExerciseCount(int n) => '📋 ${_pick(fr: "Nombre d\'exercices", en: 'Number of exercises', de: 'Anzahl Übungen', it: 'Numero di esercizi', es: 'Número de ejercicios')}: $n';

  String get textExportExercisesHeader => _pick(
        fr: '🎯 EXERCICES DÉTAILLÉS',
        en: '🎯 DETAILED EXERCISES',
        de: '🎯 ÜBUNGEN IM DETAIL',
        it: '🎯 ESERCIZI DETTAGLIATI',
        es: '🎯 EJERCICIOS DETALLADOS',
      );

  String textExportExerciseN(int n) => '▪️  ${_pick(fr: 'EXERCICE', en: 'EXERCISE', de: 'ÜBUNG', it: 'ESERCIZIO', es: 'EJERCICIO')} $n';

  String get textExportPlatformLabel => _pick(fr: 'Plateforme', en: 'Platform', de: 'Plattform', it: 'Piattaforma', es: 'Plataforma');
  String get textExportAmmoLabel => _pick(fr: 'Consommable', en: 'Consumable', de: 'Verbrauchsmaterial', it: 'Consumabile', es: 'Consumible');
  String get textExportEquipmentLabel => _pick(fr: 'Équipement', en: 'Equipment', de: 'Ausrüstung', it: 'Attrezzatura', es: 'Equipo');
  String get textExportTargetLabel => _pick(fr: 'Cible', en: 'Target', de: 'Ziel', it: 'Bersaglio', es: 'Objetivo');
  String get textExportDistanceLabel => _pick(fr: 'Distance', en: 'Distance', de: 'Entfernung', it: 'Distanza', es: 'Distancia');
  String get textExportShotsFiredLabel => _pick(fr: 'Coups tirés', en: 'Shots fired', de: 'Schüsse', it: 'Colpi sparati', es: 'Disparos');
  String get textExportPrecisionLabel => _pick(fr: 'Précision', en: 'Accuracy', de: 'Genauigkeit', it: 'Precisione', es: 'Precisión');
  String get textExportNotesLabel => _pick(fr: 'Notes', en: 'Notes', de: 'Notizen', it: 'Note', es: 'Notas');
  String get textExportNoNotes => _pick(fr: '(Sans observations)', en: '(No observations)', de: '(Keine Anmerkungen)', it: '(Senza osservazioni)', es: '(Sin observaciones)');
  String get textExportDetailedMode => _pick(fr: 'Mode: détaillé', en: 'Mode: detailed', de: 'Modus: detailliert', it: 'Modalità: dettagliata', es: 'Modo: detallado');

  String textExportStepShots(int n) => '$n ${_pick(fr: 'coups', en: 'shots', de: 'Schüsse', it: 'colpi', es: 'disparos')}';
  String textExportStepTarget(String t) => '${_pick(fr: 'cible', en: 'target', de: 'Ziel', it: 'bersaglio', es: 'objetivo')} $t';
  String textExportStepReload(String r) => '${_pick(fr: 'rechargement', en: 'reload', de: 'Nachladen', it: 'ricarica', es: 'recarga')} $r';
  String textExportStepTrigger(String t) => '${_pick(fr: 'déclencheur', en: 'trigger', de: 'Auslöser', it: 'innesco', es: 'disparador')} $t';
  String textExportStepTransition(String? from, String? to) => '${_pick(fr: 'de', en: 'from', de: 'von', it: 'da', es: 'de')} ${from ?? '—'} ${_pick(fr: 'vers', en: 'to', de: 'zu', it: 'a', es: 'a')} ${to ?? '—'}';

  String textExportAutoTotal(int n) => 'Total (AUTO): $n ${_pick(fr: 'coups', en: 'shots', de: 'Schüsse', it: 'colpi', es: 'disparos')}';
  String textExportAutoMaxDistance(int d) => '${_pick(fr: 'Distance max (AUTO)', en: 'Max distance (AUTO)', de: 'Max. Entfernung (AUTO)', it: 'Distanza max (AUTO)', es: 'Distancia máx (AUTO)')}: $d m';

  String get textExportFooter => _pick(
        fr: 'Généré par THOT - Carnet de Tir',
        en: 'Generated by THOT - Shooting Logbook',
        de: 'Erstellt von THOT - Schießbuch',
        it: 'Generato da THOT - Registro di Tiro',
        es: 'Generado por THOT - Cuaderno de Tiro',
      );
}
