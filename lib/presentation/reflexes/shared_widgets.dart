part of '../reflexes_screen.dart';

class _DrillCard extends StatefulWidget {
  const _DrillCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.isSelected,
    required this.colors,
    required this.textStyles,
    required this.isDark,
    this.isLocked = false,
    this.backgroundImage,
    this.mode,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isLocked;
  final ColorScheme colors;
  final TextTheme textStyles;
  final bool isDark;
  final String? backgroundImage;
  final _ReflexesMode? mode;

  @override
  State<_DrillCard> createState() => _DrillCardState();
}

class _DrillCardState extends State<_DrillCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _shimmerController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(_DrillCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _shimmerController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isLocked ? 0.5 : 1.0,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.backgroundImage == null
                ? (widget.isSelected
                      ? LightColors.primary
                      : widget.colors.surface)
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? widget.colors.outline.withValues(alpha: 0.3)
                  : LightColors.surfaceHighlight,
            ),
            boxShadow: AppShadows.cardPremium,
            image: widget.backgroundImage != null
                ? DecorationImage(
                    image: AssetImage(widget.backgroundImage!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(
                        alpha: widget.isSelected ? 0.12 : 0.28,
                      ),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: Stack(
            children: [
              if (widget.isSelected && widget.backgroundImage != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final progress =
                                  (_shimmerAnimation.value + 1) / 2;
                              final travel = constraints.maxWidth + 180;
                              final dx = (progress * travel) - 90;

                              return Transform.translate(
                                offset: Offset(dx, 0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 180,
                                    height: constraints.maxHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: 0.18),
                                          Colors.white.withValues(alpha: 0.06),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.35, 0.65, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 22),
                    ),
                    const Gap(AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: widget.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.backgroundImage != null
                                  ? Colors.white
                                  : (widget.isSelected
                                        ? Colors.white
                                        : widget.colors.onSurface),
                            ),
                          ),
                          if (widget.isLocked) ...[
                            const Gap(8),
                            const ProBadge(compact: true),
                          ],
                          const Gap(4),
                          Text(
                            widget.description,
                            style: widget.textStyles.bodySmall?.copyWith(
                              color: widget.backgroundImage != null
                                  ? Colors.white
                                  : (widget.isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : widget.colors.secondary),
                              shadows: widget.backgroundImage != null
                                  ? [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.85,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.mode != null &&
                  TrainingHistory.hasExerciseToday(widget.mode!.name))
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: _DiagonalCornerClipper(),
                    child: Container(
                      width: 54,
                      height: 54,
                      color: LightColors.primary,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              if (widget.isSelected)
                const Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: textStyles.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.secondary,
          ),
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: 0.72)
                  : LightColors.surfaceHighlight,
              width: 1.35,
            ),
            boxShadow: AppShadows.cardPremium,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 22),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: textStyles.bodySmall?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}





class _ReflexSessionRecord {
  _ReflexSessionRecord({
    required this.mode,
    required this.date,
    required this.primaryScore,
    required this.stats,
  });
  final _ReflexesMode mode;
  final DateTime date;
  final double primaryScore;
  final Map<String, String> stats;

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'date': date.toIso8601String(),
    'primaryScore': primaryScore,
    'stats': stats,
  };
  factory _ReflexSessionRecord.fromJson(Map<String, dynamic> json) =>
      _ReflexSessionRecord(
        mode: _ReflexesMode.values.firstWhere(
          (e) => e.name == (json['mode'] ?? 'visual'),
          orElse: () => _ReflexesMode.visual,
        ),
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        primaryScore: (json['primaryScore'] as num?)?.toDouble() ?? 0,
        stats: json['stats'] is Map
            ? (json['stats'] as Map<dynamic, dynamic>).map<String, String>(
                (key, value) =>
                    MapEntry(key.toString(), value?.toString() ?? ''),
              )
            : const <String, String>{},
      );
  String primaryLabel(AppStrings strings) {
    switch (mode) {
      case _ReflexesMode.visual:
      case _ReflexesMode.auditory:
        return '${strings.reflexesAvgReactionTime}: ${stats['avg'] ?? '0'} ms';
      case _ReflexesMode.math:
        return '${strings.reflexesMathCorrectAnswers}: ${stats['correct'] ?? '0'}';
      case _ReflexesMode.memory:
        return '${strings.reflexesMemoryMaxLength}: ${stats['maxLength'] ?? '0'}';
      case _ReflexesMode.stroop:
        return '${strings.hitFactorScoreLabel}: ${primaryScore.toStringAsFixed(1)}';
      case _ReflexesMode.mot:
        return '${strings.reflexesMotSuccessRate}: ${primaryScore.toStringAsFixed(1)} %';
    }
  }
}

