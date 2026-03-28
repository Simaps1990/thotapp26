import 'package:flutter/material.dart';

import 'package:thot/data/exercise_step.dart';
import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';

class ExerciseSummaryText extends StatelessWidget {
  final List<ExerciseStep> steps;

  const ExerciseSummaryText({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    if (steps.isEmpty) return const SizedBox.shrink();

    final spans = _buildNarrativeSpans(textStyles, steps, strings);

    final bg = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.14),
      colors.surface,
    );

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.25),
          width: 1.1,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: textStyles.bodySmall?.copyWith(
            color: colors.onSurface,
            height: 1.4,
          ),
          children: spans,
        ),
      ),
    );
  }

  List<TextSpan> _buildNarrativeSpans(TextTheme textStyles, List<ExerciseStep> steps, AppStrings strings) {
    final spans = <TextSpan>[];

    void add(String text) => spans.add(TextSpan(text: text));
    void addBold(String text) => spans.add(TextSpan(
          text: text,
          style: textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w800),
        ));

    add(strings.exerciseNarrativeIntro);

    for (int i = 0; i < steps.length; i++) {
      final s = steps[i];

      // New line and connector (Puis / Pour finir, ...) for steps after the first.
      if (i == 0) {
        // First step stays on the same line as the intro.
      } else {
        spans.add(const TextSpan(text: '\n'));
        final connector = i == steps.length - 1
            ? strings.exerciseNarrativeFinally
            : strings.exerciseNarrativeThen;
        add(connector);
      }

      switch (s.type) {
        case StepType.deplacement:
          add(strings.exerciseNarrativeMovementPrefix);
          if (s.distanceM != null) {
            add(strings.exerciseNarrativeMovementUntil);
            addBold('${s.distanceM} m');
          } else {
            addBold('—');
          }
          if (s.position != null) {
            add(' ');
add(strings.exercisePositionNarrative(s.position!));
          }
          add('.');
          break;
        case StepType.miseEnJoue:
          add(strings.exerciseNarrativeAimPrefix);
          if (s.position != null) {
            add(' ');
add(strings.exercisePositionNarrative(s.position!));
          }
          if ((s.target ?? '').trim().isNotEmpty) {
            add(strings.exerciseNarrativeOnTarget);
            addBold(s.target!.trim());
          }
          if (s.distanceM != null) {
            add(strings.exerciseNarrativeAtDistance);
            addBold('${s.distanceM} m');
          }
          add('.');
          break;
        case StepType.tir:
          add(strings.exerciseNarrativeShooterEngages);
          addBold('${s.shots ?? 0} ${strings.exerciseNarrativeShotsWord}');
          if (s.distanceM != null) {
            add(strings.exerciseNarrativeAtDistance);
            addBold('${s.distanceM} m');
          }
          if ((s.target ?? '').trim().isNotEmpty) {
            add(strings.exerciseNarrativeOnTarget);
            addBold(s.target!.trim());
          }
          add('.');
          break;
case StepType.rechargement:
  add(strings.exerciseNarrativeReloadPrefix);
addBold(s.reloadType == null ? '—' : strings.exerciseReloadTypeNarrative(s.reloadType!));
  add('.');
  break;
        case StepType.transition:
          add(strings.exerciseNarrativeTransitionPrefix);
          if ((s.weaponFrom ?? '').trim().isNotEmpty) {
add(strings.exerciseNarrativeFrom);
            addBold(s.weaponFrom!.trim());
          }
          if ((s.weaponTo ?? '').trim().isNotEmpty) {
add(strings.exerciseNarrativeTo);
            addBold(s.weaponTo!.trim());
          }
          add('.');
          break;

        case StepType.attente:
          add(strings.exerciseNarrativeWaitPrefix);
          addBold(s.durationSeconds == null ? '—' : '${s.durationSeconds} s');
          if (s.distanceM != null) {
            add(strings.exerciseNarrativeAtDistance);
            addBold('${s.distanceM} m');
          }
if ((s.trigger ?? '').trim().isNotEmpty) {
  add(strings.exerciseNarrativeWaitUntil);
  addBold(s.trigger!.trim());
}
          add('.');
          break;
        case StepType.securite:
          add(strings.exerciseNarrativeSafetySentence);
          break;
        case StepType.autre:
          add(strings.exerciseNarrativeOtherSentence);
          break;
      }
    }

    if (spans.isNotEmpty) {
      spans.add(const TextSpan(text: '\n'));
    }

    return spans;
  }


}
