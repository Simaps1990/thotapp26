part of 'app_strings.dart';

extension AppStringsMaterialTypes on AppStrings {
  // ═══════════════════════════════════════
  // PLATEFORMES
  // ═══════════════════════════════════════

  String get platformTypePistol => _pick(
    fr: 'PA',       // Pistolet Automatique
    en: 'Pistol',
    de: 'Pistole',
    it: 'Pistola',
    es: 'Pistola',
  );

  String get platformTypeRevolver => _pick(
    fr: 'Révolver', en: 'Revolver', de: 'Revolver',
    it: 'Revolver',  es: 'Revólver',
  );

  String get platformTypeSmg => _pick(
    fr: 'PM',       // Pistolet-Mitrailleur
    en: 'SMG',      // Submachine Gun — NATO/IPSC
    de: 'MP',       // Maschinenpistole
    it: 'SMG',       es: 'SMG',
  );

  String get platformTypeAr => _pick(
    fr: 'FA',       // Fusil d'Assaut
    en: 'AR',       // Auto Rifle — neutre, pro
    de: 'SG',       // Sturmgewehr
    it: 'AR',        es: 'AR',
  );

  String get platformTypeMg => _pick(
    fr: 'FM',       // Fusil Mitrailleur
    en: 'MG',       // international
    de: 'MG',       // Maschinengewehr
    it: 'MG',        es: 'MG',
  );

  String get platformTypeCarbineCanonical => _pick(
    fr: 'Carabine', en: 'Carbine', de: 'Karabiner',
    it: 'Carabina',  es: 'Carabina',
  );

  String get platformTypePr => _pick(
    fr: 'FAP',      // Fusil à Précision
    en: 'PR',       // Precision Rifle — PRS competitions
    de: 'PGW',      // Präzisionsgewehr
    it: 'PR',        es: 'PR',
  );

  String get platformTypeShotgunCanonical => _pick(
    fr: 'Fusil de chasse', en: 'Shotgun', de: 'Schrotflinte',
    it: 'Fucile da caccia', es: 'Escopeta',
  );

  String get platformTypeLr => _pick(
    fr: 'FP',       // Fusil de Précision longue portée
    en: 'LR',       // Long Range — ELR/PRS
    de: 'LR',
    it: 'LR',        es: 'LR',
  );

  /// Convertit une clé canonique PlatformTypeKey en libellé localisé.
  String platformTypeLabel(String key) => switch (key) {
    'pistol'   => platformTypePistol,
    'revolver' => platformTypeRevolver,
    'smg'      => platformTypeSmg,
    'ar'       => platformTypeAr,
    'mg'       => platformTypeMg,
    'carbine'  => platformTypeCarbineCanonical,
    'pr'       => platformTypePr,
    'shotgun'  => platformTypeShotgunCanonical,
    'lr'       => platformTypeLr,
    _          => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro'),
  };

  // ═══════════════════════════════════════
  // MUNITIONS
  // Acronymes internationaux (FMJ, TMJ, JHP, Gold Dot) identiques dans les 5 langues
  // ═══════════════════════════════════════

  String get ammoTypeFmj     => 'FMJ';
  String get ammoTypeTmj     => 'TMJ';
  String get ammoTypeJhp     => _pick(
    fr: 'Pointe creuse (JHP)',
    en: 'Hollow point (JHP)',
    de: 'Hohlspitze (JHP)',
    it: 'Punta cava (JHP)',
    es: 'Punta hueca (JHP)',
  );
  String get ammoTypeGoldDot => 'Gold Dot';

