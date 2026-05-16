part of '../new_session_screen.dart';

class _SectionHeader extends StatelessWidget {
  final Widget leading;
  final String title;

  const _SectionHeader({required this.leading, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconTheme(
          data: IconThemeData(color: colors.primary, size: 18),
          child: leading,
        ),
        const Gap(8),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _SlidingSegmentedSelector extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  const _SlidingSegmentedSelector({
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / labels.length;

        final chipGray = Color.alphaBlend(
          colors.outline.withValues(alpha: 0.8),
          baseBackground,
        );

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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
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

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final ThotProvider provider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.provider,
    required this.onEdit,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final exerciseTitle = exercise.name.trim().isEmpty
        ? strings.exerciseCardTitle(index)
        : exercise.name.trim();
    final exerciseSubtitle = exercise.name.trim().isEmpty
        ? null
        : strings.exerciseCardTitle(index);

    void openTargetPhoto(ExercisePhoto photo) {
      showDialog<void>(
        context: context,
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
                    tooltip: strings.close,
                    onPressed: () => Navigator.of(ctx).pop(),
                    color: dialogColors.onSurface,
                    style: IconButton.styleFrom(
                      backgroundColor: dialogColors.surface.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final primaryPhoto = exercise.targetPhotos.isNotEmpty
        ? exercise.targetPhotos.first
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardDecoration = BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: isDark
          ? null
          : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
      boxShadow: AppShadows.cardPremium,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMd,
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: exercise title + subtitle + edit/delete actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (exerciseSubtitle != null) ...[
                      const Gap(2),
                      Text(
                        exerciseSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  if (onMoveUp != null)
                    IconButton(
                      onPressed: onMoveUp,
                      tooltip: strings.moveUp,
                      icon: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 20,
                      ),
                      color: colors.secondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onMoveDown != null)
                    IconButton(
                      onPressed: onMoveDown,
                      tooltip: strings.moveDown,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                      ),
                      color: colors.secondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const Gap(8),
                  IconButton(
                    onPressed: onEdit,
                    tooltip: strings.edit,
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    color: colors.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Gap(8),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: strings.deleteButton,
                    icon: const Icon(Icons.delete_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const Gap(AppSpacing.md),

          // Card 3: shooting results (main target photo + shots & distance)
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.shootingResultsTitle,
                  style: textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(AppSpacing.md),
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
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: CrossPlatformImage(
                                  filePath: primaryPhoto.path,
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
                      Container(width: 1, height: 120, color: colors.outline),
                    if (primaryPhoto != null) const Gap(AppSpacing.md),

                    // Right: shots & distance (and precision if counted)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: strings.shotsFiredLabel,
                            value: '${exercise.shotsFired}',
                          ),
                          _InfoRow(
                            label: strings.shootingDistanceDetailLabel,
                            value: provider.useMetric
                                ? '${exercise.distance} m'
                                : '${(exercise.distance * 1.09361).round()} yd',
                          ),
                          if (exercise.targetName != null &&
                              exercise.targetName!.isNotEmpty)
                            _InfoRow(
                              label: strings.usedTargetLabel,
                              value: exercise.targetName!,
                            ),
                          if (exercise.isPrecisionCounted)
                            _InfoRow(
                              label: strings.statisticsPrecisionTitle,
                              value:
                                  '${exercise.precision!.toStringAsFixed(0)}%',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (exercise.observations.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            Text(
              strings.observationsTitle,
              style: textStyles.labelSmall?.copyWith(color: colors.secondary),
            ),
            Text(
              exercise.observations,
              style: textStyles.bodySmall?.copyWith(color: colors.secondary),
            ),
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
            style: textStyles.labelSmall?.copyWith(color: colors.secondary),
          ),
          const Gap(2),
          Text(
            value,
            style: textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

