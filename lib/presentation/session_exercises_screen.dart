import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/exercise_display.dart';
import 'package:thot/utils/unit_converter.dart';
import 'package:thot/presentation/exercise_steps_carousel.dart' as steps_ui;
import 'package:thot/presentation/exercise_summary_text.dart' as summary_ui;
import 'package:thot/utils/exercise_share_text.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/utils/session_text_exporter.dart';
import 'package:thot/widgets/cross_platform_image.dart';
import 'package:thot/l10n/app_strings.dart';
import 'session_list_screen.dart';

BoxDecoration _sessionCardDecoration(BuildContext context,
    {double radius = 16}) {
  final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: isDark
        ? null
        : Border.all(
            color: LightColors.surfaceHighlight,
            width: 1.35,
          ),
    boxShadow: AppShadows.cardPremium,
  );
}

class SessionExercisesScreen extends StatelessWidget {
  final String? sessionId;

  const SessionExercisesScreen({super.key, this.sessionId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final converter = UnitConverter(provider.useMetric);
    final strings = AppStrings.of(context);

    final session = _findSession(provider);
    if (session == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                title: strings.sessionNotFoundTitle,
                subtitle: sessionId == null
                    ? strings.sessionNotFoundNoId
                    : strings.sessionNotFoundId(sessionId!),
                onBack: () => context.pop(),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: AppSpacing.paddingLg,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 56, color: colors.error),
                        const Gap(AppSpacing.md),
                        Text(strings.sessionOpenFailedTitle, style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const Gap(AppSpacing.xs),
                        Text(strings.sessionOpenFailedSubtitle, style: textStyles.bodyMedium?.copyWith(color: colors.secondary), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final subtitle =
        '${session.sessionType} • ${AppDateFormats.formatDateShort(context, session.date)} • ${AppDateFormats.formatTimeShort(context, session.date)}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                title: session.name,
                subtitle: subtitle,
                onBack: () => context.pop(),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push(
                        '/sessions/new?sessionId=${Uri.encodeComponent(session.id)}',
                      );
                    } else if (value == 'share') {
                      final summary = SessionTextExporter.buildSummary(
                        session: session,
                        provider: provider,
                        converter: converter,
                      );

                      if (kIsWeb) {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (_) => SessionShareSheet(session: session, summary: summary),
                        );
                      } else {
                        await SharePlus.instance.share(
                          ShareParams(
                            text: summary,
                            subject: '${strings.sessionShareSubjectPrefix}${session.name}',
                          ),
                        );
                      }
                    } else if (value == 'delete') {
                      provider.deleteSession(session.id);
                      if (context.mounted) context.pop();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(strings.sessionMenuEdit),
                    ),
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Text(strings.sessionMenuShare),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(strings.sessionMenuDelete),
                    ),
                  ],
                ),

              ),
            ),
            SliverToBoxAdapter(child: _StatsRow(session: session)),
            if (session.weatherEnabled) SliverToBoxAdapter(child: _WeatherCard(session: session, converter: converter)),
            SliverToBoxAdapter(child: _ExercisesSection(session: session, provider: provider, converter: converter)),
            if (session.exercises.isNotEmpty) SliverToBoxAdapter(child: _ProgressChart(session: session)),
            const SliverToBoxAdapter(child: Gap(AppSpacing.xl)),
          ],
        ),
      ),
    );
  }

  Session? _findSession(ThotProvider provider) {
    if (sessionId == null || sessionId!.isEmpty) {
      debugPrint('SessionExercisesScreen: sessionId null ou vide.');
      return null;
    }

    final decoded = Uri.decodeComponent(sessionId!);
    try {
      return provider.sessions.firstWhere((s) => s.id == decoded);
    } catch (_) {
      // Fallback : cherche aussi sans décodage (IDs anciens)
      try {
        return provider.sessions.firstWhere((s) => s.id == sessionId);
      } catch (_) {
        debugPrint('SessionExercisesScreen: session $decoded introuvable.');
        return null;
      }
    }
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget? trailing;

  const _Header({required this.title, required this.subtitle, required this.onBack, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: onBack, color: colors.onSurface),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textStyles.titleLarge?.copyWith(fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                const Gap(2),
                Text(subtitle, style: textStyles.labelSmall?.copyWith(color: colors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Session session;
  const _StatsRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final totalRounds = session.totalRounds;
    final avgPrecision = session.averagePrecision;
    final hasPrecision = session.hasCountedPrecision;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: _StatsStrip(
        shotsValue: '$totalRounds',
        precisionValue:
            hasPrecision ? '${avgPrecision.toStringAsFixed(0)}%' : '—',
        exercisesValue: '${session.exercises.length}',
        shotsLabel: strings.statsShotsLabelUpper,
        precisionLabel: strings.statsAvgPrecisionLabelUpper,
        exercisesLabel: strings.statsExercisesLabelUpper,
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final String shotsValue;
  final String precisionValue;
  final String exercisesValue;
  final String shotsLabel;
  final String precisionLabel;
  final String exercisesLabel;

  const _StatsStrip({
    required this.shotsValue,
    required this.precisionValue,
    required this.exercisesValue,
    required this.shotsLabel,
    required this.precisionLabel,
    required this.exercisesLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: _sessionCardDecoration(
        context,
        radius: 18,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatCell(
                label: shotsLabel,
                value: shotsValue,
                valueColor: colors.onSurface,
              ),
            ),
            Container(width: 1, color: colors.outline),
            Expanded(
              child: _StatCell(
                label: precisionLabel,
                value: precisionValue,
                valueColor: colors.primary,
              ),
            ),
            Container(width: 1, color: colors.outline),
            Expanded(
              child: _StatCell(
                label: exercisesLabel,
                value: exercisesValue,
                valueColor: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCell({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyles.labelSmall?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: textStyles.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Session session;
  final UnitConverter converter;
  const _WeatherCard({required this.session, required this.converter});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final items = <_WeatherItem>[];
    if (session.temperatureEnabled && session.temperature.trim().isNotEmpty) {
      items.add(
        _WeatherItem(
          icon: Icons.thermostat_rounded,
          label: strings.temperatureLabel,
          value: converter.parseTemperatureString(session.temperature),
        ),
      );
    }
    if (session.windEnabled && session.wind.trim().isNotEmpty) {
      items.add(
        _WeatherItem(
          icon: Icons.air_rounded,
          label: strings.windLabel,
          value: converter.parseWindSpeedString(session.wind),
        ),
      );
    }
    if (session.humidityEnabled && session.humidity.trim().isNotEmpty) {
      items.add(
        _WeatherItem(
          icon: Icons.water_drop_rounded,
          label: strings.humidityLabel,
          value: session.humidity,
        ),
      );
    }
    if (session.pressureEnabled && session.pressure.trim().isNotEmpty) {
      items.add(
        _WeatherItem(
          icon: Icons.compress_rounded,
          label: strings.pressureLabel,
          value: session.pressure,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      padding: AppSpacing.paddingLg,
      decoration: _sessionCardDecoration(
        context,
        radius: AppRadius.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_rounded, size: 20, color: colors.primary),
              const Gap(8),
              Text(
                strings.weatherTitleShort,
                style:
                    textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: items.map((i) => _WeatherChip(item: i)).toList(),
          ),
        ],
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final _WeatherItem item;
  const _WeatherChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 18, color: colors.secondary),
          const Gap(8),
          Text(item.label, style: textStyles.labelSmall?.copyWith(color: colors.secondary, fontWeight: FontWeight.w700)),
          const Gap(6),
          Text(item.value, style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _WeatherItem {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherItem({required this.icon, required this.label, required this.value});
}

class _ExercisesSection extends StatelessWidget {
  final Session session;
  final ThotProvider provider;
  final UnitConverter converter;

  const _ExercisesSection({required this.session, required this.provider, required this.converter});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    // Utiliser la session fraîche depuis le provider pour que les cartes
    // d'exercices reflètent toujours les dernières modifications.
    final freshSession = provider.sessions
        .where((s) => s.id == session.id)
        .firstOrNull ??
        session;

    final exercises = freshSession.exercises;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/train.svg',
                width: 16,
                height: 16,
                colorFilter:
                    ColorFilter.mode(colors.primary, BlendMode.srcIn),
              ),
              const Gap(8),
              Text(
                strings.exercisesSectionTitle,
                style: textStyles.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          if (exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: _sessionCardDecoration(
                context,
                radius: AppRadius.sm,
              ),
              child: Column(
                children: [
                  Icon(Icons.fitness_center_rounded, color: colors.outline, size: 40),
                  const Gap(8),
                  Text(
                    strings.noExerciseForSession,
                    style: textStyles.bodyMedium
                        ?.copyWith(color: colors.secondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final ex = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ExerciseCard(
                  sessionId: freshSession.id,
                  index: index,
                  exercise: ex,
                  provider: provider,
                  converter: converter,
                ),
              );
            }),
          const Gap(AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String sessionId;
  final int index;
  final Exercise exercise;
  final ThotProvider provider;
  final UnitConverter converter;

  const _ExerciseCard({required this.sessionId, required this.index, required this.exercise, required this.provider, required this.converter});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final weaponName = weaponDisplayName(provider, exercise);
    final ammoName = ammoDisplayName(provider, exercise);
    final accessories = exercise.equipmentIds
        .map((id) => provider.accessories.where((a) => a.id == id).firstOrNull)
        .whereType<Accessory>()
        .toList();

    void openTargetPhoto(ExercisePhoto photo) {
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          final dialogColors = Theme.of(ctx).colorScheme;
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    color: dialogColors.surface,
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CrossPlatformImage(
                          filePath: photo.path,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                    color: dialogColors.onSurface,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          dialogColors.surface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final exerciseIndexLabel = strings.sessionExerciseDefaultTitle(index + 1);
    final exerciseTitle = exercise.name.trim().isEmpty
        ? exerciseIndexLabel
        : exercise.name.trim();

    final primaryPhoto = exercise.targetPhotos.isNotEmpty
        ? exercise.targetPhotos.first
        : null;
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: _sessionCardDecoration(
        context,
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: exercise title + index + precision toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseTitle,
                      style: textStyles.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Text(
                      exerciseIndexLabel,
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (exercise.precision != null) ...[
                const Gap(10),
                Theme(
                  data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => provider.toggleExercisePrecisionEnabled(sessionId: sessionId, exerciseId: exercise.id),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: LightColors.surfaceHighlight,
                            width: 1.35,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (exercise.precisionEnabled)
                              SvgPicture.asset(
                                'assets/images/target.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn),
                              )
                            else
                              Icon(Icons.visibility_off_rounded, size: 16, color: colors.secondary),
                            if (exercise.isPrecisionCounted) ...[
                              const Gap(6),
                              Text(
                                '${exercise.precision!.toStringAsFixed(0)}%',
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (value) async {
                  if (value == 'share') {
                    final session = provider.sessions
                        .where((s) => s.id == sessionId)
                        .firstOrNull;
                    if (session == null) return;
                    final summary = generateExerciseShareText(
                      session: session,
                      exercise: exercise,
                      provider: provider,
                      converter: converter,
                    );
                    await Clipboard.setData(ClipboardData(text: summary));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.copiedSnack)),
                    );
                  } else if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(strings.confirmDeleteTitle),
                        content: Text(strings.sessionMenuDelete),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(strings.actionCancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.error,
                            ),
                            child: Text(strings.actionDelete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    provider.deleteExerciseFromSession(
                      sessionId: sessionId,
                      exerciseId: exercise.id,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'share',
                    child: Text(strings.sessionMenuShare),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(strings.sessionMenuDelete),
                  ),
                ],
              ),
            ],
          ),
          const Gap(AppSpacing.md),

          // Card 1: weapon & equipment details
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.sessionWeaponAndEquipmentDetailsTitle,
                  style: textStyles.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Gap(AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: weapon & ammo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(label: strings.sessionLabelWeapon, value: weaponName),
                          _InfoRow(label: strings.sessionLabelAmmo, value: ammoName),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 56,
                      color: colors.outline,
                    ),
                    const Gap(AppSpacing.md),
                    // Right column: equipment & target
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (accessories.isNotEmpty)
                            _InfoRow(
                              label: strings.equipmentsTitle,
                              value:
                                  accessories.map((a) => a.name).join(', '),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Gap(AppSpacing.md),

          // Card 2: shooting results (target photo + shots & distance)
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.sessionShootingResultsTitle,
                  style: textStyles.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Gap(AppSpacing.md),
                if (exercise.steps != null && exercise.steps!.isNotEmpty) ...[
steps_ui.ExerciseStepsCarousel(steps: exercise.steps!, useMetric: provider.useMetric),
                  const Gap(AppSpacing.sm),
summary_ui.ExerciseSummaryText(steps: exercise.steps!, useMetric: provider.useMetric),
                  const Gap(AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        colors.primary.withValues(alpha: 0.12),
                        colors.surface,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: LightColors.surfaceHighlight,
                              width: 1.35,
                            ),
                          ),
                          child: Text(
                            strings.exerciseAutoBadge,
                            style: textStyles.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
strings.exerciseAutoTotals(
                              exercise.detailedTotalShots,
                              exercise.steps!.length,
                              (exercise.detailedMaxDistance ?? 0),
                              converter.useMetric ? 'm' : 'yd',
                            ),
                            style: textStyles.bodySmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: main target photo (if any)
                      if (primaryPhoto != null) ...[
                        GestureDetector(
                          onTap: () => openTargetPhoto(primaryPhoto),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CrossPlatformImage(
                                    filePath: primaryPhoto.path,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Gap(4),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  primaryPhoto.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(AppSpacing.md),
                      ],

                      // Divider between photo and stats
                      if (primaryPhoto != null)
                        Container(
                          width: 1,
                          height: 120,
                          color: colors.outline,
                        ),
                      if (primaryPhoto != null) const Gap(AppSpacing.md),

                      // Right: shots & distance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              label: strings.sessionLabelShots,
                              value: '${exercise.shotsFired}',
                            ),
                            _InfoRow(
                              label: strings.sessionLabelDistance,
                              value: converter.formatDistance(exercise.distance),
                            ),
                            if (exercise.targetName != null &&
                                exercise.targetName!.trim().isNotEmpty)
                              _InfoRow(
                                label: strings.sessionLabelTarget,
                                value: exercise.targetName!,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),


          if (exercise.observations.trim().isNotEmpty) ...[
            const Gap(AppSpacing.md),
            Text(strings.observationsTitle, style: textStyles.labelSmall?.copyWith(color: colors.secondary, fontWeight: FontWeight.w700)),
            const Gap(4),
            Text(exercise.observations, style: textStyles.bodySmall?.copyWith(height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textStyles.labelSmall?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(2),
          Text(
            value,
            style: textStyles.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final Session session;
  const _ProgressChart({required this.session});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final spots = <FlSpot>[];
    var x = 0;
    for (int i = 0; i < session.exercises.length; i++) {
      final ex = session.exercises[i];
      if (!ex.isPrecisionCounted) continue;
      spots.add(FlSpot(x.toDouble(), ex.precision!));
      x++;
    }
    if (spots.length < 2) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(strings.progressionPrecisionTitle, style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
          const Gap(AppSpacing.md),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => colors.onSurface.withValues(alpha: 0.75),
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((s) => LineTooltipItem('${s.y.toStringAsFixed(0)}%', textStyles.labelLarge!.copyWith(color: colors.surface, fontWeight: FontWeight.w900)))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: colors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: colors.primary.withValues(alpha: 0.10)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
