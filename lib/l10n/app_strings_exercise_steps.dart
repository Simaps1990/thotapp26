part of 'package:thot/l10n/app_strings.dart';

extension AppStringsExerciseSteps on AppStrings {
  String get exerciseModeLabel => _pick(
        fr: 'Mode',
        en: 'Mode',
        de: 'Modus',
        it: 'Modalità',
        es: 'Modo',
      );

  String get exerciseModeSimple => _pick(
        fr: 'Simple',
        en: 'Simple',
        de: 'Einfach',
        it: 'Semplice',
        es: 'Simple',
      );

  String get exerciseModeDetailed => _pick(
        fr: 'Détaillé',
        en: 'Detailed',
        de: 'Detailliert',
        it: 'Dettagliato',
        es: 'Detallado',
      );

  String get exerciseStepsTitle => _pick(
        fr: 'Étapes',
        en: 'Steps',
        de: 'Schritte',
        it: 'Fasi',
        es: 'Pasos',
      );

  String get exerciseAddStep => _pick(
        fr: 'Ajouter une étape',
        en: 'Add a step',
        de: 'Schritt hinzufügen',
        it: 'Aggiungi una fase',
        es: 'Añadir un paso',
      );

  String get exerciseNoSteps => _pick(
        fr: 'Aucune étape',
        en: 'No steps',
        de: 'Keine Schritte',
        it: 'Nessuna fase',
        es: 'Sin pasos',
      );

  String get exerciseAutoBadge => _pick(
        fr: 'TOTAL',
        en: 'TOTAL',
        de: 'TOTAL',
        it: 'TOTAL',
        es: 'TOTAL',
      );

  String exerciseAutoTotals(int totalShots, int stepCount, int maxDistance, String distanceUnit) => _pick(
        fr: '$totalShots coups · $stepCount étapes',
        en: '$totalShots shots · $stepCount steps',
        de: '$totalShots Schuss · $stepCount Schritte',
        it: '$totalShots colpi · $stepCount fasi',
        es: '$totalShots disparos · $stepCount pasos',
      );

  String get exerciseNewStepTitle => _pick(
        fr: 'Nouvelle étape',
        en: 'New step',
        de: 'Neuer Schritt',
        it: 'Nuova fase',
        es: 'Nuevo paso',
      );

  String get exerciseEditStepTitle => _pick(
        fr: 'Modifier l\'étape',
        en: 'Edit step',
        de: 'Schritt bearbeiten',
        it: 'Modifica fase',
        es: 'Editar paso',
      );

  String get exerciseStepTypeTitle => _pick(
        fr: 'Type',
        en: 'Type',
        de: 'Typ',
        it: 'Tipo',
        es: 'Tipo',
      );

  String get exerciseStepPositionTitle => _pick(
        fr: 'Position',
        en: 'Position',
        de: 'Position',
        it: 'Posizione',
        es: 'Posición',
      );

  String exerciseStepTypeLabel(StepType type) {
    return switch (type) {
      StepType.tir => _pick(fr: 'Tir', en: 'Fire', de: 'Schuss', it: 'Tiro', es: 'Disparo'),
      StepType.deplacement => _pick(fr: 'Déplacement', en: 'Move', de: 'Bewegung', it: 'Spostamento', es: 'Movimiento'),
      StepType.rechargement => _pick(fr: 'Rechargement', en: 'Reload', de: 'Nachladen', it: 'Ricarica', es: 'Recarga'),
      StepType.transition => _pick(fr: 'Transition', en: 'Transition', de: 'Wechsel', it: 'Transizione', es: 'Transición'),
      StepType.miseEnJoue => _pick(fr: 'Mise en joue', en: 'Aim', de: 'Anschlag', it: 'Puntamento', es: 'Apuntar'),
      StepType.attente => _pick(fr: 'Attente', en: 'Wait', de: 'Warten', it: 'Attesa', es: 'Espera'),
      StepType.securite => _pick(fr: 'Sécurité', en: 'Safety', de: 'Sicherheit', it: 'Sicurezza', es: 'Seguridad'),
      StepType.autre => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro'),
    };
  }

