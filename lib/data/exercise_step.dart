/// Type d'étape dans un exercice de tir.
enum StepType {
  tir,
  deplacement,
  rechargement,
  transition,
  miseEnJoue,
  attente,
  securite,
  autre,
}

/// Position de tir ou de déplacement.
enum ShootingPosition {
  debout,
  genou,
  couche,
  assis,
  autre,
}

enum MovementType {
  marche,
  course,
  lateral,
  repli,
  autre,
}

/// Type de rechargement.
enum ReloadType {
  tactique,
  urgence,
  aVide,
}

/// Étape détaillée d'un exercice.
class ExerciseStep {
  final String id; // uuid
  final StepType type;
  final ShootingPosition? position;
  final int? distanceM;
  final int? shots; // uniquement si type == StepType.tir
  final String? target; // cible, texte libre
  final String? platformFrom; // transition : plateforme de départ
  final String? platformTo; // transition : plateforme d'arrivée
  final String? usedPlatformId; // tir: plateforme utilisée
  final String? usedAmmoId; // tir: consommable utilisé
  final ReloadType? reloadType;
  final int? durationSeconds; // attente
  final String? trigger; // attente : déclencheur
  final String? comment;
final MovementType? movementType;


  const ExerciseStep({
    required this.id,
    required this.type,
    this.position,
    this.distanceM,
    this.shots,
    this.target,
    this.platformFrom,
    this.platformTo,
    this.usedPlatformId,
    this.usedAmmoId,
    this.reloadType,
    this.durationSeconds,
    this.trigger,
    this.comment,
    this.movementType,

  });

  ExerciseStep copyWith({
    String? id,
    StepType? type,
    ShootingPosition? position,
    int? distanceM,
    int? shots,
    String? target,
    String? platformFrom,
    String? platformTo,
    String? usedPlatformId,
    String? usedAmmoId,
    ReloadType? reloadType,
    int? durationSeconds,
    String? trigger,
    String? comment,
    MovementType? movementType,
  }) {
    return ExerciseStep(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      distanceM: distanceM ?? this.distanceM,
      shots: shots ?? this.shots,
      target: target ?? this.target,
      platformFrom: platformFrom ?? this.platformFrom,
      platformTo: platformTo ?? this.platformTo,
      usedPlatformId: usedPlatformId ?? this.usedPlatformId,
      usedAmmoId: usedAmmoId ?? this.usedAmmoId,
      reloadType: reloadType ?? this.reloadType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      trigger: trigger ?? this.trigger,
      comment: comment ?? this.comment,
      movementType: movementType ?? this.movementType,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'position': position?.name,
        'distanceM': distanceM,
        'shots': shots,
        'target': target,
        'platformFrom': platformFrom,
        'platformTo': platformTo,
        'usedPlatformId': usedPlatformId,
        'usedAmmoId': usedAmmoId,
        'reloadType': reloadType?.name,
        'durationSeconds': durationSeconds,
        'trigger': trigger,
        'comment': comment,
        'movementType': movementType?.name,
      };

  static ExerciseStep fromJson(Map<String, dynamic> json) {
    StepType parseStepType(String? raw) {
      return StepType.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => StepType.autre,
      );
    }

    ShootingPosition? parsePosition(String? raw) {
      if (raw == null) return null;
      return ShootingPosition.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => ShootingPosition.autre,
      );
    }

ReloadType? parseReloadType(String? raw) {
      if (raw == null) return null;
      return ReloadType.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => ReloadType.tactique,
      );
    }

    MovementType? parseMovementType(String? raw) {
      if (raw == null) return null;
      return MovementType.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => MovementType.autre,
      );
    }

    return ExerciseStep(
      id: json['id'] as String,
      type: parseStepType(json['type'] as String?),
      position: parsePosition(json['position'] as String?),
      distanceM: json['distanceM'] as int?,
      shots: json['shots'] as int?,
      target: json['target'] as String?,
      platformFrom: json['platformFrom'] as String?,
      platformTo: json['platformTo'] as String?,
      usedPlatformId: json['usedPlatformId'] as String?,
      usedAmmoId: json['usedAmmoId'] as String?,
      reloadType: parseReloadType(json['reloadType'] as String?),
      durationSeconds: json['durationSeconds'] as int?,
      trigger: json['trigger'] as String?,
comment: json['comment'] as String?,
      movementType: parseMovementType(json['movementType'] as String?),
    );
  }
}
