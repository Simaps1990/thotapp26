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


/// Represents a restock / consumption event in an ammo's history.
class AmmoHistoryEntry {
  final String id;
  final DateTime date;
  /// 'restock' | 'consumption'
  final String type;
  final String label;
  final int quantity;
  final String? comment;

  const AmmoHistoryEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.label,
    required this.quantity,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type,
        'label': label,
        'quantity': quantity,
        'comment': comment,
      };

  static AmmoHistoryEntry fromJson(Map<String, dynamic> json) {
    return AmmoHistoryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      label: json['label'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
    );
  }
}


class PlatformHistoryEntry {
  final String id;
  final DateTime date;
  final String type; // tir | entretien | revision
  final String label;
  final String? details;

  const PlatformHistoryEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.label,
    this.details,
  });

  PlatformHistoryEntry copyWith({
    String? id,
    DateTime? date,
    String? type,
    String? label,
    String? details,
  }) {
    return PlatformHistoryEntry(
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

  static PlatformHistoryEntry fromJson(dynamic json) {
    return PlatformHistoryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      label: json['label'] as String,
      details: json['details'] as String?,
    );
  }
}

class Platform {
  final String id;
  final String name;
  final String model;
  /// Free-form user note shown in item details.
  final String comment;
  /// Domain type shown in inventory badges (e.g. PA, FA, FM, FP...).
  final String type;
  final String caliber;
  final String serialNumber;
  final double weight;
  int totalRounds;
  DateTime lastCleaned;
  DateTime lastRevised;
  DateTime lastUsed;
  final String imageUrl;
  final String category; // 'Plateforme'
  final List<ItemDocument> documents;
  final List<PlatformHistoryEntry> history;
  final String? photoPath; // Path to item photo
  final bool isHidden;
  final List<String> linkedAccessoryIds;

  // Tracking options
  final bool trackWear;
  final bool trackCleanliness;
  final bool trackRounds;
  
  // Tracking thresholds
  final int cleaningRoundsThreshold; // Number of rounds before cleaning reminder
  final int wearRoundsThreshold; // Number of rounds for wear calculation

  /// Rounds counter snapshots to compute maintenance progress.
  ///
  /// `totalRounds` is the platform absolute counter (initial counter + all sessions).
  /// We compute progress between the last maintenance snapshot and the configured threshold.
  int roundsAtLastCleaning;
  int roundsAtLastRevision;

  Platform({
    required this.id,
    required this.name,
    required this.model,
    this.comment = '',
    this.type = 'Plateforme',
    required this.caliber,
    required this.serialNumber,
    required this.weight,
    required this.totalRounds,
    required this.lastCleaned,
    DateTime? lastRevised,
    required this.lastUsed,
    this.imageUrl = '',
    this.category = 'Plateforme',
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
    this.linkedAccessoryIds = const [],
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

  Platform copyWith({
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
    List<PlatformHistoryEntry>? history,
    String? photoPath,
    bool? trackWear,
    bool? trackCleanliness,
    bool? trackRounds,
    int? cleaningRoundsThreshold,
    int? wearRoundsThreshold,
    int? roundsAtLastCleaning,
    int? roundsAtLastRevision,
    bool? isHidden,
    List<String>? linkedAccessoryIds,
  }) {
    return Platform(
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
      linkedAccessoryIds: linkedAccessoryIds ?? this.linkedAccessoryIds,
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
  final List<AmmoHistoryEntry>? history;

  // Tracking options
  final bool trackStock;
  final int lowStockThreshold; // Alert when quantity drops below this
  final bool isHidden;
  final double? unitPrice; // Price per round
  final String currency; // Currency code: EUR, USD, CAD

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
    this.history,
    this.isHidden = false,
    this.unitPrice,
    this.currency = 'EUR',
  }) : initialQuantity = initialQuantity ?? quantity;

  /// Always returns a non-null list of history entries.
  /// Handles null from existing data / hot-reload artifacts.
  List<AmmoHistoryEntry> get safeHistory => history ?? const [];

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
    List<AmmoHistoryEntry>? history,
    bool? isHidden,
    double? unitPrice,
    String? currency,
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
      history: history ?? this.history,
      isHidden: isHidden ?? this.isHidden,
      unitPrice: unitPrice ?? this.unitPrice,
      currency: currency ?? this.currency,
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

  // Maintenance (platform-like)
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
  final List<String> linkedPlatformIds;

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
    this.linkedPlatformIds = const [],
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
    List<String>? linkedPlatformIds,
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
      linkedPlatformIds: linkedPlatformIds ?? this.linkedPlatformIds,
    );
  }
}