  String exercisePositionLabel(ShootingPosition pos) {
    return switch (pos) {
      ShootingPosition.debout => _pick(fr: 'Debout', en: 'Standing', de: 'Stehend', it: 'In piedi', es: 'De pie'),
      ShootingPosition.enMouvement => _pick(fr: 'En mouvement', en: 'Moving', de: 'In Bewegung', it: 'In movimento', es: 'En movimiento'),
      ShootingPosition.genouDroit => _pick(fr: 'Genou droit', en: 'Right knee', de: 'Rechtes Knie', it: 'Ginocchio destro', es: 'Rodilla derecha'),
      ShootingPosition.genouGauche => _pick(fr: 'Genou gauche', en: 'Left knee', de: 'Linkes Knie', it: 'Ginocchio sinistro', es: 'Rodilla izquierda'),
      ShootingPosition.couche => _pick(fr: 'Couché', en: 'Prone', de: 'Liegend', it: 'Prono', es: 'Tendido'),
      ShootingPosition.assis => _pick(fr: 'Assis', en: 'Seated', de: 'Sitzend', it: 'Seduto', es: 'Sentado'),
      ShootingPosition.autre => _pick(fr: 'Autre', en: 'Other', de: 'Andere', it: 'Altro', es: 'Otro'),
    };
  }

String exercisePositionNarrative(ShootingPosition pos) {
  return switch (pos) {
    ShootingPosition.debout => _pick(fr: 'debout', en: 'standing', de: 'stehend', it: 'in piedi', es: 'de pie'),
    ShootingPosition.enMouvement => _pick(fr: 'en mouvement', en: 'moving', de: 'in Bewegung', it: 'in movimento', es: 'en movimiento'),
    ShootingPosition.genouDroit => _pick(fr: 'genou droit', en: 'right knee', de: 'rechtes Knie', it: 'ginocchio destro', es: 'rodilla derecha'),
    ShootingPosition.genouGauche => _pick(fr: 'genou gauche', en: 'left knee', de: 'linkes Knie', it: 'ginocchio sinistro', es: 'rodilla izquierda'),
    ShootingPosition.couche => _pick(fr: 'couché', en: 'prone', de: 'liegend', it: 'prono', es: 'tendido'),
    ShootingPosition.assis => _pick(fr: 'assis', en: 'seated', de: 'sitzend', it: 'seduto', es: 'sentado'),
    ShootingPosition.autre => _pick(fr: 'autre', en: 'other', de: 'andere', it: 'altro', es: 'otro'),
  };
}

  String exerciseReloadTypeLabel(ReloadType type) {
    return switch (type) {
      ReloadType.tactique => _pick(fr: 'Tactique', en: 'Tactical', de: 'Taktisch', it: 'Tattica', es: 'Táctica'),
      ReloadType.urgence => _pick(fr: 'Urgence', en: 'Emergency', de: 'Notfall', it: 'Emergenza', es: 'Emergencia'),
      ReloadType.aVide => _pick(fr: 'À vide', en: 'Empty', de: 'Leer', it: 'A vuoto', es: 'Vacía'),
    };
  }

  String get exerciseFieldShots => _pick(
        fr: 'Coups',
        en: 'Shots',
        de: 'Schuss',
        it: 'Colpi',
        es: 'Disparos',
      );

  String get exerciseFieldDistance => _pick(
        fr: 'Distance',
        en: 'Distance',
        de: 'Distanz',
        it: 'Distanza',
        es: 'Distancia',
      );

  String get exerciseFieldTarget => _pick(
        fr: 'Cible',
        en: 'Target',
        de: 'Ziel',
        it: 'Bersaglio',
        es: 'Objetivo',
      );

  String get exerciseFieldReloadType => _pick(
        fr: 'Type',
        en: 'Type',
        de: 'Typ',
        it: 'Tipo',
        es: 'Tipo',
      );

  String get exerciseFieldDuration => _pick(
        fr: 'Durée',
        en: 'Duration',
        de: 'Dauer',
        it: 'Durata',
        es: 'Duración',
      );

  String get exerciseFieldTrigger => _pick(
        fr: 'Déclencheur',
        en: 'Trigger',
        de: 'Auslöser',
        it: 'Trigger',
        es: 'Activador',
      );

  String get exerciseFieldWeaponFrom => _pick(
        fr: 'Arme de',
        en: 'Weapon from',
        de: 'Waffe von',
        it: 'Arma da',
        es: 'Arma de',
      );

  String get exerciseFieldWeaponTo => _pick(
        fr: 'Arme vers',
        en: 'Weapon to',
        de: 'Waffe zu',
        it: 'Arma a',
        es: 'Arma a',
      );

  String get exerciseOptionalHint => _pick(
        fr: ' (optionnel)',
        en: ' (optional)',
        de: ' (optional)',
        it: ' (opzionale)',
        es: ' (opcional)',
      );

  String get exerciseStepCommentLabel => _pick(
        fr: 'Commentaire (optionnel)',
        en: 'Comment (optional)',
        de: 'Kommentar (optional)',
        it: 'Commento (opzionale)',
        es: 'Comentario (opcional)',
      );

  String get exerciseActionAdd => _pick(
        fr: 'Ajouter',
        en: 'Add',
        de: 'Hinzufügen',
        it: 'Aggiungi',
        es: 'Añadir',
      );

  String get exerciseActionSave => _pick(
        fr: 'Enregistrer',
        en: 'Save',
        de: 'Speichern',
        it: 'Salva',
        es: 'Guardar',
      );

  String exerciseConfirmDeleteStepMessage(String stepName) => _pick(
        fr: 'Voulez-vous vraiment supprimer l\'étape "$stepName" ?',
        en: 'Do you really want to delete the step "$stepName"?',
        de: 'Möchtest du den Schritt "$stepName" wirklich löschen?',
        it: 'Vuoi davvero eliminare la fase "$stepName"?',
        es: '¿Seguro que quieres eliminar el paso "$stepName"?',
      );