class _ReflexSmokeBlob extends StatefulWidget {
  const _ReflexSmokeBlob({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
    this.delay = 0,
  });
  final double? top, left, right, bottom;
  final double size;
  final Color color;
  final int delay;
  @override
  State<_ReflexSmokeBlob> createState() => _ReflexSmokeBlobState();
}

class _ReflexSmokeBlobState extends State<_ReflexSmokeBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = _ctrl.value;
            return Transform.translate(
              offset: Offset(30 * (t - 0.5), 30 * (t - 0.5)),
              child: Transform.scale(
                scale: 0.9 + 0.2 * t,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.5 - 0.25 * t),
                        widget.color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DifficultyOption {
  const _DifficultyOption({
    required this.label,
    required this.subtitle,
    required this.level,
  });
  final String label;
  final String subtitle;
  final int level;
}

Future<int?> showDifficultyPicker({
  required BuildContext context,
  required String title,
  required List<_DifficultyOption> options,
  required int currentLevel,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _DifficultyPickerSheet(
      title: title,
      options: options,
      currentLevel: currentLevel,
    ),
  );
}

class _DifficultyPickerSheet extends StatelessWidget {
  const _DifficultyPickerSheet({
    required this.title,
    required this.options,
    required this.currentLevel,
  });

  final String title;
  final List<_DifficultyOption> options;
  final int currentLevel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LightColors.iconInactive.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: options.map((opt) {
                final isSelected = opt.level == currentLevel;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(opt.level),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? LightColors.primary.withValues(alpha: 0.08)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? LightColors.primary
                              : colors.outline.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(3, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  i < opt.level
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 20,
                                  color: isSelected
                                      ? LightColors.primary
                                      : colors.secondary,
                                ),
                              );
                            }),
                          ),
                          const Gap(AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.label,
                                  style: textStyles.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                                if (opt.subtitle.isNotEmpty) ...[
                                  const Gap(2),
                                  Text(
                                    opt.subtitle,
                                    style: textStyles.bodySmall?.copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: LightColors.primary,
                            ),
                        ],
                      ),
                    ),
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

class _DiagonalCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final cornerRadius = 16.0;

    path.moveTo(0, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

extension on _ReactionDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _ReactionDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _ReactionDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _ReactionDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _MathOperator {
  String label(AppStrings s) {
    switch (this) {
      case _MathOperator.addition:
        return '+';
      case _MathOperator.subtraction:
        return '−';
      case _MathOperator.multiplication:
        return '×';
      case _MathOperator.division:
        return '÷';
      case _MathOperator.mixed:
        return s.reflexesModeMixed;
      case _MathOperator.addSubOnly:
        return '+ −';
      case _MathOperator.addSubMul:
        return '+ − ×';
    }
  }
}

extension on _MathDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _MathDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _MathDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _MathDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _MemoryDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _MemoryDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _MemoryDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _MemoryDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _StroopDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _StroopDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _StroopDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _StroopDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _MotDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _MotDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _MotDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _MotDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

class _StroopStimulusView extends StatelessWidget {
  const _StroopStimulusView({super.key, required this.word, required this.ink});
  final _StroopInkColor? word;
  final _StroopInkColor? ink;
  @override
  Widget build(BuildContext context) {
    if (word == null || ink == null) return const SizedBox.expand();
    final strings = AppStrings.of(context);
    return Center(
      child: Transform.translate(
        offset: const Offset(0, 52),
        child: Text(
          _stroopName(strings, word!),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _stroopColor(ink!),
            fontSize: 110,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeWrapper extends StatefulWidget {
  const _LandscapeWrapper({required this.color, required this.child});
  final Color color;
  final Widget child;
  @override
  State<_LandscapeWrapper> createState() => _LandscapeWrapperState();
}

class _LandscapeWrapperState extends State<_LandscapeWrapper> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaQuery.removePadding(
    context: context,
    removeTop: true,
    removeBottom: true,
    removeLeft: true,
    removeRight: true,
    child: SizedBox.expand(
      child: ColoredBox(color: widget.color, child: widget.child),
    ),
  );
}

