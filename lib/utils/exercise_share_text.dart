import 'package:flutter/material.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/utils/exercise_display.dart';
import 'package:thot/utils/unit_converter.dart';

String generateExerciseShareText({
  required BuildContext context,
  required Session session,
  required Exercise exercise,
  required ThotProvider provider,
  required UnitConverter converter,
}) {
  final strings = AppStrings.of(context);
  final platformName = platformDisplayName(context, provider, exercise);
  final ammoName = ammoDisplayName(context, provider, exercise);
  final target = (exercise.targetName ?? '').trim();
  final exerciseName = exercise.name.trim().isEmpty
      ? strings.exerciseShareUnnamed
      : exercise.name.trim();

  if (exercise.steps == null || exercise.steps!.isEmpty) {
    final buffer = StringBuffer();
    buffer.writeln('${strings.exerciseShareSimpleHeader} — $exerciseName');
    buffer.writeln('📅 ${AppDateFormats.formatDateTimeShort(context, session.date)} · ${strings.sessionTypeDisplayName(session.sessionType)}');
    buffer.writeln(
      '🔫 $platformName · $ammoName${target.isEmpty ? '' : ' · $target'}',
    );
    buffer.writeln();
    buffer.writeln(
      '${strings.exerciseShareSimpleMode} : ${strings.exerciseShareShots(exercise.shotsFired)} · ${converter.formatDistance(exercise.distance)}',
    );
    if (exercise.observations.trim().isNotEmpty) {
      buffer.writeln('💬 ${exercise.observations.trim()}');
    }
    buffer.writeln();
    buffer.writeln(strings.exerciseShareSharedVia);
    return buffer.toString();
  }

  final steps = exercise.steps!;
  final buffer = StringBuffer();
  buffer.writeln('${strings.exerciseShareDetailedHeader} — $exerciseName');
  buffer.writeln('📅 ${AppDateFormats.formatDateTimeShort(context, session.date)} · ${strings.sessionTypeDisplayName(session.sessionType)}');
  buffer.writeln('🔫 $platformName · $ammoName');
  buffer.writeln();
  buffer.writeln(strings.exerciseShareSteps);
  for (int i = 0; i < steps.length; i++) {
    final st = steps[i];
    final idx = (i + 1).toString().padLeft(2, '0');
    final icon = switch (st.type) {
      StepType.tir => '💥',
      StepType.deplacement => '🏃🏻‍♂️‍➡️',
      StepType.rechargement => '🔄',
      StepType.transition => '🔃',
      StepType.miseEnJoue => '⏺️',
      StepType.attente => '⏸️',
      StepType.securite => '🛡️',
      StepType.autre => '⚙️',
    };

    final stepLabel = strings.exerciseShareStepTypeLabel(st.type.name);
    buffer.writeln(
      '  $icon $idx — $stepLabel${st.position == null ? '' : ' · ${st.position!.name}'}',
    );

    final details = <String>[];
    if (st.shots != null) details.add(strings.exerciseShareShots(st.shots!));
    if (st.distanceM != null) details.add('${st.distanceM} m');
    if ((st.target ?? '').trim().isNotEmpty) {
      details.add(strings.exerciseShareTarget(st.target!.trim()));
    }
    if ((st.platformFrom ?? '').trim().isNotEmpty ||
        (st.platformTo ?? '').trim().isNotEmpty) {
      details.add(
        strings.exerciseSharePlatformTransfer(
          st.platformFrom ?? '—',
          st.platformTo ?? '—',
        ),
      );
    }
    if (st.reloadType != null) {
      details.add(strings.exerciseShareReload(st.reloadType!.name));
    }
    if (st.durationSeconds != null) details.add('${st.durationSeconds} s');
    if ((st.trigger ?? '').trim().isNotEmpty) {
      details.add(strings.exerciseShareTrigger(st.trigger!.trim()));
    }

    if (details.isNotEmpty) {
      buffer.writeln('    ${details.join(' · ')}');
    }
    if ((st.comment ?? '').trim().isNotEmpty) {
      buffer.writeln('    💬 ${st.comment!.trim()}');
    }
  }

  final maxDist = exercise.detailedMaxDistance ?? 0;
  buffer.writeln();
  buffer.writeln(
    '📊 ${strings.exerciseShareTotalShots} : ${strings.exerciseShareShots(exercise.detailedTotalShots)} · ${strings.exerciseShareTotalSteps(steps.length)} · $maxDist m',
  );
  buffer.writeln();
  buffer.writeln(strings.exerciseShareSharedVia);

  return buffer.toString();
}
