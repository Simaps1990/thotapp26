part of '../reflexes_screen.dart';

double _statNumber(Map<String, String> stats, String key) {
  final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(stats[key] ?? '');
  if (match == null) return 0;
  return double.tryParse(match.group(1) ?? '') ?? 0;
}

double _boundedScore(double value) => value.clamp(0, 1000).toDouble();

/// Translates a penalty reason key (the part after '_score_penalty_')
/// into a human-readable, localized label.
///
/// Returns the raw key (capitalized) as a fallback so a future-added
/// penalty type still shows something rather than nothing.
String _penaltyReasonLabel(AppStrings strings, String reasonKey) {
  switch (reasonKey) {
    case 'speed':
      return strings.reflexesPenaltyReasonSpeed;
    case 'errors':
      return strings.reflexesPenaltyReasonErrors;
    case 'accuracy':
      return strings.reflexesPenaltyReasonAccuracy;
    case 'missed':
      return strings.reflexesPenaltyReasonMissed;
    case 'timeout':
      return strings.reflexesPenaltyReasonTimeout;
    default:
      // Fallback: capitalize first letter so future keys don't look broken.
      if (reasonKey.isEmpty) return reasonKey;
      return reasonKey[0].toUpperCase() + reasonKey.substring(1);
  }
}

double _scoredValue(
  _ReflexesMode mode,
  double primaryScore,
  Map<String, String> stats,
) {
  final stored = double.tryParse(stats['_score_final'] ?? '');
  if (stored != null && stored.isFinite) return stored;
  switch (mode) {
    case _ReflexesMode.visual:
    case _ReflexesMode.auditory:
      final falseStarts = _statNumber(stats, 'Faux départs');
      return _boundedScore(
        1000 - max(0, primaryScore - 180) * 1.35 - falseStarts * 180,
      );
    case _ReflexesMode.math:
      return _boundedScore(primaryScore);
    case _ReflexesMode.memory:
      return _boundedScore(primaryScore);
    case _ReflexesMode.stroop:
      final correct = _statNumber(stats, 'Bonnes réponses');
      final wrong = _statNumber(stats, 'Mauvaises réponses');
      final total = max(1, correct + wrong);
      final accuracy = correct / total;
      return _boundedScore(
        (1000 - max(0, primaryScore - 700) * 0.45) * accuracy - wrong * 140,
      );
    case _ReflexesMode.mot:
      return _boundedScore(primaryScore * 10);
  }
}

/// Computes star rating from a normalized 0–1000 score.
///
/// Thresholds MUST stay in sync with [_ReflexesPanel._starsCalcForMode]
/// otherwise the result page and the level grid will disagree.
int _starsForScore(double score) {
  if (score >= 850) return 3;
  if (score >= 650) return 2;
  if (score >= 350) return 1; // raised from "score > 0" to avoid 1⭐ on near-zero
  return 0;
}

class _AnimatedLevelStarsBlock extends StatefulWidget {
  final int? level;
  final int stars;
  final double score;

  const _AnimatedLevelStarsBlock({
    required this.level,
    required this.stars,
    required this.score,
  });

  @override
  State<_AnimatedLevelStarsBlock> createState() =>
      _AnimatedLevelStarsBlockState();
}

