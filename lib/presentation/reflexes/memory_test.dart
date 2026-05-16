part of '../reflexes_screen.dart';

class _MemoryInputBoxesDisplay extends StatelessWidget {
  const _MemoryInputBoxesDisplay({
    required this.sequenceLength,
    required this.input,
    this.correctSequence,
    this.showResult = false,
  });

  final int sequenceLength;
  final String input;
  final String? correctSequence;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = sequenceLength <= 0 ? 1 : sequenceLength;
        const spacing = 6.0;
        final available = constraints.maxWidth - (spacing * 2 * count);
        final blockWidth = (available / count).clamp(28.0, 56.0);
        final blockHeight = blockWidth * 1.35;
        final fontSize = (blockWidth * 0.8).clamp(24.0, 44.0);
        final chars = input.characters.toList();
        final correct = correctSequence?.characters.toList() ?? [];

        Widget buildRow(List<String> digits, {bool isAnswer = false}) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final char = index < digits.length ? digits[index] : '';

              Color boxBg;
              Color borderColor;
              Color textColor;

              if (isAnswer) {
                // Always green for the reference answer row
                boxBg = const Color(0xFF0D3A28);
                borderColor = const Color(0xFF00C853);
                textColor = const Color(0xFF00E676);
              } else if (showResult && char.isNotEmpty) {
                final expectedChar = index < correct.length
                    ? correct[index]
                    : '';
                if (char == expectedChar) {
                  boxBg = const Color(0xFF0D3A28);
                  borderColor = const Color(0xFF00C853);
                  textColor = const Color(0xFF00E676);
                } else {
                  boxBg = const Color(0xFF4A1620);
                  borderColor = const Color(0xFFD32F2F);
                  textColor = const Color(0xFFFF5252);
                }
              } else {
                boxBg = const Color(0xFF1F1F1F);
                borderColor = const Color(0xFF4F4F4F);
                textColor = const Color(0xFFF2F2F2);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: spacing),
                child: Container(
                  width: blockWidth,
                  height: blockHeight,
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                      width: isAnswer ? 2.0 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isAnswer
                            ? const Color(0xFF00C853).withValues(alpha: 0.22)
                            : Colors.black.withValues(alpha: 0.34),
                        blurRadius: isAnswer ? 10 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      char,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showResult && correctSequence != null) ...[
              // --- Reference answer boxes (always green) ---
              buildRow(correct, isAnswer: true),
              const SizedBox(height: 32),
              // --- Divider between answer and user input ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(
                  height: 1.5,
                  thickness: 1.5,
                  color: const Color(0xFF4F4F4F).withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 14),
              // --- User input label ---
              Text(
                'VOTRE RÉPONSE',
                style: TextStyle(
                  color: const Color(0xFFF2F2F2).withValues(alpha: 0.45),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // --- User input boxes ---
            buildRow(chars),
          ],
        );
      },
    );
  }
}

class _MemoryRunScreen extends StatefulWidget {
  _MemoryRunScreen({
    this.onResultSaved,
    required this.difficulty,
    required this.sequenceLength,
    required this.displayMs,
    required this.rounds,
    this.history = const <_ReflexSessionRecord>[],
    this.level,
  });
  final _MemoryDifficulty difficulty;
  final int sequenceLength;
  final int displayMs;
  final int rounds;
  final List<_ReflexSessionRecord> history;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;
  @override
  State<_MemoryRunScreen> createState() => _MemoryRunScreenState();
}

