import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:thot/data/thot_provider.dart';
import 'package:thot/data/models.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/app_date_formats.dart';

void showStatisticsModal(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final baseBackground = Theme.of(context).scaffoldBackgroundColor;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final height = MediaQuery.of(context).size.height * 0.82;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height,
        decoration: BoxDecoration(
          color: baseBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LightColors.iconInactive.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(AppSpacing.md),
            StatisticsScreen(
              backgroundColor: baseBackground,
              useSafeArea: false,
            ),
          ],
        ),
      );
    },
  );
}

class StatisticsScreen extends StatefulWidget {
  final Color? backgroundColor;
  final bool useSafeArea;

  const StatisticsScreen({
    super.key,
    this.backgroundColor,
    this.useSafeArea = true,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  BoxDecoration _statsCardDecoration(
    BuildContext context, {
    double radius = 16,
    Color? borderColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? (isDark ? colors.outline : LightColors.surfaceHighlight),
        width: 1.2,
      ),
      boxShadow: AppShadows.cardPremium,
    );
  }

  double? _computeRecentPrecisionDelta(List<Session> sessionsWithPrecision) {
    if (sessionsWithPrecision.length < 2) return null;

    final sorted = [...sessionsWithPrecision]
      ..sort((a, b) => a.date.compareTo(b.date));

    final recentCount = math.min(3, sorted.length);
    final recent = sorted.sublist(sorted.length - recentCount);

    final previousEnd = sorted.length - recentCount;
    if (previousEnd <= 0) return null;

    final previousStart = math.max(0, previousEnd - recentCount);
    final previous = sorted.sublist(previousStart, previousEnd);
    if (previous.isEmpty) return null;

    final recentAvg =
        recent.map<double>((s) => s.averagePrecision).reduce((a, b) => a + b) /
            recent.length;

    final previousAvg =
        previous.map<double>((s) => s.averagePrecision).reduce((a, b) => a + b) /
            previous.length;

    return recentAvg - previousAvg;
  }

  int? _computeRegularityScore(List<Session> sessionsWithPrecision) {
    if (sessionsWithPrecision.length < 2) return null;

    final values =
        sessionsWithPrecision.map<double>((s) => s.averagePrecision).toList();

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final stdDev = math.sqrt(variance);

    final score = (100 - (stdDev * 2.4)).clamp(0, 100).round();
    return score;
  }

  List<_WeeklyBucket> _buildWeeklyBuckets(List<Session> sessions) {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);

    final buckets = <_WeeklyBucket>[];
    for (int i = 5; i >= 0; i--) {
      final start = currentWeekStart.subtract(Duration(days: 7 * i));
      final end = start.add(const Duration(days: 7));

      final weekSessions = sessions.where((s) {
        final date = s.date;
        return !date.isBefore(start) && date.isBefore(end);
      }).toList();

      final totalShots = weekSessions.fold<int>(
        0,
        (sum, s) => sum + s.totalRounds,
      );

      buckets.add(
        _WeeklyBucket(
          label: '${start.day}/${start.month}',
          sessions: weekSessions.length,
          shots: totalShots,
        ),
      );
    }

    return buckets;
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  String _trendLabel(AppStrings strings, double? delta) {
    if (delta == null) return strings.statisticsTrendStableLabel;
    if (delta.abs() < 0.5) return strings.statisticsTrendStableLabel;
    final sign = delta > 0 ? '+' : '';
    return strings.statisticsTrendPointsLabel('$sign${delta.toStringAsFixed(0)}');
  }

  Color _trendTone(BuildContext context, double? delta) {
    final colors = Theme.of(context).colorScheme;
    if (delta == null || delta.abs() < 0.5) return colors.secondary;
    return delta > 0 ? colors.primary : colors.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final baseBackground =
        widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    final sessions = provider.sessions;
    final sessionsWithPrecision =
        sessions.where((s) => s.hasCountedPrecision).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final totalShots = provider.totalRoundsFired;
    final totalSessions = provider.totalSessions;
    final totalPlatforms = provider.platforms.length;
    final totalAmmos = provider.ammos.length;
    final totalAccessories = provider.accessories.length;

    final avgPrecision = sessionsWithPrecision.isEmpty
        ? null
        : sessionsWithPrecision
                .map((s) => s.averagePrecision)
                .reduce((a, b) => a + b) /
            sessionsWithPrecision.length;

    final bestSession = sessionsWithPrecision.isEmpty
        ? null
        : ([...sessionsWithPrecision]
              ..sort((a, b) => b.averagePrecision.compareTo(a.averagePrecision)))
            .first;

    final longestSession = sessions.isEmpty
        ? null
        : ([...sessions]..sort((a, b) => b.totalRounds.compareTo(a.totalRounds))).first;

    final lastSession = sessions.isEmpty
        ? null
        : ([...sessions]..sort((a, b) => b.date.compareTo(a.date))).first;

    final mostUsedPlatform = provider.platforms.isEmpty
        ? null
        : ([...provider.platforms]..sort((a, b) => b.totalRounds.compareTo(a.totalRounds)))
            .first;

    final topPlatforms = [...provider.platforms]
      ..sort((a, b) => b.totalRounds.compareTo(a.totalRounds));
    final topPlatformsLimited = topPlatforms.take(4).toList();

    final lowestAmmo = provider.ammos.isEmpty
        ? null
        : ([...provider.ammos]
              ..sort((a, b) {
                final aRatio = a.lowStockThreshold <= 0
                    ? double.infinity
                    : a.quantity / a.lowStockThreshold;
                final bRatio = b.lowStockThreshold <= 0
                    ? double.infinity
                    : b.quantity / b.lowStockThreshold;
                return aRatio.compareTo(bRatio);
              }))
            .first;

    final perfectSessions = sessions
        .where((s) => s.hasCountedPrecision && s.averagePrecision >= 100)
        .length;

    final totalMaintenances = provider.platforms
        .expand((w) => w.history)
        .where((h) => h.type == 'entretien')
        .length;

    final totalRevisions = provider.platforms
        .expand((w) => w.history)
        .where((h) => h.type == 'revision')
        .length;

    final sessionsThisMonth = sessions.where((s) {
      final now = DateTime.now();
      return s.date.year == now.year && s.date.month == now.month;
    }).length;

    final sessionsThisWeek = sessions.where((s) {
      final now = DateTime.now();
      final startOfWeek = _startOfWeek(now);
      return !s.date.isBefore(startOfWeek);
    }).length;

    final platformNeedingRevision = provider.platforms.isEmpty
        ? null
        : ([...provider.platforms]
              ..sort((a, b) => b.revisionProgress.compareTo(a.revisionProgress)))
            .first;

    final platformNeedingCleaning = provider.platforms.isEmpty
        ? null
        : ([...provider.platforms]
              ..sort((a, b) => b.cleaningProgress.compareTo(a.cleaningProgress)))
            .first;

    final platformTypeCounts = <String, int>{};
    for (final platform in provider.platforms) {
      platformTypeCounts[platform.type] = (platformTypeCounts[platform.type] ?? 0) + 1;
    }

    final precisionDelta = _computeRecentPrecisionDelta(sessionsWithPrecision);
    final regularityScore = _computeRegularityScore(sessionsWithPrecision);
    final weeklyBuckets = _buildWeeklyBuckets(sessions);

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  strings.statisticsPageTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              strings.statisticsPageSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Divider(color: colors.outline),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(title: strings.statisticsGlobalSummaryTitle),
                const Gap(AppSpacing.md),
                _StatsGrid(
                  childAspectRatio: 1.55,
                  children: [
                    _KpiCard(
                      title: strings.statisticsSessionsLabel,
                      value: '$totalSessions',
                      footnote: '${strings.statisticsThisMonthLabel}: $sessionsThisMonth',
                      icon: Icons.timeline_rounded,
                      tone: colors.primary,
                    ),
                    _KpiCard(
                      title: strings.statisticsShotsFiredLabel,
                      value: '$totalShots',
                      footnote: '${strings.statisticsThisWeekLabel}: $sessionsThisWeek',
                      icon: Icons.gps_fixed_rounded,
                      tone: colors.primary,
                    ),
                    _KpiCard(
                      title: strings.statisticsAveragePrecisionLabel,
                      value: avgPrecision == null
                          ? '—'
                          : '${avgPrecision.toStringAsFixed(0)}%',
                      footnote: _trendLabel(strings, precisionDelta),
                      icon: Icons.track_changes_rounded,
                      tone: _trendTone(context, precisionDelta),
                    ),
                    _KpiCard(
                      title: strings.statisticsRegularityLabel,
                      value: regularityScore == null ? '—' : '$regularityScore',
                      suffix: regularityScore == null ? null : '/100',
                      footnote: strings.statisticsSessionsStabilityLabel,
                      icon: Icons.insights_rounded,
                      tone: colors.secondary,
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),
                _SectionTitle(title: strings.statisticsMyEquipmentTitle),
                const Gap(AppSpacing.md),
                SizedBox(
                  height: 112,
                  child: Row(
                    children: [
                      Expanded(
                        child: _EquipmentStatCard(
                          label: strings.statisticsPlatformsLabel,
                          value: '$totalPlatforms',
                          svgAsset: 'assets/images/tube.svg',
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: _EquipmentStatCard(
                          label: strings.statisticsAmmosLabel,
                          value: '$totalAmmos',
                          svgAsset: 'assets/images/pointe.svg',
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: _EquipmentStatCard(
                          label: strings.statisticsAccessoriesLabel,
                          value: '$totalAccessories',
                          svgAsset: 'assets/images/material.svg',
                          iconSize: 84,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsPrecisionTitle),
                const Gap(AppSpacing.md),
                _AnalyticsLineCard(
                  title: strings.statisticsAveragePrecisionLabel,
                  value: avgPrecision == null ? '—' : '${avgPrecision.toStringAsFixed(0)}%',
                  badge: _trendLabel(strings, precisionDelta),
                  badgeTone: _trendTone(context, precisionDelta),
                  tone: colors.tertiary,
                  points: sessionsWithPrecision
                      .map(
                        (s) => _LinePoint(
                          label: '${s.date.day}/${s.date.month}',
                          value: s.averagePrecision.toDouble(),
                        ),
                      )
                      .toList(),
                  footerLeft: '${sessionsWithPrecision.length} ${strings.statisticsSessionsWithPrecisionLabel}',
                  footerRight:
                      regularityScore == null ? null : strings.statisticsRegularityScoreValue(regularityScore),
                  emptyLabel: strings.statisticsPrecisionChartEmptyLabel,
                ),
                const Gap(AppSpacing.md),
                _StatsGrid(
                  childAspectRatio: 1.55,
                  children: [
                    _KpiCard(
                      title: strings.statisticsPerfectSessionsLabel,
                      value: '$perfectSessions',
                      footnote: totalSessions == 0 ? '0%' : '${((perfectSessions / totalSessions) * 100).round()}%',
                      icon: Icons.workspace_premium_rounded,
                      tone: colors.primary,
                    ),
                    _KpiCard(
                      title: strings.statisticsBestSessionLabel,
                      value: bestSession == null
                          ? '—'
                          : bestSession.averagePrecision.toStringAsFixed(0),
                      suffix: bestSession == null ? null : '%',
                      footnote: bestSession?.name,
                      icon: Icons.emoji_events_rounded,
                      tone: colors.secondary,
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsRhythmTitle),
                const Gap(AppSpacing.md),
                _ActivityBarsCard(
                  title: strings.statisticsRecentPaceTitle,
                  subtitle: strings.statisticsSessionsPerWeekLabel,
                  tone: colors.primary,
                  buckets: weeklyBuckets,
                  totalLabel: '${strings.statisticsThisMonthLabel}: $sessionsThisMonth',
                  emptyLabel: strings.statisticsRhythmChartEmptyLabel,
                ),
                const Gap(AppSpacing.md),
                _StatsGrid(
                  childAspectRatio: 1.92,
                  children: [
                    _KpiCard(
                      title: strings.statisticsThisWeekLabel,
                      value: '$sessionsThisWeek',
                      icon: Icons.date_range_rounded,
                      tone: colors.secondary,
                    ),
                    _KpiCard(
                      title: strings.statisticsThisMonthLabel,
                      value: '$sessionsThisMonth',
                      icon: Icons.calendar_today_rounded,
                      tone: colors.secondary,
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsMaintenanceTitle),
                const Gap(AppSpacing.md),
                _MaintenanceOverviewCard(
                  revisionLabel: strings.statisticsClosestRevisionPlatformLabel,
                  cleaningLabel: strings.statisticsClosestCleaningPlatformLabel,
                  revisionPlatform: platformNeedingRevision?.name ?? '—',
                  cleaningPlatform: platformNeedingCleaning?.name ?? '—',
                  revisionProgress: platformNeedingRevision?.revisionProgress ?? 0,
                  cleaningProgress: platformNeedingCleaning?.cleaningProgress ?? 0,
                  revisionCount: totalRevisions,
                  cleaningCount: totalMaintenances,
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsSmartIndicatorsTitle),
                const Gap(AppSpacing.md),
                _InsightRow(
                  icon: Icons.touch_app_rounded,
                  label: strings.statisticsMostUsedPlatformLabel,
                  value: mostUsedPlatform == null
                      ? '—'
                      : '${mostUsedPlatform.name} • ${strings.statisticsSmartIndicatorShotsValue(mostUsedPlatform.totalRounds)}',
                  tone: colors.primary,
                ),
                const Gap(AppSpacing.sm),
                _InsightRow(
                  icon: Icons.warning_amber_rounded,
                  label: strings.statisticsMostCriticalAmmoLabel,
                  value: lowestAmmo == null
                      ? '—'
                      : '${lowestAmmo.name} • ${strings.statisticsSmartIndicatorAmmoValue(lowestAmmo.quantity, lowestAmmo.lowStockThreshold)}',
                  tone: colors.tertiary,
                ),
                const Gap(AppSpacing.sm),
                _InsightRow(
                  icon: Icons.local_fire_department_rounded,
                  label: strings.statisticsLongestSessionLabel,
                  value: longestSession == null
                      ? '—'
                      : '${longestSession.name} • ${strings.statisticsSmartIndicatorShotsValue(longestSession.totalRounds)}',
                  tone: colors.primary,
                ),
                const Gap(AppSpacing.sm),
                _InsightRow(
                  icon: Icons.history_rounded,
                  label: strings.statisticsLastSessionLabel,
                  value: lastSession == null
                      ? '—'
                      : '${lastSession.name} • ${AppDateFormats.formatDateShort(context, lastSession.date)}',
                  tone: colors.secondary,
                ),
                const Gap(AppSpacing.lg),

                // ── Cost statistics ───────────────────────────────
                Builder(builder: (_) {
                  final monthlyCosts = provider.getMonthlyCosts(6);
                  final totalCost6m = monthlyCosts.fold<double>(0, (s, m) => s + ((m['cost'] as double?) ?? 0));
                  final hasCosts = totalCost6m > 0;
                  final topAmmos = provider.getTopAmmosByCost(6);

                  // Derive currency symbol from user's ammo data.
                  String currencySymbol(String code) {
                    switch (code) {
                      case 'USD': return '\$';
                      case 'CAD': return 'CA\$';
                      case 'GBP': return '£';
                      case 'CHF': return 'CHF';
                      case 'JPY': return '¥';
                      case 'AUD': return 'A\$';
                      case 'EUR':
                      default: return '€';
                    }
                  }
                  // Use the dominant currency among priced ammos.
                  final pricedAmmos = provider.ammos.where((a) => a.unitPrice != null && a.unitPrice! > 0).toList();
                  final dominantCurrency = pricedAmmos.isEmpty
                      ? 'EUR'
                      : (pricedAmmos
                            .fold<Map<String, int>>({}, (m, a) {
                              m[a.currency] = (m[a.currency] ?? 0) + 1;
                              return m;
                            })
                            .entries
                            .reduce((a, b) => a.value >= b.value ? a : b)
                          ).key;
                  final sym = currencySymbol(dominantCurrency);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle(title: strings.statisticsCostTitle),
                      const Gap(AppSpacing.md),
                      if (!hasCosts)
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: (context.findAncestorStateOfType<_StatisticsScreenState>())
                                  ?._statsCardDecoration(context) ??
                              BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                border: Border.all(color: colors.outline),
                              ),
                          child: Column(
                            children: [
                              Icon(Icons.attach_money_rounded, size: 40, color: colors.secondary.withValues(alpha: 0.5)),
                              const Gap(AppSpacing.sm),
                              Text(
                                strings.statisticsCostChartEmptyLabel,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.secondary),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _CostDashboardCard(
                          monthlyCosts: monthlyCosts,
                          topAmmos: topAmmos,
                          provider: provider,
                          totalCost: totalCost6m,
                          currencySymbol: sym,
                        ),
                      ],
                      const Gap(AppSpacing.lg),
                    ],
                  );
                }),

                _SectionTitle(title: strings.statisticsPlatformsByTypeTitle),
                const Gap(AppSpacing.md),
                _ModernDonutCard(
                  counts: platformTypeCounts,
                ),
                const Gap(AppSpacing.md),
                _TopPlatformsBarsCard(
                  title: strings.statisticsTopPlatformsTitle,
                  subtitle: strings.statisticsPlatformVolumeLabel,
                  platforms: topPlatformsLimited,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: baseBackground,
      body: widget.useSafeArea ? SafeArea(child: content) : content,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Text(
      title,
      style: textStyles.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colors.secondary,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;

  const _StatsGrid({
    required this.children,
    this.childAspectRatio = 1.55,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final String? footnote;
  final IconData icon;
  final Color tone;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tone,
    this.suffix,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(12),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: tone),
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.labelMedium?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const Gap(4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    suffix!,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (footnote != null) ...[
            const Gap(6),
            Text(
              footnote!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyles.labelSmall?.copyWith(
                color: colors.secondary,
                height: 1.0,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalyticsLineCard extends StatelessWidget {
  final String title;
  final String value;
  final String badge;
  final Color badgeTone;
  final Color tone;
  final List<_LinePoint> points;
  final String footerLeft;
  final String? footerRight;
  final String emptyLabel;

  const _AnalyticsLineCard({
    required this.title,
    required this.value,
    required this.badge,
    required this.badgeTone,
    required this.tone,
    required this.points,
    required this.footerLeft,
    required this.emptyLabel,
    this.footerRight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    final chartPoints = points.isEmpty
        ? <FlSpot>[]
        : List.generate(
            points.length,
            (i) => FlSpot(i.toDouble(), points[i].value),
          );

    final double minY = points.isEmpty
        ? 0.0
        : math.max(
            0.0,
            points.map((e) => e.value).reduce(math.min) - 8,
          ).toDouble();

    final maxPointValue = points.isEmpty
        ? 100.0
        : points.map((e) => e.value).reduce(math.max).toDouble();
    final double maxY = points.isEmpty
        ? 100.0
        : (maxPointValue + math.max(8.0, maxPointValue * 0.12));
    final chartHorizontalPadding = points.length > 1 ? 0.18 : 0.5;
    final chartMinX = points.isEmpty ? 0.0 : -chartHorizontalPadding;
    final chartMaxX = points.isEmpty
        ? 1.0
        : (points.length - 1).toDouble() + chartHorizontalPadding;
    final chartYInterval = math.max(1.0, ((maxY - minY) / 3).ceilToDouble());

    return Container(
      height: 292,
      padding: AppSpacing.paddingLg,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textStyles.labelLarge?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeTone.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: textStyles.labelSmall?.copyWith(
                    color: badgeTone,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          Text(
            value,
            style: textStyles.displaySmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const Gap(6),
          Text(
            footerLeft,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(14),
          Expanded(
            child: points.isEmpty
                ? _ChartEmptyState(label: emptyLabel)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.hardEdge,
                    child: LineChart(
                      LineChartData(
                        minX: chartMinX,
                        maxX: chartMaxX,
                        minY: minY,
                        maxY: maxY,
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => colors.surface,
                            tooltipBorder: BorderSide(color: colors.outline),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final point = points[spot.x.toInt()];
                                return LineTooltipItem(
                                  '${point.label}\n${point.value.toStringAsFixed(0)}%',
                                  textStyles.bodySmall!.copyWith(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: chartYInterval,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: colors.outline.withValues(alpha: 0.18),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: chartYInterval,
                              getTitlesWidget: (value, meta) {
                                if (value >= maxY - chartYInterval * 0.35) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  value.toInt().toString(),
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.secondary,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 24,
                              interval: points.length > 3 ? (points.length - 1) / 2 : 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.round();
                                if (index < 0 || index >= points.length) {
                                  return const SizedBox.shrink();
                                }
                                if (points.length > 3 &&
                                    index != 0 &&
                                    index != points.length - 1 &&
                                    index != (points.length - 1) ~/ 2) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    points[index].label,
                                    style: textStyles.labelSmall?.copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartPoints,
                            isCurved: true,
                            color: tone,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, xPercent, barData, index) => FlDotCirclePainter(
                                radius: 3.2,
                                color: tone,
                                strokeWidth: 2,
                                strokeColor: colors.surface,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: tone.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          if (footerRight != null) ...[
            const Gap(10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                footerRight!,
                style: textStyles.bodySmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CostDashboardCard extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyCosts;
  final Map<String, double> topAmmos;
  final ThotProvider provider;
  final double totalCost;
  final String currencySymbol;

  const _CostDashboardCard({
    required this.monthlyCosts,
    required this.topAmmos,
    required this.provider,
    required this.totalCost,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );
    final maxCost = monthlyCosts.fold<double>(
      0,
      (max, month) => ((month['cost'] as double?) ?? 0) > max
          ? (month['cost'] as double?) ?? 0
          : max,
    );

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.statisticsMonthlyCostLabel,
                  style: textStyles.labelLarge?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${totalCost.toStringAsFixed(0)} $currencySymbol',
                style: textStyles.titleMedium?.copyWith(
                  color: colors.tertiary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          if (topAmmos.isNotEmpty) ...[
            Text(
              strings.statisticsTopAmmoLabel,
              style: textStyles.labelSmall?.copyWith(color: colors.secondary),
            ),
            const Gap(8),
            ...topAmmos.entries.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final ammo = provider.ammos.firstWhere(
                (a) => a.id == entry.value.key,
                orElse: () => Ammo(
                  id: '',
                  name: '',
                  brand: '',
                  caliber: '',
                  quantity: 0,
                  lastUsed: null,
                ),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: textStyles.labelMedium?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        ammo.name,
                        style: textStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.value.value.toStringAsFixed(0)} $currencySymbol',
                      style: textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.tertiary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Gap(12),
          ],
          Text(
            strings.statisticsCostPerMonthSubtitle,
            style: textStyles.labelSmall?.copyWith(color: colors.secondary),
          ),
          const Gap(8),
          SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyCosts.map((monthData) {
                final cost = (monthData['cost'] as double?) ?? 0;
                final height = maxCost > 0
                    ? (cost / maxCost * 82).clamp(4.0, 82.0)
                    : 4.0;
                final month = monthData['month'] as DateTime;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        width: 9,
                        decoration: BoxDecoration(
                          color: colors.tertiary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const Gap(5),
                      Text(
                        '${month.month}',
                        style: textStyles.labelSmall?.copyWith(
                          fontSize: 10,
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityBarsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String totalLabel;
  final String emptyLabel;
  final Color tone;
  final List<_WeeklyBucket> buckets;

  const _ActivityBarsCard({
    required this.title,
    required this.subtitle,
    required this.totalLabel,
    required this.emptyLabel,
    required this.tone,
    required this.buckets,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    final maxValue = buckets.isEmpty
        ? 1
        : buckets.map((e) => e.sessions).reduce(math.max).clamp(1, 9999);

    return Container(
      height: 256,
      padding: AppSpacing.paddingLg,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textStyles.labelLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                ),
              ),
              Text(
                totalLabel,
                style: textStyles.bodySmall?.copyWith(
                  color: colors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: buckets.isEmpty
                ? _ChartEmptyState(label: emptyLabel)
                : BarChart(
                    BarChartData(
                      maxY: maxValue.toDouble() + 1,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: colors.outline.withValues(alpha: 0.16),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                            reservedSize: 0,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= buckets.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  buckets[index].label,
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.secondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => colors.surface,
                          tooltipBorder: BorderSide(color: colors.outline),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final bucket = buckets[group.x];
                            return BarTooltipItem(
                              strings.statisticsActivityTooltipValue(
                                bucket.label,
                                bucket.sessions,
                                bucket.shots,
                              ),
                              textStyles.bodySmall!.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
                      barGroups: List.generate(
                        buckets.length,
                        (i) {
                          final bucket = buckets[i];
                          final isLatest = i == buckets.length - 1;
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: bucket.sessions.toDouble(),
                                width: 20,
                                color: isLatest ? tone : tone.withValues(alpha: 0.35),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxValue.toDouble() + 1,
                                  color: colors.outline.withValues(alpha: 0.10),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceOverviewCard extends StatelessWidget {
  final String revisionLabel;
  final String cleaningLabel;
  final String revisionPlatform;
  final String cleaningPlatform;
  final double revisionProgress;
  final double cleaningProgress;
  final int revisionCount;
  final int cleaningCount;

  const _MaintenanceOverviewCard({
    required this.revisionLabel,
    required this.cleaningLabel,
    required this.revisionPlatform,
    required this.cleaningPlatform,
    required this.revisionProgress,
    required this.cleaningProgress,
    required this.revisionCount,
    required this.cleaningCount,
  });

  Color _tone(BuildContext context, double value) {
    final colors = Theme.of(context).colorScheme;
    if (value >= 0.75) return colors.tertiary;
    if (value >= 0.40) return colors.primary;
    return colors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final revisionTone = _tone(context, revisionProgress);
    final cleaningTone = _tone(context, cleaningProgress);

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.statisticsMaintenanceOverviewSubtitle,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: strings.statisticsCleaningsLabel,
                  value: '$cleaningCount',
                  tone: cleaningTone,
                  icon: Icons.cleaning_services_rounded,
                  compact: true,
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: _MiniMetric(
                  label: strings.statisticsRevisionsLabel,
                  value: '$revisionCount',
                  tone: revisionTone,
                  icon: Icons.build_circle_rounded,
                  compact: true,
                ),
              ),
            ],
          ),
          const Gap(16),
          _ProgressInsight(
            icon: Icons.build_rounded,
            label: revisionLabel,
            platformName: revisionPlatform,
            progress: revisionProgress,
            tone: revisionTone,
            compact: true,
          ),
          const Gap(12),
          _ProgressInsight(
            icon: Icons.cleaning_services_rounded,
            label: cleaningLabel,
            platformName: cleaningPlatform,
            progress: cleaningProgress,
            tone: cleaningTone,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _ModernDonutCard extends StatelessWidget {
  final Map<String, int> counts;

  const _ModernDonutCard({
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final textStyles = Theme.of(context).textTheme;

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    final palette = [
      colors.primary,
      colors.secondary,
      colors.tertiary,
      colors.primary.withValues(alpha: 0.60),
      colors.secondary.withValues(alpha: 0.60),
      colors.tertiary.withValues(alpha: 0.60),
    ];

    final total = counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a + b);
    int i = 0;

    final sections = counts.entries.map((e) {
      final value = e.value.toDouble();
      final color = palette[i++ % palette.length];
      return PieChartSectionData(
        value: value,
        color: color,
        radius: 18,
        title: '',
      );
    }).toList();

    final entries = counts.entries.toList();

    return Container(
      height: 218,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 0,
      ),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: sections.isEmpty
                              ? [
                                  PieChartSectionData(
                                    value: 1,
                                    color: colors.outline.withValues(alpha: 0.25),
                                    radius: 18,
                                    title: '',
                                  ),
                                ]
                              : sections,
                          sectionsSpace: 4,
                          centerSpaceRadius: 48,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${counts.length}',
                            style: textStyles.headlineSmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            strings.statisticsTypesShortLabel,
                            style: textStyles.labelSmall?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: entries.isEmpty
                        ? [
                            Text(
                              '—',
                              style: textStyles.bodyMedium?.copyWith(
                                color: colors.secondary,
                              ),
                            ),
                          ]
                        : entries.asMap().entries.map((item) {
                            final index = item.key;
                            final entry = item.value;
                            final tone = palette[index % palette.length];
                            final percent = ((entry.value / total) * 100).round();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: tone,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const Gap(8),
                                  Flexible(
                                    child: Text(
                                      strings.itemPlatformTypeLabel(entry.key),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    '$percent%',
                                    style: textStyles.labelSmall?.copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPlatformsBarsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Platform> platforms;

  const _TopPlatformsBarsCard({
    required this.title,
    required this.subtitle,
    required this.platforms,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    final maxRounds = platforms.isEmpty
        ? 1
        : platforms.map((e) => e.totalRounds).reduce(math.max).clamp(1, 999999);

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textStyles.labelLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          Text(
            subtitle,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(16),
          if (platforms.isEmpty)
            _ChartEmptyState(label: strings.statisticsNoPlatformsToAnalyzeLabel)
          else
            Column(
              children: List.generate(platforms.length, (index) {
                final platform = platforms[index];
                final tone = [
                  colors.primary,
                  colors.secondary,
                  colors.tertiary,
                  colors.primary.withValues(alpha: 0.55),
                ][index % 4];
                final ratio = platform.totalRounds / maxRounds;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              platform.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyles.bodyMedium?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            '${platform.totalRounds}',
                            style: textStyles.labelMedium?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: ratio.clamp(0.0, 1.0),
                          backgroundColor: colors.outline.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(tone),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tone;
  final bool compact;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final decoration = compact
        ? BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
          )
        : (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: decoration,
      child: Row(
        children: [
          Icon(icon, size: 18, color: tone),
          const Gap(8),
          Expanded(
            child: Text(
              label,
              style: textStyles.bodySmall?.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: textStyles.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressInsight extends StatelessWidget {
  final IconData icon;
  final String label;
  final String platformName;
  final double progress;
  final Color tone;
  final bool compact;

  const _ProgressInsight({
    required this.icon,
    required this.label,
    required this.platformName,
    required this.progress,
    required this.tone,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final decoration = compact
        ? BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
          )
        : (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.outline),
            );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: tone),
              const Gap(8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                style: textStyles.labelMedium?.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: tone.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(tone),
            ),
          ),
          const Gap(8),
          Text(
            platformName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyles.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? tag;
  final Color? tone;

  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
    // ignore: unused_element_parameter
    this.tag,
    this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final rowTone = tone ?? colors.primary;

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context, radius: 16) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: decoration,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: rowTone.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: rowTone),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textStyles.labelSmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: rowTone.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tag!,
                style: textStyles.labelSmall?.copyWith(
                  color: rowTone,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EquipmentStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String svgAsset;
  final double? iconSize;

  const _EquipmentStatCard({
    required this.label,
    required this.value,
    required this.svgAsset,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
                ?._statsCardDecoration(context, radius: 16) ??
            BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            );

    return Container(
      decoration: decoration,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Align(
            alignment: const Alignment(0, 0.40),
            child: SvgPicture.asset(
              svgAsset,
              width: iconSize ?? 68,
              height: iconSize ?? 68,
              colorFilter: ColorFilter.mode(
                colors.secondary.withValues(alpha: 0.15),
                BlendMode.srcIn,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.labelSmall?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Expanded(
                  child: Center(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.displaySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  final String label;

  const _ChartEmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.secondary,
            ),
      ),
    );
  }
}

class _LinePoint {
  final String label;
  final double value;

  const _LinePoint({
    required this.label,
    required this.value,
  });
}

class _WeeklyBucket {
  final String label;
  final int sessions;
  final int shots;

  const _WeeklyBucket({
    required this.label,
    required this.sessions,
    required this.shots,
  });
}
