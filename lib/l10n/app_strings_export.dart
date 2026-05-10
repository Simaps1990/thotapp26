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
}