  String get ammoTypeSoftPoint => _pick(
    fr: 'Soft Point', en: 'Soft Point', de: 'Teilmantel',
    it: 'Punta molle', es: 'Punta blanda',
  );
  String get ammoTypeLead => _pick(
    fr: 'Plomb', en: 'Lead', de: 'Blei', it: 'Piombo', es: 'Plomo',
  );
  String get ammoTypeSubsonic => _pick(
    fr: 'Subsonique', en: 'Subsonic', de: 'Subsonisch',
    it: 'Subsonico', es: 'Subsónico',
  );
  String get ammoTypeTracer => _pick(
    fr: 'Traçante', en: 'Tracer', de: 'Leuchtspur',
    it: 'Tracciante', es: 'Trazadora',
  );

  String ammoTypeLabel(String key) => switch (key) {
    'fmj'        => ammoTypeFmj,
    'tmj'        => ammoTypeTmj,
    'jhp'        => ammoTypeJhp,
    'gold_dot'   => ammoTypeGoldDot,
    'soft_point' => ammoTypeSoftPoint,
    'lead'       => ammoTypeLead,
    'subsonic'   => ammoTypeSubsonic,
    'tracer'     => ammoTypeTracer,
    _            => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro'),
  };

  // ═══════════════════════════════════════
  // ACCESSOIRES — les getters individuels existent DÉJÀ dans app_strings_inventory.dart
  // Ajouter UNIQUEMENT la méthode de résolution par clé canonique.
  // ═══════════════════════════════════════

  /// Résout une clé canonique AccessoryTypeKey vers le getter existant.
  /// Les getters individuels (accessoryTypeOptics, etc.) sont dans app_strings_inventory.dart.
  String accessoryTypeLabel(String key) => switch (key) {
    'optics'         => accessoryTypeOptics,
    'lights'         => accessoryTypeLights,
    'lasers'         => accessoryTypeLasers,
    'holsters'       => accessoryTypeHolsters,
    'slings'         => accessoryTypeSlings,
    'magazines'      => accessoryTypeMagazines,
    'mag_pouches'    => accessoryTypeMagazinePouches,
    'cleaning'       => accessoryTypeCleaning,
    'suppressor'     => accessoryTypeSuppressor,
    'compensators'   => accessoryTypeCompensators,
    'grips'          => accessoryTypeGrips,
    'bipods'         => accessoryTypeBipods,
    'mounts'         => accessoryTypeMounts,
    'iron_sights'    => accessoryTypeIronSights,
    'stocks'         => accessoryTypeStocks,
    'triggers'       => accessoryTypeTriggers,
    'internal_parts' => accessoryTypeInternalParts,
    'transport'      => accessoryTypeTransport,
    'security'       => accessoryTypeSafety,
    'protections'    => accessoryTypeProtection,
    'chronographs'   => accessoryTypeChronographs,
    'timers'         => accessoryTypeTimers,
    'targets'        => accessoryTypeTargets,
    'shooting_rests' => accessoryTypeShootingStands,
    'tools'          => accessoryTypeTools,
    _                => accessoryTypeMisc,
  };

  // ═══════════════════════════════════════
  // DOCUMENTS
  // ═══════════════════════════════════════

  String get documentTypeInvoiceCanonical  => _pick(fr: 'Facture',  en: 'Invoice',        de: 'Rechnung',          it: 'Fattura',   es: 'Factura');
  String get documentTypeServiceCanonical  => _pick(fr: 'Révision', en: 'Service Record', de: 'Wartungsprotokoll', it: 'Revisione', es: 'Revisión');
  String get documentTypeManualCanonical   => _pick(fr: 'Manuel',   en: 'Manual',         de: 'Handbuch',          it: 'Manuale',   es: 'Manual');
  String get documentTypeWarrantyCanonical => _pick(fr: 'Garantie', en: 'Warranty',       de: 'Garantie',          it: 'Garanzia',  es: 'Garantía');

  String documentTypeLabel(String key) => switch (key) {
    'invoice'  => documentTypeInvoiceCanonical,
    'service'  => documentTypeServiceCanonical,
    'manual'   => documentTypeManualCanonical,
    'warranty' => documentTypeWarrantyCanonical,
    _          => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro'),
  };
}
