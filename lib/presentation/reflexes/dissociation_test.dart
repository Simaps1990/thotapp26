part of '../reflexes_screen.dart';

Future<_ReflexSessionRecord?> _startDissociationTestLevel({
  required BuildContext context,
  required int level,
  required Map<String, List<_ReflexSessionRecord>> historyByMode,
  required void Function(_ReflexSessionRecord) onResultSaved,
}) async {
  final p = dissociationLevelParams(level);
  return Navigator.of(context).push<_ReflexSessionRecord>(
    PageRouteBuilder<_ReflexSessionRecord>(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => _DissociationRunScreen(
        durationSeconds: p.durationSeconds,
        tempoMs: p.tempoMs,
        tempoToleranceMs: p.tempoToleranceMs,
        stimulusMinDelayMs: p.stimulusMinDelayMs,
        stimulusMaxDelayMs: p.stimulusMaxDelayMs,
        noGoRatio: p.noGoRatio,
        enableRuleSwitch: p.enableRuleSwitch,
        ruleSwitchEveryMs: p.ruleSwitchEveryMs,
        history:
            historyByMode[_ReflexesMode.dissociation.name] ??
            const <_ReflexSessionRecord>[],
        onResultSaved: onResultSaved,
        level: level,
      ),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

enum _StimulusType { go, noGo }

class _DissociationRunScreen extends StatefulWidget {
  final int durationSeconds;
  final int tempoMs;
  final int tempoToleranceMs;
  final int stimulusMinDelayMs;
  final int stimulusMaxDelayMs;
  final double noGoRatio;
  final bool enableRuleSwitch;
  final int ruleSwitchEveryMs;
  final List<_ReflexSessionRecord> history;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;

  const _DissociationRunScreen({
    required this.durationSeconds,
    required this.tempoMs,
    required this.tempoToleranceMs,
    required this.stimulusMinDelayMs,
    required this.stimulusMaxDelayMs,
    required this.noGoRatio,
    required this.enableRuleSwitch,
    required this.ruleSwitchEveryMs,
    this.history = const <_ReflexSessionRecord>[],
    this.onResultSaved,
    this.level,
  });

  @override
  State<_DissociationRunScreen> createState() => _DissociationRunScreenState();
}

class _DissociationRunScreenState extends State<_DissociationRunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  final _sessionStopwatch = Stopwatch();

  // Timers
  Timer? _mainTimer;
  Timer? _stimulusTimer;
  Timer? _countdownTimer;
  Timer? _feedbackTimer;
  Timer? _ruleSwitchTimer;
  Timer? _tempoPulseTimer;

  // State
  int _countdown = 3;
  bool _isCountingDown = true;
  bool _showResults = false;
  bool _isRuleInverted = false;
  bool _isPaused = false;
  bool _keepLandscapeForNextLevel = false;
  bool _leftPressed = false;
  bool _rightPressed = false;
  _ReflexSessionRecord? _currentResult;

  // Gameplay tracking
  int _tempoTapCount = 0;
  int _tempoErrors = 0;
  int _stimulusCount = 0;
  int _stimulusResponses = 0;
  int _missedStimuli = 0;
  int _impulsiveErrors = 0;
  int _ruleSwitchErrors = 0;
  final List<int> _tempoDeviations = [];
  final List<int> _reactionTimes = [];

  // Tempo pulse tracking (to detect ignored rhythm zone)
  int _expectedTempoCount = 0;
  int _validTempoTapCount = 0;
  int _missedTempoCount = 0;
  bool _tempoHitThisBeat = false;

  // Current stimulus
  _StimulusType? _currentStimulus;
  bool _handlingStimulusTap = false;
  bool _handlingTempoTap = false;
  DateTime? _stimulusStartTime;
  DateTime? _lastTempoExpectedTime;

  // Feedback
  String? _feedbackText;
  Color? _feedbackColor;
  late final AnimationController _feedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );

  // Tempo pulse visualization
  double _tempoPulseValue = 0.0;

  // Left button should be green when tempo pulse is active
  bool _shouldTapLeft = false;

  // Stimulus feedback
  bool? _lastStimulusSuccess;
  double _feedbackOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _startCountdown();
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdown = 3;
    _isCountingDown = true;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
          _isCountingDown = false;
          _startSession();
        }
      });
    });
  }

  void _startSession() {
    _sessionStopwatch.start();
    _lastTempoExpectedTime = DateTime.now();

    // Main session timer
    _mainTimer = Timer(Duration(seconds: widget.durationSeconds), () => _endSession());

    // Tempo pulse timer for visual feedback and tracking
    // First pulse delayed by tempoMs to give user time to react
    _tempoPulseTimer = Timer(Duration(milliseconds: widget.tempoMs), () {
      if (!mounted) return;
      _triggerTempoPulse();
      // After first pulse, start periodic timer
      _tempoPulseTimer = Timer.periodic(
        Duration(milliseconds: widget.tempoMs),
        (_) => _triggerTempoPulse(),
      );
    });

    // Schedule first stimulus
    _scheduleNextStimulus();

    // Rule switching timer (if enabled)
    if (widget.enableRuleSwitch) {
      _ruleSwitchTimer = Timer.periodic(
        Duration(milliseconds: widget.ruleSwitchEveryMs),
        (_) => _toggleRule(),
      );
    }
  }

  void _scheduleNextStimulus() {
    if (_showResults || !mounted) return;

    final delay = widget.stimulusMinDelayMs +
        _random.nextInt(widget.stimulusMaxDelayMs - widget.stimulusMinDelayMs);

    _stimulusTimer?.cancel();
    _stimulusTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted || _showResults) return;

      final isNoGo = _random.nextDouble() < widget.noGoRatio;
      setState(() {
        _currentStimulus = isNoGo ? _StimulusType.noGo : _StimulusType.go;
        _stimulusStartTime = DateTime.now();
        _handlingStimulusTap = false;
      });

      // Stimulus timeout (user missed it)
      _stimulusTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted || _showResults) return;
        if (_currentStimulus != null && !_handlingStimulusTap) {
          _onStimulusMissed();
        }
      });
    });
  }

  void _toggleRule() {
    if (!mounted || _showResults) return;
    setState(() {
      _isRuleInverted = !_isRuleInverted;
    });
  }

  void _onTempoTap() {
    if (_isCountingDown || _showResults) return;

    // Cooldown to prevent spam
    if (_handlingTempoTap) return;
    _handlingTempoTap = true;
    Future.delayed(const Duration(milliseconds: 120), () {
      _handlingTempoTap = false;
    });

    _tempoTapCount++;

    // Calculate deviation from expected tempo
    final now = DateTime.now();
    final expected = _lastTempoExpectedTime ?? now;
    final deviation = now.difference(expected).inMilliseconds.abs();

    // Check if within tolerance
    final isOnTempo = deviation <= widget.tempoToleranceMs;

    if (isOnTempo) {
      _tempoDeviations.add(deviation);
      _validTempoTapCount++;
      _tempoHitThisBeat = true;
      _showFeedback(
        AppStrings.of(context).reflexesDissociationFeedbackOnTempo,
        const Color(0xFF81C784),
      );
    } else {
      _tempoErrors++;
      _showFeedback(
        AppStrings.of(context).reflexesDissociationFeedbackOffTempo,
        const Color(0xFFE57373),
      );
    }
  }

  void _onStimulusTap() {
    if (_isCountingDown || _showResults || _currentStimulus == null) return;
    if (_handlingStimulusTap) return;
    _handlingStimulusTap = true;

    final strings = AppStrings.of(context);
    final now = DateTime.now();

    // Calculate reaction time
    final reactionTime =
        _stimulusStartTime != null
            ? now.difference(_stimulusStartTime!).inMilliseconds
            : 0;

    // Determine if response was correct based on rule
    final shouldTapGo = _isRuleInverted ? false : true;
    final shouldTapNoGo = _isRuleInverted ? true : false;

    final isGo = _currentStimulus == _StimulusType.go;
    final isCorrect = (isGo && shouldTapGo) || (!isGo && shouldTapNoGo);

    if (isCorrect) {
      _stimulusResponses++;
      _reactionTimes.add(reactionTime);
      _showFeedback(
        strings.reflexesDissociationFeedbackGoodSignal,
        const Color(0xFF81C784),
      );
    } else {
      _impulsiveErrors++;
      if (widget.enableRuleSwitch && _isRuleInverted) {
        _ruleSwitchErrors++;
      }
      _showFeedback(
        strings.reflexesDissociationFeedbackWrongSignal,
        const Color(0xFFE57373),
      );
    }

    setState(() {
      _currentStimulus = null;
    });

    _scheduleNextStimulus();
  }

  void _onStimulusMissed() {
    final strings = AppStrings.of(context);

    // Determine if missing was an error based on rule
    final shouldHaveTapped = _isRuleInverted
        ? _currentStimulus == _StimulusType.noGo
        : _currentStimulus == _StimulusType.go;

    if (shouldHaveTapped) {
      _missedStimuli++;
      if (widget.enableRuleSwitch && _isRuleInverted) {
        _ruleSwitchErrors++;
      }
      _showFeedback(
        strings.reflexesDissociationFeedbackMissed,
        const Color(0xFFFFB74D),
      );
    }

    setState(() {
      _currentStimulus = null;
    });

    _scheduleNextStimulus();
  }

  void _showFeedback(String text, Color color) {
    _feedbackTimer?.cancel();
    _feedbackAnimationController.stop();

    setState(() {
      _feedbackText = text;
      _feedbackColor = color;
    });

    _feedbackAnimationController.forward(from: 0.0);

    _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _feedbackText = null;
        });
      }
    });
  }

  Future<void> _endSession({bool stoppedEarly = false}) async {
    if (_showResults) return;

    _sessionStopwatch.stop();
    _cancelAllTimers();

    // Final check for any pending tempo pulse before session ends
    if (_expectedTempoCount > 0 && !_tempoHitThisBeat) {
      _checkMissedTempoPulse();
    }

    final strings = AppStrings.of(context);

    // Calculate stats
    final avgTempoDeviation = _tempoDeviations.isEmpty
        ? 0
        : _tempoDeviations.reduce((a, b) => a + b) ~/ _tempoDeviations.length;

    final avgReactionTime = _reactionTimes.isEmpty
        ? 0
        : _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length;

    // Calculate score
    var score = 1000.0;

    // Tempo penalties
    final tempoPenalty = avgTempoDeviation * 1.2;
    final tempoErrorsPenalty = _tempoErrors * 35;
    final missedTempoPenalty = _missedTempoCount * 45; // Strong penalty for ignoring rhythm

    // Stimulus penalties
    final missedPenalty = _missedStimuli * 80;
    final impulsivePenalty = _impulsiveErrors * 120;
    final reactionPenalty = max(0, avgReactionTime - 350) * 0.7;
    final ruleSwitchPenalty = _ruleSwitchErrors * 100;

    // Rhythm compliance ratio penalty (if user barely uses the rhythm zone)
    double rhythmRatioPenalty = 0.0;
    if (_expectedTempoCount > 5) {
      final rhythmCompletionRatio = _validTempoTapCount / _expectedTempoCount;
      if (rhythmCompletionRatio < 0.65) {
        rhythmRatioPenalty = (0.65 - rhythmCompletionRatio) * 450; // Up to ~225 points penalty
      }
    }

    score -= tempoPenalty +
        tempoErrorsPenalty +
        missedTempoPenalty +
        missedPenalty +
        impulsivePenalty +
        reactionPenalty +
        ruleSwitchPenalty +
        rhythmRatioPenalty;

    // Stability bonus (limited)
    if (_tempoDeviations.isNotEmpty &&
        _tempoErrors == 0 &&
        _missedStimuli == 0 &&
        _impulsiveErrors == 0 &&
        _missedTempoCount == 0) {
      score += 60;
    }

    score = score.clamp(0.0, 1000.0);

    // Build stats map
    final stats = <String, String>{
      '_score_final': score.toStringAsFixed(1),
      '_score_base': '1000',
      '_score_penalty_tempo': tempoPenalty.toStringAsFixed(1),
      '_score_penalty_errors': (tempoErrorsPenalty + missedPenalty + impulsivePenalty).toStringAsFixed(1),
      '_score_penalty_reaction': reactionPenalty.toStringAsFixed(1),
      '_level': widget.level?.toString() ?? '',
      strings.reflexesDissociationDuration:
          '${widget.durationSeconds}s',
      strings.reflexesDissociationTempoAccuracy:
          '${((1 - (avgTempoDeviation / widget.tempoMs)).clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
      strings.reflexesDissociationAvgTempoDeviation:
          '${avgTempoDeviation}ms',
      strings.reflexesDissociationAvgReactionTime:
          '${avgReactionTime}ms',
      strings.reflexesDissociationTempoErrors:
          '$_tempoErrors',
      strings.reflexesDissociationMissedStimuli:
          '$_missedStimuli',
      strings.reflexesDissociationImpulseErrors:
          '$_impulsiveErrors',
      strings.reflexesDissociationRuleSwitchErrors:
          '$_ruleSwitchErrors',
      strings.reflexesDissociationExpectedPulses:
          '$_expectedTempoCount',
      strings.reflexesDissociationValidTaps:
          '$_validTempoTapCount',
      strings.reflexesDissociationMissedPulses:
          '$_missedTempoCount',
      if (stoppedEarly) '_stopped_early': '1',
    };

    final result = _ReflexSessionRecord(
      mode: _ReflexesMode.dissociation,
      date: DateTime.now(),
      primaryScore: score,
      stats: stats,
    );

    await _restorePortrait();
    if (!mounted) return;
    setState(() {
      _currentResult = result;
      _showResults = true;
    });

    widget.onResultSaved?.call(result);
  }

  void _cancelAllTimers() {
    _mainTimer?.cancel();
    _stimulusTimer?.cancel();
    _countdownTimer?.cancel();
    _feedbackTimer?.cancel();
    _ruleSwitchTimer?.cancel();
    _tempoPulseTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_showResults && !_isCountingDown) {
        _isPaused = true;
        _cancelAllTimers();
      }
    } else if (state == AppLifecycleState.resumed && _isPaused) {
      _isPaused = false;
      if (!_showResults && !_isCountingDown) {
        _endSession();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelAllTimers();
    _feedbackAnimationController.dispose();
    WakelockPlus.disable();
    if (_keepLandscapeForNextLevel) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    }
    super.dispose();
  }

  Future<void> _restorePortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  void _nextLevel() {
    final current = _currentResult;
    if (current == null) return;
    _keepLandscapeForNextLevel = true;
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

  void _restart() {
    _keepLandscapeForNextLevel = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() {
      _showResults = false;
      _currentResult = null;
      _tempoTapCount = 0;
      _tempoErrors = 0;
      _stimulusCount = 0;
      _stimulusResponses = 0;
      _missedStimuli = 0;
      _impulsiveErrors = 0;
      _ruleSwitchErrors = 0;
      _tempoDeviations.clear();
      _reactionTimes.clear();
      _isRuleInverted = false;
      _currentStimulus = null;
      _sessionStopwatch.reset();
      _tempoPulseValue = 0.0;
      _expectedTempoCount = 0;
      _validTempoTapCount = 0;
      _missedTempoCount = 0;
      _tempoHitThisBeat = false;
    });
    _startCountdown();
  }

  void _checkMissedTempoPulse() {
    // Called at each tempo pulse - checks if user tapped since last pulse
    if (_expectedTempoCount > 0 && !_tempoHitThisBeat) {
      _missedTempoCount++;
    }
    _expectedTempoCount++;
    _tempoHitThisBeat = false;
  }

  void _triggerTempoPulse() {
    _checkMissedTempoPulse();
    setState(() {
      _tempoPulseValue = 1.0;
      _shouldTapLeft = true;
      _lastTempoExpectedTime = DateTime.now();
    });
    // Fade out pulse and button color after tolerance window
    Future.delayed(Duration(milliseconds: widget.tempoToleranceMs), () {
      if (mounted) {
        setState(() {
          _tempoPulseValue = 0.0;
          _shouldTapLeft = false;
        });
      }
    });
  }

  void _handleLeftTap() {
    if (_handlingTempoTap) return;
    _handlingTempoTap = true;

    final now = DateTime.now();
    final expected = _lastTempoExpectedTime;

    if (expected != null) {
      final diff = now.difference(expected).inMilliseconds.abs();
      if (diff <= widget.tempoToleranceMs) {
        // Valid tempo tap
        _tempoTapCount++;
        _validTempoTapCount++;
        _tempoDeviations.add(diff);
        _tempoHitThisBeat = true;
      } else {
        // Off-beat tap (error)
        _tempoErrors++;
      }
    }

    Future.delayed(const Duration(milliseconds: 50), () {
      _handlingTempoTap = false;
    });
  }

  void _handleRightTap() {
    if (_handlingStimulusTap) return;
    _handlingStimulusTap = true;

    final now = DateTime.now();
    final stimulusStart = _stimulusStartTime;

    if (_currentStimulus != null && stimulusStart != null) {
      final reactionTime = now.difference(stimulusStart).inMilliseconds;
      _reactionTimes.add(reactionTime);
      _stimulusResponses++;

      final isCorrect = (_currentStimulus == _StimulusType.go && !_isRuleInverted) ||
                        (_currentStimulus == _StimulusType.noGo && _isRuleInverted);

      setState(() {
        _lastStimulusSuccess = isCorrect;
        _feedbackOpacity = 1.0;
      });

      // Fade out feedback
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _feedbackOpacity = 0.0);
        }
      });

      if (_currentStimulus == _StimulusType.go) {
        if (_isRuleInverted) {
          _ruleSwitchErrors++;
        }
      } else {
        _impulsiveErrors++;
        if (_isRuleInverted) {
          _ruleSwitchErrors++;
        }
      }

      _clearStimulus();
    }

    Future.delayed(const Duration(milliseconds: 50), () {
      _handlingStimulusTap = false;
    });
  }

  List<_ReflexSessionRecord> _topRecords() {
    final current = _currentResult;
    final levelStr = widget.level?.toString();
    final strings = AppStrings.of(context);
    var records = <_ReflexSessionRecord>[
      ...widget.history,
      if (current != null) current,
    ];
    if (levelStr != null) {
      records = records.where((r) => r.stats['_level'] == levelStr).toList();
    }
    records.sort(
      (a, b) => _scoredValue(
        b.mode,
        b.primaryScore,
        b.stats,
        strings,
      ).compareTo(_scoredValue(a.mode, a.primaryScore, a.stats, strings)),
    );
    return records;
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    if (_showResults) {
      return _buildResultsScreen(context, strings, colors, texts);
    }

    return _buildGameScreen(context, strings, colors, texts);
  }

  Widget _buildResultsScreen(BuildContext context, AppStrings strings, ColorScheme colors, TextTheme texts) {
    final topRecords = _topRecords();
    final finalScore = _scoredValue(
      _ReflexesMode.dissociation,
      _currentResult!.primaryScore,
      _currentResult!.stats,
      strings,
    );
    final stars = _currentResult!.stats['_stopped_early'] == '1' ? 0 : _starsForScore(finalScore);
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(AppSpacing.md),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(_currentResult),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade300
                              : LightColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: _ResultTitleWithScaleInfo(
                        mode: _ReflexesMode.dissociation,
                        title: strings.reflexesResultsTitle,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AnimatedLevelStarsBlock(
                      level: widget.level,
                      stars: stars,
                      score: _currentResult!.stats['_stopped_early'] == '1' ? 0 : finalScore,
                    ),
                    const Gap(AppSpacing.lg),
                    if (_currentResult!.stats['_stopped_early'] != '1')
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
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationTempoAccuracy,
                              _currentResult!.stats[
                                  strings.reflexesDissociationTempoAccuracy] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationExpectedPulses,
                              _currentResult!.stats[
                                  strings.reflexesDissociationExpectedPulses] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationValidTaps,
                              _currentResult!.stats[
                                  strings.reflexesDissociationValidTaps] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationMissedPulses,
                              _currentResult!.stats[
                                  strings.reflexesDissociationMissedPulses] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationAvgTempoDeviation,
                              _currentResult!.stats[
                                  strings.reflexesDissociationAvgTempoDeviation] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationAvgReactionTime,
                              _currentResult!.stats[
                                  strings.reflexesDissociationAvgReactionTime] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationTempoErrors,
                              _currentResult!.stats[
                                  strings.reflexesDissociationTempoErrors] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationMissedStimuli,
                              _currentResult!.stats[
                                  strings.reflexesDissociationMissedStimuli] ??
                                  '',
                            ),
                            _buildStatRow(
                              texts,
                              colors,
                              strings.reflexesDissociationImpulseErrors,
                              _currentResult!.stats[
                                  strings.reflexesDissociationImpulseErrors] ??
                                  '',
                            ),
                            if (widget.enableRuleSwitch)
                              _buildStatRow(
                                texts,
                                colors,
                                strings.reflexesDissociationRuleSwitchErrors,
                                _currentResult!.stats[
                                    strings.reflexesDissociationRuleSwitchErrors] ??
                                    '',
                              ),
                          ],
                        ),
                      ),
                    const Gap(AppSpacing.lg),
                    // Action buttons
                    SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _restart,
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.surfaceContainerHighest,
                                foregroundColor: colors.onSurfaceVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.replay_rounded, size: 20),
                              label: Text(strings.colorPodRestart.toUpperCase()),
                            ),
                          ),
                          if (stars > 0) ...[
                            const Gap(AppSpacing.sm),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _nextLevel,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                                label: Text(strings.colorPodNext.toUpperCase()),
                                iconAlignment: IconAlignment.end,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.lg),
                    _ResultTopThreeCard(
                      records: topRecords,
                      colors: colors,
                      textStyles: texts,
                      strings: strings,
                      scoreTextBuilder: (r) {
                        final s = _scoredValue(r.mode, r.primaryScore, r.stats, strings);
                        return '${s.toStringAsFixed(0)} pts';
                      },
                      dateTextBuilder: (date) => _formatDate(date),
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

  Widget _buildGameScreen(BuildContext context, AppStrings strings, ColorScheme colors, TextTheme texts) {
    // Active gameplay screen
    final isGo = _currentStimulus == _StimulusType.go;
    final isNoGo = _currentStimulus == _StimulusType.noGo;

    // Stimulus colors
    final goColor = _isRuleInverted
        ? const Color(0xFFE57373) // Red when inverted (should NOT tap)
        : const Color(0xFF81C784); // Green normally (should tap)
    final noGoColor = _isRuleInverted
        ? const Color(0xFF81C784) // Green when inverted (should tap)
        : const Color(0xFFE57373); // Red normally (should NOT tap)

    // Left button color: green when user should tap (tempo pulse active)
    final leftButtonColor = _shouldTapLeft ? const Color(0xFF4CAF50) : const Color(0xFF2A3550);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                radius: 1.5,
                colors: [Color(0xFF2A3550), Color(0xFF1A1F2E)],
              ),
            ),
          ),
          // Smoke blobs
          const _ReflexSmokeBlob(
            top: -120,
            left: -100,
            size: 380,
            color: Color(0xFF3D2A55),
          ),
          const _ReflexSmokeBlob(
            top: 150,
            right: -140,
            size: 320,
            color: Color(0xFF2D3A50),
            delay: 800,
          ),
          if (!_isCountingDown)
          SafeArea(
            child: Column(
              children: [
                // Header with stop button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timer and stats (left)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_sessionStopwatch.elapsed.inSeconds}s / ${widget.durationSeconds}s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            strings.reflexesDissociationRhythmErrors(_tempoErrors.toString()),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Rule inverted indicator (center)
                      if (_isRuleInverted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB74D).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFB74D),
                            ),
                          ),
                          child: Text(
                            strings.reflexesDissociationRuleInverted,
                            style: const TextStyle(
                              color: Color(0xFFFFB74D),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                    ],
                  ),
                ),

                // Instruction
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    _isRuleInverted
                        ? strings.reflexesDissociationInstructionInverted
                        : strings.reflexesDissociationInstruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),

                const Gap(AppSpacing.lg),

                // Main game area with two zones
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        // LEFT ZONE: Tempo/Rhythm — bouton 3D
                        Expanded(
                          child: GestureDetector(
                            onTapDown: (_) {
                              setState(() => _leftPressed = true);
                              _handleLeftTap();
                            },
                            onTapUp: (_) => setState(() => _leftPressed = false),
                            onTapCancel: () => setState(() => _leftPressed = false),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Shadow layer (fond 3D)
                                Positioned.fill(
                                  top: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _shouldTapLeft
                                          ? const Color(0xFF245D28)
                                          : const Color(0xFF2B2B2B),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          offset: const Offset(0, 7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Top layer animé
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 90),
                                  curve: Curves.easeOut,
                                  top: _leftPressed ? 8 : 0,
                                  left: 0,
                                  right: 0,
                                  bottom: _leftPressed ? 0 : 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: _leftPressed
                                            ? (_shouldTapLeft
                                                ? [const Color(0xFF388E3C), const Color(0xFF2E7D32)]
                                                : [const Color(0xFF424242), const Color(0xFF2E2E2E)])
                                            : (_shouldTapLeft
                                                ? [const Color(0xFF66BB6A), const Color(0xFF388E3C), const Color(0xFF2E7D32)]
                                                : [const Color(0xFF616161), const Color(0xFF424242), const Color(0xFF2E2E2E)]),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_shouldTapLeft
                                                  ? const Color(0xFF4CAF50)
                                                  : const Color(0xFF3A3A3A))
                                              .withValues(alpha: _leftPressed ? 0.18 : 0.28),
                                          blurRadius: _leftPressed ? 12 : 24,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: RadialGradient(
                                          center: const Alignment(-0.3, -0.4),
                                          radius: 0.9,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.22),
                                            Colors.white.withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          width: 70 + (_tempoPulseValue * 40),
                                          height: 70 + (_tempoPulseValue * 40),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(
                                              alpha: 0.1 + (_tempoPulseValue * 0.3),
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.3 + (_tempoPulseValue * 0.4),
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        // RIGHT ZONE: Stimulus — bouton 3D
                        Expanded(
                          child: GestureDetector(
                            onTapDown: (_) {
                              setState(() => _rightPressed = true);
                              _handleRightTap();
                            },
                            onTapUp: (_) => setState(() => _rightPressed = false),
                            onTapCancel: () => setState(() => _rightPressed = false),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Shadow layer (fond 3D)
                                Positioned.fill(
                                  top: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isGo
                                          ? const Color(0xFF245D28)
                                          : isNoGo
                                              ? const Color(0xFF8B1A1A)
                                              : const Color(0xFF2B2B2B),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          offset: const Offset(0, 7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Top layer animé
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 90),
                                  curve: Curves.easeOut,
                                  top: _rightPressed ? 8 : 0,
                                  left: 0,
                                  right: 0,
                                  bottom: _rightPressed ? 0 : 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: _rightPressed
                                            ? (isGo
                                                ? [const Color(0xFF388E3C), const Color(0xFF2E7D32)]
                                                : isNoGo
                                                    ? [const Color(0xFFD32F2F), const Color(0xFFB71C1C)]
                                                    : [const Color(0xFF424242), const Color(0xFF2E2E2E)])
                                            : (isGo
                                                ? [const Color(0xFF66BB6A), const Color(0xFF388E3C), const Color(0xFF2E7D32)]
                                                : isNoGo
                                                    ? [const Color(0xFFEF5350), const Color(0xFFD32F2F), const Color(0xFFB71C1C)]
                                                    : [const Color(0xFF616161), const Color(0xFF424242), const Color(0xFF2E2E2E)]),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isGo
                                                  ? const Color(0xFF4CAF50)
                                                  : isNoGo
                                                      ? const Color(0xFFE53935)
                                                      : const Color(0xFF3A3A3A))
                                              .withValues(alpha: _rightPressed ? 0.18 : 0.28),
                                          blurRadius: _rightPressed ? 12 : 24,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: RadialGradient(
                                          center: const Alignment(-0.3, -0.4),
                                          radius: 0.9,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.22),
                                            Colors.white.withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (isGo)
                                            Text(
                                              strings.reflexesDissociationTap,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 32,
                                                letterSpacing: 1.5,
                                              ),
                                            )
                                          else if (isNoGo)
                                            Text(
                                              strings.reflexesDissociationNoGo,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 32,
                                                letterSpacing: 1.5,
                                              ),
                                            )
                                          else
                                            Text(
                                              strings.reflexesDissociationWaiting,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                              ),
                                            ),
                                          if (_lastStimulusSuccess != null) ...[
                                            const Gap(AppSpacing.sm),
                                            AnimatedOpacity(
                                              opacity: _feedbackOpacity,
                                              duration: const Duration(milliseconds: 100),
                                              child: Icon(
                                                _lastStimulusSuccess!
                                                    ? Icons.check_circle_rounded
                                                    : Icons.cancel_rounded,
                                                color: _lastStimulusSuccess!
                                                    ? const Color(0xFF81C784)
                                                    : const Color(0xFFE57373),
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
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
                const Gap(AppSpacing.lg),
              ],
            ),
          ),
          if (_isCountingDown)
            Center(
              child: AnimatedScale(
                key: ValueKey(_countdown),
                scale: 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Text(
                        _countdown > 0 ? '$_countdown' : 'GO !',
                        style: TextStyle(
                          fontSize: _countdown > 0 ? 160 : 120,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -4,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Positioned(
            top: 20,
            right: 12,
            child: SafeArea(
              child: TextButton(
                onPressed: () => _endSession(stoppedEarly: true),
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
    );
  }

  void _clearStimulus() {
    setState(() {
      _currentStimulus = null;
      _stimulusStartTime = null;
    });
  }

  _ReflexSessionRecord _recordFromCurrent(Map<String, String> current) {
    return _ReflexSessionRecord(
      mode: _ReflexesMode.dissociation,
      date: DateTime.now(),
      primaryScore: double.tryParse(current['_score_final'] ?? '') ?? 0,
      stats: current,
    );
  }

  Widget _buildStatRow(TextTheme texts, ColorScheme colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: texts.bodyMedium?.copyWith(color: colors.secondary),
          ),
          Text(
            value,
            style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
