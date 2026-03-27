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
      final connector = i == 0
          ? ''
          : (i == steps.length - 1
              ? strings.exerciseNarrativeFinally
              : strings.exerciseNarrativeThen);
      add(connector);

      switch (s.type) {
        case StepType.deplacement:
          add('par un déplacement de ');
          addBold(s.distanceM == null ? '—' : '${s.distanceM} m');
          if (s.position != null) {
            add(' ');
            add(_posText(s.position!));
          }
          add('.');
          break;
        case StepType.miseEnJoue:
          add('avec une mise en joue');
          if (s.position != null) {
            add(' ');
            add(_posText(s.position!));
          }
          if ((s.target ?? '').trim().isNotEmpty) {
            add(' sur ');
            addBold(s.target!.trim());
          }
          if (s.distanceM != null) {
            add(' à ');
            addBold('${s.distanceM} m');
          }
          add('.');
          break;
        case StepType.tir:
          add('le tireur engage avec ');
          addBold('${s.shots ?? 0} coups');
          if (s.distanceM != null) {
            add(' à ');
            addBold('${s.distanceM} m');
          }
          if ((s.target ?? '').trim().isNotEmpty) {
            add(' sur ');
            addBold(s.target!.trim());
          }
          add('.');
          break;
        case StepType.rechargement:
          add('un rechargement ');
          addBold(_reloadText(s.reloadType));
          add('.');
          break;
        case StepType.transition:
          add('une transition d’arme');
          if ((s.weaponFrom ?? '').trim().isNotEmpty) {
            add(' de ');
            addBold(s.weaponFrom!.trim());
          }
          if ((s.weaponTo ?? '').trim().isNotEmpty) {
            add(' vers ');
            addBold(s.weaponTo!.trim());
          }
          add('.');
          break;
        case StepType.attente:
          add('une attente de ');
          addBold(s.durationSeconds == null ? '—' : '${s.durationSeconds} s');
          if ((s.trigger ?? '').trim().isNotEmpty) {
            add(' (');
            addBold(s.trigger!.trim());
            add(')');
          }
          add('.');
          break;
        case StepType.securite:
          add('une phase sécurité.');
          break;
        case StepType.autre:
          add("une action. ");
          break;
      }
    }

    if (spans.isNotEmpty) {
      spans.add(const TextSpan(text: '\n'));
    }

    return spans;
  }

  String _posText(ShootingPosition pos) {
    return switch (pos) {
      ShootingPosition.debout => 'debout',
      ShootingPosition.enMouvement => 'en mouvement',
      ShootingPosition.genouDroit => 'genou droit',
      ShootingPosition.genouGauche => 'genou gauche',
      ShootingPosition.couche => 'couché',
      ShootingPosition.assis => 'assis',
      ShootingPosition.autre => 'autre',
    };
  }

  String _reloadText(ReloadType? t) {
    return switch (t) {
      ReloadType.tactique => 'tactique',
      ReloadType.urgence => 'd’urgence',
      ReloadType.aVide => 'à vide',
      _ => '—',
    };
  }
}
