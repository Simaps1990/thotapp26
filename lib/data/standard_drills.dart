import 'package:thot/data/models.dart';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/l10n/app_strings.dart';

class StandardDrills {
  /// Returns all standard drills as ExerciseTemplate, with localized names
  /// and observations based on the active language.
  static List<ExerciseTemplate> all(AppStrings strings) {
    return [
      _billDrill(strings),
      _mozambique(strings),
      _elPresidente(strings),
      _dotTorture(strings),
      _fast(strings),
      _theTest(strings),
      _hackathornStandards(strings),
      _hateful8(strings),
      _twoReloadTwo(strings),
    ];
  }

  static ExerciseTemplate _billDrill(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_bill_drill',
      name: s.standardDrillBillName,
      createdAt: now,
      shotsFired: 6,
      distance: 7,
      detailedMode: true,
      observations: s.standardDrillBillObservations,
      steps: [
        ExerciseStep(
          id: 'std_bill_step_1',
          type: StepType.miseEnJoue,
          position: ShootingPosition.debout,
          distanceM: 7,
          comment: s.standardDrillBillStep1Comment,
        ),
        ExerciseStep(
          id: 'std_bill_step_2',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillBillStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_bill_step_3',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 6,
          target: s.standardDrillBillStep3Target,
          comment: s.standardDrillBillStep3Comment,
        ),
      ],
    );
  }

  static ExerciseTemplate _mozambique(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_mozambique',
      name: s.standardDrillMozambiqueName,
      createdAt: now,
      shotsFired: 3,
      distance: 7,
      detailedMode: true,
      observations: s.standardDrillMozambiqueObservations,
      steps: [
        ExerciseStep(
          id: 'std_mozambique_step_1',
          type: StepType.miseEnJoue,
          position: ShootingPosition.debout,
          distanceM: 7,
          comment: s.standardDrillMozambiqueStep1Comment,
        ),
        ExerciseStep(
          id: 'std_mozambique_step_2',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillMozambiqueStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_mozambique_step_3',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 2,
          target: s.standardDrillMozambiqueStep3Target,
          comment: s.standardDrillMozambiqueStep3Comment,
        ),
        ExerciseStep(
          id: 'std_mozambique_step_4',
          type: StepType.transition,
          comment: s.standardDrillMozambiqueStep4Comment,
        ),
        ExerciseStep(
          id: 'std_mozambique_step_5',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 1,
          target: s.standardDrillMozambiqueStep5Target,
          comment: s.standardDrillMozambiqueStep5Comment,
        ),
      ],
    );
  }

  static ExerciseTemplate _elPresidente(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_el_presidente',
      name: s.standardDrillElPresidenteName,
      createdAt: now,
      shotsFired: 12,
      distance: 10,
      detailedMode: true,
      observations: s.standardDrillElPresidenteObservations,
      steps: [
        ExerciseStep(
          id: 'std_el_presidente_step_1',
          type: StepType.miseEnJoue,
          position: ShootingPosition.debout,
          distanceM: 10,
          comment: s.standardDrillElPresidenteStep1Comment,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_2',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillElPresidenteStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_3',
          type: StepType.transition,
          comment: s.standardDrillElPresidenteStep3Comment,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_4',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 2,
          target: s.standardDrillElPresidenteStep4Target,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_5',
          type: StepType.transition,
          comment: s.standardDrillElPresidenteStep5Comment,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_6',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 2,
          target: s.standardDrillElPresidenteStep6Target,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_7',
          type: StepType.transition,
          comment: s.standardDrillElPresidenteStep7Comment,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_8',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 2,
          target: s.standardDrillElPresidenteStep8Target,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_9',
          type: StepType.rechargement,
          reloadType: ReloadType.urgence,
          comment: s.standardDrillElPresidenteStep9Comment,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_10',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 2,
          target: s.standardDrillElPresidenteStep10Target,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_11',
          type: StepType.transition,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_12',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 2,
          target: s.standardDrillElPresidenteStep12Target,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_13',
          type: StepType.transition,
        ),
        ExerciseStep(
          id: 'std_el_presidente_step_14',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 2,
          target: s.standardDrillElPresidenteStep14Target,
        ),
      ],
    );
  }

  static ExerciseTemplate _dotTorture(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_dot_torture',
      name: s.standardDrillDotTortureName,
      createdAt: now,
      shotsFired: 50,
      distance: 3,
      detailedMode: true,
      observations: s.standardDrillDotTortureObservations,
      steps: [
        ExerciseStep(
          id: 'std_dot_torture_step_1',
          type: StepType.miseEnJoue,
          position: ShootingPosition.debout,
          distanceM: 3,
          comment: s.standardDrillDotTortureStep1Comment,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_2',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 5,
          target: s.standardDrillDotTortureStep2Target,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_3',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 4,
          target: s.standardDrillDotTortureStep3Target,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_4',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 4,
          target: s.standardDrillDotTortureStep4Target,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_5',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 5,
          target: s.standardDrillDotTortureStep5Target,
          comment: s.standardDrillDotTortureStep5Comment,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_6',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 5,
          target: s.standardDrillDotTortureStep6Target,
          comment: s.standardDrillDotTortureStep6Comment,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_7',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 5,
          target: s.standardDrillDotTortureStep7Target,
          comment: s.standardDrillDotTortureStep7Comment,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_8',
          type: StepType.rechargement,
          reloadType: ReloadType.tactique,
          comment: s.standardDrillDotTortureStep8Comment,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_9',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 5,
          target: s.standardDrillDotTortureStep9Target,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_10',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 5,
          target: s.standardDrillDotTortureStep10Target,
        ),
        ExerciseStep(
          id: 'std_dot_torture_step_11',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 3,
          shots: 12,
          target: s.standardDrillDotTortureStep11Target,
          comment: s.standardDrillDotTortureStep11Comment,
        ),
      ],
    );
  }

  static ExerciseTemplate _fast(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_fast',
      name: s.standardDrillFastName,
      createdAt: now,
      shotsFired: 6,
      distance: 7,
      detailedMode: true,
      observations: s.standardDrillFastObservations,
      steps: [
        ExerciseStep(
          id: 'std_fast_step_1',
          type: StepType.miseEnJoue,
          position: ShootingPosition.debout,
          distanceM: 7,
          comment: s.standardDrillFastStep1Comment,
        ),
        ExerciseStep(
          id: 'std_fast_step_2',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillFastStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_fast_step_3',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 2,
          target: s.standardDrillFastStep3Target,
          comment: s.standardDrillFastStep3Comment,
        ),
        ExerciseStep(
          id: 'std_fast_step_4',
          type: StepType.rechargement,
          reloadType: ReloadType.urgence,
          comment: s.standardDrillFastStep4Comment,
        ),
        ExerciseStep(
          id: 'std_fast_step_5',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 4,
          target: s.standardDrillFastStep5Target,
          comment: s.standardDrillFastStep5Comment,
        ),
      ],
    );
  }

  static ExerciseTemplate _theTest(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_the_test',
      name: s.standardDrillTheTestName,
      createdAt: now,
      shotsFired: 10,
      distance: 10,
      detailedMode: true,
      observations: s.standardDrillTheTestObservations,
      steps: [
        ExerciseStep(
          id: 'std_the_test_step_1',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillBillStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_the_test_step_2',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 10,
          target: s.standardDrillBillStep3Target,
        ),
      ],
    );
  }

  static ExerciseTemplate _hackathornStandards(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_hackathorn_standards',
      name: s.standardDrillHackathornName,
      createdAt: now,
      shotsFired: 12,
      distance: 7,
      detailedMode: true,
      observations: s.standardDrillHackathornObservations,
      steps: [
        ExerciseStep(
          id: 'std_hackathorn_step_1',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillBillStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_hackathorn_step_2',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 5,
          shots: 4,
          target: s.standardDrillBillStep3Target,
        ),
        ExerciseStep(id: 'std_hackathorn_step_3', type: StepType.transition),
        ExerciseStep(
          id: 'std_hackathorn_step_4',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 4,
          target: s.standardDrillBillStep3Target,
        ),
        ExerciseStep(id: 'std_hackathorn_step_5', type: StepType.transition),
        ExerciseStep(
          id: 'std_hackathorn_step_6',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 10,
          shots: 4,
          target: s.standardDrillBillStep3Target,
        ),
      ],
    );
  }

  static ExerciseTemplate _hateful8(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_hateful_8',
      name: s.standardDrillHateful8Name,
      createdAt: now,
      shotsFired: 8,
      distance: 7,
      detailedMode: true,
      observations: s.standardDrillHateful8Observations,
      steps: [
        ExerciseStep(
          id: 'std_hateful_8_step_1',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillBillStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_hateful_8_step_2',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 8,
          target: s.standardDrillBillStep3Target,
        ),
      ],
    );
  }

  static ExerciseTemplate _twoReloadTwo(AppStrings s) {
    final now = DateTime.now();
    return ExerciseTemplate(
      id: 'std_2_reload_2',
      name: s.standardDrillTwoReloadTwoName,
      createdAt: now,
      shotsFired: 4,
      distance: 7,
      detailedMode: true,
      observations: s.standardDrillTwoReloadTwoObservations,
      steps: [
        ExerciseStep(
          id: 'std_2_reload_2_step_1',
          type: StepType.attente,
          durationSeconds: 2,
          trigger: s.standardDrillBillStep2Trigger,
        ),
        ExerciseStep(
          id: 'std_2_reload_2_step_2',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 2,
          target: s.standardDrillBillStep3Target,
        ),
        ExerciseStep(
          id: 'std_2_reload_2_step_3',
          type: StepType.rechargement,
          reloadType: ReloadType.urgence,
          comment: s.standardDrillFastStep4Comment,
        ),
        ExerciseStep(
          id: 'std_2_reload_2_step_4',
          type: StepType.tir,
          position: ShootingPosition.debout,
          distanceM: 7,
          shots: 2,
          target: s.standardDrillBillStep3Target,
        ),
      ],
    );
  }
}
