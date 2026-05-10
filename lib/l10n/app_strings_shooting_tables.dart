part of 'app_strings.dart';

extension AppStringsShootingTables on AppStrings {
  // --- Shooting Tables Tool ---

  String get shootingTablesToolTitle => _pick(fr: 'TABLE DE RÉGLAGE', en: 'ADJUSTMENT TABLE', de: 'EINSTELLTABELLE', it: 'TABELLA DI REGOLAZIONE', es: 'TABLA DE AJUSTE');
  String get shootingTablesToolSubtitle => _pick(fr: 'Connaître les décalages ballistiques selon distances, configurations et climats.', en: 'Know ballistic offsets based on distances, setups, and climates.', de: 'Kenntnis ballistischer Abweichungen je nach Entfernung, Konfiguration und Klima.', it: 'Conoscere gli scostamenti balistici in base a distanze, configurazioni e climi.', es: 'Conocer los desvíos balísticos según distancias, configuraciones y climas.');
  String get shootingTablesListSubtitle => _pick(
        fr: 'Préenregistrez vos relevés selon les distances et corrections à appliquer, ou un accès rapide aux bonnes corrections en fonction d\'une distance. Idéal pour les plateformes à usage collectif.\n\nDOPE : mesure prise sur le terrain (non calculée), gage de réalisme et précision.',
        en: 'Pre-record your readings based on distances and corrections to apply, or quick access to the right corrections based on a distance. Ideal for collective-use platforms.\n\nDOPE: measurement taken in the field (not calculated), a guarantee of realism and precision.',
        de: 'Zeichnen Sie Ihre Messwerte basierend auf Entfernungen und Korrekturen auf, oder schneller Zugriff auf die richtigen Korrekturen basierend auf einer Entfernung. Ideal für Plattformen für gemeinsame Nutzung.\n\nDOPE: im Feld gemessene (nicht berechnete) Messung, Garantie für Realismus und Präzision.',
        it: 'Pre-registra i tuoi rilevamenti in base alle distanze e correzioni da applicare, o accesso rapido alle correzioni giuste in base a una distanza. Ideale per piattaforme ad uso collettivo.\n\nDOPE: misurazione presa sul campo (non calcolata), garanzia di realismo e precisione.',
        es: 'Pre-registre sus lecturas según distancias y correcciones a aplicar, o acceso rápido a las correcciones correctas según una distancia. Ideal para plataformas de uso colectivo.\n\nDOPE: medición tomada en el campo (no calculada), garantía de realismo y precisión.',
      );
  String get shootingTablesSearchHint => _pick(fr: 'Rechercher par plateforme, consommable ou distance…', en: 'Search by platform, consumable, or distance…', de: 'Nach Plattform, Verbrauchsmaterial oder Entfernung suchen…', it: 'Cerca per piattaforma, consumabile o distanza…', es: 'Buscar por plataforma, consumable o distancia…');
  String get shootingTableCreateButton => _pick(fr: 'Créer une table', en: 'Create table', de: 'Tabelle erstellen', it: 'Crea tabella', es: 'Crear tabla');
  String get shootingTableSortDate => _pick(fr: 'Date', en: 'Date', de: 'Datum', it: 'Data', es: 'Fecha');
  String get shootingTableSortName => _pick(fr: 'Nom', en: 'Name', de: 'Name', it: 'Nome', es: 'Nombre');
  String get shootingTableSortDistance => _pick(fr: 'Distance', en: 'Distance', de: 'Entfernung', it: 'Distanza', es: 'Distancia');
  String get shootingTableNoTable => _pick(fr: 'Aucune table enregistrée.', en: 'No table saved yet.', de: 'Noch keine Tabelle gespeichert.', it: 'Nessuna tabella salvata.', es: 'Aún no hay ninguna tabla guardada.');
  String get shootingTableNameLabel => _pick(fr: 'Nom de la table', en: 'Table name', de: 'Tabellenname', it: 'Nome tabella', es: 'Nombre de la tabla');
  String get shootingTableNameHint => _pick(fr: 'Ex: HK416 14.5" FMJ', en: 'E.g. HK416 14.5" FMJ', de: 'Z.B. HK416 14.5" FMJ', it: 'Es: HK416 14.5" FMJ', es: 'Ej: HK416 14.5" FMJ');
  String get shootingTableSaveButton => _pick(fr: 'ENREGISTRER', en: 'SAVE', de: 'SPEICHERN', it: 'SALVA', es: 'GUARDAR');
  String shootingTableDeleteTableConfirm(String tableName) => _pick(fr: 'Supprimer la table "$tableName" ?', en: 'Delete table "$tableName"?', de: 'Tabelle "$tableName" löschen?', it: 'Eliminare la tabella "$tableName"?', es: '¿Eliminar la tabla "$tableName"?');
  String get shootingTableContextTitle => _pick(fr: 'Contexte de la table', en: 'Table context', de: 'Tabellenkontext', it: 'Contesto tabella', es: 'Contexto de la tabla');
  String get shootingTableNoPlatform => _pick(fr: 'Aucune plateforme disponible.', en: 'No platform available.', de: 'Keine Plattform verfügbar.', it: 'Nessuna piattaforma disponibile.', es: 'No hay plataforma disponible.');
  String get shootingTablePlatformLabel => _pick(fr: 'Plateforme', en: 'Platform', de: 'Plattform', it: 'Piattaforma', es: 'Plataforma');
  String get shootingTableOtherOption => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro');
  String get shootingTableCustomPlatformHint => _pick(fr: 'Nom de la plateforme (ex: empruntée)', en: 'Platform name (e.g., borrowed)', de: 'Plattformname (z.B. geliehen)', it: 'Nome piattaforma (es. prestata)', es: 'Nombre de plataforma (ej. prestada)');
  String get shootingTableAmmoLabel => _pick(fr: 'Consommable', en: 'Ammo / consumable', de: 'Verbrauchsmaterial', it: 'Consumabile', es: 'Consumible');
  String get shootingTableNoAmmo => _pick(fr: 'Aucun consommable', en: 'No consumable', de: 'Kein Verbrauchsmaterial', it: 'Nessun consumabile', es: 'Sin consumible');
  String get shootingTableCustomAmmoHint => _pick(fr: 'Nom du consommable (ex: emprunté)', en: 'Ammo name (e.g., borrowed)', de: 'Verbrauchsmaterialname (z.B. geliehen)', it: 'Nome consumabile (es. prestato)', es: 'Nombre de consumible (ej. prestado)');
  String get shootingTableAccessoriesLabel => _pick(fr: 'Accessoires', en: 'Accessories', de: 'Zubehör', it: 'Accessori', es: 'Accesorios');
  String get shootingTableManageAccessories => _pick(fr: 'Gérer', en: 'Manage', de: 'Verwalten', it: 'Gestisci', es: 'Gestionar');
  String get shootingTableCustomAccessoryHint => _pick(fr: 'Ajouter un accessoire personnalisé', en: 'Add custom accessory', de: 'Benutzerdefiniertes Zubehör hinzufügen', it: 'Aggiungi accessorio personalizzato', es: 'Agregar accesorio personalizado');
  String get shootingTableAddAccessory => _pick(fr: 'Entrez le nom et appuyez sur Entrée', en: 'Enter name and press Enter', de: 'Namen eingeben und Enter drücken', it: 'Inserisci il nome e premi Invio', es: 'Ingrese el nombre y presione Enter');
  String get shootingTableAccessoryPickerTitle => _pick(fr: 'Sélectionner des accessoires', en: 'Select accessories', de: 'Zubehör auswählen', it: 'Seleziona accessori', es: 'Seleccionar accesorios');
  String get shootingTableNoAccessory => _pick(fr: 'Aucun accessoire sélectionné.', en: 'No accessory selected.', de: 'Kein Zubehör ausgewählt.', it: 'Nessun accessorio selezionato.', es: 'Ningún accesorio seleccionado.');
  String get shootingTableDistancesTitle => _pick(fr: 'Distances', en: 'Distances', de: 'Entfernungen', it: 'Distanze', es: 'Distancias');
  String get shootingTableNoDistance => _pick(fr: 'Aucune distance enregistrée.', en: 'No distance recorded.', de: 'Keine Entfernung erfasst.', it: 'Nessuna distanza registrata.', es: 'Ninguna distancia registrada.');
  String get shootingTableTargetTitle => _pick(fr: 'Cible', en: 'Target', de: 'Ziel', it: 'Bersaglio', es: 'Blanco');
  String get shootingTableModeActive => _pick(fr: 'Distance active', en: 'Active distance', de: 'Aktive Entfernung', it: 'Distanza attiva', es: 'Distancia activa');
  String get shootingTableModeAll => _pick(fr: 'Toutes', en: 'All', de: 'Alle', it: 'Tutte', es: 'Todas');
  String get shootingTableZoomTarget => _pick(fr: 'Cible', en: 'Target', de: 'Ziel', it: 'Bersaglio', es: 'Blanco');
String get shootingTableZoomFitAll => _pick(
  fr: 'Vue large',
  en: 'Wide view',
  de: 'Große Ansicht',
  it: 'Vista ampia',
  es: 'Vista amplia',
);
  String get shootingTableNoImpactInTarget => _pick(fr: 'Aucun impact en cible', en: 'No impact on target', de: 'Kein Treffer in der Scheibe', it: 'Nessun impatto nel bersaglio', es: 'Ningún impacto en el blanco');
  String get shootingTableAxisHint => _pick(fr: 'Convention : X négatif = gauche, X positif = droite • Y négatif = bas, Y positif = haut.', en: 'Convention: negative X = left, positive X = right • negative Y = down, positive Y = up.', de: 'Konvention: negatives X = links, positives X = rechts • negatives Y = unten, positives Y = oben.', it: 'Convenzione: X negativo = sinistra, X positivo = destra • Y negativo = basso, Y positivo = alto.', es: 'Convención: X negativo = izquierda, X positivo = derecha • Y negativo = abajo, Y positivo = arriba.');
String get shootingTableScaleFixedHint => _pick(
  fr: 'Échelle visuelle fixe : ±10 autour du centre.',
  en: 'Fixed visual scale: ±10 around the center.',
  de: 'Feste visuelle Skala: ±10 um die Mitte.',
  it: 'Scala visiva fissa: ±10 attorno al centro.',
  es: 'Escala visual fija: ±10 alrededor del centro.',
);
  String get shootingTableNoImpact => _pick(fr: 'Aucun impact à afficher.', en: 'No impact to display.', de: 'Kein Treffer anzuzeigen.', it: 'Nessun impatto da visualizzare.', es: 'No hay impactos para mostrar.');
  String get shootingTableImpactDetailsTitle => _pick(fr: 'Détail de l\'impact sélectionné', en: 'Selected impact details', de: 'Details des ausgewählten Treffers', it: 'Dettagli dell\'impatto selezionato', es: 'Detalle del impacto seleccionado');
  String get shootingTableEntriesTitle => _pick(fr: 'Relevés', en: 'Entries', de: 'Einträge', it: 'Rilievi', es: 'Registros');
  String get shootingTableNoEntry => _pick(fr: 'Aucun relevé enregistré.', en: 'No entry recorded.', de: 'Kein Eintrag erfasst.', it: 'Nessun rilievo registrato.', es: 'Ningún registro guardado.');
  String get shootingTableAddEntryTitle => _pick(fr: 'Ajouter un relevé', en: 'Add entry', de: 'Eintrag hinzufügen', it: 'Aggiungi rilievo', es: 'Añadir registro');
  String get shootingTableEditEntryTitle => _pick(fr: 'Modifier le relevé', en: 'Edit entry', de: 'Eintrag bearbeiten', it: 'Modifica rilievo', es: 'Editar registro');
  String get shootingTableDeleteEntryConfirm => _pick(fr: 'Supprimer ce relevé ?', en: 'Delete this entry?', de: 'Diesen Eintrag löschen?', it: 'Eliminare questo rilievo?', es: '¿Eliminar este registro?');
  String get shootingTableDistanceUnitLabel => _pick(fr: 'Unité de distance', en: 'Distance unit', de: 'Entfernungseinheit', it: 'Unità distanza', es: 'Unidad de distancia');
  String get shootingTableHorizontalLabel => _pick(fr: 'Écart horizontal (X)', en: 'Horizontal offset (X)', de: 'Horizontale Abweichung (X)', it: 'Scostamento orizzontale (X)', es: 'Desvío horizontal (X)');
  String get shootingTableVerticalLabel => _pick(fr: 'Écart vertical (Y)', en: 'Vertical offset (Y)', de: 'Vertikale Abweichung (Y)', it: 'Scostamento verticale (Y)', es: 'Desvío vertical (Y)');
  String get shootingTableOffsetUnitLabel => _pick(fr: 'Unité des écarts', en: 'Offset unit', de: 'Abweichungseinheit', it: 'Unità scostamenti', es: 'Unidad de desvío');
  String get shootingTableCorrectionLabel => _pick(fr: 'Correction retenue', en: 'Applied correction', de: 'Angewendete Korrektur', it: 'Correzione adottata', es: 'Corrección retenida');
  String get shootingTableDistanceHint => _pick(fr: 'ex: 25', en: 'e.g. 25', de: 'z. B. 25', it: 'es: 25', es: 'ej.: 25');
  String get shootingTableHorizontalHint => _pick(fr: 'ex: -2', en: 'e.g. -2', de: 'z. B. -2', it: 'es: -2', es: 'ej.: -2');
  String get shootingTableVerticalHint => _pick(fr: 'ex: +1', en: 'e.g. +1', de: 'z. B. +1', it: 'es: +1', es: 'ej.: +1');
  String get shootingTableDistanceUnitMeter => _pick(fr: 'm', en: 'm', de: 'm', it: 'm', es: 'm');
  String get shootingTableDistanceUnitYard => _pick(fr: 'yd', en: 'yd', de: 'yd', it: 'yd', es: 'yd');
  String get shootingTableOffsetUnitCm => _pick(fr: 'cm', en: 'cm', de: 'cm', it: 'cm', es: 'cm');
  String get shootingTableOffsetUnitInch => _pick(fr: 'pouce', en: 'inch', de: 'Zoll', it: 'pollice', es: 'pulgada');
}