enum AdjustmentDistanceUnit {
  meter,
  yard,
}

enum AdjustmentOffsetUnit {
  centimeter,
  inch,
}

class ShootingAdjustmentEntry {
  final String id;
  final double distance;
  final AdjustmentDistanceUnit distanceUnit;
  final double horizontalOffset;
  final double verticalOffset;
  final AdjustmentOffsetUnit offsetUnit;
  final String correction;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShootingAdjustmentEntry({
    required this.id,
    required this.distance,
    required this.distanceUnit,
    required this.horizontalOffset,
    required this.verticalOffset,
    required this.offsetUnit,
    required this.correction,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  ShootingAdjustmentEntry copyWith({
    String? id,
    double? distance,
    AdjustmentDistanceUnit? distanceUnit,
    double? horizontalOffset,
    double? verticalOffset,
    AdjustmentOffsetUnit? offsetUnit,
    String? correction,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShootingAdjustmentEntry(
      id: id ?? this.id,
      distance: distance ?? this.distance,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      horizontalOffset: horizontalOffset ?? this.horizontalOffset,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      offsetUnit: offsetUnit ?? this.offsetUnit,
      correction: correction ?? this.correction,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'distance': distance,
        'distanceUnit': distanceUnit.name,
        'horizontalOffset': horizontalOffset,
        'verticalOffset': verticalOffset,
        'offsetUnit': offsetUnit.name,
        'correction': correction,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ShootingAdjustmentEntry.fromJson(Map<String, dynamic> json) {
    final distanceUnitRaw = (json['distanceUnit'] ?? 'meter') as String;
    final offsetUnitRaw = (json['offsetUnit'] ?? 'centimeter') as String;

    return ShootingAdjustmentEntry(
      id: (json['id'] ?? '') as String,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      distanceUnit: AdjustmentDistanceUnit.values.firstWhere(
        (u) => u.name == distanceUnitRaw,
        orElse: () => AdjustmentDistanceUnit.meter,
      ),
      horizontalOffset: (json['horizontalOffset'] as num?)?.toDouble() ?? 0,
      verticalOffset: (json['verticalOffset'] as num?)?.toDouble() ?? 0,
      offsetUnit: AdjustmentOffsetUnit.values.firstWhere(
        (u) => u.name == offsetUnitRaw,
        orElse: () => AdjustmentOffsetUnit.centimeter,
      ),
      correction: (json['correction'] ?? '') as String,
      note: (json['note'] ?? '') as String,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '') as String) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '') as String) ??
          DateTime.now(),
    );
  }
}

class ShootingAdjustmentTable {
  final String id;
  final String name;
  final String platformId;
  final String? customPlatformName;
  final String? ammoId;
  final String? customAmmoName;
  final bool accessoriesCustomized;
  final List<String> accessoryIds;
  final List<String> customAccessoryNames;
  final List<ShootingAdjustmentEntry> entries;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDope;

  const ShootingAdjustmentTable({
    required this.id,
    this.name = '',
    required this.platformId,
    this.customPlatformName,
    this.ammoId,
    this.customAmmoName,
    this.accessoriesCustomized = false,
    this.accessoryIds = const [],
    this.customAccessoryNames = const [],
    this.entries = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isDope = false,
  });

