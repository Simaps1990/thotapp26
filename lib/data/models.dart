import 'exercise_step.dart';

class ItemDocument {
  final String path;
  final String name;
  final String type;
  /// Optional expiry date for the document (e.g. permit, certificate).
  final DateTime? expiryDate;
  /// How many days before expiry to show the alert. 0 = no notification.
  final int notifyBeforeDays;

  const ItemDocument({
    required this.path,
    required this.name,
    required this.type,
    this.expiryDate,
    this.notifyBeforeDays = 0,
  });

  ItemDocument copyWith({
    String? path,
    String? name,
    String? type,
    DateTime? expiryDate,
    bool clearExpiryDate = false,
    int? notifyBeforeDays,
  }) => ItemDocument(
        path: path ?? this.path,
        name: name ?? this.name,
        type: type ?? this.type,
        expiryDate: clearExpiryDate ? null : (expiryDate ?? this.expiryDate),
        notifyBeforeDays: notifyBeforeDays ?? this.notifyBeforeDays,
      );

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'type': type,
        if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
        'notifyBeforeDays': notifyBeforeDays,
      };

  static ItemDocument fromJson(dynamic json) {
    if (json is String) {
      final inferredName = _inferFilename(json);
      return ItemDocument(path: json, name: inferredName, type: 'Document');
    }
    if (json is Map) {
      final path = (json['path'] ?? json['filePath'] ?? '') as String;
      final name = (json['name'] ?? '') as String;
      final type = (json['type'] ?? 'Document') as String;
      final expiryRaw = json['expiryDate'];
      final DateTime? expiryDate =
          expiryRaw != null ? DateTime.tryParse(expiryRaw as String) : null;
      final notifyBeforeDays = (json['notifyBeforeDays'] as int?) ?? 0;
      return ItemDocument(
        path: path,
        name: name.isEmpty ? _inferFilename(path) : name,
        type: type.isEmpty ? 'Document' : type,
        expiryDate: expiryDate,
        notifyBeforeDays: notifyBeforeDays,
      );
    }
    return const ItemDocument(path: '', name: 'Document', type: 'Document');
  }

  static String _inferFilename(String path) {
    if (path.isEmpty) return 'Document.pdf';
    final normalized = path.replaceAll('\\', '/');
    final last = normalized.split('/').last;
    return last.isEmpty ? 'Document.pdf' : last;
  }
}






class WeaponHistoryEntry {
  final String id;
  final DateTime date;
  final String type; // tir | entretien | revision
  final String label;
  final String? details;

  const WeaponHistoryEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.label,
    this.details,
  });

  WeaponHistoryEntry copyWith({
    String? id,
    DateTime? date,
    String? type,
    String? label,
    String? details,
  }) {
    return WeaponHistoryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      label: label ?? this.label,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type,
        'label': label,
        'details': details,
      };

  static WeaponHistoryEntry fromJson(dynamic json) {
    return WeaponHistoryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      label: json['label'] as String,
      details: json['details'] as String?,
    );
  }
}

class Weapon {
  final String id;
  final String name;
  final String model;
  /// Free-form user note shown in item details.
  final String comment;
  /// Domain type shown in inventory badges (e.g. Pistolet semi-auto, Fusil d'assaut...).
  final String type;
  final String caliber;
  final String serialNumber;
  final double weight;
  int totalRounds;
  DateTime lastCleaned;
  DateTime lastRevised;
  DateTime lastUsed;
  final String imageUrl;
  final String category; // 'Arme'
  final List<ItemDocument> documents;
  final List<WeaponHistoryEntry> history;
  final String? photoPath; // Path to item photo
  final bool isHidden;

  // Tracking options
  final bool trackWear;
  final bool trackCleanliness;
  final bool trackRounds;
  
  // Tracking thresholds
  final int cleaningRoundsThreshold; // Number of rounds before cleaning reminder
  final int wearRoundsThreshold; // Number of rounds for wear calculation

  /// Rounds counter snapshots to compute maintenance progress.
  ///
  /// `totalRounds` is the weapon absolute counter (initial counter + all sessions).
  /// We compute progress between the last maintenance snapshot and the configured threshold.
  int roundsAtLastCleaning;
  int roundsAtLastRevision;

