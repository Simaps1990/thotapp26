part of '../reflexes_screen.dart';

class _StroopRunScreen extends StatefulWidget {
  const _StroopRunScreen({
    required this.difficulty,
    required this.history,
    this.level,
  });
  final _StroopDifficulty difficulty;
  final List<_ReflexSessionRecord> history;
  final int? level;
  @override
  State<_StroopRunScreen> createState() => _StroopRunScreenState();
}

class _StroopRunScreenState extends State<_StroopRunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  int _countdown = 3;
  bool _running = false;
  Timer? _timer;
  Stopwatch? _rt;
  DateTime? _stimulusShownAt;
  _StroopInkColor? _word;
  _StroopInkColor? _ink;
  bool _congruent = false;
  bool _responded = false;
  final _cong = <Duration>[];
  final _conf = <Duration>[];
  final _reactionTimes = <Duration>[];
  int _responses = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  final Map<String, int> _wordCounts = {
    'red': 0,
    'blue': 0,
    'green': 0,
    'yellow': 0,
  };
  final Map<String, int> _inkCounts = {
    'red': 0,
    'blue': 0,
    'green': 0,
    'yellow': 0,
  };
  bool _showResults = false;
  Map<String, String>? _currentResult;
  bool _aborted = false;
  late final AnimationController _feedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );
  String? _answerFeedbackText;
  Color? _answerFeedbackTextColor;
  Color? _answerFeedbackBgColor;
  Color? _answerFeedbackAccentColor;
  Completer<void> _responseCompleter = Completer<void>();
  bool? _lastAnswerCorrect;
  int _lastResponseMs = 0;
  int _stimuliShown = 0;

  double _parsePrimary(Map<String, String> entry) {
    return double.tryParse(entry['_primary'] ?? '') ?? double.infinity;
  }

  String _fmtDate(String value) =>
      value.replaceFirst('-', '/').replaceFirst('-', '/');

  double _parseFirstNumber(String value) {
    final m = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(value);
    if (m == null) return double.infinity;
    return double.tryParse(m.group(1) ?? '') ?? double.infinity;
  }

  List<Map<String, String>> _top3(AppStrings strings) {
    final items = widget.history
        .map(
          (e) => {
            '_modeKey': _ReflexesMode.stroop.name,
            'modeLabel': strings.cognitiveDrillModeStroop,
            'date': e.date.toString().substring(0, 16),
            '_primary': _scoredValue(
              e.mode,
              e.primaryScore,
              e.stats,
            ).toStringAsFixed(3),
            ...e.stats,
          },
        )
        .where((e) {
          final p = _parsePrimary(e);
          return p.isFinite && p > 50;
        })
        .toList();
    final current = _currentResult;
    if (current != null) {
      final primary =
          double.tryParse(current['_score_final'] ?? '') ??
          _parseFirstNumber(current[strings.reflexesAvgReactionTime] ?? '');
      if (primary.isFinite && primary > 0) {
        items.add({
          '_modeKey': _ReflexesMode.stroop.name,
          'modeLabel': strings.cognitiveDrillModeStroop,
          'date': DateTime.now().toString().substring(0, 16),
          '_primary': primary.toStringAsFixed(3),
          ...current,
        });
      }
    }
    items.sort((a, b) => _parsePrimary(b).compareTo(_parsePrimary(a)));
    return items.take(3).toList();
  }

  int _getCount() => widget.difficulty == _StroopDifficulty.easy
      ? 15
      : widget.difficulty == _StroopDifficulty.medium
      ? 20
      : 25;

  void _closeToTools() {
    final current = _currentResult;
    if (current == null) {
      Navigator.of(context).pop();
      return;
    }
    final payload = Map<String, String>.from(current)..['_close_tools'] = '1';
    Navigator.of(context).pop(
      _ReflexSessionRecord(
        mode: _ReflexesMode.stroop,
        date: DateTime.now(),
        primaryScore: double.tryParse(current['_score_final'] ?? '') ?? 0,
        stats: payload,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _loop();
  }

  Future<void> _loop() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
        unawaited(TimerSound.play().catchError((_) {}));
        await Future.delayed(const Duration(milliseconds: 450));
        if (!mounted) return;
        setState(() {
          _running = true;
          _stimuliShown = 0;
        });
        _run();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _run() async {
    for (var i = 0; i < _getCount(); i++) {
      if (_aborted || !mounted) break;
      final stim = _pick(i);
      _word = stim.$1;
      _ink = stim.$2;
      _congruent = stim.$3;
      _responded = false;
      _lastResponseMs = 0;
      _rt = null;
      _stimulusShownAt = null;
      _wordCounts[_word!.name] = _wordCounts[_word!.name]! + 1;
      _inkCounts[_ink!.name] = _inkCounts[_ink!.name]! + 1;
      _stimuliShown = i + 1;
      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _responded || _word == null || _ink == null) return;
          _stimulusShownAt = DateTime.now();
          _rt = Stopwatch()..start();
        });
      }

      _responseCompleter = Completer<void>();
      final responseFuture = _responseCompleter.future;

      await responseFuture;
      if (_aborted || !mounted) break;

      _rt?.stop();
      _showAnswerFeedback(_lastAnswerCorrect ?? false, _lastResponseMs);
      await Future.delayed(const Duration(seconds: 1));
      if (_aborted || !mounted) break;

      if (mounted) {
        setState(() {
          _answerFeedbackText = null;
          _word = null;
          _ink = null;
        });
      }
      await Future.delayed(const Duration(milliseconds: 180));
    }
    if (_aborted || !mounted) return;
    final strings = AppStrings.of(context);
    final shown = _wordCounts.values.fold<int>(0, (a, b) => a + b);
    final avgMs = _reactionTimes.isEmpty
        ? double.infinity
        : _reactionTimes.fold<int>(
                0,
                (sum, duration) => sum + duration.inMilliseconds,
              ) /
              _reactionTimes.length;
    final avgMsLabel = avgMs.isFinite ? '${avgMs.toStringAsFixed(0)} ms' : '—';
    final total = max(1, _correctAnswers + _wrongAnswers);
    final accuracy = _correctAnswers / total;
    final targetMs = switch (widget.difficulty) {
      _StroopDifficulty.easy => 1400.0,
      _StroopDifficulty.medium => 1200.0,
      _StroopDifficulty.hard => 1050.0,
    };
    final speedPenalty = avgMs.isFinite
        ? max(0.0, avgMs - targetMs) * 0.45
        : 300.0;
    final baseScore = 1000.0 - speedPenalty;
    final accuracyPenalty = (1 - accuracy) * 520;
    final errorPenalty = _wrongAnswers * 140.0;
    final score = (baseScore - accuracyPenalty - errorPenalty)
        .clamp(0, 1000)
        .toDouble();
    final stats = <String, String>{
      'mode': 'stroop',
      'difficulty': widget.difficulty.name,
      '_score_final': score.toStringAsFixed(1),
      '_score_base': baseScore.toStringAsFixed(1),
      '_score_penalty_speed': speedPenalty.toStringAsFixed(1),
      '_score_penalty_accuracy': accuracyPenalty.toStringAsFixed(1),
      '_score_penalty_errors': errorPenalty.toStringAsFixed(1),
      if (widget.level != null) '_level': widget.level.toString(),
      strings.cognitiveDrillResultsStimuliCount: '$shown',
      strings.cognitiveDrillResultsResponses: '$_responses',
      strings.reflexesAvgReactionTime: avgMsLabel,
      strings.reflexesMathCorrectAnswers: '$_correctAnswers',
      strings.reflexesMathWrongAnswers: '$_wrongAnswers',
      strings.cognitiveDrillStroopAvgCongruent: _avg(_cong),
      strings.cognitiveDrillStroopAvgConflict: _avg(_conf),
      strings.stroopWordsRed: '${_wordCounts['red']}',
      strings.stroopWordsBlue: '${_wordCounts['blue']}',
      strings.stroopWordsGreen: '${_wordCounts['green']}',
      strings.stroopWordsYellow: '${_wordCounts['yellow']}',
      strings.stroopInkRed: '${_inkCounts['red']}',
      strings.stroopInkBlue: '${_inkCounts['blue']}',
      strings.stroopInkGreen: '${_inkCounts['green']}',
      strings.stroopInkYellow: '${_inkCounts['yellow']}',
    };
    setState(() {
      _currentResult = stats;
      _showResults = true;
    });
  }

  _ReflexSessionRecord _recordFromCurrent(Map<String, String> current) {
    return _ReflexSessionRecord(
      mode: _ReflexesMode.stroop,
      date: DateTime.now(),
      primaryScore: double.tryParse(current['_score_final'] ?? '') ?? 0,
      stats: current,
    );
  }

  void _stop() {
    _aborted = true;
    _timer?.cancel();
    _rt?.stop();
    if (!mounted) return;
    if (_wordCounts.values.any((v) => v > 0)) {
      final strings = AppStrings.of(context);
      final stats = <String, String>{
        'mode': 'stroop',
        'difficulty': widget.difficulty.name,
        strings.cognitiveDrillResultsStimuliCount:
            '${_wordCounts.values.reduce((a, b) => a + b)}',
        strings.cognitiveDrillResultsResponses: '$_responses',
        strings.reflexesAvgReactionTime: _avgMs(_reactionTimes),
        strings.reflexesMathCorrectAnswers: '$_correctAnswers',
        strings.reflexesMathWrongAnswers: '$_wrongAnswers',
        strings.cognitiveDrillStroopAvgCongruent: _avg(_cong),
        strings.cognitiveDrillStroopAvgConflict: _avg(_conf),
        strings.stroopWordsRed: '${_wordCounts['red']}',
        strings.stroopWordsBlue: '${_wordCounts['blue']}',
        strings.stroopWordsGreen: '${_wordCounts['green']}',
        strings.stroopWordsYellow: '${_wordCounts['yellow']}',
        strings.stroopInkRed: '${_inkCounts['red']}',
        strings.stroopInkBlue: '${_inkCounts['blue']}',
        strings.stroopInkGreen: '${_inkCounts['green']}',
        strings.stroopInkYellow: '${_inkCounts['yellow']}',
        '_stopped_early': '1',
        if (widget.level != null) '_level': widget.level.toString(),
      };
      setState(() {
        _currentResult = stats;
        _showResults = true;
      });
    } else {
      Navigator.pop(context);
    }
  }

  (_StroopInkColor, _StroopInkColor, bool) _pick(int i) {
    // Ratio de congruence selon difficulté :
    // Easy 60% congruents, Medium 50%, Hard 30%
    final congruentRatio = widget.difficulty == _StroopDifficulty.easy
        ? 0.60
        : widget.difficulty == _StroopDifficulty.medium
        ? 0.50
        : 0.30;
    final congruent = _random.nextDouble() < congruentRatio;
    final ink = _StroopInkColor.values[_random.nextInt(4)];
    if (congruent) return (ink, ink, true);
    final words = _StroopInkColor.values.where((e) => e != ink).toList();
    return (words[_random.nextInt(words.length)], ink, false);
  }

  void _respond(_StroopInkColor selectedColor) {
    if (!_running || _word == null || _ink == null || _responded) return;
    _responded = true;
    _responses++;
    final shownAt = _stimulusShownAt;
    final d = shownAt == null
        ? (_rt?.elapsed ?? Duration.zero)
        : DateTime.now().difference(shownAt);
    _lastResponseMs = d.inMilliseconds;
    _rt?.stop();
    final isCorrect = selectedColor == _ink;
    _lastAnswerCorrect = isCorrect;
    if (isCorrect) {
      _correctAnswers++;
      if (d.inMilliseconds > 50 && d.inMilliseconds < 2500) {
        _reactionTimes.add(d);
        (_congruent ? _cong : _conf).add(d);
      }
    } else {
      _wrongAnswers++;
    }
    if (!_responseCompleter.isCompleted) {
      _responseCompleter.complete();
    }
    setState(() {});
  }

  void _showAnswerFeedback(bool isCorrect, int ms) {
    setState(() {
      _answerFeedbackText = isCorrect
          ? 'BONNE REPONSE • $ms ms'
          : 'MAUVAISE REPONSE • $ms ms';
      _answerFeedbackTextColor = isCorrect
          ? const Color(0xFFE8FFF4)
          : const Color(0xFFFFECEF);
      _answerFeedbackBgColor = isCorrect
          ? const Color(0xFF0D402A)
          : const Color(0xFF4C1621);
      _answerFeedbackAccentColor = isCorrect
          ? const Color(0xFF00E676)
          : const Color(0xFFFF5252);
    });
    _feedbackAnimationController.reset();
    _feedbackAnimationController.forward();
  }

  String _avgMs(List<Duration> list) {
    if (list.isEmpty) return '—';
    final avgMs =
        list.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds) /
        list.length;
    return '${avgMs.toStringAsFixed(0)} ms';
  }

  String _avg(List<Duration> l) => l.isEmpty
      ? '—'
      : '${(l.fold<int>(0, (a, b) => a + b.inMilliseconds) / l.length / 1000).toStringAsFixed(2)} s';

  Widget _buildAnswerButton(AppStrings strings, _StroopInkColor color) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: (_running && _ink != null) ? () => _respond(color) : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.black.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            _stroopColorLabel(strings, color).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBubble({
    required String text,
    required Color? textColor,
    required Color? bgColor,
    required Color? accentColor,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: _feedbackAnimationController,
      builder: (_, __) {
        final t = _feedbackAnimationController.value;
        final appear = Curves.easeOutBack.transform((t / 0.32).clamp(0.0, 1.0));
        final vanish = ((t - 0.65) / 0.35).clamp(0.0, 1.0);
        final scale = 0.72 + (appear * 0.28) - (vanish * 0.08);
        final opacity = ((1.0 - vanish) * (0.65 + 0.35 * appear))
            .clamp(0.0, 1.0)
            .toDouble();
        final y = (16 * (1.0 - appear)) - (22 * vanish);
        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, y),
            child: Opacity(
              opacity: opacity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (bgColor ?? const Color(0xFF1E2432)).withValues(
                        alpha: 0.98,
                      ),
                      (accentColor ?? const Color(0xFF00E676)).withValues(
                        alpha: 0.26,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (accentColor ?? Colors.white).withValues(
                      alpha: 0.55,
                    ),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (accentColor ?? Colors.black).withValues(
                        alpha: 0.45,
                      ),
                      blurRadius: 18,
                      spreadRadius: 1.5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accentColor, size: 18),
                    const Gap(6),
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _aborted = true;
      _timer?.cancel();
      _rt?.stop();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rt?.stop();
    _feedbackAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final texts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final showChoices = _running && _ink != null;

    if (_showResults && _currentResult != null) {
      final top3 = _top3(strings);
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
                          onTap: () => Navigator.of(
                            context,
                          ).pop(_recordFromCurrent(_currentResult!)),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: LightColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        Expanded(
                          child: _ResultTitleWithScaleInfo(
                            mode: _ReflexesMode.stroop,
                            title: strings.reflexesResultsTitle,
                          ),
                        ),
                        GestureDetector(
                          onTap: _closeToTools,
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
                          score:
                              double.tryParse(
                                _currentResult!['_score_final'] ?? '0',
                              ) ??
                              0,
                          stars: _starsForScore(
                            double.tryParse(
                                  _currentResult!['_score_final'] ?? '0',
                                ) ??
                                0,
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
                                mode: _ReflexesMode.stroop,
                                primaryScore:
                                    double.tryParse(
                                      _currentResult!['_score_final'] ?? '',
                                    ) ??
                                    0,
                                stats: _currentResult!,
                              ),
                              const Gap(AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      strings.cognitiveDrillResultsStimuliCount,
                                      style: texts.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _currentResult![strings
                                            .cognitiveDrillResultsStimuliCount] ??
                                        '0',
                                    style: texts.titleMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      strings.reflexesAvgReactionTime,
                                      style: texts.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _currentResult![strings
                                            .reflexesAvgReactionTime] ??
                                        '—',
                                    style: texts.titleMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      strings.reflexesMathCorrectAnswers,
                                      style: texts.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _currentResult![strings
                                            .reflexesMathCorrectAnswers] ??
                                        '0',
                                    style: texts.titleMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      strings.reflexesMathWrongAnswers,
                                      style: texts.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _currentResult![strings
                                            .reflexesMathWrongAnswers] ??
                                        '0',
                                    style: texts.titleMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      strings.reflexesDifficultyLabel,
                                      style: texts.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.difficulty == _StroopDifficulty.easy
                                        ? strings.reflexesDifficultyEasy
                                        : widget.difficulty ==
                                              _StroopDifficulty.medium
                                        ? strings.reflexesDifficultyMedium
                                        : strings.reflexesDifficultyHard,
                                    style: texts.titleMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w800,
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
                                    setState(() {
                                      _showResults = false;
                                      _currentResult = null;
                                      _aborted = false;
                                      _countdown = 3;
                                      _running = false;
                                      _word = null;
                                      _ink = null;
                                      _responded = false;
                                      _responses = 0;
                                      _correctAnswers = 0;
                                      _wrongAnswers = 0;
                                      _reactionTimes.clear();
                                      _cong.clear();
                                      _conf.clear();
                                      _wordCounts.updateAll((key, value) => 0);
                                      _inkCounts.updateAll((key, value) => 0);
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) _loop();
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
                                  onPressed: () {
                                    final current = _currentResult;
                                    if (current == null) return;
                                    Navigator.of(context).pop(
                                      _recordFromCurrent(
                                        Map<String, String>.from(current)
                                          ..['_next_level'] = '1',
                                      ),
                                    );
                                  },
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
                        Container(
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
                                  Icon(
                                    Icons.emoji_events_rounded,
                                    color: colors.primary,
                                  ),
                                  const Gap(AppSpacing.sm),
                                  Text(
                                    strings.reflexesTopThree,
                                    style: texts.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(AppSpacing.md),
                              if (top3.isEmpty)
                                Text(
                                  strings.cognitiveDrillNoScores,
                                  style: texts.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                  ),
                                )
                              else
                                ...top3.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final row = entry.value;
                                  final medalColor = index == 0
                                      ? const Color(0xFFFFC107)
                                      : index == 1
                                      ? const Color(0xFFB0BEC5)
                                      : const Color(0xFFCD7F32);
                                  final score = _parsePrimary(row);
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
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
                                            score.isFinite
                                                ? '${score.toStringAsFixed(0)} pts'
                                                : '—',
                                            style: texts.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _fmtDate(row['date'] ?? ''),
                                          style: texts.bodySmall?.copyWith(
                                            color: colors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
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

    Color _getHardModeBackground() {
      if (widget.difficulty != _StroopDifficulty.hard) return Colors.black;
      if (_ink == null) return Colors.black;
      final allColors = [
        const Color(0xFFE53935), // red
        const Color(0xFF1E88E5), // blue
        const Color(0xFF43A047), // green
        const Color(0xFFFDD835), // yellow
      ];

      final currentColor = _stroopColor(_ink!);
      final availableColors = allColors
          .where((c) => c != currentColor)
          .toList();
      return availableColors[_random.nextInt(availableColors.length)];
    }

    final hardBg = _getHardModeBackground();
    return Scaffold(
      backgroundColor: hardBg,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: SizedBox.expand(
          child: Stack(
            children: [
              _LandscapeWrapper(
                color: hardBg,
                child: Column(
                  children: [
                    Expanded(
                      child: _running
                          ? AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOut,
                                  ),
                                  child: child,
                                );
                              },
                              child: _word == null || _ink == null
                                  ? const SizedBox.expand(
                                      key: ValueKey('stroop-empty'),
                                    )
                                  : _StroopStimulusView(
                                      key: ValueKey(
                                        'stroop-${_stimuliShown}-${_word!.name}-${_ink!.name}',
                                      ),
                                      word: _word,
                                      ink: _ink,
                                    ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final maxHeight = constraints.maxHeight;
                                final targetNumberSize = _countdown > 0
                                    ? 160.0
                                    : 120.0;
                                final numberFontSize = min(
                                  targetNumberSize,
                                  maxHeight * 0.62,
                                );
                                final prepareFontSize = min(
                                  18.0,
                                  max(14.0, maxHeight * 0.075),
                                );
                                return ExerciseCountdownBackground(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedScale(
                                          key: ValueKey(_countdown),
                                          scale: 1.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.elasticOut,
                                          onEnd: () {
                                            if (mounted) {
                                              setState(() {});
                                            }
                                          },
                                          child: TweenAnimationBuilder<double>(
                                            tween: Tween<double>(
                                              begin: 0.5,
                                              end: 1.0,
                                            ),
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.elasticOut,
                                            builder: (context, scale, child) {
                                              return Transform.scale(
                                                scale: scale,
                                                child: Text(
                                                  _countdown > 0
                                                      ? '$_countdown'
                                                      : 'GO !',
                                                  style: TextStyle(
                                                    fontSize: numberFontSize,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: -4,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        if (_countdown > 0) ...[
                                          const Gap(12),
                                          Text(
                                            strings.colorPodPrepare,
                                            style: TextStyle(
                                              fontSize: prepareFontSize,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: _running ? AppSpacing.sm : 0,
                      ),
                      child: SizedBox(
                        height: _running ? 22 : 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          opacity: showChoices ? 1 : 0,
                          child: Text(
                            strings.cognitiveDrillStroopRunInstruction,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          _running ? AppSpacing.sm : 0,
                          AppSpacing.lg,
                          _running ? AppSpacing.lg : 0,
                        ),
                        child: SizedBox(
                          height: _running ? 52 : 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 140),
                            curve: Curves.easeOut,
                            opacity: showChoices ? 1 : 0,
                            child: IgnorePointer(
                              ignoring: !showChoices,
                              child: Row(
                                children: [
                                  _buildAnswerButton(
                                    strings,
                                    _StroopInkColor.red,
                                  ),
                                  const Gap(AppSpacing.sm),
                                  _buildAnswerButton(
                                    strings,
                                    _StroopInkColor.blue,
                                  ),
                                  const Gap(AppSpacing.sm),
                                  _buildAnswerButton(
                                    strings,
                                    _StroopInkColor.green,
                                  ),
                                  const Gap(AppSpacing.sm),
                                  _buildAnswerButton(
                                    strings,
                                    _StroopInkColor.yellow,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 12,
                child: SafeArea(
                  child: _running
                      ? Text(
                          '$_stimuliShown/${_getCount()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (_answerFeedbackText != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: const Alignment(0, -0.62),
                      child: _buildFeedbackBubble(
                        text: _answerFeedbackText!,
                        textColor: _answerFeedbackTextColor,
                        bgColor: _answerFeedbackBgColor,
                        accentColor: _answerFeedbackAccentColor,
                        icon: Icons.flash_on_rounded,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 20,
                right: 12,
                child: SafeArea(
                  child: TextButton(
                    onPressed: _stop,
                    child: Text(
                      strings.colorPodStop,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _stroopColor(_StroopInkColor color) {
  switch (color) {
    case _StroopInkColor.red:
      return const Color(0xFFE53935);
    case _StroopInkColor.blue:
      return const Color(0xFF1E88E5);
    case _StroopInkColor.green:
      return const Color(0xFF43A047);
    case _StroopInkColor.yellow:
      return const Color(0xFFFDD835);
  }
}

String _stroopName(AppStrings strings, _StroopInkColor color) {
  switch (color) {
    case _StroopInkColor.red:
      return strings.colorPodRed.toUpperCase();
    case _StroopInkColor.blue:
      return strings.colorPodBlue.toUpperCase();
    case _StroopInkColor.green:
      return strings.colorPodGreen.toUpperCase();
    case _StroopInkColor.yellow:
      return strings.colorPodYellow.toUpperCase();
  }
}

String _stroopColorLabel(AppStrings strings, _StroopInkColor color) {
  switch (color) {
    case _StroopInkColor.red:
      return strings.colorPodRed;
    case _StroopInkColor.blue:
      return strings.colorPodBlue;
    case _StroopInkColor.green:
      return strings.colorPodGreen;
    case _StroopInkColor.yellow:
      return strings.colorPodYellow;
  }
}