  ShootingAdjustmentTable copyWith({
    String? id,
    String? name,
    String? platformId,
    String? customPlatformName,
    String? ammoId,
    String? customAmmoName,
    bool clearAmmoId = false,
    bool? accessoriesCustomized,
    List<String>? accessoryIds,
    List<String>? customAccessoryNames,
    List<ShootingAdjustmentEntry>? entries,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDope,
  }) {
    return ShootingAdjustmentTable(
      id: id ?? this.id,
      name: name ?? this.name,
      platformId: platformId ?? this.platformId,
      customPlatformName: customPlatformName ?? this.customPlatformName,
      ammoId: clearAmmoId ? null : (ammoId ?? this.ammoId),
      customAmmoName: customAmmoName ?? this.customAmmoName,
      accessoriesCustomized:
          accessoriesCustomized ?? this.accessoriesCustomized,
      accessoryIds: accessoryIds ?? this.accessoryIds,
      customAccessoryNames: customAccessoryNames ?? this.customAccessoryNames,
      entries: entries ?? this.entries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDope: isDope ?? this.isDope,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'platformId': platformId,
        if (customPlatformName != null) 'customPlatformName': customPlatformName,
        'ammoId': ammoId,
        if (customAmmoName != null) 'customAmmoName': customAmmoName,
        'accessoriesCustomized': accessoriesCustomized,
        'accessoryIds': accessoryIds,
        if (customAccessoryNames.isNotEmpty) 'customAccessoryNames': customAccessoryNames,
        'entries': entries.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isDope': isDope,
      };

  factory ShootingAdjustmentTable.fromJson(Map<String, dynamic> json) {
    final entriesRaw = (json['entries'] as List?) ?? const [];
    final rawName = json['name'];
    final rawPlatformId = json['platformId'];
    final rawAmmoId = json['ammoId'];
    final rawCustomPlatformName = json['customPlatformName'];
    final rawCustomAmmoName = json['customAmmoName'];
    final rawCustomAccessoryNames = (json['customAccessoryNames'] as List?) ?? const [];
    return ShootingAdjustmentTable(
      id: (json['id'] ?? '').toString(),
      name: rawName == null ? '' : rawName.toString(),
      platformId: rawPlatformId == null ? '' : rawPlatformId.toString(),
      customPlatformName: rawCustomPlatformName?.toString(),
      ammoId: rawAmmoId?.toString(),
      customAmmoName: rawCustomAmmoName?.toString(),
      customAccessoryNames: rawCustomAccessoryNames.map((e) => e.toString()).toList(),
      accessoriesCustomized: (json['accessoriesCustomized'] ?? false) == true,
      accessoryIds: ((json['accessoryIds'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      entries: entriesRaw
          .whereType<Map>()
          .map((e) => ShootingAdjustmentEntry.fromJson(e.cast<String, dynamic>()))
          .toList(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '') as String) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '') as String) ??
          DateTime.now(),
      isDope: (json['isDope'] ?? false) == true,
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

class ExercisePlatformAssignment {
  final String platformId;
  final String? platformLabel;
  final List<String> ammoIds;
  final List<String> accessoryIds;

  const ExercisePlatformAssignment({
    required this.platformId,
    this.platformLabel,
    this.ammoIds = const [],
    this.accessoryIds = const [],
  });
}

class ExerciseShotAllocation {
  final String platformId;
  final String ammoId;
  final int shots;

  const ExerciseShotAllocation({
    required this.platformId,
    required this.ammoId,
    required this.shots,
  });
}

class Exercise {
  final String id;
  final String name;
  final String platformId;
  final String? platformLabel;
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
  final List<ExercisePlatformAssignment> platformAssignments;
  final List<ExerciseShotAllocation> shotAllocations;

  Exercise({
    required this.id,
    this.name = '',
    required this.platformId,
    this.platformLabel,
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
    this.platformAssignments = const [],
    this.shotAllocations = const [],
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

  Map<String, int> get platformShotImpact {
    final impact = <String, int>{};

    if (steps != null && steps!.isNotEmpty) {
      for (final step in steps!) {
        if (step.type != StepType.tir) continue;
        final shots = step.shots ?? 0;
        if (shots <= 0) continue;
        final wid = (step.usedPlatformId ?? '').trim();
        if (wid.isEmpty || wid == 'none' || wid == 'borrowed') continue;
        impact[wid] = (impact[wid] ?? 0) + shots;
      }
      if (impact.isNotEmpty) return impact;
    }

    if (shotAllocations.isNotEmpty) {
      for (final alloc in shotAllocations) {
        final wid = alloc.platformId.trim();
        if (wid.isEmpty || wid == 'none' || wid == 'borrowed') continue;
        if (alloc.shots <= 0) continue;
        impact[wid] = (impact[wid] ?? 0) + alloc.shots;
      }
      if (impact.isNotEmpty) return impact;
    }

    if (platformId != 'none' && platformId != 'borrowed') {
      impact[platformId] = shotsFired;
    }
    return impact;
  }

  Map<String, int> get ammoShotImpact {
    final impact = <String, int>{};

    if (steps != null && steps!.isNotEmpty) {
      for (final step in steps!) {
        if (step.type != StepType.tir) continue;
        final shots = step.shots ?? 0;
        if (shots <= 0) continue;
        final aid = (step.usedAmmoId ?? '').trim();
        if (aid.isEmpty || aid == 'none' || aid == 'borrowed') continue;
        impact[aid] = (impact[aid] ?? 0) + shots;
      }
      if (impact.isNotEmpty) return impact;
    }

    if (shotAllocations.isNotEmpty) {
      for (final alloc in shotAllocations) {
        final aid = alloc.ammoId.trim();
        if (aid.isEmpty || aid == 'none' || aid == 'borrowed') continue;
        if (alloc.shots <= 0) continue;
        impact[aid] = (impact[aid] ?? 0) + alloc.shots;
      }
      if (impact.isNotEmpty) return impact;
    }

    if (ammoId != 'none' && ammoId != 'borrowed') {
      impact[ammoId] = shotsFired;
    }
    return impact;
  }

  Map<String, int> get equipmentShotImpact {
    final impact = <String, int>{};
    final platformImpact = platformShotImpact;

    if (platformAssignments.isNotEmpty && platformImpact.isNotEmpty) {
      for (final assignment in platformAssignments) {
        final platformShots = platformImpact[assignment.platformId] ?? 0;
        if (platformShots <= 0) continue;
        for (final accessoryId in assignment.accessoryIds) {
          impact[accessoryId] = (impact[accessoryId] ?? 0) + platformShots;
        }
      }
      if (impact.isNotEmpty) return impact;
    }

    for (final id in equipmentIds) {
      impact[id] = (impact[id] ?? 0) + shotsFired;
    }
    return impact;
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? platformId,
    String? platformLabel,
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
    List<ExercisePlatformAssignment>? platformAssignments,
    List<ExerciseShotAllocation>? shotAllocations,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      platformId: platformId ?? this.platformId,
      platformLabel: platformLabel ?? this.platformLabel,
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
      platformAssignments: platformAssignments ?? this.platformAssignments,
      shotAllocations: shotAllocations ?? this.shotAllocations,
    );
  }
}

class Session {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String? shootingDistance; // Pas de tir
  final double? locationLatitude;
  final double? locationLongitude;
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
  final List<String> platformIds;

  Session({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    this.shootingDistance,
    this.locationLatitude,
this.locationLongitude,
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
    this.platformIds = const [],
  });

  Session copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? location,
    String? shootingDistance,
    double? locationLatitude,
    double? locationLongitude,
    String? sessionType,
    List<Exercise>? exercises,
    bool? weatherEnabled,
    String? temperature,
    String? wind,
    String? humidity,
    String? pressure,
    bool? temperatureEnabled,
    bool? windEnabled,
    bool? humidityEnabled,
    bool? pressureEnabled,
    List<String>? platformIds,
  }) {
    return Session(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      shootingDistance: shootingDistance ?? this.shootingDistance,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      sessionType: sessionType ?? this.sessionType,
      exercises: exercises ?? this.exercises,
      weatherEnabled: weatherEnabled ?? this.weatherEnabled,
      temperature: temperature ?? this.temperature,
      wind: wind ?? this.wind,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      temperatureEnabled: temperatureEnabled ?? this.temperatureEnabled,
      windEnabled: windEnabled ?? this.windEnabled,
      humidityEnabled: humidityEnabled ?? this.humidityEnabled,
      pressureEnabled: pressureEnabled ?? this.pressureEnabled,
      platformIds: platformIds ?? this.platformIds,
    );
  }

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
  
  // Impact on platforms (count of shots per platform)
  Map<String, int> get platformImpact {
    Map<String, int> impact = {};
    for (var ex in exercises) {
      ex.platformShotImpact.forEach((platformId, shots) {
        impact[platformId] = (impact[platformId] ?? 0) + shots;
      });
    }
    return impact;
  }
  
  // Impact on ammo (count of shots per ammo)
  Map<String, int> get ammoImpact {
    Map<String, int> impact = {};
    for (var ex in exercises) {
      ex.ammoShotImpact.forEach((ammoId, shots) {
        impact[ammoId] = (impact[ammoId] ?? 0) + shots;
      });
    }
    return impact;
  }
  
  // Impact on equipment (count of shots per equipment)
  Map<String, int> get equipmentImpact {
    Map<String, int> impact = {};
    for (var ex in exercises) {
      ex.equipmentShotImpact.forEach((equipmentId, shots) {
        impact[equipmentId] = (impact[equipmentId] ?? 0) + shots;
      });
    }
    return impact;
  }
}

class Diagnostic {
  final String id;
  final DateTime date;
  final String platformId;

  /// Snapshot pour conserver un historique lisible
  final String platformNameSnapshot;
  final String platformTypeSnapshot;

  final Map<String, dynamic> responses;

  /// Clé technique de l’incident principal
  final String incidentKey;

  /// Clé technique du problème supposé
  final String suspectedIssueKey;

  /// low / medium / high
  final String riskLevelKey;

  /// Ex:
  /// {
  ///   'ammo_defective': 80,
  ///   'fouling_dirty': 40,
  ///   'configuration_issue': 25,
  ///   'component_damage': 15,
  /// }
  final Map<String, int> probabilities;

  /// Label final affiché
  final String finalDecision;

  final String summary;

  Diagnostic({
    required this.id,
    required this.date,
    required this.platformId,
    this.platformNameSnapshot = '',
    this.platformTypeSnapshot = '',
    required this.responses,
    required this.incidentKey,
    required this.suspectedIssueKey,
    required this.riskLevelKey,
    required this.probabilities,
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

class ExerciseTemplate {
  final String id;
  final String name;
  final DateTime createdAt;
  final int shotsFired;
  final int distance;
  final bool detailedMode;
  final List<ExerciseStep>? steps;
  final String observations;

  ExerciseTemplate({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.shotsFired,
    required this.distance,
    required this.detailedMode,
    this.steps,
    this.observations = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'shotsFired': shotsFired,
        'distance': distance,
        'detailedMode': detailedMode,
        'steps': steps?.map((s) => s.toJson()).toList(),
        'observations': observations,
      };

  static ExerciseTemplate fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List<dynamic>?;
    return ExerciseTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      shotsFired: (json['shotsFired'] as num).toInt(),
      distance: (json['distance'] as num).toInt(),
      detailedMode: json['detailedMode'] as bool? ?? false,
      steps: rawSteps?.map((e) => ExerciseStep.fromJson(e as Map<String, dynamic>)).toList(),
      observations: (json['observations'] as String?) ?? '',
    );
  }
}
