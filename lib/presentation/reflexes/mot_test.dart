part of '../reflexes_screen.dart';

class _MotCircle {
  Offset position;
  Offset velocity;
  _MotCircle({required this.position, required this.velocity});
}

class _MotRunScreen extends StatefulWidget {
  _MotRunScreen({
    required this.difficulty,
    required this.totalCircles,
    required this.targetCount,
    required this.trackingDurationMs,
    required this.speedPxPerSec,
    required this.trials,
    required this.circleDiameter,
    required this.highlightDurationMs,
    this.history = const <_ReflexSessionRecord>[],
    this.onResultSaved,
    this.level,
  });
  final _MotDifficulty difficulty;
  final int totalCircles;
  final int targetCount;
  final int trackingDurationMs;
  final double speedPxPerSec;
  final int trials;
  final double circleDiameter;
  final int highlightDurationMs;
  final List<_ReflexSessionRecord> history;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;

  @override
  State<_MotRunScreen> createState() => _MotRunScreenState();
}

enum _MotPhase {
  countdown,
  memorize,
  tracking,
  identification,
  feedback,
  results,
}

class _MotRunScreenState extends State<_MotRunScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  int _countdown = 3;
  bool _isCountingDown = true;
  _MotPhase _phase = _MotPhase.countdown;
  int _trial = 0;
  List<_MotCircle> _circles = [];
  Set<int> _targetIndices = {};
  Set<int> _selectedIndices = {};
  List<int> _trialScores = [];
  Ticker? _animationTicker;
  Timer? _timer;
  Timer? _phaseTimer;
  Timer? _blinkTimer;
  bool _showResults = false;
  _ReflexSessionRecord? _currentResult;
  String? _feedbackText;
  Color? _feedbackTextColor;
  Color? _feedbackBgColor;
  Color? _feedbackAccentColor;
  bool _isFeedbackSuccess = false;
  bool _keepLandscapeForNextLevel = false;
  late final AnimationController _feedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
  Size? _gameZoneSize;
  bool _retryStartTrialScheduled = false;
  bool _abortedByBackground = false;
  final _repaintNotifier = ValueNotifier<int>(0);

  int _compareScores(_ReflexSessionRecord a, _ReflexSessionRecord b) {
    final strings = AppStrings.of(context);
    return _scoredValue(
      b.mode,
      b.primaryScore,
      b.stats,
      strings,
    ).compareTo(_scoredValue(a.mode, a.primaryScore, a.stats, strings));
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _feedbackAnimationController.addListener(() {
      if (!mounted) return;
      _repaintNotifier.value++;
    });
    WakelockPlus.enable();
    TimerSound.warmUp();
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAnimationTicker();
    _timer?.cancel();
    _phaseTimer?.cancel();
    _blinkTimer?.cancel();
    _feedbackAnimationController.dispose();
    _repaintNotifier.dispose();
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

  void _startCountdown() {
    _timer?.cancel();
    _countdown = 3;
    _isCountingDown = true;
    _phase = _MotPhase.countdown;
    if (mounted) setState(() {});
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        _countdown--;
        setState(() {});
      } else {
        timer.cancel();
        _isCountingDown = false;
        _startMemorizePhase();
      }
    });
  }

  void _startMemorizePhase() {
    _phase = _MotPhase.memorize;
    _trial = 0;
    _trialScores.clear();
    _startTrial();
  }

  void _stop() {
    _timer?.cancel();
    _phaseTimer?.cancel();
    _blinkTimer?.cancel();
    _disposeAnimationTicker();
    _finish(stoppedEarly: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_showResults && !_isCountingDown) {
        _abortedByBackground = true;
        _stop();
      }
    } else if (state == AppLifecycleState.resumed) {
      _abortedByBackground = false;
    }
  }

  void _disposeAnimationTicker() {
    final ticker = _animationTicker;
    _animationTicker = null;
    ticker?.dispose();
  }

  Future<void> _restorePortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
  }

  void _startTrial() {
    _disposeAnimationTicker();
    _phaseTimer?.cancel();
    _phase = _MotPhase.memorize;
    _selectedIndices.clear();
    _circles.clear();
    _targetIndices.clear();

    if (_gameZoneSize == null) {
      if (!_retryStartTrialScheduled) {
        _retryStartTrialScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _retryStartTrialScheduled = false;
          if (!mounted) return;
          if (_phase == _MotPhase.memorize && _circles.isEmpty) {
            _startTrial();
          }
        });
      }
      return;
    }
    final padding = 0.0;
    final gameWidth = _gameZoneSize!.width - padding * 2;
    final gameHeight = _gameZoneSize!.height - padding * 2;
    final radius = widget.circleDiameter / 2;
    final minDistance = widget.circleDiameter * 1.2;

    for (int i = 0; i < widget.totalCircles; i++) {
      Offset? pos;
      int attempts = 0;
      while (pos == null && attempts < 200) {
        final x =
            padding +
            radius +
            _random.nextDouble() * (gameWidth - widget.circleDiameter);
        final y =
            padding +
            radius +
            _random.nextDouble() * (gameHeight - widget.circleDiameter);
        final candidate = Offset(x, y);
        bool valid = true;
        for (final circle in _circles) {
          if ((candidate - circle.position).distance < minDistance) {
            valid = false;
            break;
          }
        }
        if (valid) {
          pos = candidate;
        }
        attempts++;
      }
      if (pos == null) {
        _circles.clear();
        _startTrial();
        return;
      }
      _circles.add(_MotCircle(position: pos, velocity: Offset.zero));
    }

    final allIndices = List.generate(widget.totalCircles, (i) => i)
      ..shuffle(_random);
    _targetIndices = allIndices.take(widget.targetCount).toSet();

    if (mounted) setState(() {});

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      setState(() {});
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: widget.highlightDurationMs), () {
      _blinkTimer?.cancel();
      _blinkTimer = null;
      if (!mounted) return;
      _startTrackingPhase();
    });
  }

  void _startTrackingPhase() {
    _phase = _MotPhase.tracking;
    final angle = _random.nextDouble() * 2 * 3.14159;
    _circles.asMap().forEach((i, circle) {
      circle.velocity = Offset(
        widget.speedPxPerSec * cos(angle + i * 0.5),
        widget.speedPxPerSec * sin(angle + i * 0.5),
      );
    });
    if (mounted) setState(() {});

    _animationTicker = createTicker((elapsed) {
      if (!mounted) return;
      final dt = elapsed.inMicroseconds / 1000000.0 - (_lastFrameTime ?? 0);
      _lastFrameTime = elapsed.inMicroseconds / 1000000.0;

      if (_gameZoneSize == null) return;
      final padding = 0.0;
      final gameWidth = _gameZoneSize!.width - padding * 2;
      final gameHeight = _gameZoneSize!.height - padding * 2;
      final radius = widget.circleDiameter / 2;

      for (final circle in _circles) {
        circle.position += circle.velocity * dt;

        if (circle.position.dx - radius < padding) {
          circle.position = Offset(padding + radius, circle.position.dy);
          circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
        }
        if (circle.position.dx + radius > padding + gameWidth) {
          circle.position = Offset(
            padding + gameWidth - radius,
            circle.position.dy,
          );
          circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
        }
        if (circle.position.dy - radius < padding) {
          circle.position = Offset(circle.position.dx, padding + radius);
          circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
        }
        if (circle.position.dy + radius > padding + gameHeight) {
          circle.position = Offset(
            circle.position.dx,
            padding + gameHeight - radius,
          );
          circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
        }
      }

      for (int i = 0; i < _circles.length; i++) {
        for (int j = i + 1; j < _circles.length; j++) {
          final delta = _circles[i].position - _circles[j].position;
          final dist = delta.distance;
          if (dist < widget.circleDiameter && dist > 0.001) {
            final normal = delta / dist;
            final overlap = widget.circleDiameter - dist;

            _circles[i].position += normal * (overlap / 2);
            _circles[j].position -= normal * (overlap / 2);

            final relativeVel = _circles[i].velocity - _circles[j].velocity;
            final velAlongNormal =
                relativeVel.dx * normal.dx + relativeVel.dy * normal.dy;

            if (velAlongNormal > 0) continue;

            final impulse = normal * velAlongNormal;
            _circles[i].velocity -= impulse;
            _circles[j].velocity += impulse;
          }
        }
      }

      if (mounted) _repaintNotifier.value++;
    });
    _lastFrameTime = 0;
    _animationTicker!.start();

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: widget.trackingDurationMs), () {
      if (!mounted) return;
      _disposeAnimationTicker();
      _startIdentificationPhase();
    });
  }

  double? _lastFrameTime;

  void _startIdentificationPhase() {
    _phase = _MotPhase.identification;
    if (mounted) setState(() {});
  }

  void _handleCircleTap(Offset tapPosition) {
    if (_phase != _MotPhase.identification) return;
    final radius = widget.circleDiameter / 2;
    for (int i = 0; i < _circles.length; i++) {
      if ((tapPosition - _circles[i].position).distance <= radius) {
        setState(() {
          if (_selectedIndices.contains(i)) {
            _selectedIndices.remove(i);
          } else {
            _selectedIndices.add(i);
          }
          if (_selectedIndices.length == widget.targetCount) {
            _startFeedbackPhase();
          }
        });
        break;
      }
    }
  }

  void _startFeedbackPhase() {
    _phase = _MotPhase.feedback;
    final score = _selectedIndices.intersection(_targetIndices).length;
    _trialScores.add(score);

    final strings = AppStrings.of(context);
    _isFeedbackSuccess = score == widget.targetCount;
    if (_isFeedbackSuccess) {
      _feedbackText = strings.reflexesFeedbackCorrect;
      _feedbackTextColor = const Color(0xFFE8FFF4);
      _feedbackBgColor = const Color(0xFF0D3A28);
      _feedbackAccentColor = const Color(0xFF00E676);
    } else {
      _feedbackText = strings.reflexesFeedbackFalse;
      _feedbackTextColor = const Color(0xFFFFECEF);
      _feedbackBgColor = const Color(0xFF4A1620);
      _feedbackAccentColor = const Color(0xFFFF5252);
    }

    _feedbackAnimationController.reset();
    _feedbackAnimationController.forward();

    if (mounted) setState(() {});

    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (_trial < widget.trials - 1) {
        _trial++;
        _startTrial();
      } else {
        _finish();
      }
    });
  }

  Future<void> _finish({bool stoppedEarly = false}) async {
    final strings = AppStrings.of(context);
    final totalPossible = widget.trials * widget.targetCount;
    final totalCorrect = _trialScores.fold<int>(0, (a, b) => a + b);
    final avgScore = _trialScores.isEmpty
        ? 0.0
        : totalCorrect / _trialScores.length;
    final successRate = totalPossible == 0
        ? 0.0
        : (totalCorrect / totalPossible) * 100;

    final baseScore = successRate * 10;
    final missedTargets = totalPossible - totalCorrect;
    final errorPenalty = missedTargets * 120.0;
    final score = _boundedScore(baseScore - errorPenalty);
    final result = _ReflexSessionRecord(
      mode: _ReflexesMode.mot,
      date: DateTime.now(),
      primaryScore: score,
      stats: {
        '_score_final': score.toStringAsFixed(1),
        '_score_base': baseScore.toStringAsFixed(1),
        '_score_penalty_errors': errorPenalty.toStringAsFixed(1),
        strings.reflexesMotTrialLabel: '${widget.trials}',
        strings.reflexesMotTargetsFound: '$totalCorrect / $totalPossible',
        strings.reflexesMotAvgScore: avgScore.toStringAsFixed(2),
        strings.reflexesMotSuccessRate: '${successRate.toStringAsFixed(1)} %',
        if (widget.level != null) '_level': widget.level.toString(),
        if (stoppedEarly) '_stopped_early': '1',
      },
    );
    await _restorePortrait();
    if (!mounted) return;
    setState(() {
      _currentResult = result;
      _phase = _MotPhase.results;
      _showResults = true;
    });
  }

  Color _getCircleColor(int index) {
    if (_phase == _MotPhase.memorize) {
      final isTarget = _targetIndices.contains(index);
      final blinkOn = (_blinkTimer?.tick ?? 0) % 2 == 0;
      return isTarget && blinkOn
          ? const Color(0xFFFF9800)
          : const Color(0xFFE0E0E0);
    } else if (_phase == _MotPhase.identification) {
      return _selectedIndices.contains(index)
          ? const Color(0xFF1E88E5)
          : const Color(0xFFE0E0E0);
    } else if (_phase == _MotPhase.feedback) {
      final isTarget = _targetIndices.contains(index);
      final isSelected = _selectedIndices.contains(index);
      if (!_isFeedbackSuccess && isSelected) return const Color(0xFFFF5252);
      if (isTarget && isSelected) return const Color(0xFF00E676);
      if (!isTarget && isSelected) return const Color(0xFFFF5252);
      if (isTarget && !isSelected) return const Color(0xFFFF9800);
      return const Color(0xFFE0E0E0);
    }
    return const Color(0xFFE0E0E0);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    if (_showResults && _currentResult != null) {
      return _buildResultsScaffold(context, strings, colors, textStyles);
    }

    return _buildGameScaffold(context, strings, colors, textStyles);
  }

  Widget _buildGameScaffold(
    BuildContext context,
    AppStrings strings,
    ColorScheme colors,
    TextTheme textStyles,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, 0.5),
                radius: 1.2,
                colors: [Color(0xFF2A3550), Color(0xFF1A1F2E)],
              ),
            ),
          ),
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
          const _ReflexSmokeBlob(
            bottom: -120,
            left: 50,
            size: 400,
            color: Color(0xFF1F3F50),
            delay: 1600,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${strings.reflexesMotTrialLabel} ${(_trial + 1)}/${widget.trials}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final zoneSize = constraints.biggest;
                      if (_gameZoneSize == null ||
                          (_gameZoneSize!.width - zoneSize.width).abs() > 0.5 ||
                          (_gameZoneSize!.height - zoneSize.height).abs() >
                              0.5) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _gameZoneSize = zoneSize;
                          });
                        });
                      }

                      return _isCountingDown
                          ? Center(
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
                            )
                          : GestureDetector(
                              onTapDown: (details) =>
                                  _handleCircleTap(details.localPosition),
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _MotPainter(
                                  repaint: _repaintNotifier,
                                  circles: _circles,
                                  getCircleColor: _getCircleColor,
                                  circleDiameter: widget.circleDiameter,
                                  phase: _phase,
                                  selectedIndices: _selectedIndices,
                                  isFailureFeedback:
                                      _phase == _MotPhase.feedback &&
                                      !_isFeedbackSuccess,
                                  feedbackAnimValue:
                                      _feedbackAnimationController.value,
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_feedbackText != null)
            Positioned(
              top: 210,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _feedbackAnimationController,
                  builder: (_, __) {
                    final t = _feedbackAnimationController.value;
                    final appear = Curves.easeOutBack.transform(
                      (t / 0.32).clamp(0.0, 1.0),
                    );
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
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  (_feedbackBgColor ?? const Color(0xFF1E2432))
                                      .withValues(alpha: 0.98),
                                  (_feedbackAccentColor ??
                                          const Color(0xFF00E676))
                                      .withValues(alpha: 0.26),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: (_feedbackAccentColor ?? Colors.white)
                                    .withValues(alpha: 0.55),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_feedbackAccentColor ?? Colors.black)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 22,
                                  spreadRadius: 2,
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
                                Icon(
                                  Icons.flash_on_rounded,
                                  color: _feedbackAccentColor,
                                  size: 22,
                                ),
                                const Gap(8),
                                Text(
                                  _feedbackText!,
                                  style: TextStyle(
                                    color: _feedbackTextColor,
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
    );
  }

  Widget _buildResultsScaffold(
    BuildContext context,
    AppStrings strings,
    ColorScheme colors,
    TextTheme textStyles,
  ) {
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final topRecords = _topRecords();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: BoxDecoration(
            color: baseBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade300
                                : LightColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(color: colors.outline),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Builder(builder: (ctx) {
                        final stoppedEarly = _currentResult!.stats['_stopped_early'] == '1';
                        final computedScore = _scoredValue(
                          _currentResult!.mode,
                          _currentResult!.primaryScore,
                          _currentResult!.stats,
                          strings,
                        );
                        return _AnimatedLevelStarsBlock(
                          level: widget.level,
                          score: stoppedEarly ? 0 : computedScore,
                          stars: stoppedEarly ? 0 : _starsForScore(computedScore),
                        );
                      }),
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
                                style: textStyles.labelLarge?.copyWith(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              e.key,
                                              style: textStyles.bodyMedium
                                                  ?.copyWith(
                                                    color: colors.secondary,
                                                  ),
                                            ),
                                          ),
                                          const Gap(AppSpacing.md),
                                          Text(
                                            e.value,
                                            style: textStyles.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.onSurface,
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
                      Builder(builder: (context) {
                        final earnedStars = _currentResult!.stats['_stopped_early'] == '1' ? 0 : _starsForScore(_scoredValue(
                          _currentResult!.mode,
                          _currentResult!.primaryScore,
                          _currentResult!.stats,
                          strings,
                        ));
                        return SizedBox(
                          height: 52,
                          child: Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    widget.onResultSaved?.call(_currentResult!);
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.landscapeLeft,
                                      DeviceOrientation.landscapeRight,
                                    ]);
                                    SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.immersiveSticky,
                                    );
                                    setState(() {
                                      _showResults = false;
                                      _currentResult = null;
                                      _gameZoneSize = null;
                                    });
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) _startCountdown();
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
                              if (earnedStars > 0) ...[  
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
                                    label: Text(strings.colorPodNext.toUpperCase()),
                                    iconAlignment: IconAlignment.end,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
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
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.md),
                            if (topRecords.isEmpty)
                              Text(
                                strings.reflexesNoSessions,
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.secondary,
                                ),
                              )
                            else
                              ...topRecords
                                  .take(3)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final record = entry.value;
                                    final medalColor = index == 0
                                        ? const Color(0xFFFFC107)
                                        : index == 1
                                        ? const Color(0xFFB0BEC5)
                                        : const Color(0xFFCD7F32);
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
                                              record.primaryScore
                                                  .toStringAsFixed(2),
                                              style: textStyles.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            _formatDate(record.date),
                                            style: textStyles.bodySmall
                                                ?.copyWith(
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
}

class _MotPainter extends CustomPainter {
  final ValueNotifier<int> repaint;
  final List<_MotCircle> circles;
  final Color Function(int) getCircleColor;
  final double circleDiameter;
  final _MotPhase phase;
  final Set<int> selectedIndices;
  final bool isFailureFeedback;
  final double feedbackAnimValue;

  _MotPainter({
    required this.repaint,
    required this.circles,
    required this.getCircleColor,
    required this.circleDiameter,
    required this.phase,
    required this.selectedIndices,
    required this.isFailureFeedback,
    required this.feedbackAnimValue,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = circleDiameter / 2;
    for (int i = 0; i < circles.length; i++) {
      final circle = circles[i];
      var position = circle.position;
      if (isFailureFeedback && selectedIndices.contains(i)) {
        final wave = sin(feedbackAnimValue * 20 * pi);
        position = Offset(position.dx + (wave * 4), position.dy);
      }
      final paint = Paint()
        ..color = getCircleColor(i)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MotPainter oldDelegate) {
    return true;
  }
}