  String get exerciseNarrativeIntro => _pick(
fr: 'L\'exercice se déroule comme suit : ',
en: 'The drill goes as follows: ',
de: 'Die Übung läuft wie folgt ab: ',
it: 'L\'esercizio si svolge come segue: ',
es: 'El ejercicio se desarrolla así: ',
      );

  String get exerciseNarrativeThen => _pick(
        fr: '',
        en: '',
        de: '',
        it: '',
        es: '',
      );

  String get exerciseNarrativeFinally => _pick(
        fr: '',
        en: '',
        de: '',
        it: '',
        es: '',
      );

  // Narrative fragments for exercise summary (all languages)

  /// e.g. "un déplacement " / "a movement "
  String get exerciseNarrativeMovementPrefix => _pick(
fr: 'Il se déplace ',
en: 'He moves ',
de: 'Er bewegt sich ',
it: 'Il tiratore si sposta ',
es: 'El tirador se desplaza ',
      );

  /// e.g. "jusqu'à " / "up to "
  String get exerciseNarrativeMovementUntil => _pick(
fr: 'jusqu\'à ',
en: 'up to ',
de: 'bis auf ',
it: 'fino a ',
es: 'hasta ',
      );

  /// e.g. "une attente de " / "a wait of "
  String get exerciseNarrativeWaitPrefix => _pick(
fr: 'Il attend ',
en: 'He waits ',
de: 'Er wartet ',
it: 'Il tiratore attende ',
es: 'El tirador espera ',
      );

String get exerciseNarrativeWaitUntil => _pick(
  fr: ' jusqu\'au ',
  en: ' until ',
  de: ' bis zum ',
  it: ' fino al ',
  es: ' hasta el ',
);

// Pour la transition
String get exerciseNarrativeFrom => _pick(
  fr: ' de ',
  en: ' from ',
  de: ' von ',
  it: ' da ',
  es: ' de ',
);

String get exerciseNarrativeTo => _pick(
  fr: ' vers ',
  en: ' to ',
  de: ' zu ',
  it: ' a ',
  es: ' a ',
);

  /// e.g. "le tireur engage " / "the shooter engages "
  String get exerciseNarrativeShooterEngages => _pick(
fr: 'Il engage ',
en: 'He fires ',
de: 'Er feuert ',
it: 'Il tiratore ingaggia ',
es: 'El tirador realiza ',
      );

  /// e.g. "coups" / "shots"
  String get exerciseNarrativeShotsWord => _pick(
        fr: 'coups',
        en: 'shots',
        de: 'Schuss',
        it: 'colpi',
        es: 'disparos',
      );

  /// e.g. " sur la cible " / " on the target "
  String get exerciseNarrativeOnTarget => _pick(
        fr: ' sur la cible ',
        en: ' on the target ',
        de: ' auf die Zielscheibe ',
        it: ' sul bersaglio ',
        es: ' sobre el blanco ',
      );

  /// e.g. "avec une mise en joue" / "with an aim"
  String get exerciseNarrativeAimPrefix => _pick(
fr: 'Il met en joue, ',
en: 'He aims, ',
de: 'Er nimmt Anschlag, ',
it: 'Il tiratore punta, ',
es: 'El tirador apunta, ',
      );

  /// e.g. "il effectue un rechargement " / "they perform a "
  String get exerciseNarrativeReloadPrefix => _pick(
fr: 'Il effectue un rechargement ',
en: 'He performs a ',
de: 'Er führt ein Nachladen durch: ',
it: 'Il tiratore esegue una ricarica ',
es: 'El tirador realiza una recarga ',
      );

String exerciseReloadTypeNarrative(ReloadType type) {
  return switch (type) {
    ReloadType.tactique => _pick(fr: 'tactique', en: 'tactical', de: 'taktisch', it: 'tattica', es: 'táctico'),
    ReloadType.urgence  => _pick(fr: 'd\'urgence', en: 'emergency', de: 'unter Druck', it: 'd\'emergenza', es: 'de emergencia'),
    ReloadType.aVide    => _pick(fr: 'à vide', en: 'on empty', de: 'auf leer', it: 'a vuoto', es: 'en vacío'),
  };
}

  /// e.g. "une transition d’arme" / "a weapon transition"
  String get exerciseNarrativeTransitionPrefix => _pick(
fr: 'Il effectue une transition d\'arme',
en: 'He transitions',
de: 'Er wechselt die Waffe',
it: 'Il tiratore effettua una transizione d\'arma',
es: 'El tirador realiza una transición de arma',
      );

  /// e.g. " à " / " at "
  String get exerciseNarrativeAtDistance => _pick(
        fr: ' à ',
        en: ' at ',
        de: ' auf ',
        it: ' a ',
        es: ' a ',
      );

  /// Full sentence for safety phase
  String get exerciseNarrativeSafetySentence => _pick(
        fr: 'Phase sécurité.',
        en: 'Safety phase.',
        de: 'Sicherheitsphase.',
        it: 'Fase di sicurezza.',
        es: 'Fase de seguridad.',
      );

  /// Full sentence for generic action
  String get exerciseNarrativeOtherSentence => _pick(
        fr: 'Action.',
        en: 'Action.',
        de: 'Aktion.',
        it: 'Azione.',
        es: 'Acción.',
      );
}
