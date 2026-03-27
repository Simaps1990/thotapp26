import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
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
      final height = MediaQuery.of(context).size.height * 0.8;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: height,
        decoration: BoxDecoration(
          color: baseBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            SizedBox(height: 12),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: colors.outline,
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

enum _StatsChartRange { week, month, year }

extension on _StatsChartRange {
  String shortLabel(AppStrings strings) {
    switch (this) {
      case _StatsChartRange.week:
        return strings.precisionFilterWeekShort;
      case _StatsChartRange.month:
        return strings.precisionFilterMonthShort;
      case _StatsChartRange.year:
        return strings.precisionFilterYearShort;
    }
  }

  String longLabel(AppStrings strings) {
    switch (this) {
      case _StatsChartRange.week:
        return strings.precisionFilterWeekLong;
      case _StatsChartRange.month:
        return strings.precisionFilterMonthLong;
      case _StatsChartRange.year:
        return strings.precisionFilterYearLong;
    }
  }
}

class StatisticsScreen extends StatefulWidget {
  final Color? backgroundColor;
  final bool useSafeArea;

  const StatisticsScreen({Key? key, this.backgroundColor, this.useSafeArea = true})
      : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  _StatsChartRange _shotsRange = _StatsChartRange.month;
  _StatsChartRange _sessionsRange = _StatsChartRange.month;

  BoxDecoration _statsCardDecoration(BuildContext context, {double radius = AppRadius.lg}) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? colors.outline : LightColors.surfaceHighlight,
        width: 1.35,
      ),
      boxShadow: AppShadows.cardPremium,
    );
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
        sessions.where((s) => s.hasCountedPrecision).toList();

    final totalShots = provider.totalRoundsFired;
    final totalSessions = provider.totalSessions;
    final totalWeapons = provider.weapons.length;
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
        : (sessionsWithPrecision.toList()
              ..sort((a, b) => b.averagePrecision.compareTo(a.averagePrecision)))
            .first;

    final longestSession = sessions.isEmpty
        ? null
        : (sessions.toList()
              ..sort((a, b) => b.totalRounds.compareTo(a.totalRounds)))
            .first;

    final mostUsedWeapon = provider.weapons.isEmpty
        ? null
        : (provider.weapons.toList()
              ..sort((a, b) => b.totalRounds.compareTo(a.totalRounds)))
            .first;

    final lowestAmmo = provider.ammos.isEmpty
        ? null
        : (provider.ammos.toList()
              ..sort((a, b) => a.quantity.compareTo(b.quantity)))
            .first;

    final perfectSessions = sessions
        .where((s) => s.hasCountedPrecision && s.averagePrecision >= 100)
        .length;

    final avgShotsPerSession =
        totalSessions == 0 ? 0 : (totalShots / totalSessions);

    final totalMaintenances = provider.weapons
        .expand((w) => w.history)
        .where((h) => h.type == 'entretien')
        .length;

    final totalRevisions = provider.weapons
        .expand((w) => w.history)
        .where((h) => h.type == 'revision')
        .length;

    final sessionsThisMonth = sessions.where((s) {
      final now = DateTime.now();
      return s.date.year == now.year && s.date.month == now.month;
    }).length;

    final sessionsThisWeek = sessions.where((s) {
      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      return !s.date.isBefore(startOfWeek);
    }).length;

    final averageExercisesPerSession = totalSessions == 0
        ? 0.0
        : sessions.fold<int>(0, (sum, s) => sum + s.exercises.length) /
            totalSessions;

    final weaponNeedingRevision = provider.weapons.isEmpty
        ? null
        : (provider.weapons.toList()
              ..sort(
                (a, b) => b.revisionProgress.compareTo(a.revisionProgress),
              ))
            .first;

    final weaponNeedingCleaning = provider.weapons.isEmpty
        ? null
        : (provider.weapons.toList()
              ..sort(
                (a, b) => b.cleaningProgress.compareTo(a.cleaningProgress),
              ))
            .first;

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
                  children: [
                    _StatTile(
                      title: strings.statisticsSessionsLabel,
                      value: '$totalSessions',
                    ),
                    _StatTile(
                      title: strings.statisticsShotsFiredLabel,
                      value: '$totalShots',
                    ),
                    _StatTile(
                      title: strings.statisticsWeaponsLabel,
                      value: '$totalWeapons',
                    ),
                    _StatTile(
                      title: strings.statisticsAmmosLabel,
                      value: '$totalAmmos',
                    ),
                    _StatTile(
                      title: strings.statisticsAccessoriesLabel,
                      value: '$totalAccessories',
                    ),
                    _StatTile(
                      title: strings.statisticsShotsPerSessionLabel,
                      value: avgShotsPerSession == 0
                          ? '0'
                          : avgShotsPerSession.toStringAsFixed(0),
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsPrecisionTitle),
                const Gap(AppSpacing.md),
                _StatsGrid(
                  children: [
                    _StatTile(
                      title: strings.statisticsAveragePrecisionLabel,
                      value: avgPrecision == null
                          ? '—'
                          : '${avgPrecision.toStringAsFixed(0)}%',
                    ),
                    _StatTile(
                      title: strings.statisticsPerfectSessionsLabel,
                      value: '$perfectSessions',
                    ),
                    _StatTile(
                      title: strings.statisticsBestSessionLabel,
                      value: bestSession == null
                          ? '—'
                          : '${bestSession.averagePrecision.toStringAsFixed(0)}%',
                    ),
                    _StatTile(
                      title: strings.statisticsBestSessionDateLabel,
                      value: bestSession == null
                          ? '—'
                          : AppDateFormats.formatDateShort(
                              context,
                              bestSession.date,
                            ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsRhythmTitle),
                const Gap(AppSpacing.md),
                _StatsGrid(
                  children: [
                    _StatTile(
                      title: strings.statisticsThisWeekLabel,
                      value: '$sessionsThisWeek',
                    ),
                    _StatTile(
                      title: strings.statisticsThisMonthLabel,
                      value: '$sessionsThisMonth',
                    ),
                    _StatTile(
                      title: strings.statisticsExercisesPerSessionLabel,
                      value: averageExercisesPerSession == 0
                          ? '0'
                          : averageExercisesPerSession.toStringAsFixed(1),
                    ),
                    _StatTile(
                      title: strings.statisticsSessionsWithPrecisionLabel,
                      value: '${sessionsWithPrecision.length}',
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsMaintenanceTitle),
                const Gap(AppSpacing.md),
                _StatsGrid(
                  children: [
                    _StatTile(
                      title: strings.statisticsCleaningsLabel,
                      value: '$totalMaintenances',
                    ),
                    _StatTile(
                      title: strings.statisticsRevisionsLabel,
                      value: '$totalRevisions',
                    ),
                  ],
                ),
                const Gap(AppSpacing.md),
                _DetailCard(
                  label: strings.statisticsClosestRevisionWeaponLabel,
                  value: weaponNeedingRevision == null
                      ? '—'
                      : '${weaponNeedingRevision.name} • ${(weaponNeedingRevision.revisionProgress * 100).round()}%',
                ),
                const Gap(AppSpacing.md),
                _DetailCard(
                  label: strings.statisticsClosestCleaningWeaponLabel,
                  value: weaponNeedingCleaning == null
                      ? '—'
                      : '${weaponNeedingCleaning.name} • ${(weaponNeedingCleaning.cleaningProgress * 100).round()}%',
                ),
                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsSmartIndicatorsTitle),
                const Gap(AppSpacing.md),
                _DetailCard(
                  label: strings.statisticsMostUsedWeaponLabel,
                  value: mostUsedWeapon == null
                      ? '—'
                      : '${mostUsedWeapon.name} • ${strings.statisticsSmartIndicatorShotsValue(mostUsedWeapon.totalRounds)}',
                ),
                const Gap(AppSpacing.md),
                _DetailCard(
                  label: strings.statisticsMostCriticalAmmoLabel,
                  value: lowestAmmo == null
                      ? '—'
                      : '${lowestAmmo.name} • ${strings.statisticsSmartIndicatorAmmoValue(lowestAmmo.quantity, lowestAmmo.lowStockThreshold)}',
                ),
                const Gap(AppSpacing.md),
                _DetailCard(
                  label: strings.statisticsLongestSessionLabel,
                  value: longestSession == null
                      ? '—'
                      : '${longestSession.name} • ${strings.statisticsSmartIndicatorShotsValue(longestSession.totalRounds)}',
                ),
                const Gap(AppSpacing.md),
                _DetailCard(
                  label: strings.statisticsLastSessionLabel,
                  value: sessions.isEmpty
                      ? '—'
                      : '${sessions.first.name} • ${AppDateFormats.formatDateShort(context, sessions.first.date)}',
                ),

                const Gap(AppSpacing.lg),

                const Gap(AppSpacing.lg),

                _SectionTitle(title: strings.statisticsWeaponsByTypeTitle),

                const Gap(AppSpacing.md),
                _PieWeaponsByTypeChart(weapons: provider.weapons),
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

  const _StatsGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.2,
      children: children,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
            ?._statsCardDecoration(context) ??
        BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        );

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textStyles.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppSpacing.xs),
          Text(
            value,
            style: textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;

  const _DetailCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
            ?._statsCardDecoration(context, radius: AppRadius.lg) ??
        BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        );

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textStyles.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Gap(4),
          Text(
            value,
            style: textStyles.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSectionHeader extends StatelessWidget {
  final String title;
  final _StatsChartRange selectedRange;
  final AppStrings strings;
  final ValueChanged<_StatsChartRange> onSelected;

  const _ChartSectionHeader({
    required this.title,
    required this.selectedRange,
    required this.strings,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: _SectionTitle(title: title),
        ),
        PopupMenuButton<_StatsChartRange>(
          initialValue: selectedRange,
          tooltip: strings.homePrecisionFilterTooltip,
          onSelected: onSelected,
          itemBuilder: (context) => _StatsChartRange.values
              .map(
                (range) => PopupMenuItem<_StatsChartRange>(
                  value: range,
                  child: Text(range.longLabel(strings)),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: (context.findAncestorStateOfType<_StatisticsScreenState>())
                    ?._statsCardDecoration(context, radius: AppRadius.sm) ??
                BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: colors.outline),
                ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedRange.shortLabel(strings),
                  style: textStyles.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  color: colors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartBucket {
  final String label;
  final int value;

  const _ChartBucket({
    required this.label,
    required this.value,
  });
}

List<_ChartBucket> _buildChartBuckets(
  BuildContext context,
  List<Session> sessions,
  _StatsChartRange range, {
  required bool countShots,
}) {
  final locale = Localizations.localeOf(context).languageCode;
  final now = DateTime.now();

  int sessionValue(Session session) {
    if (!countShots) return 1;
    return session.exercises.fold<int>(0, (sum, e) {
      final value = e.shotsFired;
      return sum + (value is num ? value.toInt() : 0);
    });
  }

  switch (range) {
    case _StatsChartRange.week:
      final today = DateTime(now.year, now.month, now.day);
      return List.generate(7, (index) {
        final day = today.subtract(Duration(days: 6 - index));
        final value = sessions
            .where(
              (s) =>
                  s.date.year == day.year &&
                  s.date.month == day.month &&
                  s.date.day == day.day,
            )
            .fold<int>(0, (sum, s) => sum + sessionValue(s));
        final weekdayLabel = DateFormat('E', locale).format(day);
        return _ChartBucket(label: weekdayLabel, value: value);
      });

    case _StatsChartRange.month:
      return List.generate(12, (index) {
        final monthDate = DateTime(now.year, now.month - (11 - index), 1);
        final value = sessions
            .where(
              (s) =>
                  s.date.year == monthDate.year &&
                  s.date.month == monthDate.month,
            )
            .fold<int>(0, (sum, s) => sum + sessionValue(s));
        return _ChartBucket(
          label: DateFormat('MMM', locale).format(monthDate),
          value: value,
        );
      });

    case _StatsChartRange.year:
      return List.generate(10, (index) {
        final year = now.year - (9 - index);
        final value = sessions
            .where((s) => s.date.year == year)
            .fold<int>(0, (sum, s) => sum + sessionValue(s));
        return _ChartBucket(label: year.toString(), value: value);
      });
  }
}

double _chartMaxY(List<_ChartBucket> buckets) {
  final maxValue =
      buckets.fold<int>(0, (max, bucket) => bucket.value > max ? bucket.value : max);
  return maxValue <= 0 ? 4.0 : (maxValue * 1.2).ceilToDouble();
}

double _chartInterval(List<_ChartBucket> buckets) {
  final maxValue =
      buckets.fold<int>(0, (max, bucket) => bucket.value > max ? bucket.value : max);
  final maxY = _chartMaxY(buckets);
  return maxValue <= 4 ? 1.0 : (maxY / 4).ceilToDouble();
}

double _chartGroupSpace(_StatsChartRange range) {
  switch (range) {
    case _StatsChartRange.week:
      return 12;
    case _StatsChartRange.month:
      return 6;
    case _StatsChartRange.year:
      return 8;
  }
}

double _chartBottomReservedSize(_StatsChartRange range) {
  switch (range) {
    case _StatsChartRange.week:
      return 32;
    case _StatsChartRange.month:
      return 30;
    case _StatsChartRange.year:
      return 28;
  }
}

double _chartLabelWidth(_StatsChartRange range) {
  switch (range) {
    case _StatsChartRange.week:
      return 32;
    case _StatsChartRange.month:
      return 22;
    case _StatsChartRange.year:
      return 20;
  }
}

double _chartBarWidth(_StatsChartRange range) {
  switch (range) {
    case _StatsChartRange.week:
      return 16;
    case _StatsChartRange.month:
      return 10;
    case _StatsChartRange.year:
      return 8;
  }
}

bool _shouldShowBottomLabel(_StatsChartRange range, int index, int length) {
  final isLast = index == length - 1;
  switch (range) {
    case _StatsChartRange.week:
      return true;

    case _StatsChartRange.month:
      return isLast || index % 2 == 0;
    case _StatsChartRange.year:
      return isLast || index % 3 == 0;
  }
}

class _BarShotsPerPeriodChart extends StatelessWidget {
  final List<Session> sessions;
  final _StatsChartRange range;

  const _BarShotsPerPeriodChart({
    required this.sessions,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final buckets = _buildChartBuckets(
      context,
      sessions,
      range,
      countShots: true,
    );
    final bars = <BarChartGroupData>[];
    for (int i = 0; i < buckets.length; i++) {
      final v = buckets[i].value.toDouble();
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: v,
              color: colors.primary,
              width: _chartBarWidth(range),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    final chartMaxY = _chartMaxY(buckets);
    final leftInterval = _chartInterval(buckets);

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
            ?._statsCardDecoration(context, radius: AppRadius.sm) ??
        BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: colors.outline),
        );

    return Container(
      height: 260,
      decoration: decoration,
      padding: AppSpacing.paddingMd,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: (buckets.length * 46).toDouble() + 40.0,
          child: BarChart(
            BarChartData(
              maxY: chartMaxY,
              alignment: BarChartAlignment.spaceAround,
              groupsSpace: _chartGroupSpace(range),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: leftInterval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.outline.withValues(alpha: 0.35),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: leftInterval,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _chartBottomReservedSize(range),
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= buckets.length) {
                        return const SizedBox.shrink();
                      }
                      if (!_shouldShowBottomLabel(range, idx, buckets.length)) {
                        return const SizedBox.shrink();
                      }
                      final label = buckets[idx].label;
                      return SizedBox(
                        width: _chartLabelWidth(range),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: textStyles.labelSmall?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: bars,
            ),
          ),
        ),
      ),
    );
  }
}

class _BarSessionsPerPeriodChart extends StatelessWidget {
  final List<Session> sessions;
  final _StatsChartRange range;

  const _BarSessionsPerPeriodChart({
    required this.sessions,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final buckets = _buildChartBuckets(
      context,
      sessions,
      range,
      countShots: false,
    );
    final bars = <BarChartGroupData>[];
    for (int i = 0; i < buckets.length; i++) {
      final v = buckets[i].value.toDouble();
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: v,
              color: colors.primary,
              width: _chartBarWidth(range),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    final chartMaxY = _chartMaxY(buckets);
    final leftInterval = _chartInterval(buckets);

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
            ?._statsCardDecoration(context, radius: AppRadius.sm) ??
        BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: colors.outline),
        );

    return Container(
      height: 260,
      decoration: decoration,
      padding: AppSpacing.paddingMd,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: (buckets.length * 46).toDouble() + 40.0,
          child: BarChart(
            BarChartData(
              maxY: chartMaxY,
              alignment: BarChartAlignment.spaceAround,
              groupsSpace: _chartGroupSpace(range),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: leftInterval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.outline.withValues(alpha: 0.35),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: leftInterval,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: textStyles.labelSmall?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _chartBottomReservedSize(range),
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= buckets.length) {
                        return const SizedBox.shrink();
                      }
                      if (!_shouldShowBottomLabel(range, idx, buckets.length)) {
                        return const SizedBox.shrink();
                      }
                      final label = buckets[idx].label;
                      return SizedBox(
                        width: _chartLabelWidth(range),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: textStyles.labelSmall?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: bars,
            ),
          ),
        ),
      ),
    );
  }
}

class _PieWeaponsByTypeChart extends StatelessWidget {
  final List<Weapon> weapons;

  const _PieWeaponsByTypeChart({required this.weapons});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final counts = <String, int>{};

    for (final w in weapons) {
      counts[w.type] = (counts[w.type] ?? 0) + 1;
    }

    final total =
        counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a + b);

    final palette = [
      colors.primary,
      colors.secondary,
      colors.tertiary ?? colors.primaryContainer,
      colors.error,
      colors.surfaceTint,
    ];

    int i = 0;
    final sections = counts.entries.map((e) {
      final value = e.value.toDouble();
      final color = palette[i++ % palette.length];
      return PieChartSectionData(
        value: value,
        color: color,
        radius: 46,
        title: '${((value / total) * 100).round()}% ',
        titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      );
    }).toList();

    final decoration =
        (context.findAncestorStateOfType<_StatisticsScreenState>())
            ?._statsCardDecoration(context, radius: AppRadius.sm) ??
        BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: colors.outline),
        );

    return Container(
      height: 260,
      decoration: decoration,
      padding: AppSpacing.paddingMd,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections.isEmpty
                    ? [
                        PieChartSectionData(
                          value: 1,
                          color: colors.outline,
                          radius: 46,
                          title: '—',
                        ),
                      ]
                    : sections,
                sectionsSpace: 2,
                centerSpaceRadius: 34,
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: counts.entries.map((e) {
              final idx = counts.keys.toList().indexOf(e.key);
              final c = palette[idx % palette.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${strings.itemWeaponTypeLabel(e.key)} (${e.value})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.secondary,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}