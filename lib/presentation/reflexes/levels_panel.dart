part of '../reflexes_screen.dart';

// ─────────────────────────────────────────────────────────────
//  _LevelsPanelBody — grille 50 niveaux intégrée au bottom sheet
// ─────────────────────────────────────────────────────────────

class _LevelsPanelBody extends StatefulWidget {
  const _LevelsPanelBody({
    required this.modeKey,
    required this.mode,
    required this.description,
    required this.infoTooltip,
    required this.colors,
    required this.textStyles,
    required this.onStartLevel,
    required this.starsCalculator,
    required this.scoreLabel,
  });

  final String modeKey;
  final _ReflexesMode mode;
  final String description;
  final String infoTooltip;
  final ColorScheme colors;
  final TextTheme textStyles;
  final Future<({double? score, bool closeAll, bool nextLevel})> Function(
    int level,
  )
  onStartLevel;
  final int Function(double score) starsCalculator;
  final String Function(double score) scoreLabel;

  @override
  State<_LevelsPanelBody> createState() => _LevelsPanelBodyState();
}

class _LevelsPanelBodyState extends State<_LevelsPanelBody> {
  static const int _kTotal = 50;

  Map<int, ExerciseLevelRecord> _records = {};
  bool _loading = true;
  int? _runningLevel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_LevelsPanelBody old) {
    super.didUpdateWidget(old);
    if (old.modeKey != widget.modeKey) _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await loadLevelRecords(widget.modeKey);
    if (mounted)
      setState(() {
        _records = records;
        _loading = false;
      });

    // Auto-scroll to the current unlocked level after render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final unlocked = _unlockedUpTo;
      final row = (unlocked - 1) ~/ 5;
      if (row > 2) {
        final screenWidth = MediaQuery.of(context).size.width;
        final gridWidth = screenWidth - 32; // AppSpacing.md * 2
        final itemWidth = (gridWidth - 32) / 5; // 4 * crossAxisSpacing(8)
        final itemHeight = itemWidth / 0.82; // childAspectRatio
        final rowHeight = itemHeight + 8; // mainAxisSpacing

        // Target offset to show the row somewhat in the middle or top
        final targetOffset = (row - 1) * rowHeight;
        final maxScroll = _scrollController.position.maxScrollExtent;

        _scrollController.animateTo(
          targetOffset.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  int get _unlockedUpTo {
    if (_records.isEmpty) return 1;
    int maxLevel = 1;
    for (final lvl in _records.keys) {
      if (lvl > maxLevel) maxLevel = lvl;
    }
    return (maxLevel + 1).clamp(1, _kTotal);
  }

  int get _earnedStars {
    int total = 0;
    for (final record in _records.values) {
      total += widget.starsCalculator(record.score);
    }
    return total;
  }

  int get _maxStarsAtCurrentAdvancement {
    return _unlockedUpTo * 3;
  }

  Future<void> _play(int level) async {
    if (level > _unlockedUpTo) return;
    setState(() => _runningLevel = level);
    final result = await widget.onStartLevel(level);
    if (!mounted) return;
    setState(() => _runningLevel = null);
    if (result.score != null && result.score! >= 0) {
      final record = ExerciseLevelRecord(
        level: level,
        score: result.score!,
        date: DateTime.now(),
      );
      await saveLevelRecord(widget.modeKey, record, _records);
      if (mounted) {
        await _load();
      }
    }
    if (!mounted) return;
    if (result.closeAll) {
      // Close the entire levels panel
      Navigator.of(context).pop();
      return;
    }
    if (result.nextLevel) {
      final nextLvl = level + 1;
      if (nextLvl <= _kTotal && nextLvl <= _unlockedUpTo) {
        _play(nextLvl);
      }
    }
  }

  List<TextSpan> _parseBold(String text, TextStyle base) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last)
        spans.add(TextSpan(text: text.substring(last, m.start), style: base));
      spans.add(
        TextSpan(
          text: m.group(1),
          style: base.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      last = m.end;
    }
    if (last < text.length)
      spans.add(TextSpan(text: text.substring(last), style: base));
    return spans;
  }

  Widget _buildDescription() {
    final base =
        widget.textStyles.bodyMedium?.copyWith(
          color: widget.colors.onSurface,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(color: widget.colors.onSurface, height: 1.4);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.colors.outline.withValues(alpha: 0.35),
        ),
      ),
      child: RichText(
        text: TextSpan(children: _parseBold(widget.description, base)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlocked = _unlockedUpTo;

    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Text(
                  '${_records.length} / $_kTotal',
                  style: widget.textStyles.labelMedium?.copyWith(
                    color: LightColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _records.length / _kTotal,
                      minHeight: 4,
                      backgroundColor: widget.colors.outline.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        LightColors.primary,
                      ),
                    ),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: LightColors.primary,
                    ),
                    const Gap(2),
                    Text(
                      '$_earnedStars / $_maxStarsAtCurrentAdvancement',
                      style: widget.textStyles.labelMedium?.copyWith(
                        color: LightColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          // Description de l'exercice
          if (widget.description.isNotEmpty) ...[
            _buildDescription(),
            const Gap(AppSpacing.sm),
          ],
          // Grid
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.82,
              ),
              itemCount: _kTotal,
              addRepaintBoundaries: true,
              cacheExtent: 200,
              itemBuilder: (ctx, index) {
                final level = index + 1;
                final isUnlocked = level <= unlocked;
                final record = _records[level];
                final stars = record != null
                    ? widget.starsCalculator(record.score)
                    : 0;
                final isRunning = _runningLevel == level;

                return _LevelCell(
                  level: level,
                  isUnlocked: isUnlocked,
                  stars: stars,
                  bestScore: record != null
                      ? widget.scoreLabel(record.score)
                      : null,
                  isRunning: isRunning,
                  onTap: isUnlocked ? () => _play(level) : null,
                  colors: widget.colors,
                  textStyles: widget.textStyles,
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCell extends StatelessWidget {
  const _LevelCell({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.bestScore,
    required this.isRunning,
    required this.onTap,
    required this.colors,
    required this.textStyles,
    required this.isDark,
  });

  final int level;
  final bool isUnlocked;
  final int stars;
  final String? bestScore;
  final bool isRunning;
  final VoidCallback? onTap;
  final ColorScheme colors;
  final TextTheme textStyles;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasRecord = bestScore != null;

    Color bg;
    Color borderColor;
    Color textColor;

    if (!isUnlocked) {
      bg = isDark
          ? colors.surface.withValues(alpha: 0.4)
          : const Color(0xFFF0F0F0);
      borderColor = colors.outline.withValues(alpha: 0.18);
      textColor = colors.onSurface.withValues(alpha: 0.28);
    } else if (hasRecord) {
      bg = colors.surface;
      borderColor = LightColors.primary.withValues(alpha: 0.55);
      textColor = colors.onSurface;
    } else {
      bg = colors.surface;
      borderColor = LightColors.primary;
      textColor = colors.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isRunning ? LightColors.primary.withValues(alpha: 0.15) : bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isRunning ? LightColors.primary : borderColor,
            width: isRunning ? 2.0 : 1.2,
          ),
          boxShadow: isUnlocked && !isRunning
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isRunning
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LightColors.primary,
                    ),
                  ),
                ),
              )
            : !isUnlocked
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: colors.onSurface.withValues(alpha: 0.22),
                  ),
                  const Gap(2),
                  Text(
                    '$level',
                    style: textStyles.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final filled = i < stars;
                        return Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 11,
                          color: filled
                              ? const Color(0xFFFFC107)
                              : colors.onSurface.withValues(alpha: 0.18),
                        );
                      }),
                    ),
                    const Gap(3),
                    Text(
                      '$level',
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    if (bestScore != null) ...[
                      const Gap(2),
                      Text(
                        bestScore!,
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.secondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

