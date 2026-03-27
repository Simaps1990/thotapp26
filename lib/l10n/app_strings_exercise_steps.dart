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
        fr: 'AUTO',
        en: 'AUTO',
        de: 'AUTO',
        it: 'AUTO',
        es: 'AUTO',
      );

  String exerciseAutoTotals(int totalShots, int stepCount, int maxDistance, String distanceUnit) => _pick(
        fr: 'Total : $totalShots coups · $stepCount étapes · $maxDistance $distanceUnit',
        en: 'Total: $totalShots shots · $stepCount steps · $maxDistance $distanceUnit',
        de: 'Gesamt: $totalShots Schuss · $stepCount Schritte · $maxDistance $distanceUnit',
        it: 'Totale: $totalShots colpi · $stepCount fasi · $maxDistance $distanceUnit',
        es: 'Total: $totalShots disparos · $stepCount pasos · $maxDistance $distanceUnit',
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
        es: 'Disparador',
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
        es: '¿Realmente quieres eliminar el paso "$stepName"?',
      );

  String get exerciseNarrativeIntro => _pick(
        fr: "L'exercice débute ",
        en: 'The drill starts ',
        de: 'Die Übung beginnt ',
        it: "L'esercizio inizia ",
        es: 'El ejercicio comienza ',
      );

  String get exerciseNarrativeThen => _pick(
        fr: ' puis ',
        en: ' then ',
        de: ' dann ',
        it: ' poi ',
        es: ' luego ',
      );

  String get exerciseNarrativeFinally => _pick(
        fr: ' pour finir, ',
        en: ' finally, ',
        de: ' zum Schluss, ',
        it: ' infine, ',
        es: ' por último, ',
      );
}
