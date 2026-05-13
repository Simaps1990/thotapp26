import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/achievement_definitions.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/l10n/app_strings.dart';

BoxDecoration _achievementCardDecoration(
  BuildContext context, {
  double radius = AppRadius.sm,
}) {
  final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: isDark
        ? null
        : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
    boxShadow: AppShadows.cardPremium,
  );
}

class AchievementsScreen extends StatefulWidget {
  final bool useSafeArea;

  const AchievementsScreen({Key? key, this.useSafeArea = true})
    : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // recent | oldest | level_high | level_low
  String _sort = 'recent';
  String _category = 'all';
  int _achievementStatusIndex = 0;

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

  String _categoryLabel(AppStrings strings, String category) {
    switch (category) {
      case 'regularity':
        return strings.achievementCategoryRegularity;
      case 'precision':
        return strings.achievementCategoryPrecision;
      case 'speed':
        return strings.achievementCategorySpeed;
      case 'maintenance':
        return strings.achievementCategoryMaintenance;
      case 'diagnostic':
        return strings.achievementCategoryDiagnostic;
      case 'tools':
        return strings.achievementCategoryTools;
      default:
        return strings.achievementCategoryAll;
    }
  }

  String _rarityLabel(AppStrings strings, String rarity) {
    switch (rarity) {
      case 'advanced':
        return strings.achievementRarityAdvanced;
      case 'expert':
        return strings.achievementRarityExpert;
      case 'elite':
        return strings.achievementRarityElite;
      default:
        return strings.achievementRarityCommon;
    }
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'advanced':
        return const Color(0xFF8C97A8);
      case 'expert':
        return const Color(0xFFC2A14A);
      case 'elite':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF8A5A3C);
    }
  }

  String? _achievementIconAsset(String id) {
    if (id.contains('ammo') || id.contains('round'))
      return 'assets/images/pointe.svg';
    if (id.contains('platform')) return 'assets/images/tube.svg';
    if (id.contains('cleaning') || id.contains('revision'))
      return 'assets/images/material.svg';
    if (id.contains('session')) return 'assets/images/seance.svg';
    if (id.contains('precision') || id.contains('perfect'))
      return 'assets/images/target.svg';
    if (id.contains('reflex')) return 'assets/images/train.svg';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final achievements = achievementDefinitions
        .where((a) => _category == 'all' || a.category == _category)
        .toList();

    // Tri
    achievements.sort((a, b) {
      final da = provider.achievementUnlockDate(a.id);
      final db = provider.achievementUnlockDate(b.id);
      switch (_sort) {
        case 'oldest':
          return (da ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            db ?? DateTime.fromMillisecondsSinceEpoch(0),
          );
        case 'level_high':
          return _tierRank(b.tier).compareTo(_tierRank(a.tier));
        case 'level_low':
          return _tierRank(a.tier).compareTo(_tierRank(b.tier));
        case 'recent':
        default:
          return (db ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            da ?? DateTime.fromMillisecondsSinceEpoch(0),
          );
      }
    });

    final visibleAchievements = achievements.where((a) {
      final progress = a.progress(provider);
      final safeTarget = a.target <= 0 ? 1 : a.target;
      final isUnlocked = progress >= safeTarget;
      if (_achievementStatusIndex == 0) return isUnlocked;
      return !isUnlocked && progress > 0;
    }).toList();

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
                child: Row(
                  children: [
                    Text(
                      strings.homeTrophiesTitle,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Tooltip(
                      message: strings.achievementsInfoTooltip,
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 4),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: textStyles.bodySmall?.copyWith(
                        color: colors.surface,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: colors.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.xs),
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 28,
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Divider(color: colors.outline),
          const Gap(AppSpacing.sm),

          SizedBox(
            height: 44,
            child: _AchievementStatusSelector(
              selectedIndex: _achievementStatusIndex,
              labels: [
                strings.achievementsUnlockedFilter,
                strings.achievementsInProgressFilter,
              ],
              onSelected: (index) {
                setState(() {
                  _achievementStatusIndex = index;
                });
              },
            ),
          ),
          const Gap(AppSpacing.md),

          if (visibleAchievements.isEmpty)
            _EmptyCard(text: strings.homeTrophiesEmpty)
          else
            ...visibleAchievements.asMap().entries.map((entry) {
              final index = entry.key;
              final a = entry.value;
              final tierColor = _tierColor(a.tier);
              final rarityColor = _rarityColor(a.rarity);
              final date = provider.achievementUnlockDate(a.id);
              final progress = a.progress(provider);
              final safeTarget = a.target <= 0 ? 1 : a.target;
              final isUnlocked = progress >= safeTarget;
              final isInProgress = _achievementStatusIndex == 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Opacity(
                  opacity: isInProgress ? 0.6 : 1,
                  child: _AchievementCard(
                    index: index,
                    title: strings.achievementTitle(a.id),
                    description: strings.achievementDescription(a.id),
                    color: a.rarity == 'elite' ? rarityColor : tierColor,
                    tier: a.tier,
                    rarityLabel: _rarityLabel(strings, a.rarity),
                    rarityColor: rarityColor,
                    progress: progress,
                    target: a.target,
                    unlockedAt: isUnlocked ? date : null,
                    iconAsset: _achievementIconAsset(a.id),
                  ),
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

class _GradientAchievementIcon extends StatelessWidget {
  final double size;
  final Color baseColor;
  final String? assetPath;

  const _GradientAchievementIcon({
    required this.size,
    required this.baseColor,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor;
    final dark = Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor;
    final child = assetPath == null
        ? Icon(Icons.emoji_events_rounded, size: size, color: Colors.white)
        : SvgPicture.asset(
            assetPath!,
            width: size,
            height: size,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          );

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, baseColor, dark],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }
}

class _AchievementStatusSelector extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  const _AchievementStatusSelector({
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final chipGray = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / labels.length;

        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: chipGray,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: subtleBorderColor),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < labels.length; i++)
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onSelected(i),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: Center(
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyles.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: i == selectedIndex
                                    ? colors.onPrimary
                                    : colors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final Color color;
  final String tier;
  final String rarityLabel;
  final Color rarityColor;
  final int progress;
  final int target;
  final DateTime? unlockedAt;
  final String? iconAsset;

  const _AchievementCard({
    required this.index,
    required this.title,
    required this.description,
    required this.color,
    required this.tier,
    required this.rarityLabel,
    required this.rarityColor,
    required this.progress,
    required this.target,
    this.unlockedAt,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final dateLabel = unlockedAt == null
        ? null
        : AppDateFormats.formatDateShort(context, unlockedAt!);
    final safeTarget = target <= 0 ? 1 : target;
    final ratio = (progress / safeTarget).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 600)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
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
                      child: _GradientAchievementIcon(
                        size: 28,
                        baseColor: color,
                        assetPath: iconAsset,
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                title.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Gap(AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: rarityColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: rarityColor.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Text(
                                rarityLabel,
                                style: textStyles.labelSmall?.copyWith(
                                  color: rarityColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          description,
                          style: textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const Gap(8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 4,
                            backgroundColor: colors.outline.withValues(
                              alpha: 0.12,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              unlockedAt == null
                                  ? color.withValues(alpha: 0.55)
                                  : color,
                            ),
                          ),
                        ),
                        const Gap(6),
                        Row(
                          children: [
                            Text(
                              '${progress.clamp(0, target)} / $target',
                              style: textStyles.labelSmall?.copyWith(
                                color: colors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (dateLabel != null) ...[
                              const Spacer(),
                              Text(
                                dateLabel,
                                style: textStyles.labelSmall?.copyWith(
                                  color: colors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
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
              style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
