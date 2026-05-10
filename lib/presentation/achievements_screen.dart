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
              const Gap(AppSpacing.sm),

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
              const Gap(AppSpacing.sm),

              if (unlocked.isEmpty)
                _EmptyCard(
                  text: strings.homeTrophiesEmpty,
                )
              else
                ...List.generate(unlocked.length, (index) {
                  final a = unlocked[index];
                  final tierColor = _tierColor(a.tier);
                  final date = provider.achievementUnlockDate(a.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _AchievementCard(
                      index: index,
                      title: strings.achievementTitle(a.id),
                      description: strings.achievementDescription(a.id),
                      color: tierColor,
                      tier: a.tier,
                      unlockedAt: date,
                    ),
                  );
                }),
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
    final light = Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor;
    final dark = Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor;

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
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(Icons.emoji_events_rounded, size: size, color: Colors.white),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final Color color;
  final String tier;
  final DateTime? unlockedAt;

  const _AchievementCard({
    required this.index,
    required this.title,
    required this.description,
    required this.color,
    required this.tier,
    this.unlockedAt,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final dateLabel = unlockedAt == null 
        ? null 
        : AppDateFormats.formatDateShort(context, unlockedAt!);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 600)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: _achievementCardDecoration(context, radius: 20),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Glow behind the icon
            Positioned(
              left: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: _GradientTrophyIcon(size: 28, baseColor: color),
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.toUpperCase(),
                                    style: textStyles.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    description,
                                    style: textStyles.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurface,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (dateLabel != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  dateLabel,
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(8),
                        // Tier indicator line
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _achievementCardDecoration(context, radius: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: colors.outline.withValues(alpha: 0.5),
            ),
            const Gap(AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: textStyles.bodyMedium?.copyWith(
                color: colors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
