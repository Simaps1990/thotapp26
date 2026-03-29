import 'package:thot/data/models.dart';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/utils/exercise_display.dart';
import 'package:thot/utils/unit_converter.dart';

String generateExerciseShareText({
  required Session session,
  required Exercise exercise,
  required ThotProvider provider,
  required UnitConverter converter,
}) {
  final weaponName = weaponDisplayName(provider, exercise);
  final ammoName = ammoDisplayName(provider, exercise);
  final target = (exercise.targetName ?? '').trim();

  if (exercise.steps == null || exercise.steps!.isEmpty) {
    final buffer = StringBuffer();
    buffer.writeln('⚡ EXERCICE — ${exercise.name.trim().isEmpty ? 'Sans nom' : exercise.name.trim()}');
    buffer.writeln('📅 ${session.date.toLocal()} · ${session.sessionType}');
    buffer.writeln('🔫 $weaponName · $ammoName${target.isEmpty ? '' : ' · $target'}');
    buffer.writeln();
    buffer.writeln('Mode simple : ${exercise.shotsFired} coups · ${converter.formatDistance(exercise.distance)}');
    if (exercise.observations.trim().isNotEmpty) {
      buffer.writeln('💬 ${exercise.observations.trim()}');
    }
    buffer.writeln();
    buffer.writeln('✅ Partagé via THOT');
    return buffer.toString();
  }

  final steps = exercise.steps!;
  final buffer = StringBuffer();
  buffer.writeln('📋 EXERCICE — ${exercise.name.trim().isEmpty ? 'Sans nom' : exercise.name.trim()}');
  buffer.writeln('📅 ${session.date.toLocal()} · ${session.sessionType}');
  buffer.writeln('🔫 $weaponName · $ammoName');
  buffer.writeln();
  buffer.writeln('Étapes :');
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

    buffer.writeln('  $icon $idx — ${st.type.name.toUpperCase()}${st.position == null ? '' : ' · ${st.position!.name}'}');

    final details = <String>[];
    if (st.shots != null) details.add('${st.shots} coups');
    if (st.distanceM != null) details.add('${st.distanceM} m');
    if ((st.target ?? '').trim().isNotEmpty) details.add('cible ${st.target!.trim()}');
    if ((st.weaponFrom ?? '').trim().isNotEmpty || (st.weaponTo ?? '').trim().isNotEmpty) {
      details.add('de ${st.weaponFrom ?? '—'} vers ${st.weaponTo ?? '—'}');
    }
    if (st.reloadType != null) details.add('rechargement ${st.reloadType!.name}');
    if (st.durationSeconds != null) details.add('${st.durationSeconds} s');
    if ((st.trigger ?? '').trim().isNotEmpty) details.add('déclencheur: ${st.trigger!.trim()}');

    if (details.isNotEmpty) {
      buffer.writeln('    ${details.join(' · ')}');
    }
    if ((st.comment ?? '').trim().isNotEmpty) {
      buffer.writeln('    💬 ${st.comment!.trim()}');
    }
  }

  final maxDist = exercise.detailedMaxDistance ?? 0;
  buffer.writeln();
  buffer.writeln('📊 Total : ${exercise.detailedTotalShots} coups · ${steps.length} étapes · $maxDist m');
  buffer.writeln();
  buffer.writeln('✅ Partagé via THOT');

  return buffer.toString();
}
