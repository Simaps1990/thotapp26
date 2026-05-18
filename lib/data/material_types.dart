/// Clés canoniques stockées en base. STABLES et IMMUABLES.
/// Les labels localisés sont dans app_strings_material_types.dart.
abstract final class PlatformTypeKey {
  static const String pistol   = 'pistol';
  static const String revolver = 'revolver';
  static const String smg      = 'smg';
  static const String ar       = 'ar';
  static const String mg       = 'mg';
  static const String carbine  = 'carbine';
  static const String pr       = 'pr';
  static const String shotgun  = 'shotgun';
  static const String lr       = 'lr';
  static const String other    = 'other';

  static const List<String> all = [
    pistol, revolver, smg, ar, mg, carbine, pr, shotgun, lr, other,
  ];
}

abstract final class AmmoTypeKey {
  static const String fmj       = 'fmj';
  static const String tmj       = 'tmj';
  static const String jhp       = 'jhp';
  static const String goldDot   = 'gold_dot';
  static const String softPoint = 'soft_point';
  static const String lead      = 'lead';
  static const String subsonic  = 'subsonic';
  static const String tracer    = 'tracer';
  static const String other     = 'other';

  static const List<String> all = [
    fmj, tmj, jhp, goldDot, softPoint, lead, subsonic, tracer, other,
  ];
}

abstract final class AccessoryTypeKey {
  static const String optics        = 'optics';
  static const String lights        = 'lights';
  static const String lasers        = 'lasers';
  static const String holsters      = 'holsters';
  static const String slings        = 'slings';
  static const String magazines     = 'magazines';
  static const String magPouches    = 'mag_pouches';
  static const String cleaning      = 'cleaning';
  static const String suppressor    = 'suppressor';
  static const String compensators  = 'compensators';
  static const String grips         = 'grips';
  static const String bipods        = 'bipods';
  static const String mounts        = 'mounts';
  static const String ironSights    = 'iron_sights';
  static const String stocks        = 'stocks';
  static const String triggers      = 'triggers';
  static const String internalParts = 'internal_parts';
  static const String transport     = 'transport';
  static const String security      = 'security';
  static const String protections   = 'protections';
  static const String chronographs  = 'chronographs';
  static const String timers        = 'timers';
  static const String targets       = 'targets';
  static const String shootingRests = 'shooting_rests';
  static const String tools         = 'tools';
  static const String other         = 'other';

  static const List<String> all = [
    optics, lights, lasers, holsters, slings, magazines, magPouches,
    cleaning, suppressor, compensators, grips, bipods, mounts, ironSights,
    stocks, triggers, internalParts, transport, security, protections,
    chronographs, timers, targets, shootingRests, tools, other,
  ];

  /// Accessoires qui activent la section maintenance dans item_detail_screen.
  static const Set<String> maintenanceEnabled = {
    suppressor, compensators, triggers, internalParts,
  };

  /// Accessoires qui activent le suivi d'usure.
  static const Set<String> wearEnabled = {
    optics, lights, lasers, suppressor, compensators, mounts, triggers,
    internalParts,
  };

  /// Accessoires qui activent le suivi de propreté.
  static const Set<String> cleanlinessEnabled = {
    suppressor, compensators,
  };

  /// Accessoires qui activent le suivi de batterie.
  static const Set<String> batteryEnabled = {
    optics, lights, lasers, chronographs, timers,
  };
}

abstract final class DocumentTypeKey {
  static const String invoice  = 'invoice';
  static const String service  = 'service';
  static const String manual   = 'manual';
  static const String warranty = 'warranty';
  static const String other    = 'other';

  static const List<String> all = [invoice, service, manual, warranty, other];
}

/// Clés canoniques pour les documents utilisateur (Permis, licences, certificats).
abstract final class UserDocumentTypeKey {
  static const String huntingPermit       = 'hunting_permit';
  static const String fftLicense          = 'fft_license';
  static const String idCard              = 'id_card';
  static const String platformPermit      = 'platform_permit';
  static const String medicalCertificate  = 'medical_certificate';
  static const String other               = 'other';

