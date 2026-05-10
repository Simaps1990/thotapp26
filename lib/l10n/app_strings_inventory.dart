part of 'app_strings.dart';

extension AppStringsInventory on AppStrings {
  // --- Document Types ---
  String get documentTypeInvoice => _pick(fr: 'Facture', en: 'Invoice', de: 'Rechnung', it: 'Fattura', es: 'Factura');
  String get documentTypeRevision => _pick(fr: 'Révision', en: 'Revision', de: 'Revision', it: 'Revisione', es: 'Revisión');
  String get documentTypeMaintenance => _pick(fr: 'Entretien', en: 'Maintenance', de: 'Wartung', it: 'Manutenzione', es: 'Mantenimiento');
  String get documentTypeManual => _pick(fr: 'Manuel', en: 'Manual', de: 'Handbuch', it: 'Manuale', es: 'Manual');
  String get documentTypeWarranty => _pick(fr: 'Garantie', en: 'Warranty', de: 'Garantie', it: 'Garanzia', es: 'Garantía');
  String get documentTypeOther => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro');

  // --- Accessory Types ---
  String get accessoryTypeOptics => _pick(fr: 'Optiques', en: 'Optics', de: 'Optik', it: 'Ottiche', es: 'Óptica');
  String get accessoryTypeLights => _pick(fr: 'Lampes', en: 'Lights', de: 'Lampen', it: 'Luci', es: 'Luzes');
  String get accessoryTypeLasers => _pick(fr: 'Lasers', en: 'Lasers', de: 'Laser', it: 'Laser', es: 'Láseres');
  String get accessoryTypeHolsters => _pick(fr: 'Holsters', en: 'Holsters', de: 'Holster', it: 'Fondine', es: 'Fundas');
  String get accessoryTypeSlings => _pick(fr: 'Sangles', en: 'Slings', de: 'Schleifen', it: 'Imbracature', es: 'Correas');
  String get accessoryTypeMagazines => _pick(fr: 'Chargeurs', en: 'Magazines', de: 'Magazine', it: 'Caricatori', es: 'Cargadores');
  String get accessoryTypeMagazinePouches => _pick(fr: 'Porte-chargeurs', en: 'Magazine pouches', de: 'Magazintaschen', it: 'Portacaricatori', es: 'Portacargadores');
  String get accessoryTypeCleaning => _pick(fr: 'Nettoyage', en: 'Cleaning', de: 'Reinigung', it: 'Pulizia', es: 'Limpieza');
  String get accessoryTypeSuppressor => _pick(fr: 'SUPP', en: 'Suppressor', de: 'Schalldämpfer', it: 'Silenziatore', es: 'Silenciador');
  String get accessoryTypeCompensators => _pick(fr: 'Compensateurs', en: 'Compensators', de: 'Kompensatoren', it: 'Compensatori', es: 'Compensadores');
  String get accessoryTypeGrips => _pick(fr: 'Poignées', en: 'Grips', de: 'Griffe', it: 'Impugnature', es: 'Empuñaduras');
  String get accessoryTypeBipods => _pick(fr: 'Bipieds', en: 'Bipods', de: 'Zweibeine', it: 'Bipiedi', es: 'Bípodes');
  String get accessoryTypeMounts => _pick(fr: 'Montages', en: 'Mounts', de: 'Montagen', it: 'Montaggi', es: 'Montajes');
  String get accessoryTypeIronSights => _pick(fr: 'Visée mécanique', en: 'Iron sights', de: 'Kimme und Korn', it: 'Mirino meccanico', es: 'Mira mecánica');
  String get accessoryTypeStocks => _pick(fr: 'Crosses', en: 'Stocks', de: 'Schaft', it: 'Calcio', es: 'Culata');
  String get accessoryTypeTriggers => _pick(fr: 'Détentes', en: 'Triggers', de: 'Abzüge', it: 'Grilletti', es: 'Gatillos');
  String get accessoryTypeInternalParts => _pick(fr: 'Pièces internes', en: 'Internal parts', de: 'Innenteile', it: 'Parti interne', es: 'Piezas internas');
  String get accessoryTypeTransport => _pick(fr: 'Transport', en: 'Transport', de: 'Transport', it: 'Trasporto', es: 'Transporte');
  String get accessoryTypeSafety => _pick(fr: 'Sécurité', en: 'Safety', de: 'Sicherheit', it: 'Sicurezza', es: 'Seguridad');
  String get accessoryTypeProtection => _pick(fr: 'Protections', en: 'Protection', de: 'Schutz', it: 'Protezione', es: 'Protección');
  String get accessoryTypeChronographs => _pick(fr: 'Chronographes', en: 'Chronographs', de: 'Chronographen', it: 'Cronografi', es: 'Cronógrafos');
  String get accessoryTypeTimers => _pick(fr: 'Timers', en: 'Timers', de: 'Timer', it: 'Timer', es: 'Temporizadores');
  String get accessoryTypeTargets => _pick(fr: 'Cibles', en: 'Targets', de: 'Ziele', it: 'Bersagli', es: 'Blancos');
  String get accessoryTypeShootingStands => _pick(fr: "Supports d'appui", en: 'Support stands', de: 'Auflagen', it: "Supporti d'appoggio", es: 'Soportes de apoyo');
  String get accessoryTypeTools => _pick(fr: 'Outils', en: 'Tools', de: 'Werkzeuge', it: 'Attrezzi', es: 'Herramientas');
  String get accessoryTypeMisc => _pick(fr: 'Divers', en: 'Misc', de: 'Sonstiges', it: 'Varie', es: 'Varios');