class _AnimatedLevelStarsBlockState extends State<_AnimatedLevelStarsBlock>
    with SingleTickerProviderStateMixin {
  // Total animation length. Each star plays a fast 220ms zoom-in animation;
  // the 3 stars are staggered (see Interval below) so the whole sequence
  // completes around ~520ms.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _scheduleStarsAnimation();
  }

  @override
  void didUpdateWidget(covariant _AnimatedLevelStarsBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stars != widget.stars ||
        oldWidget.level != widget.level ||
        oldWidget.score != widget.score) {
      _scheduleStarsAnimation();
    }
  }

  void _scheduleStarsAnimation() {
    _controller.value = 0;
    _startTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 450ms delay before the first star arrives — gives the result page
      // time to fade in and lets the user focus on the score before the
      // stars impact the layout.
      _startTimer = Timer(const Duration(milliseconds: 450), () {
        if (mounted) _controller.forward(from: 0);
      });
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final stars = widget.stars.clamp(0, 3);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline.withValues(alpha: 0.55)),
          boxShadow: AppShadows.cardPremium,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.reflexesLevelValue('${widget.level ?? '—'}'),
                  style: texts.labelLarge?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const Gap(2),
                Text(
                  strings.reflexesPointsValue(widget.score.toStringAsFixed(0)),
                  style: texts.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final visible = index < stars;
                // Staggered left→right: each star starts 0.30 after the
                // previous one and takes 0.42 of the controller duration
                // (~220ms each). The sequence covers 0.00→1.00.
                final start = index * 0.30;
                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    start,
                    (start + 0.42).clamp(0, 1),
                    // easeOutCubic settles fast at the end and doesn't
                    // overshoot — feels like a snappy impact, not a bounce.
                    curve: Curves.easeOutCubic,
                  ),
                );
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 3),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Always-visible empty star backdrop (shown for 0 and
                        // for unobtained slots). Stays static.
                        _EmptyResultStar(colors: colors),
                        // Animated premium star — only for obtained slots.
                        if (visible)
                          AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              final value = animation.value;
                              // Zoom-in "dézoom" effect: star arrives from the
                              // viewer (scale 2.8 → 1.0), blurred and faded
                              // for the first 60% of the animation, then it
                              // crystallises.
                              final scale = 2.8 - value * 1.8; // 2.8 → 1.0
                              final opacity = Curves.easeIn.transform(value);
                              // Blur fades out as the star approaches its
                              // resting size — gone by the end.
                              final blur = (1 - value) * 6.0;
                              return Opacity(
                                opacity: opacity.clamp(0.0, 1.0),
                                child: Transform.scale(
                                  scale: scale,
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: blur,
                                      sigmaY: blur,
                                    ),
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: _PremiumResultStar(colors: colors),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResultStar extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyResultStar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: 39,
            color: colors.shadow.withValues(alpha: 0.10),
            semanticLabel: AppStrings.of(context).reflexesScoreScaleStarsLabel,
          ),
          Icon(
            Icons.star_border_rounded,
            size: 39,
            color: colors.outline.withValues(alpha: 0.55),
            semanticLabel: AppStrings.of(context).reflexesScoreScaleStarsLabel,
            shadows: [
              Shadow(
                color: colors.shadow.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumResultStar extends StatelessWidget {
  final ColorScheme colors;

  const _PremiumResultStar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFD36A).withValues(alpha: 0.24),
            const Color(0xFFFFA726).withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0.0, 0.58, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: 39,
            color: colors.shadow.withValues(alpha: 0.18),
            shadows: [
              Shadow(
                color: colors.shadow.withValues(alpha: 0.28),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF3B0), Color(0xFFFFC447), Color(0xFFFF8F1F)],
            ).createShader(bounds),
            child: Icon(
              Icons.star_rounded,
              size: 37,
              semanticLabel: AppStrings.of(context).reflexesScoreScaleStarsLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTopThreeCard extends StatelessWidget {
  const _ResultTopThreeCard({
    required this.records,
    required this.colors,
    required this.textStyles,
    required this.strings,
    required this.scoreTextBuilder,
    required this.dateTextBuilder,
  });

  final List<_ReflexSessionRecord> records;
  final ColorScheme colors;
  final TextTheme textStyles;
  final AppStrings strings;
  final String Function(_ReflexSessionRecord record) scoreTextBuilder;
  final String Function(DateTime date) dateTextBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
        boxShadow: AppShadows.cardPremium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: colors.primary),
              const Gap(AppSpacing.sm),
              Text(
                strings.reflexesTopThree,
                style: textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          if (records.isEmpty)
            Text(
              strings.reflexesNoSessions,
              style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
            )
          else
            ...records.take(3).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final medalColor = index == 0
                  ? const Color(0xFFFFC107)
                  : index == 1
                  ? const Color(0xFFB0BEC5)
                  : const Color(0xFFCD7F32);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: medalColor,
                      size: 20,
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        scoreTextBuilder(record),
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      dateTextBuilder(record.date),
                      style: textStyles.bodySmall?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ResultTitleWithScaleInfo extends StatelessWidget {
  const _ResultTitleWithScaleInfo({required this.mode, required this.title});

  final _ReflexesMode mode;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: texts.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
        ),
        const Gap(6),
        Tooltip(
          richMessage: TextSpan(
            style: texts.bodySmall?.copyWith(
              color: colors.surface,
              height: 1.35,
            ),
            children: _scoreScaleSpans(context, mode),
          ),
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 8),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colors.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

List<InlineSpan> _scoreScaleSpans(BuildContext context, _ReflexesMode mode) {
  final colors = Theme.of(context).colorScheme;
  final strings = AppStrings.of(context);
  final label = TextStyle(color: colors.secondary, fontWeight: FontWeight.w800);
  final content = _scoreScaleContent(context, mode);
  return [
    TextSpan(text: '${strings.reflexesScoreScaleScoreLabel} : ', style: label),
    TextSpan(text: '${content.$1}\n'),
    TextSpan(
      text: '${strings.reflexesScoreScalePenaltyLabel} : ',
      style: label,
    ),
    TextSpan(text: '${content.$2}\n'),
    TextSpan(text: '${strings.reflexesScoreScaleStarsLabel} : ', style: label),
    TextSpan(text: content.$3),
  ];
}

(String, String, String) _scoreScaleContent(
  BuildContext context,
  _ReflexesMode mode,
) {
  final strings = AppStrings.of(context);
  switch (mode) {
    case _ReflexesMode.visual:
    case _ReflexesMode.auditory:
      return (
        strings.reflexesScoreScaleReactionScore,
        strings.reflexesScoreScaleReactionPenalty,
        strings.reflexesScoreScaleStarsRule,
      );
    case _ReflexesMode.math:
      return (
        strings.reflexesScoreScaleMathScore,
        strings.reflexesScoreScaleMathPenalty,
        strings.reflexesScoreScaleStarsRule,
      );
    case _ReflexesMode.memory:
      return (
        strings.reflexesScoreScaleMemoryScore,
        strings.reflexesScoreScaleMemoryPenalty,
        strings.reflexesScoreScaleStarsRule,
      );
    case _ReflexesMode.stroop:
      return (
        strings.reflexesScoreScaleStroopScore,
        strings.reflexesScoreScaleStroopPenalty,
        strings.reflexesScoreScaleStarsRule,
      );
    case _ReflexesMode.mot:
      return (
        strings.reflexesScoreScaleMotScore,
        strings.reflexesScoreScaleMotPenalty,
        strings.reflexesScoreScaleStarsRule,
      );
  }
}

class _ScoreEquationBlock extends StatelessWidget {
  const _ScoreEquationBlock({
    required this.mode,
    required this.primaryScore,
    required this.stats,
  });

  final _ReflexesMode mode;
  final double primaryScore;
  final Map<String, String> stats;

  double _num(String key) => double.tryParse(stats[key] ?? '') ?? 0;

  String? _valueContaining(String text) {
    for (final entry in stats.entries) {
      if (entry.key.toLowerCase().contains(text.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  String _withMs(String value) {
    final trimmed = value.trim();
    return trimmed.toLowerCase().endsWith('ms') ? trimmed : '$trimmed ms';
  }

  String _scoreOrigin(AppStrings strings, double base) {
    final avgReaction = _valueContaining('réaction');
    final avgAnswer = _valueContaining('réponse');
    final correct = _valueContaining('bonnes réponses');
    final memoryCorrect = _valueContaining('correct');
    final targets = _valueContaining('cibles');
    final reactionLabel = avgReaction == null ? null : _withMs(avgReaction);
    final answerLabel = avgAnswer == null ? null : _withMs(avgAnswer);
    final points = strings.reflexesPointsValue(base.toStringAsFixed(0));
    if (mode == _ReflexesMode.visual || mode == _ReflexesMode.auditory) {
      return strings.reflexesScoreOriginReaction(
        reactionLabel ?? '${primaryScore.toStringAsFixed(0)} ms',
        points,
      );
    }
    if (mode == _ReflexesMode.stroop) {
      return strings.reflexesScoreOriginAverage(
        reactionLabel ?? '${primaryScore.toStringAsFixed(0)} ms',
        points,
      );
    }
    if (mode == _ReflexesMode.math) {
      return strings.reflexesScoreOriginMath(
        correct ?? '—',
        answerLabel ?? '—',
        points,
      );
    }
    if (mode == _ReflexesMode.memory) {
      return strings.reflexesScoreOriginMemory(memoryCorrect ?? '—', points);
    }
    return strings.reflexesScoreOriginMot(targets ?? '—', points);
  }

  Widget _bulletLine(BuildContext context, String text, Color color) {
    final texts = Theme.of(context).textTheme;
    final style = texts.bodyMedium?.copyWith(
      color: color,
      fontWeight: FontWeight.w400,
    );
    final separatorIndex = text.indexOf(':');
    final title = separatorIndex >= 0
        ? text.substring(0, separatorIndex + 1)
        : text;
    final content = separatorIndex >= 0
        ? text.substring(separatorIndex + 1)
        : '';

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: '• $title',
            style: style?.copyWith(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final finalScore = _scoredValue(mode, primaryScore, stats);
    final base = _num('_score_base');
    // Keyed penalties — each line tells the user WHY they lost points.
    // The key after '_score_penalty_' identifies the source (speed,
    // accuracy, errors, missed, etc.) and is translated via AppStrings.
    final keyedPenalties = <MapEntry<String, double>>[];
    for (final entry in stats.entries) {
      if (!entry.key.startsWith('_score_penalty_')) continue;
      final value = double.tryParse(entry.value) ?? 0;
      if (value <= 0) continue;
      final reason = entry.key.substring('_score_penalty_'.length);
      keyedPenalties.add(MapEntry(reason, value));
    }
    // Show the heaviest penalties first — more useful feedback.
    keyedPenalties.sort((a, b) => b.value.compareTo(a.value));
    final penaltyTotal = keyedPenalties.fold<double>(
      0,
      (sum, e) => sum + e.value,
    );
    final effectiveBase = base > 0 ? base : finalScore;
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bulletLine(
            context,
            _scoreOrigin(strings, effectiveBase),
            colors.onSurface,
          ),
          const Gap(6),
          _bulletLine(
            context,
            penaltyTotal > 0
                ? strings.reflexesPenaltyValue(
                    '−${strings.reflexesPointsValue(penaltyTotal.toStringAsFixed(0))}',
                  )
                : strings.reflexesPenaltyValue(
                    strings.reflexesPointsValue('0'),
                  ),
            penaltyTotal > 0 ? colors.error : colors.onSurfaceVariant,
          ),
          // Per-reason breakdown — only shown when there's at least one
          // non-zero penalty. Indented under the total to make the
          // hierarchy obvious.
          if (keyedPenalties.isNotEmpty) ...[
            const Gap(4),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in keyedPenalties)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '• ${_penaltyReasonLabel(strings, p.key)}  '
                        '−${p.value.toStringAsFixed(0)}',
                        style: texts.bodySmall?.copyWith(
                          color: colors.error.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const Gap(10),
          Container(height: 1, color: colors.outline.withValues(alpha: 0.45)),
          const Gap(10),
          Text(
            strings.reflexesTotalValue(
              strings.reflexesPointsValue(finalScore.toStringAsFixed(0)),
            ),
            textAlign: TextAlign.center,
            style: texts.headlineSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}