class _MemoryRunScreenState extends State<_MemoryRunScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _random = Random();
  List<int> _sequence = [];
  String _input = '';
  int _round = 1;
  int _correct = 0;
  int _maxLength = 0;
  bool _showSequence = true;
  String? _feedback;
  String? _memoryFeedback;
  Timer? _memoryFeedbackTimer;
  late final AnimationController _memoryFeedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
  bool _showResults = false;
  _ReflexSessionRecord? _currentResult;
  // For color-coded box feedback
  bool _showInputResult = false;
  String? _expectedSequenceStr;

  int _compareScores(_ReflexSessionRecord a, _ReflexSessionRecord b) {
    return _scoredValue(
      b.mode,
      b.primaryScore,
      b.stats,
    ).compareTo(_scoredValue(a.mode, a.primaryScore, a.stats));
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  List<_ReflexSessionRecord> _topRecords() {
    final current = _currentResult;
    final levelStr = widget.level?.toString();
    var records = <_ReflexSessionRecord>[
      ...widget.history,
      if (current != null) current,
    ];
    if (levelStr != null) {
      records = records.where((r) => r.stats['_level'] == levelStr).toList();
    }
    records.sort(_compareScores);
    return records;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _startRound();
  }

  Future<void> _startRound() async {
    _sequence = List.generate(
      widget.sequenceLength,
      (_) => _random.nextInt(10),
    );
    _input = '';
    _feedback = null;
    _showSequence = true;
    _showInputResult = false;
    _expectedSequenceStr = null;
    if (mounted) setState(() {});
    await Future.delayed(Duration(milliseconds: widget.displayMs));
    if (!mounted) return;
    setState(() => _showSequence = false);
  }

  Future<void> _submit() async {
    if (_showSequence) return;
    final expected = _sequence.join();
    final strings = AppStrings.of(context);
    final success = _input == expected;

    // Show color-coded result
    setState(() {
      _showInputResult = true;
      _expectedSequenceStr = expected;
    });

    if (success) {
      _correct++;
      _maxLength = max(_maxLength, widget.sequenceLength);
      _feedback = strings.reflexesMemoryCorrect;
      _memoryFeedback = 'ok';
    } else {
      var idx = 0;
      while (idx < _input.length &&
          idx < expected.length &&
          _input[idx] == expected[idx]) {
        idx++;
      }
      _feedback = '${strings.reflexesMemoryIncorrect} ${idx + 1}';
      _memoryFeedback = 'wrong';
    }
    _memoryFeedbackAnimationController.reset();
    _memoryFeedbackAnimationController.forward();
    _memoryFeedbackTimer?.cancel();
    _memoryFeedbackTimer = Timer(const Duration(milliseconds: 600), () {
      setState(() => _memoryFeedback = null);
    });

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_round >= widget.rounds) {
      final successRate = widget.rounds == 0 ? 0.0 : _correct / widget.rounds;
      final lengthBonus = min(1.0, widget.sequenceLength / 8.0) * 180;
      final baseScore = (820 * successRate) + lengthBonus;
      final errorPenalty = (widget.rounds - _correct) * 170.0;
      final score = _boundedScore(baseScore - errorPenalty);
      final result = _ReflexSessionRecord(
        mode: _ReflexesMode.memory,
        date: DateTime.now(),
        primaryScore: score,
        stats: {
          '_score_final': score.toStringAsFixed(1),
          '_score_base': baseScore.toStringAsFixed(1),
          '_score_penalty_errors': errorPenalty.toStringAsFixed(1),
          strings.reflexesMemoryRounds: '${widget.rounds}',
          strings.reflexesMemoryCorrect: '$_correct',
          strings.reflexesMemoryMaxLength: '$_maxLength',
          strings.reflexesMemorySequenceLength: '${widget.sequenceLength}',
          if (widget.level != null) '_level': widget.level.toString(),
        },
      );
      setState(() {
        _currentResult = result;
        _showResults = true;
      });
      return;
    }

    _round++;
    _startRound();
  }

  void _restartRun() {
    _round = 1;
    _correct = 0;
    _maxLength = 0;
    _input = '';
    _feedback = null;
    _showSequence = true;
    _sequence = [];
    _startRound();
  }

  void _closeToTools() {
    final current = _currentResult;
    if (current == null) return;
    final flaggedStats = Map<String, String>.from(current.stats)
      ..['_close_tools'] = '1'
      ..['_close_all'] = '1';
    Navigator.of(context).pop(
      _ReflexSessionRecord(
        mode: current.mode,
        date: current.date,
        primaryScore: current.primaryScore,
        stats: flaggedStats,
      ),
    );
  }

  void _nextLevel() {
    final current = _currentResult;
    if (current == null) return;
    final flaggedStats = Map<String, String>.from(current.stats)
      ..['_next_level'] = '1';
    Navigator.of(context).pop(
      _ReflexSessionRecord(
        mode: current.mode,
        date: current.date,
        primaryScore: current.primaryScore,
        stats: flaggedStats,
      ),
    );
  }

  void _stop() {
    if (_correct > 0) {
      final strings = AppStrings.of(context);
      final successRate = widget.rounds == 0 ? 0.0 : _correct / widget.rounds;
      final lengthBonus = min(1.0, widget.sequenceLength / 8.0) * 180;
      final baseScore = (820 * successRate) + lengthBonus;
      final errorPenalty = (widget.rounds - _correct) * 170.0;
      final score = _boundedScore(baseScore - errorPenalty);
      final result = _ReflexSessionRecord(
        mode: _ReflexesMode.memory,
        date: DateTime.now(),
        primaryScore: score,
        stats: {
          '_score_final': score.toStringAsFixed(1),
          '_score_base': baseScore.toStringAsFixed(1),
          '_score_penalty_errors': errorPenalty.toStringAsFixed(1),
          strings.reflexesMemoryRounds: '${_round - 1}',
          strings.reflexesMemoryCorrect: '$_correct',
          strings.reflexesMemoryMaxLength: '$_maxLength',
          strings.reflexesMemorySequenceLength: '${widget.sequenceLength}',
          '_stopped_early': '1',
          if (widget.level != null) '_level': widget.level.toString(),
        },
      );
      setState(() {
        _currentResult = result;
        _showResults = true;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stop();
    }
  }

  @override
  void dispose() {
    _memoryFeedbackTimer?.cancel();
    _memoryFeedbackAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final texts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (_showResults && _currentResult != null) {
      final baseBackground = Theme.of(context).scaffoldBackgroundColor;
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: BoxDecoration(
              color: baseBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: LightColors.iconInactive.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pop(_currentResult),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade300
                                  : LightColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        Expanded(
                          child: _ResultTitleWithScaleInfo(
                            mode: _currentResult!.mode,
                            title: strings.reflexesResultsTitle,
                          ),
                        ),
                        GestureDetector(
                          onTap: _closeToTools,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 32,
                              color: colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Divider(color: colors.outline),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.paddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AnimatedLevelStarsBlock(
                          level: widget.level,
                          score: _scoredValue(
                            _currentResult!.mode,
                            _currentResult!.primaryScore,
                            _currentResult!.stats,
                          ),
                          stars: _starsForScore(
                            _scoredValue(
                              _currentResult!.mode,
                              _currentResult!.primaryScore,
                              _currentResult!.stats,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        Container(
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                strings.reflexesModeMemory,
                                style: texts.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.secondary,
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              _ScoreEquationBlock(
                                mode: _currentResult!.mode,
                                primaryScore: _currentResult!.primaryScore,
                                stats: _currentResult!.stats,
                              ),
                              const Gap(AppSpacing.md),
                              ..._currentResult!.stats.entries
                                  .where((e) => !e.key.startsWith('_'))
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              e.key,
                                              style: texts.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            e.value,
                                            style: texts.titleMedium?.copyWith(
                                              color: colors.primary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        SizedBox(
                          height: 52,
                          child: Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    widget.onResultSaved?.call(_currentResult!);
                                    setState(() {
                                      _showResults = false;
                                      _currentResult = null;
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) _restartRun();
                                        });
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        colors.surfaceContainerHighest,
                                    foregroundColor: colors.onSurfaceVariant,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.replay_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    strings.colorPodRestart.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const Gap(AppSpacing.sm),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _nextLevel,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    strings.colorPodNext.toUpperCase(),
                                  ),
                                  iconAlignment: IconAlignment.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        _ResultTopThreeCard(
                          records: _topRecords(),
                          colors: colors,
                          textStyles: texts,
                          strings: strings,
                          scoreTextBuilder: (record) =>
                              strings.reflexesPointsValue(
                                _scoredValue(
                                  record.mode,
                                  record.primaryScore,
                                  record.stats,
                                ).toStringAsFixed(0),
                              ),
                          dateTextBuilder: _formatDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${strings.reflexesMemoryRounds}: $_round/${widget.rounds}',
                        style: texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _stop,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        child: Text(
                          strings.colorPodStop,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _showSequence
                      ? _MemorySequenceFlipDisplay(sequence: _sequence)
                      : Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            _MemoryInputBoxesDisplay(
                              sequenceLength: widget.sequenceLength,
                              input: _input,
                              correctSequence: _expectedSequenceStr,
                              showResult: _showInputResult,
                            ),
                            if (_memoryFeedback != null)
                              Positioned(
                                top: -78,
                                child: AnimatedBuilder(
                                  animation: _memoryFeedbackAnimationController,
                                  builder: (_, __) {
                                    final t = _memoryFeedbackAnimationController
                                        .value;
                                    final appear = Curves.easeOutBack.transform(
                                      (t / 0.32).clamp(0.0, 1.0),
                                    );
                                    final vanish = ((t - 0.65) / 0.35).clamp(
                                      0.0,
                                      1.0,
                                    );
                                    final scale =
                                        0.72 +
                                        (appear * 0.28) -
                                        (vanish * 0.08);
                                    final y =
                                        (16 * (1.0 - appear)) - (22 * vanish);
                                    final opacity =
                                        ((1.0 - vanish) *
                                                (0.65 + 0.35 * appear))
                                            .clamp(0.0, 1.0)
                                            .toDouble();
                                    final isOk = _memoryFeedback == 'ok';
                                    final accent = isOk
                                        ? const Color(0xFF00E676)
                                        : const Color(0xFFFF5252);
                                    final bg = isOk
                                        ? const Color(0xFF0D3A28)
                                        : const Color(0xFF4A1620);
                                    final textColor = isOk
                                        ? const Color(0xFFE8FFF4)
                                        : const Color(0xFFFFECEF);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Transform.translate(
                                        offset: Offset(0, y),
                                        child: Opacity(
                                          opacity: opacity,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  bg.withValues(alpha: 0.98),
                                                  accent.withValues(
                                                    alpha: 0.26,
                                                  ),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(26),
                                              border: Border.all(
                                                color: accent.withValues(
                                                  alpha: 0.55,
                                                ),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accent.withValues(
                                                    alpha: 0.25,
                                                  ),
                                                  blurRadius: 22,
                                                  spreadRadius: 2,
                                                ),
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isOk
                                                      ? Icons.flash_on_rounded
                                                      : Icons.close_rounded,
                                                  color: accent,
                                                  size: 22,
                                                ),
                                                const Gap(8),
                                                Text(
                                                  isOk
                                                      ? strings
                                                            .reflexesMathFeedbackOk
                                                            .toUpperCase()
                                                      : strings
                                                            .reflexesMathFeedbackWrong
                                                            .toUpperCase(),
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 19,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                  const Spacer(),
                  _NumericPad(
                    onDigit: (d) {
                      if (_showSequence) return;
                      setState(() => _input += d);
                    },
                    onBackspace: () {
                      if (_showSequence || _input.isEmpty) return;
                      setState(
                        () => _input = _input.substring(0, _input.length - 1),
                      );
                    },
                    onOk: () {
                      if (_showSequence) return;
                      _submit();
                    },
                    okLabel: 'OK',
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

class _MemorySequenceFlipDisplay extends StatefulWidget {
  const _MemorySequenceFlipDisplay({required this.sequence});
  final List<int> sequence;

  @override
  State<_MemorySequenceFlipDisplay> createState() =>
      _MemorySequenceFlipDisplayState();
}

class _MemorySequenceFlipDisplayState extends State<_MemorySequenceFlipDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  @override
  void didUpdateWidget(covariant _MemorySequenceFlipDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sequence.join() != widget.sequence.join()) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequence = widget.sequence;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = sequence.isEmpty ? 1 : sequence.length;
                final spacing = 6.0;
                final available = constraints.maxWidth - (spacing * 2 * count);
                final blockWidth = (available / count).clamp(28.0, 56.0);
                final blockHeight = blockWidth * 1.35;
                final fontSize = (blockWidth * 0.8).clamp(24.0, 44.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sequence.asMap().entries.map((entry) {
                    final index = entry.key;
                    final digit = entry.value;
                    final count = sequence.length <= 1 ? 1 : sequence.length;
                    final start = (index / count) * 0.55;
                    final end = (start + 0.45).clamp(0.0, 1.0);
                    final segment = Interval(
                      start,
                      end,
                      curve: Curves.easeOutCubic,
                    ).transform(_ctrl.value);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing),
                      child: Opacity(
                        opacity: segment,
                        child: Transform.translate(
                          offset: Offset(0, (1 - segment) * 14),
                          child: Container(
                            width: blockWidth,
                            height: blockHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1F1F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF4F4F4F),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.34),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$digit',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFF2F2F2),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NumericPad extends StatelessWidget {
  const _NumericPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onOk,
    required this.okLabel,
  });
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onOk;
  final String okLabel;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget key(
      String label,
      VoidCallback onTap, {
      Color? bg,
      Color? textColor,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: bg ?? colors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: row.map((v) => key(v, () => onDigit(v))).toList()),
        Row(
          children: [
            key('⌫', onBackspace),
            key('0', () => onDigit('0')),
            key(
              okLabel,
              onOk,
              bg: colors.primaryContainer,
              textColor: colors.onPrimaryContainer,
            ),
          ],
        ),
      ],
    );
  }
}