  String get docExpiryExpiresOn => _pick(
        fr: 'Expire le',
        en: 'Expires on',
        de: 'Läuft ab am',
        it: 'Scade il',
        es: 'Caduca el',
      );

  String get docExpiryNotifyHint => _pick(
        fr: 'Les rappels nécessitent l\'activation des notifications.',
        en: 'Reminders require notifications to be enabled.',
        de: 'Erinnerungen erfordern die Aktivierung von Benachrichtigungen.',
        it: 'I promemoria richiedono l\'attivazione delle notifiche.',
        es: 'Los recordatorios requieren activar las notificaciones.',
      );

  // --- Platform Types ---
  String get platformTypePA => _pick(fr: 'PA', en: 'PA', de: 'PA', it: 'PA', es: 'PA');
  String get platformTypeRevolver => _pick(fr: 'Révolver', en: 'Revolver', de: 'Revolver', it: 'Revolver', es: 'Revólver');
  String get platformTypePM => _pick(fr: 'PM', en: 'PM', de: 'PM', it: 'PM', es: 'PM');
  String get platformTypeFA => _pick(fr: 'FA', en: 'FA', de: 'FA', it: 'FA', es: 'FA');
  String get platformTypeFM => _pick(fr: 'FM', en: 'FM', de: 'FM', it: 'FM', es: 'FM');
  String get platformTypeCarbine => _pick(fr: 'Carabine', en: 'Carbine', de: 'Karabiner', it: 'Carabina', es: 'Carabina');
  String get platformTypeFAP => _pick(fr: 'FAP', en: 'FAP', de: 'FAP', it: 'FAP', es: 'FAP');
  String get platformTypeShotgun => _pick(fr: 'Fusil de chasse', en: 'Shotgun', de: 'Flinte', it: 'Fucile da caccia', es: 'Escopeta');
  String get platformTypeFP => _pick(fr: 'FP', en: 'FP', de: 'FP', it: 'FP', es: 'FP');
  String get platformTypeOther => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro');

  // --- Ammo Projectile Types ---
  String get ammoTypeFMJ => _pick(fr: 'FMJ', en: 'FMJ', de: 'FMJ', it: 'FMJ', es: 'FMJ');
  String get ammoTypeTMJ => _pick(fr: 'TMJ', en: 'TMJ', de: 'TMJ', it: 'TMJ', es: 'TMJ');
  String get ammoTypeJHP => _pick(fr: 'Pointe creuse (JHP)', en: 'Hollow point (JHP)', de: 'Hohlspitze (JHP)', it: 'Punta cava (JHP)', es: 'Punta hueca (JHP)');
  String get ammoTypeGoldDot => _pick(fr: 'Gold Dot', en: 'Gold Dot', de: 'Gold Dot', it: 'Gold Dot', es: 'Gold Dot');
  String get ammoTypeSoftPoint => _pick(fr: 'Soft Point', en: 'Soft Point', de: 'Soft Point', it: 'Soft Point', es: 'Soft Point');
  String get ammoTypeLead => _pick(fr: 'Plomb', en: 'Lead', de: 'Blei', it: 'Piombo', es: 'Plomo');
  String get ammoTypeSubsonic => _pick(fr: 'Subsonique', en: 'Subsonic', de: 'Subsonisch', it: 'Subsonico', es: 'Subsónico');
  String get ammoTypeTracer => _pick(fr: 'Traçante', en: 'Tracer', de: 'Leuchtspur', it: 'Tracciante', es: 'Trazador');