  Weapon({
    required this.id,
    required this.name,
    required this.model,
    this.comment = '',
    this.type = 'Arme',
    required this.caliber,
    required this.serialNumber,
    required this.weight,
    required this.totalRounds,
    required this.lastCleaned,
    DateTime? lastRevised,
    required this.lastUsed,
    this.imageUrl = '',
    this.category = 'Arme',
    this.trackWear = true,
    this.trackCleanliness = true,
    this.trackRounds = true,
    this.cleaningRoundsThreshold = 500,
    this.wearRoundsThreshold = 10000,
    int? roundsAtLastCleaning,
    int? roundsAtLastRevision,
    this.documents = const [],
    this.history = const [],
    this.photoPath,
    this.isHidden = false,
  })  : lastRevised = lastRevised ?? lastCleaned,
        roundsAtLastCleaning = roundsAtLastCleaning ?? totalRounds,
        roundsAtLastRevision = roundsAtLastRevision ?? totalRounds;

  int get roundsSinceCleaning => (totalRounds - roundsAtLastCleaning).clamp(0, 1 << 30);

  int get roundsSinceRevision => (totalRounds - roundsAtLastRevision).clamp(0, 1 << 30);

  /// 0.0 = just cleaned, 1.0 = reached / exceeded cleaning threshold.
  double get cleaningProgress {
    if (!trackCleanliness) return 0.0;
    if (cleaningRoundsThreshold <= 0) return 0.0;
    return (roundsSinceCleaning / cleaningRoundsThreshold).clamp(0.0, 1.0);
  }

  /// 0.0 = just revised, 1.0 = reached / exceeded revision threshold.
  double get revisionProgress {
    if (!trackWear) return 0.0;
    if (wearRoundsThreshold <= 0) return 0.0;
    return (roundsSinceRevision / wearRoundsThreshold).clamp(0.0, 1.0);
  }