  static const List<String> all = [
    huntingPermit,
    fftLicense,
    idCard,
    platformPermit,
    medicalCertificate,
    other,
  ];
}

/// Migration FR legacy → clé canonique.
abstract final class MaterialTypeMigration {
  static const Map<String, String> platform = {
    'PA': 'pistol',
    'Pistolet semi-automatique': 'pistol',
    'Révolver': 'revolver',
    'PM': 'smg',
    'FA': 'ar',
    'FM': 'mg',
    'Carabine': 'carbine',
    'FAP': 'pr',
    'Fusil de chasse': 'shotgun',
    'FP': 'lr',
    'Autre': 'other',
  };

  static const Map<String, String> ammo = {
    'FMJ': 'fmj',
    'TMJ': 'tmj',
    'Pointe creuse (JHP)': 'jhp',
    'Gold Dot': 'gold_dot',
    'Soft Point': 'soft_point',
    'Plomb': 'lead',
    'Subsonique': 'subsonic',
    'Traçante': 'tracer',
    'Autre': 'other',
  };

  static const Map<String, String> accessory = {
    'Optiques': 'optics',
    'Lampes': 'lights',
    'Lasers': 'lasers',
    'Holsters': 'holsters',
    'Sangles': 'slings',
    'Chargeurs': 'magazines',
    'Porte-chargeurs': 'mag_pouches',
    'Nettoyage': 'cleaning',
    'SUPP': 'suppressor',
    'Compensateurs': 'compensators',
    'Poignées': 'grips',
    'Bipieds': 'bipods',
    'Montages': 'mounts',
    'Visée mécanique': 'iron_sights',
    'Crosses': 'stocks',
    'Détentes': 'triggers',
    'Pièces internes': 'internal_parts',
    'Transport': 'transport',
    'Sécurité': 'security',
    'Protections': 'protections',
    'Chronographes': 'chronographs',
    'Timers': 'timers',
    'Cibles': 'targets',
    'Supports de tir': 'shooting_rests',
    'Outils': 'tools',
    'Divers': 'other',
  };

  static const Map<String, String> document = {
    'Facture': 'invoice',
    'Révision': 'service',
    'Entretien': 'service',
    'Manuel': 'manual',
    'Garantie': 'warranty',
    'Autre': 'other',
  };

  /// Migration legacy (toutes langues) → clé canonique UserDocument.
  static const Map<String, String> userDocument = {
    'Permis de chasse': 'hunting_permit',
    'Hunting permit': 'hunting_permit',
    'Jagdschein': 'hunting_permit',
    'Permesso di caccia': 'hunting_permit',
    'Permiso de caza': 'hunting_permit',
    'Licence FFT': 'fft_license',
    'FFT license': 'fft_license',
    'FFT-Lizenz': 'fft_license',
    'Licenza FFT': 'fft_license',
    'Licencia FFT': 'fft_license',
    "Carte d'identité": 'id_card',
    'ID card': 'id_card',
    'Personalausweis': 'id_card',
    "Carta d'identità": 'id_card',
    'Documento de identidad': 'id_card',
    'Autorisation de port de plateforme': 'platform_permit',
    'Platform carry permit': 'platform_permit',
    'Konfigurationsmitführungsgenehmigung': 'platform_permit',
    'Autorizzazione al porto di configurazione': 'platform_permit',
    'Permiso de porte de configuración': 'platform_permit',
    'Certificat médical': 'medical_certificate',
    'Medical certificate': 'medical_certificate',
    'Ärztliches Attest': 'medical_certificate',
    'Certificato medico': 'medical_certificate',
    'Certificado médico': 'medical_certificate',
    'Autre': 'other',
    'Other': 'other',
    'Andere': 'other',
    'Altro': 'other',
    'Otro': 'other',
  };

  /// Résout une valeur stockée vers sa clé canonique.
  static String resolve(
    String stored,
    Map<String, String> migrationMap,
    List<String> canonicalList, {
    String fallback = 'other',
  }) {
    if (canonicalList.contains(stored)) return stored;
    return migrationMap[stored] ?? fallback;
  }
}