  // --- Cost Tracking ---
  String get ammoUnitPriceLabel => _pick(
        fr: 'Prix unitaire (€)',
        en: 'Unit price (€)',
        de: 'Stückpreis (€)',
        it: 'Prezzo unitario (€)',
        es: 'Precio unitario (€)',
      );

  String get ammoUnitPriceHint => _pick(
        fr: 'Optionnel — prix par cartouche',
        en: 'Optional — price per round',
        de: 'Optional — Preis pro Patrone',
        it: 'Opzionale — prezzo per cartuccia',
        es: 'Opcional — precio por cartucho',
      );

  String get costDashboardTitle => _pick(
        fr: 'Coût des séances',
        en: 'Session costs',
        de: 'Sitzungskosten',
        it: 'Costi delle sessioni',
        es: 'Costos de sesiones',
      );

  String get costDashboardYearlyTotal => _pick(
        fr: 'Coût des 12 derniers mois',
        en: 'Last 12 months cost',
        de: 'Kosten der letzten 12 Monate',
        it: 'Costo ultimi 12 mesi',
        es: 'Costo últimos 12 meses',
      );

  String get costSessionEstimate => _pick(
        fr: 'Coût estimé',
        en: 'Estimated cost',
        de: 'Geschätzte Kosten',
        it: 'Costo stimato',
        es: 'Costo estimado',
      );

  String get ammoTotalShotCost => _pick(
        fr: 'Coût total tiré',
        en: 'Total fired cost',
        de: 'Gesamtkosten verschossen',
        it: 'Costo totale sparato',
        es: 'Costo total disparado',
      );

  String get ammoRemainingStockCost => _pick(
        fr: 'Coût stock restant',
        en: 'Remaining stock cost',
        de: 'Restbestandskosten',
        it: 'Costo stock rimanente',
        es: 'Costo stock restante',
      );

  // --- Link/Unlink ---
  String get linkAccessories => _pick(fr: 'Lier des accessoires', en: 'Link accessories', de: 'Zubehör verknüpfen', it: 'Collega accessori', es: 'Vincular accesorios');
  String get linkPlatforms => _pick(fr: 'Lier des plateformes', en: 'Link platforms', de: 'Plattformen verknüpfen', it: 'Collega piattaforme', es: 'Vincular plataformas');
  String get unlinkConfirm => _pick(fr: 'Êtes-vous sûr de vouloir délier cet élément ?', en: 'Are you sure you want to unlink this item?', de: 'Möchten Sie dieses Element wirklich entknüpfen?', it: 'Sei sicuro di voler scollegare questo elemento?', es: '¿Estás seguro de que quieres desvincular este elemento?');
String get associateAccessory => _pick(
  fr: 'Associer',
  en: 'Link',
  de: 'Verknüpfen',
  it: 'Associare',
  es: 'Vincular',
);
String get associatePlatform => _pick(
  fr: 'Associer',
  en: 'Link',
  de: 'Verknüpfen',
  it: 'Associare',
  es: 'Vincular',
);

  // --- Templates ---
  String get templatesLabel => _pick(fr: 'Modèles', en: 'Templates', de: 'Vorlagen', it: 'Modelli', es: 'Plantillas');

  // --- Category Constants ---
  String get categoryPlatform => _pick(fr: 'PLATEFORME', en: 'PLATFORMS', de: 'PLATTFORMEN', it: 'PIATTAFORME', es: 'PLATAFORMAS');
  String get categoryConsumable => _pick(fr: 'CONSOMMABLES', en: 'CONSUMABLES', de: 'VERBRAUCHSMATERIAL', it: 'CONSUMABILI', es: 'CONSUMIBLES');
  String get categoryAccessory => _pick(fr: 'ACCESSOIRES', en: 'ACCESSORIES', de: 'ZUBEHÖR', it: 'ACCESSORI', es: 'ACCESORIOS');

  // --- Error Messages ---
  String get citySearchUnavailable => _pick(fr: 'Recherche de ville indisponible', en: 'City search unavailable', de: 'Stadtsuche nicht verfügbar', it: 'Ricerca città non disponibile', es: 'Búsqueda de ciudad no disponible');
}
