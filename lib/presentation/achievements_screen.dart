import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/achievement_definitions.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/l10n/app_strings.dart';

BoxDecoration _achievementCardDecoration(BuildContext context,
    {double radius = AppRadius.sm}) {
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

class AchievementsScreen extends StatefulWidget {
  final bool useSafeArea;

  const AchievementsScreen({Key? key, this.useSafeArea = true}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // recent | oldest | level_high | level_low
  String _sort = 'recent';

  Color _tierColor(String tier) {
    switch (tier) {
      case 'gold':
        return const Color(0xFFC2A14A);
      case 'silver':
        return const Color(0xFF8C97A8);
      default:
        return const Color(0xFF8A5A3C);
    }
  }

  int _tierRank(String tier) => tier == 'gold' ? 3 : (tier == 'silver' ? 2 : 1);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final unlocked = achievementDefinitions
        .where((a) => a.progress(provider) >= a.target)
        .toList();

    // Tri
    unlocked.sort((a, b) {
      final da = provider.achievementUnlockDate(a.id);
      final db = provider.achievementUnlockDate(b.id);
      switch (_sort) {
        case 'oldest':
          return (da ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(db ?? DateTime.fromMillisecondsSinceEpoch(0));
        case 'level_high':
          return _tierRank(b.tier).compareTo(_tierRank(a.tier));
        case 'level_low':
          return _tierRank(a.tier).compareTo(_tierRank(b.tier));
        case 'recent':
        default:
          return (db ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(da ?? DateTime.fromMillisecondsSinceEpoch(0));
      }
    });

    final contentPadding = widget.useSafeArea
        ? AppSpacing.paddingLg
        : const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          );

    final content = SingleChildScrollView(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.homeTrophiesTitle,
                          style: textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          strings.homeTrophiesSubtitle,
                          style: textStyles.bodySmall?.copyWith(
                            color: colors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.sm),
              Divider(color: colors.outline),
              const Gap(AppSpacing.md),

              // Ligne d’en-tête + tri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.homeTrophiesUnlocked(unlockedAchievementsCount(provider)),
                    style: textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.sort_rounded, color: colors.onSurface),
                    onSelected: (v) => setState(() => _sort = v),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'recent', child: Text(strings.achievementsSortRecent)),
                      PopupMenuItem(value: 'oldest', child: Text(strings.achievementsSortOldest)),
                      PopupMenuItem(value: 'level_high', child: Text(strings.achievementsSortLevelHigh)),
                      PopupMenuItem(value: 'level_low', child: Text(strings.achievementsSortLevelLow)),
                    ],
                  ),
                ],
              ),
              const Gap(AppSpacing.md),

              if (unlocked.isEmpty)
                _EmptyCard(
                  text: strings.homeTrophiesEmpty,
                )
              else
                ...unlocked.map((a) {
                  final tierColor = _tierColor(a.tier);
                  final date = provider.achievementUnlockDate(a.id);
                  return Padding(
                    // Espacement léger entre cartes
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _AchievementCard(
                      title: strings.achievementTitle(a.id),
                      description: strings.achievementDescription(a.id),
                      color: tierColor,
                      unlockedAt: date, // date seule, sans heure ni préfixe
                    ),
                  );
                }).toList(),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.useSafeArea ? SafeArea(child: content) : content,
    );
  }
}

class _GradientTrophyIcon extends StatelessWidget {
  final double size;
  final Color baseColor;

  const _GradientTrophyIcon({required this.size, required this.baseColor});

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(baseColor, Colors.white, 0.35) ?? baseColor;
    final dark = Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            light,
            baseColor,
            dark,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(Icons.emoji_events_rounded, size: size, color: Colors.white),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final DateTime? unlockedAt;

  const _AchievementCard({
    required this.title,
    required this.description,
    required this.color,
    this.unlockedAt,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final dateLabel =
        unlockedAt == null ? null : AppDateFormats.formatDateShort(context, unlockedAt!);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: _achievementCardDecoration(context, radius: 16),
      child: Row(
        children: [
          _GradientTrophyIcon(size: 28, baseColor: color),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (dateLabel != null) ...[
                      const Gap(AppSpacing.sm),
                      Text(
                        dateLabel,
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(AppSpacing.xs),
                Text(
                  description,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                    height: 1.3,
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

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: _achievementCardDecoration(context, radius: 16),
      child: Text(
        text,
        style: textStyles.bodyMedium?.copyWith(
          color: colors.secondary,
        ),
      ),
    );
  }
}
