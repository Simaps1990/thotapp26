import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:thot/data/exercise_step.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/unit_converter.dart';
import 'package:thot/utils/exercise_display.dart';

/// Builds a readable, structured, plain-text summary for a shooting session.
abstract final class SessionTextExporter {
  static String buildSummary({
    required BuildContext context,
    required Session session,
    required ThotProvider provider,
    required UnitConverter converter,
  }) {
    final strings = AppStrings.of(context);
    final locale = (provider.appLocale ?? const Locale('fr')).toLanguageTag();
    final dateFormat = DateFormat('d MMMM yyyy HH:mm', locale);
    final buffer = StringBuffer();

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(strings.textExportTitle);
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    buffer.writeln('📌 ${session.name}');
    buffer.writeln('📅 ${_capitalizeFirstLetter(dateFormat.format(session.date))}');
    if (session.location.trim().isNotEmpty) buffer.writeln('📍 ${session.location}');
    if (session.shootingDistance != null && session.shootingDistance!.trim().isNotEmpty) {
      buffer.writeln('🎯 ${session.shootingDistance}');
    }
    buffer.writeln(strings.textExportType(session.sessionType));
    buffer.writeln();

    if (session.weatherEnabled) {
      final hasAnyWeatherField =
          (session.temperatureEnabled && session.temperature.isNotEmpty) ||
          (session.windEnabled && session.wind.isNotEmpty) ||
          (session.humidityEnabled && session.humidity.isNotEmpty) ||
          (session.pressureEnabled && session.pressure.isNotEmpty);
      if (hasAnyWeatherField) {
        buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        buffer.writeln(strings.textExportWeatherHeader);
        buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        if (session.temperatureEnabled && session.temperature.isNotEmpty) {
          buffer.writeln(strings.textExportTemperature(converter.parseTemperatureString(session.temperature)));
        }
        if (session.windEnabled && session.wind.isNotEmpty) {
          buffer.writeln(strings.textExportWind(converter.parseWindSpeedString(session.wind)));
        }
        if (session.humidityEnabled && session.humidity.isNotEmpty) buffer.writeln(strings.textExportHumidity(session.humidity));
        if (session.pressureEnabled && session.pressure.isNotEmpty) buffer.writeln(strings.textExportPressure(session.pressure));
        buffer.writeln();
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(strings.textExportStatsHeader);
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(strings.textExportTotalShots(session.totalRounds));
    buffer.writeln(strings.textExportAvgPrecision(session.hasCountedPrecision ? '${session.averagePrecision.toStringAsFixed(1)}%' : '—'));
    buffer.writeln(strings.textExportExerciseCount(session.exercises.length));
    buffer.writeln();

    if (session.exercises.isNotEmpty) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln(strings.textExportExercisesHeader);
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      for (int i = 0; i < session.exercises.length; i++) {
        final ex = session.exercises[i];
        final platformName = platformDisplayName(context, provider, ex);
        final ammoName = ammoDisplayName(context, provider, ex);

        final equipmentNames = _resolveEquipmentNames(ex.equipmentIds, provider);

        buffer.writeln();
        buffer.writeln('${strings.textExportExerciseN(i + 1)}${ex.name.trim().isEmpty ? '' : ' — ${ex.name}'}');
        buffer.writeln('   ├─ ${strings.textExportPlatformLabel}: $platformName');
        buffer.writeln('   ├─ ${strings.textExportAmmoLabel}: $ammoName');
        if (equipmentNames.isNotEmpty) buffer.writeln('   ├─ ${strings.textExportEquipmentLabel}: ${equipmentNames.join(', ')}');
        if (ex.targetName != null && ex.targetName!.trim().isNotEmpty) buffer.writeln('   ├─ ${strings.textExportTargetLabel}: ${ex.targetName}');

        final hasSteps = ex.steps != null && ex.steps!.isNotEmpty;
        if (!hasSteps) {
          buffer.writeln('   ├─ ${strings.textExportDistanceLabel}: ${converter.formatDistance(ex.distance)}');
          buffer.writeln('   ├─ ${strings.textExportShotsFiredLabel}: ${ex.shotsFired}');
          if (ex.isPrecisionCounted) buffer.writeln('   ├─ ${strings.textExportPrecisionLabel}: ${ex.precision!.toStringAsFixed(1)}%');
          if (ex.observations.trim().isNotEmpty) {
            buffer.writeln('   └─ ${strings.textExportNotesLabel}: ${ex.observations}');
          } else {
            buffer.writeln('   └─ ${strings.textExportNoNotes}');
          }
          continue;
        }

        buffer.writeln('   ├─ ${strings.textExportDetailedMode}');
        for (int si = 0; si < ex.steps!.length; si++) {
          final st = ex.steps![si];
          final idx = (si + 1).toString().padLeft(2, '0');
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

          final details = <String>[];
          if (st.position != null) details.add(st.position!.name);
          if (st.shots != null) details.add(strings.textExportStepShots(st.shots!));
          if (st.distanceM != null) details.add('${st.distanceM} m');
          if ((st.target ?? '').trim().isNotEmpty) details.add(strings.textExportStepTarget(st.target!.trim()));
          if (st.reloadType != null) details.add(strings.textExportStepReload(st.reloadType!.name));
          if (st.durationSeconds != null) details.add('${st.durationSeconds} s');
          if ((st.trigger ?? '').trim().isNotEmpty) details.add(strings.textExportStepTrigger(st.trigger!.trim()));
          if ((st.platformFrom ?? '').trim().isNotEmpty || (st.platformTo ?? '').trim().isNotEmpty) {
            details.add(strings.textExportStepTransition(st.platformFrom, st.platformTo));
          }

          buffer.writeln('   │   $icon $idx — ${st.type.name}${details.isEmpty ? '' : ' · ${details.join(' · ')}'}');
          if ((st.comment ?? '').trim().isNotEmpty) {
            buffer.writeln('   │      💬 ${st.comment!.trim()}');
          }
        }
        buffer.writeln('   ├─ ${strings.textExportAutoTotal(ex.detailedTotalShots)}');
        buffer.writeln('   ├─ ${strings.textExportAutoMaxDistance(ex.detailedMaxDistance ?? 0)}');
        if (ex.isPrecisionCounted) buffer.writeln('   ├─ ${strings.textExportPrecisionLabel}: ${ex.precision!.toStringAsFixed(1)}%');
        if (ex.observations.trim().isNotEmpty) {
          buffer.writeln('   └─ ${strings.textExportNotesLabel}: ${ex.observations}');
        } else {
          buffer.writeln('   └─ ${strings.textExportNoNotes}');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(strings.textExportFooter);
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString();
  }

  static List<String> _resolveEquipmentNames(List<String> ids, ThotProvider provider) {
    if (ids.isEmpty) return const [];
    final names = <String>[];
    final seen = HashSet<String>();
    for (final id in ids) {
      if (!seen.add(id)) continue;
      final accessory = provider.accessories.where((a) => a.id == id).firstOrNull;
      if (accessory != null && accessory.name.trim().isNotEmpty) names.add(accessory.name);
    }
    return names;
  }

  static String _capitalizeFirstLetter(String value) {
    if (value.isEmpty) return value;
    return value.replaceFirstMapped(
      RegExp(r'[A-Za-zÀ-ÿ]'),
      (match) => match.group(0)!.toUpperCase(),
    );
  }
}
