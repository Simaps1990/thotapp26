part of '../reflexes_screen.dart';

class _MathRunScreen extends StatefulWidget {
  _MathRunScreen({
    this.onResultSaved,
    required this.durationSeconds,
    required this.difficulty,
    required this.operatorMode,
    required this.operandMax,
    this.history = const <_ReflexSessionRecord>[],
    this.level,
  });
  final int durationSeconds;
  final _MathDifficulty difficulty;
  final _MathOperator operatorMode;
  final int operandMax;
  final List<_ReflexSessionRecord> history;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;
  @override
  State<_MathRunScreen> createState() => _MathRunScreenState();
}

class _MathRunScreenState extends State<_MathRunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  final _questionStopwatch = Stopwatch();
  final _answerTimes = <int>[];
  Timer? _ticker;
  int _remaining = 0;
  int _left = 0;
  int _right = 0;
  String _operator = '+';
  int _expected = 0;
  String _input = '';
  int _correct = 0;
  int _wrong = 0;
  final Map<String, int> _operatorCounts = {'+': 0, '−': 0, '×': 0, '÷': 0};
  final Map<String, int> _operatorAnswered = {'+': 0, '−': 0, '×': 0, '÷': 0};
  final Map<String, int> _operatorCorrect = {'+': 0, '−': 0, '×': 0, '÷': 0};
  bool _showResults = false;
  _ReflexSessionRecord? _currentResult;
  String? _mathFeedback;
  Timer? _mathFeedbackTimer;
  late final AnimationController _mathFeedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

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

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _restartRun() {
    _ticker?.cancel();
    _questionStopwatch
      ..stop()
      ..reset();
    _remaining = widget.durationSeconds;
    _left = 0;
    _right = 0;
    _expected = 0;
    _input = '';
    _correct = 0;
    _wrong = 0;
    _answerTimes.clear();
    _operatorCounts
      ..update('+', (_) => 0)
      ..update('−', (_) => 0)
      ..update('×', (_) => 0)
      ..update('÷', (_) => 0);
    _operatorAnswered
      ..update('+', (_) => 0)
      ..update('−', (_) => 0)
      ..update('×', (_) => 0)
      ..update('÷', (_) => 0);
    _operatorCorrect
      ..update('+', (_) => 0)
      ..update('−', (_) => 0)
      ..update('×', (_) => 0)
      ..update('÷', (_) => 0);
    _nextQuestion();
    _startTicker();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _remaining = widget.durationSeconds;
    _nextQuestion();
    _startTicker();
  }

  void _nextQuestion() {
    final _MathOperator op;
    switch (widget.operatorMode) {
      case _MathOperator.addSubOnly:
        op = _random.nextBool()
            ? _MathOperator.addition
            : _MathOperator.subtraction;
        break;
      case _MathOperator.addSubMul:
        final r = _random.nextInt(3);
        op = r == 0
            ? _MathOperator.addition
            : r == 1
            ? _MathOperator.subtraction
            : _MathOperator.multiplication;
        break;
      case _MathOperator.mixed:
        final r = _random.nextInt(4);
        op = r == 0
            ? _MathOperator.addition
            : r == 1
            ? _MathOperator.subtraction
            : r == 2
            ? _MathOperator.multiplication
            : _MathOperator.division;
        break;
      default:
        op = widget.operatorMode;
    }

    final addSubMax = widget.operandMax;
    final mulMax = 12;

    switch (op) {
      case _MathOperator.addition:
        _left = 1 + _random.nextInt(addSubMax);
        _right = 1 + _random.nextInt(addSubMax);
        _operator = '+';
        _expected = _left + _right;
        break;
      case _MathOperator.subtraction:
        _left = 1 + _random.nextInt(addSubMax);
        _right = 1 + _random.nextInt(addSubMax);
        if (_right > _left) {
          final t = _left;
          _left = _right;
          _right = t;
        }
        _operator = '−';
        _expected = _left - _right;
        break;
      case _MathOperator.multiplication:
        _left = 2 + _random.nextInt(mulMax - 1);
        _right = 2 + _random.nextInt(mulMax - 1);
        _operator = '×';
        _expected = _left * _right;
        break;
      case _MathOperator.division:
        final divisor = 2 + _random.nextInt(mulMax - 1);
        final quotient = 2 + _random.nextInt(mulMax - 1);
        _left = divisor * quotient;
        _right = divisor;
        _operator = '÷';
        _expected = quotient;
        break;
      default:
        _left = 1;
        _right = 1;
        _operator = '+';
        _expected = 2;
    }

    _operatorCounts[_operator] = (_operatorCounts[_operator] ?? 0) + 1;
    _input = '';
    _questionStopwatch
      ..reset()
      ..start();
    if (mounted) setState(() {});
  }

  void _submit() {
    if (_input.isEmpty) return;
    _questionStopwatch.stop();
    final value = int.tryParse(_input);
    final correct = value == _expected;
    _operatorAnswered[_operator] = _operatorAnswered[_operator]! + 1;
    if (correct) {
      _correct++;
      _operatorCorrect[_operator] = _operatorCorrect[_operator]! + 1;
    } else {
      _wrong++;
    }
    _answerTimes.add(_questionStopwatch.elapsedMilliseconds);
    setState(() => _mathFeedback = correct ? 'ok' : 'wrong');
    _mathFeedbackAnimationController.reset();
    _mathFeedbackAnimationController.forward();
    _mathFeedbackTimer?.cancel();
    _mathFeedbackTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _mathFeedback = null);
    });
    _nextQuestion();
  }

  void _finish() {
    final avg = _answerTimes.isEmpty
        ? 0.0
        : _answerTimes.reduce((a, b) => a + b) / _answerTimes.length;
    final strings = AppStrings.of(context);
    final avgSeconds = (avg / 1000).floor();
    final avgMs = (avg % 1000).toInt();

    final difficultyCoefficient = switch (widget.difficulty) {
      _MathDifficulty.easy => 1.0,
      _MathDifficulty.medium => 1.5,
      _MathDifficulty.hard => 2.0,
    };

    final totalAnswers = max(1, _correct + _wrong);
    final accuracy = _correct / totalAnswers;
    final targetMs = switch (widget.difficulty) {
      _MathDifficulty.easy => 5200.0,
      _MathDifficulty.medium => 6500.0,
      _MathDifficulty.hard => 8200.0,
    };
    final speedRatio = avg > 0 ? (targetMs / avg).clamp(0.0, 1.15) : 0.0;
    final baseScore =
        (620 * accuracy) + (280 * speedRatio) + (100 * min(1.0, _correct / 12));
    final errorPenalty = _wrong * difficultyCoefficient * 95;
    final score = _boundedScore(baseScore - errorPenalty);

    final difficultyLabel = switch (widget.difficulty) {
      _MathDifficulty.easy => strings.reflexesDifficultyEasy,
      _MathDifficulty.medium => strings.reflexesDifficultyMedium,
      _MathDifficulty.hard => strings.reflexesDifficultyHard,
    };

    final result = _ReflexSessionRecord(
      mode: _ReflexesMode.math,
      date: DateTime.now(),
      primaryScore: score,
      stats: {
        '_score_final': score.toStringAsFixed(1),
        '_score_base': baseScore.toStringAsFixed(1),
        '_score_penalty_errors': errorPenalty.toStringAsFixed(1),
        strings.reflexesMathCorrectAnswers: '$_correct',
        strings.reflexesMathWrongAnswers: '$_wrong',
        strings.reflexesAvgAnswerTime:
            '${avgSeconds}s ${avgMs.toString().padLeft(3, '0')}ms',
        '_op_add_total': '${_operatorAnswered['+']}',
        '_op_add_correct': '${_operatorCorrect['+']}',
        '_op_sub_total': '${_operatorAnswered['−']}',
        '_op_sub_correct': '${_operatorCorrect['−']}',
        '_op_mul_total': '${_operatorAnswered['×']}',
        '_op_mul_correct': '${_operatorCorrect['×']}',
        '_op_div_total': '${_operatorAnswered['÷']}',
        '_op_div_correct': '${_operatorCorrect['÷']}',
        'difficulty': difficultyLabel,
        'difficultyCoefficient': difficultyCoefficient.toString(),
        if (widget.level != null) '_level': widget.level.toString(),
      },
    );
    setState(() {
      _currentResult = result;
      _showResults = true;
    });
  }

  void _stop() {
    _ticker?.cancel();
    _questionStopwatch.stop();
    if (_correct > 0 || _wrong > 0) {
      final avg = _answerTimes.isEmpty
          ? 0.0
          : _answerTimes.reduce((a, b) => a + b) / _answerTimes.length;
      final strings = AppStrings.of(context);
      final avgSeconds = (avg / 1000).floor();
      final avgMs = (avg % 1000).toInt();

      final difficultyCoefficient = switch (widget.difficulty) {
        _MathDifficulty.easy => 1.0,
        _MathDifficulty.medium => 1.5,
        _MathDifficulty.hard => 2.0,
      };

      final totalAnswers = max(1, _correct + _wrong);
      final accuracy = _correct / totalAnswers;
      final targetMs = switch (widget.difficulty) {
        _MathDifficulty.easy => 5200.0,
        _MathDifficulty.medium => 6500.0,
        _MathDifficulty.hard => 8200.0,
      };
      final speedRatio = avg > 0 ? (targetMs / avg).clamp(0.0, 1.15) : 0.0;
      final baseScore =
          (620 * accuracy) +
          (280 * speedRatio) +
          (100 * min(1.0, _correct / 12));
      final errorPenalty = _wrong * difficultyCoefficient * 95;
      final score = _boundedScore(baseScore - errorPenalty);

      final difficultyLabel = switch (widget.difficulty) {
        _MathDifficulty.easy => strings.reflexesDifficultyEasy,
        _MathDifficulty.medium => strings.reflexesDifficultyMedium,
        _MathDifficulty.hard => strings.reflexesDifficultyHard,
      };

      final result = _ReflexSessionRecord(
        mode: _ReflexesMode.math,
        date: DateTime.now(),
        primaryScore: score,
        stats: {
          '_score_final': score.toStringAsFixed(1),
          '_score_base': baseScore.toStringAsFixed(1),
          '_score_penalty_errors': errorPenalty.toStringAsFixed(1),
          strings.reflexesMathCorrectAnswers: '$_correct',
          strings.reflexesMathWrongAnswers: '$_wrong',
          strings.reflexesAvgAnswerTime:
              '${avgSeconds}s ${avgMs.toString().padLeft(3, '0')}ms',
          '_op_add_total': '${_operatorAnswered['+']}',
          '_op_add_correct': '${_operatorCorrect['+']}',
          '_op_sub_total': '${_operatorAnswered['−']}',
          '_op_sub_correct': '${_operatorCorrect['−']}',
          '_op_mul_total': '${_operatorAnswered['×']}',
          '_op_mul_correct': '${_operatorCorrect['×']}',
          '_op_div_total': '${_operatorAnswered['÷']}',
          '_op_div_correct': '${_operatorCorrect['÷']}',
          'difficulty': difficultyLabel,
          'difficultyCoefficient': difficultyCoefficient.toString(),
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
      _ticker?.cancel();
      _questionStopwatch.stop();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _mathFeedbackTimer?.cancel();
    _mathFeedbackAnimationController.dispose();
    _questionStopwatch.stop();
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
                                strings.reflexesPerformance,
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
                              _buildStatRow(
                                texts,
                                colors,
                                strings.reflexesMathCorrectAnswers,
                                _currentResult!.stats[strings
                                        .reflexesMathCorrectAnswers] ??
                                    '',
                              ),
                              _buildStatRow(
                                texts,
                                colors,
                                strings.reflexesMathWrongAnswers,
                                _currentResult!.stats[strings
                                        .reflexesMathWrongAnswers] ??
                                    '',
                              ),
                              _buildStatRow(
                                texts,
                                colors,
                                strings.reflexesAvgAnswerTime,
                                _currentResult!.stats[strings
                                        .reflexesAvgAnswerTime] ??
                                    '',
                              ),
                              const Gap(AppSpacing.md),
                              Text(
                                strings.reflexesMathOperationsTitle,
                                style: texts.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.secondary,
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildOperationRow(
                                          texts,
                                          colors,
                                          '+',
                                          _currentResult!.stats,
                                        ),
                                        _buildOperationRow(
                                          texts,
                                          colors,
                                          '−',
                                          _currentResult!.stats,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 80,
                                    color: colors.outline,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildOperationRow(
                                          texts,
                                          colors,
                                          '×',
                                          _currentResult!.stats,
                                        ),
                                        _buildOperationRow(
                                          texts,
                                          colors,
                                          '÷',
                                          _currentResult!.stats,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${strings.reflexesTimerLabel}: ${_remaining}s',
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
                  const Gap(2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      '${strings.hitFactorScoreLabel}: ${_correct - _wrong}',
                      style: texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                      key: ValueKey('score_$_correct-$_wrong'),
                    ),
                  ),
                  const Gap(AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 190,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 70),
                          child: Text(
                            '$_left $_operator $_right = ?',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (_mathFeedback != null)
                          Positioned(
                            top: 20,
                            child: AnimatedBuilder(
                              animation: _mathFeedbackAnimationController,
                              builder: (_, __) {
                                final t =
                                    _mathFeedbackAnimationController.value;
                                final appear = Curves.easeOutBack.transform(
                                  (t / 0.32).clamp(0.0, 1.0),
                                );
                                final vanish = ((t - 0.65) / 0.35).clamp(
                                  0.0,
                                  1.0,
                                );
                                final scale =
                                    0.72 + (appear * 0.28) - (vanish * 0.08);
                                final y = (16 * (1.0 - appear)) - (22 * vanish);
                                final opacity =
                                    ((1.0 - vanish) * (0.65 + 0.35 * appear))
                                        .clamp(0.0, 1.0)
                                        .toDouble();
                                final isOk = _mathFeedback == 'ok';
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
                                              accent.withValues(alpha: 0.26),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
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
                                              color: Colors.black.withValues(
                                                alpha: 0.15,
                                              ),
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
                  ),
                  const Gap(AppSpacing.xl),
                  Center(
                    child: Text(
                      _input.isEmpty ? '—' : _input,
                      style: TextStyle(
                        color: colors.primaryContainer,
                        fontWeight: FontWeight.w900,
                        fontSize: 64,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _NumericPad(
                    onDigit: (d) => setState(() => _input += d),
                    onBackspace: () {
                      if (_input.isEmpty) return;
                      setState(
                        () => _input = _input.substring(0, _input.length - 1),
                      );
                    },
                    onOk: _submit,
                    okLabel: 'OK',
                  ),
                  const Gap(AppSpacing.lg),
                ],
              ),
            ),
          ),
          const Positioned(top: 20, right: 12, child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    TextTheme texts,
    ColorScheme colors,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: texts.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationRow(
    TextTheme texts,
    ColorScheme colors,
    String operator,
    Map<String, String> stats,
  ) {
    final strings = AppStrings.of(context);
    final totalKey = operator == '+'
        ? '_op_add_total'
        : operator == '−'
        ? '_op_sub_total'
        : operator == '×'
        ? '_op_mul_total'
        : '_op_div_total';
    final correctKey = operator == '+'
        ? '_op_add_correct'
        : operator == '−'
        ? '_op_sub_correct'
        : operator == '×'
        ? '_op_mul_correct'
        : '_op_div_correct';
    final correct = int.tryParse(stats[correctKey] ?? '0') ?? 0;
    final answered = int.tryParse(stats[totalKey] ?? '0') ?? 0;
    final ratioText = '$correct / $answered';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                operator,
                style: texts.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operator == '+'
                      ? strings.reflexesMathOpAddition
                      : operator == '−'
                      ? strings.reflexesMathOpSubtraction
                      : operator == '×'
                      ? strings.reflexesMathOpMultiplication
                      : strings.reflexesMathOpDivision,
                  style: texts.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ratioText,
                  style: texts.bodySmall?.copyWith(color: colors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