  Weapon copyWith({
    String? id,
    String? name,
    String? model,
    String? comment,
    String? type,
    String? caliber,
    String? serialNumber,
    double? weight,
    int? totalRounds,
    DateTime? lastCleaned,
    DateTime? lastRevised,
    DateTime? lastUsed,
    String? imageUrl,
    String? category,
    List<ItemDocument>? documents,
    List<WeaponHistoryEntry>? history,
    String? photoPath,
    bool? trackWear,
    bool? trackCleanliness,
    bool? trackRounds,
    int? cleaningRoundsThreshold,
    int? wearRoundsThreshold,
    int? roundsAtLastCleaning,
    int? roundsAtLastRevision,
    bool? isHidden,
  }) {
    return Weapon(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      comment: comment ?? this.comment,
      type: type ?? this.type,
      caliber: caliber ?? this.caliber,
      serialNumber: serialNumber ?? this.serialNumber,
      weight: weight ?? this.weight,
      totalRounds: totalRounds ?? this.totalRounds,
      lastCleaned: lastCleaned ?? this.lastCleaned,
      lastRevised: lastRevised ?? this.lastRevised,
      lastUsed: lastUsed ?? this.lastUsed,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      documents: documents ?? this.documents,
      history: history ?? this.history,
      photoPath: photoPath ?? this.photoPath,
      trackWear: trackWear ?? this.trackWear,
      trackCleanliness: trackCleanliness ?? this.trackCleanliness,
      trackRounds: trackRounds ?? this.trackRounds,
      cleaningRoundsThreshold: cleaningRoundsThreshold ?? this.cleaningRoundsThreshold,
      wearRoundsThreshold: wearRoundsThreshold ?? this.wearRoundsThreshold,
      roundsAtLastCleaning: roundsAtLastCleaning ?? this.roundsAtLastCleaning,
      roundsAtLastRevision: roundsAtLastRevision ?? this.roundsAtLastRevision,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

class Ammo {
  final String id;
  final String name;
  final String brand;
  final String caliber;
  /// Free-form user note shown in item details.
  final String comment;
  /// Projectile / bullet type (e.g. FMJ, Pointe creuse, Gold Dot...).
  ///
  /// Stored as free text so the dropdown can evolve over time.
  final String projectileType;
  int quantity;
  /// Initial stock quantity (used to compute stock criticality over time).
  ///
  /// This value should remain stable even when sessions consume ammo.
  ///
  /// When the user performs a **restock**, we treat the new post-restock
  /// quantity as the new “stock de départ” baseline.
  int initialQuantity;
  final String imageUrl;
  DateTime lastUsed;
  final List<ItemDocument> documents;
  final String? photoPath; // Path to item photo
  
  // Tracking options
  final bool trackStock;
  final int lowStockThreshold; // Alert when quantity drops below this
  final bool isHidden;

  Ammo({
    required this.id,
    required this.name,
    required this.brand,
    required this.caliber,
    this.comment = '',
    this.projectileType = '',
    required this.quantity,
    int? initialQuantity,
    this.imageUrl = '',
    required this.lastUsed,
    this.trackStock = true,
    this.lowStockThreshold = 50,
    this.documents = const [],
    this.photoPath,
    this.isHidden = false,
  }) : initialQuantity = initialQuantity ?? quantity;

  Ammo copyWith({
    String? id,
    String? name,
    String? brand,
    String? caliber,
    String? comment,
    String? projectileType,
    int? quantity,
    int? initialQuantity,
    String? imageUrl,
    DateTime? lastUsed,
    bool? trackStock,
    int? lowStockThreshold,
    List<ItemDocument>? documents,
    String? photoPath,
    bool? isHidden,
  }) {
    return Ammo(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      caliber: caliber ?? this.caliber,
      comment: comment ?? this.comment,
      projectileType: projectileType ?? this.projectileType,
      quantity: quantity ?? this.quantity,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUsed: lastUsed ?? this.lastUsed,
      trackStock: trackStock ?? this.trackStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      documents: documents ?? this.documents,
      photoPath: photoPath ?? this.photoPath,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

class Accessory {
  final String id;
  /// Display name (used across most UI).
  ///
  /// For new items we build it from `brand` + `model`.
  final String name;
  final String brand;
  final String model;
  /// Free-form user note shown in item details.
  final String comment;
  /// Domain type shown in inventory badges (e.g. Optique, Holster, Protection...).
  final String type;
  final String imageUrl;
  DateTime lastUsed;
  /// Total number of shots fired while this accessory was selected in exercises.
  ///
  /// This is used for accessory follow-up (it does NOT participate in critical indicators).
  int totalRounds;

  // Maintenance (weapon-like)
  DateTime lastCleaned;
  DateTime lastRevised;

  // Tracking options
  final bool trackWear;
  final bool trackCleanliness;

  // Tracking thresholds
  final int cleaningRoundsThreshold;
  final int wearRoundsThreshold;

  int roundsAtLastCleaning;
  int roundsAtLastRevision;

  DateTime? batteryChangedAt;
  final List<ItemDocument> documents;
  final String? photoPath; // Path to item photo
  final bool isHidden;
  
  // Tracking options
  final bool trackBattery;

  Accessory({
    required this.id,
    required this.name,
    this.brand = '',
    this.model = '',
    this.comment = '',
    required this.type,
    this.imageUrl = '',
    required this.lastUsed,
    this.totalRounds = 0,
    DateTime? lastCleaned,
    DateTime? lastRevised,
    this.trackWear = false,
    this.trackCleanliness = false,
    this.cleaningRoundsThreshold = 500,
    this.wearRoundsThreshold = 10000,
    int? roundsAtLastCleaning,
    int? roundsAtLastRevision,
    this.batteryChangedAt,
    this.trackBattery = false,
    this.documents = const [],
    this.photoPath,
    this.isHidden = false,
  })  : lastCleaned = lastCleaned ?? lastUsed,
        lastRevised = lastRevised ?? (lastCleaned ?? lastUsed),
        roundsAtLastCleaning = roundsAtLastCleaning ?? totalRounds,
        roundsAtLastRevision = roundsAtLastRevision ?? totalRounds;

  int get roundsSinceCleaning =>
      (totalRounds - roundsAtLastCleaning).clamp(0, 1 << 30);

  int get roundsSinceRevision =>
      (totalRounds - roundsAtLastRevision).clamp(0, 1 << 30);

  double get cleaningProgress {
    if (!trackCleanliness) return 0.0;
    if (cleaningRoundsThreshold <= 0) return 0.0;
    return (roundsSinceCleaning / cleaningRoundsThreshold).clamp(0.0, 1.0);
  }

  double get revisionProgress {
    if (!trackWear) return 0.0;
    if (wearRoundsThreshold <= 0) return 0.0;
    return (roundsSinceRevision / wearRoundsThreshold).clamp(0.0, 1.0);
  }

  Accessory copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? comment,
    String? type,
    String? imageUrl,
    DateTime? lastUsed,
    int? totalRounds,
    DateTime? lastCleaned,
    DateTime? lastRevised,
    bool? trackWear,
    bool? trackCleanliness,
    int? cleaningRoundsThreshold,
    int? wearRoundsThreshold,
    int? roundsAtLastCleaning,
    int? roundsAtLastRevision,
    DateTime? batteryChangedAt,
    bool? trackBattery,
    List<ItemDocument>? documents,
    String? photoPath,
    bool? isHidden,
  }) {
    return Accessory(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      comment: comment ?? this.comment,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUsed: lastUsed ?? this.lastUsed,
      totalRounds: totalRounds ?? this.totalRounds,
      lastCleaned: lastCleaned ?? this.lastCleaned,
      lastRevised: lastRevised ?? this.lastRevised,
      trackWear: trackWear ?? this.trackWear,
      trackCleanliness: trackCleanliness ?? this.trackCleanliness,
      cleaningRoundsThreshold:
          cleaningRoundsThreshold ?? this.cleaningRoundsThreshold,
      wearRoundsThreshold: wearRoundsThreshold ?? this.wearRoundsThreshold,
      roundsAtLastCleaning: roundsAtLastCleaning ?? this.roundsAtLastCleaning,
      roundsAtLastRevision: roundsAtLastRevision ?? this.roundsAtLastRevision,
      batteryChangedAt: batteryChangedAt ?? this.batteryChangedAt,
      trackBattery: trackBattery ?? this.trackBattery,
      documents: documents ?? this.documents,
      photoPath: photoPath ?? this.photoPath,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

class ExercisePhoto {
  final String id;
  final String name;
  final String path;

  const ExercisePhoto({
    required this.id,
    required this.name,
    required this.path,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
      };

  factory ExercisePhoto.fromJson(Map<String, dynamic> json) {
    return ExercisePhoto(
      id: json['id'] as String,
      name: (json['name'] ?? 'Photo') as String,
      path: json['path'] as String,
    );
  }

  ExercisePhoto copyWith({
    String? id,
    String? name,
    String? path,
  }) {
    return ExercisePhoto(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String weaponId;
  final String? weaponLabel;
  final String ammoId;
  final String? ammoLabel;
  final List<String> equipmentIds;
  final String? targetName;
  final List<ExercisePhoto> targetPhotos;
  final int shotsFired;
  final int distance;
  final double? precision;
  final bool precisionEnabled;
  final String observations;
  // null = mode simple (comportement actuel), non-null = mode détaillé par étapes.
  final List<ExerciseStep>? steps;

  Exercise({
    required this.id,
    this.name = '',
    required this.weaponId,
    this.weaponLabel,
    required this.ammoId,
    this.ammoLabel,
    this.equipmentIds = const [],
    this.targetName,
    this.targetPhotos = const [],
    required this.shotsFired,
    required this.distance,
    this.precision,
    this.precisionEnabled = true,
    this.observations = '',
    this.steps,
  });

  bool get isPrecisionCounted => precision != null && precisionEnabled;

  /// Total de coups calculés depuis les étapes en mode détaillé.
  /// Ne modifie pas le champ existant [shotsFired].
  int get detailedTotalShots {
    if (steps == null || steps!.isEmpty) return 0;
    return steps!
        .where((s) => s.type == StepType.tir && s.shots != null)
        .fold<int>(0, (sum, s) => sum + (s.shots ?? 0));
  }

  /// Distance maximale renseignée dans les étapes (en mètres), en mode détaillé.
  int? get detailedMaxDistance {
    if (steps == null || steps!.isEmpty) return null;
    final distances =
        steps!.map((s) => s.distanceM).where((d) => d != null).cast<int>();
    if (distances.isEmpty) return null;
    return distances.reduce((a, b) => a > b ? a : b);
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? weaponId,
    String? weaponLabel,
    String? ammoId,
    String? ammoLabel,
    List<String>? equipmentIds,
    String? targetName,
    List<ExercisePhoto>? targetPhotos,
    int? shotsFired,
    int? distance,
    double? precision,
    bool? precisionEnabled,
    String? observations,
    List<ExerciseStep>? steps,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      weaponId: weaponId ?? this.weaponId,
      weaponLabel: weaponLabel ?? this.weaponLabel,
      ammoId: ammoId ?? this.ammoId,
      ammoLabel: ammoLabel ?? this.ammoLabel,
      equipmentIds: equipmentIds ?? this.equipmentIds,
      targetName: targetName ?? this.targetName,
      targetPhotos: targetPhotos ?? this.targetPhotos,
      shotsFired: shotsFired ?? this.shotsFired,
      distance: distance ?? this.distance,
      precision: precision ?? this.precision,
      precisionEnabled: precisionEnabled ?? this.precisionEnabled,
      observations: observations ?? this.observations,
      steps: steps ?? this.steps,
    );
  }
}

class Session {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String? shootingDistance; // Pas de tir
  final String sessionType; // Personnel, Professionnel, Compétition
  final List<Exercise> exercises;
  
  // Weather (optional)
  final bool weatherEnabled;
  final String temperature;
  final String wind;
  final String humidity;
  final String pressure;

  /// Per-field enable flags.
  /// When a field is disabled by the user, the UI shows it struck-through and
  /// the value should be treated as “not applicable” for this session.
  final bool temperatureEnabled;
  final bool windEnabled;
  final bool humidityEnabled;
  final bool pressureEnabled;

  Session({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    this.shootingDistance,
    this.sessionType = 'Personnel',
    this.exercises = const [],
    this.weatherEnabled = false,
    this.temperature = '',
    this.wind = '',
    this.humidity = '',
    this.pressure = '',
    this.temperatureEnabled = true,
    this.windEnabled = true,
    this.humidityEnabled = true,
    this.pressureEnabled = true,
  });

  int get totalRounds => exercises.fold(0, (sum, ex) => sum + ex.shotsFired);

  /// True if at least one exercise has a precision value that is marked as
  /// counted (`precisionEnabled == true`).
  ///
  /// Use this for UI decisions (show/hide precision), instead of relying on
  /// `averagePrecision == 0`, because a real precision can legitimately be 0%.
  bool get hasCountedPrecision => exercises.any((e) => e.isPrecisionCounted);
  
  double get averagePrecision {
    if (exercises.isEmpty) return 0.0;
    final withPrecision = exercises.where((e) => e.isPrecisionCounted);
    if (withPrecision.isEmpty) return 0.0;
    double totalScore = withPrecision.fold(0.0, (sum, ex) => sum + (ex.precision ?? 0));
    return totalScore / withPrecision.length;
  }
  
  // Impact on weapons (count of shots per weapon)
  Map<String, int> get weaponImpact {
    Map<String, int> impact = {};
    for (var ex in exercises) {
      if (ex.weaponId == 'none' || ex.weaponId == 'borrowed') continue;
      impact[ex.weaponId] = (impact[ex.weaponId] ?? 0) + ex.shotsFired;
    }
    return impact;
  }
  
  // Impact on ammo (count of shots per ammo)
  Map<String, int> get ammoImpact {
    Map<String, int> impact = {};
    for (var ex in exercises) {
      if (ex.ammoId == 'none' || ex.ammoId == 'borrowed') continue;
      impact[ex.ammoId] = (impact[ex.ammoId] ?? 0) + ex.shotsFired;
    }
    return impact;
  }
  
  // Impact on equipment (count of shots per equipment)
  Map<String, int> get equipmentImpact {
    Map<String, int> impact = {};
    for (var ex in exercises) {
      for (final id in ex.equipmentIds) {
        impact[id] = (impact[id] ?? 0) + ex.shotsFired;
      }
    }
    return impact;
  }
}

class Diagnostic {
  final String id;
  final DateTime date;
  final String weaponId;
  final Map<String, dynamic> responses;
  final String finalDecision;
  final String summary;

  Diagnostic({
    required this.id,
    required this.date,
    required this.weaponId,
    required this.responses,
    required this.finalDecision,
    required this.summary,
  });
}

class UserDocument {
  final String id;
  final String name;
  final String type; // "Permis de chasse", "Licence FFT", "Carte identité", etc.
  final String filePath;
  final DateTime addedDate;
  /// Optional expiry date for the document (e.g. permit, licence).
  final DateTime? expiryDate;
  /// How many days before expiry to show the alert. 0 = no notification.
  final int notifyBeforeDays;

  UserDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    required this.addedDate,
    this.expiryDate,
    this.notifyBeforeDays = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'filePath': filePath,
        'addedDate': addedDate.toIso8601String(),
        if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
        'notifyBeforeDays': notifyBeforeDays,
      };

  static UserDocument fromJson(Map<String, dynamic> json) {
    final expiryRaw = json['expiryDate'];
    final DateTime? expiryDate =
        expiryRaw != null ? DateTime.tryParse(expiryRaw as String) : null;
    final notifyBeforeDays = (json['notifyBeforeDays'] as int?) ?? 0;

    return UserDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      filePath: json['filePath'] as String,
      addedDate: DateTime.parse(json['addedDate'] as String),
      expiryDate: expiryDate,
      notifyBeforeDays: notifyBeforeDays,
    );
  }
}
