part of '../reflexes_screen.dart';

Future<_ReflexSessionRecord?> _startVisualTestLevel({
  required BuildContext context,
  required int level,
  required Map<String, List<_ReflexSessionRecord>> historyByMode,
  required void Function(_ReflexSessionRecord) onResultSaved,
}) async {
  final p = visualLevelParams(level);
  return Navigator.of(context).push<_ReflexSessionRecord>(
    PageRouteBuilder<_ReflexSessionRecord>(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => _ReactionRunScreen(
        history:
            historyByMode[_ReflexesMode.visual.name] ??
            const <_ReflexSessionRecord>[],
        stimuliCount: p.stimuliCount,
        minDelayMs: p.minDelayMs,
        maxDelayMs: p.maxDelayMs,
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

class _ReactionRunScreen extends StatefulWidget {
  final _ReflexesMode mode;
  final List<_ReflexSessionRecord> history;
  final int stimuliCount;
  final int minDelayMs;
  final int maxDelayMs;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;

  _ReactionRunScreen({
    this.mode = _ReflexesMode.visual,
    this.history = const <_ReflexSessionRecord>[],
    this.stimuliCount = 10,
    this.minDelayMs = 800,
    this.maxDelayMs = 2200,
    this.onResultSaved,
    this.level,
  });

  @override
  State<_ReactionRunScreen> createState() => _ReactionRunScreenState();
}

class _ReactionRunScreenState extends State<_ReactionRunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  final _stopwatch = Stopwatch();
  final _timesMs = <int>[];
  int _falseStarts = 0;
  int _index = 0;
  bool _armed = false;
  Color? _visualSignalColor;
  bool _handlingTap = false;
  bool _buttonPressed = false;
  String? _feedbackText;
  Color? _feedbackTextColor;
  Color? _feedbackBgColor;
  Color? _feedbackAccentColor;
  Timer? _timer;
  Timer? _feedbackTimer;
  late final AnimationController _feedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
  int _countdown = 3;
  bool _isCountingDown = true;
  bool _showResults = false;
  _ReflexSessionRecord? _currentResult;

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
    TimerSound.warmUp();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _armed = false;
    _index = 0;
    _falseStarts = 0;
    _timesMs.clear();
    _countdown = 3;
    _isCountingDown = true;
    _visualSignalColor = null;
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
        _scheduleNext();
      }
    });
  }

  void _scheduleNext() {
    _armed = false;
    _visualSignalColor = null;
    _stopwatch
      ..stop()
      ..reset();
    if (mounted) setState(() {});
    final spread = widget.maxDelayMs - widget.minDelayMs;
    final delay =
        widget.minDelayMs + (spread <= 0 ? 0 : _random.nextInt(spread));
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delay), () async {
      if (!mounted) return;
      if (widget.mode == _ReflexesMode.auditory) {
        var played = false;
        try {
          await TimerSound.play();
          played = true;
        } catch (_) {}
        if (!played) {
          try {
            await SystemSound.play(SystemSoundType.alert);
          } catch (_) {}
        }
        if (!mounted) return;
        _armed = true;
        _stopwatch
          ..reset()
          ..start();
        setState(() {});
      } else {
        // Green 50%, Red 35%, Orange 15% – no blue
        final rand = _random.nextDouble();
        final Color signalColor;
        if (rand < 0.50) {
          signalColor = const Color(0xFF43A047); // green – GO
        } else if (rand < 0.85) {
          signalColor = const Color(0xFFD32F2F); // red – NO GO
        } else {
          signalColor = const Color(0xFFFF9800); // orange – NO GO
        }
        final isGoSignal = signalColor == const Color(0xFF43A047);

        _visualSignalColor = signalColor;
        _armed = isGoSignal;

        if (isGoSignal) {
          _stopwatch
            ..reset()
            ..start();
          setState(() {});
          return;
        }

        setState(() {});
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: 650), () {
          if (!mounted) return;
          _scheduleNext();
        });
      }
    });
  }

  void _tap() {
    if (_handlingTap) return;
    _handlingTap = true;
    if (!_armed) {
      _falseStarts++;
      _timer?.cancel();
      _showFalseFeedback();
      setState(() {});
      _scheduleNext();
      _handlingTap = false;
      return;
    }
    _stopwatch.stop();
    final ms = _stopwatch.elapsedMilliseconds;
    _timesMs.add(ms);
    _index++;
    _showSpeedFeedback(ms);
    if (_index >= widget.stimuliCount) {
      _finish();
    } else {
      _scheduleNext();
    }
    _handlingTap = false;
  }

  void _showFalseFeedback() {
    final strings = AppStrings.of(context);
    setState(() {
      _feedbackText = strings.reflexesFeedbackFalse;
      _feedbackTextColor = const Color(0xFFFFECEF);
      _feedbackBgColor = const Color(0xFF4C1621);
      _feedbackAccentColor = const Color(0xFFFF5252);
    });
    _feedbackAnimationController.reset();
    _feedbackAnimationController.forward();
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() => _feedbackText = null);
    });
  }

  void _showSpeedFeedback(int ms) {
    final strings = AppStrings.of(context);
    String text;
    Color textColor;
    Color bgColor;
    Color accentColor;

    final veryFastThreshold = widget.mode == _ReflexesMode.auditory ? 160 : 200;
    final fastThreshold = widget.mode == _ReflexesMode.auditory ? 220 : 300;
    final slowThreshold = widget.mode == _ReflexesMode.auditory ? 400 : 450;

    if (ms <= veryFastThreshold) {
      text = strings.reflexesFeedbackVeryFast;
      textColor = const Color(0xFFE8FFF4);
      bgColor = const Color(0xFF0D402A);
      accentColor = const Color(0xFF00E676);
    } else if (ms <= fastThreshold) {
      text = strings.reflexesFeedbackFast;
      textColor = const Color(0xFFEAFBFF);
      bgColor = const Color(0xFF0E3952);
      accentColor = const Color(0xFF00B0FF);
    } else if (ms <= slowThreshold) {
      text = strings.reflexesFeedbackSlow;
      textColor = const Color(0xFFFFF5E8);
      bgColor = const Color(0xFF4A2A0E);
      accentColor = const Color(0xFFFFB300);
    } else {
      text = strings.reflexesFeedbackVerySlow;
      textColor = const Color(0xFFFFECEF);
      bgColor = const Color(0xFF4C1621);
      accentColor = const Color(0xFFFF5252);
    }

    setState(() {
      _feedbackText = '${text.toUpperCase()} • ${ms} ms';
      _feedbackTextColor = textColor;
      _feedbackBgColor = bgColor;
      _feedbackAccentColor = accentColor;
    });
    _feedbackAnimationController.reset();
    _feedbackAnimationController.forward();
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() => _feedbackText = null);
    });
  }

  void _finish() {
    final avg = _timesMs.isEmpty
        ? 0.0
        : _timesMs.reduce((a, b) => a + b) / _timesMs.length;
    final variance = _timesMs.isEmpty
        ? 0.0
        : _timesMs
                  .map((v) => pow(v - avg, 2).toDouble())
                  .reduce((a, b) => a + b) /
              _timesMs.length;
    final strings = AppStrings.of(context);
    final speedPenalty =
        max(0.0, avg - 180.0) *
        (widget.mode == _ReflexesMode.auditory ? 1.45 : 1.35);
    final errorPenalty = _falseStarts * 180.0;
    final score = _boundedScore(1000 - speedPenalty - errorPenalty);
    final result = _ReflexSessionRecord(
      mode: widget.mode,
      date: DateTime.now(),
      primaryScore: score,
      stats: {
        '_score_final': score.toStringAsFixed(1),
        '_score_base': '1000',
        '_score_penalty_speed': speedPenalty.toStringAsFixed(1),
        '_score_penalty_errors': errorPenalty.toStringAsFixed(1),
        strings.reflexesStimuliCountLabel: _index.toString(),
        strings.reflexesAvgReactionTime: avg.toStringAsFixed(1),
        strings.reflexesStdDevReactionTime: sqrt(variance).toStringAsFixed(1),
        strings.reflexesMinReactionTime:
            (_timesMs.isEmpty ? 0 : _timesMs.reduce(min)).toString(),
        strings.reflexesMaxReactionTime:
            (_timesMs.isEmpty ? 0 : _timesMs.reduce(max)).toString(),
        strings.reflexesFalseStarts: _falseStarts.toString(),
        if (widget.level != null) '_level': widget.level.toString(),
      },
    );
    setState(() {
      _currentResult = result;
      _showResults = true;
    });
  }

  void _stop() {
    _timer?.cancel();
    _stopwatch.stop();
    if (_timesMs.isNotEmpty) {
      final avg = _timesMs.reduce((a, b) => a + b) / _timesMs.length;
      final variance =
          _timesMs
              .map((v) => pow(v - avg, 2).toDouble())
              .reduce((a, b) => a + b) /
          _timesMs.length;
      final strings = AppStrings.of(context);
      final result = _ReflexSessionRecord(
        mode: widget.mode,
        date: DateTime.now(),
        primaryScore: avg,
        stats: {
          strings.reflexesStimuliCountLabel: _index.toString(),
          strings.reflexesAvgReactionTime: avg.toStringAsFixed(1),
          strings.reflexesStdDevReactionTime: sqrt(variance).toStringAsFixed(1),
          strings.reflexesMinReactionTime:
              (_timesMs.isEmpty ? 0 : _timesMs.reduce(min)).toString(),
          strings.reflexesMaxReactionTime:
              (_timesMs.isEmpty ? 0 : _timesMs.reduce(max)).toString(),
          strings.reflexesFalseStarts: _falseStarts.toString(),
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
      _timer?.cancel();
      _stopwatch.stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    _feedbackAnimationController.dispose();
    _stopwatch.stop();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    if (_showResults && _currentResult != null) {
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
                                  strings.reflexesStimuliCountLabel,
                                  _currentResult!.stats[strings
                                          .reflexesStimuliCountLabel] ??
                                      '',
                                ),
                                _buildStatRow(
                                  texts,
                                  colors,
                                  strings.reflexesAvgReactionTime,
                                  '${_currentResult!.stats[strings.reflexesAvgReactionTime] ?? ''} ms',
                                ),
                                _buildStatRow(
                                  texts,
                                  colors,
                                  strings.reflexesStdDevReactionTime,
                                  '${_currentResult!.stats[strings.reflexesStdDevReactionTime] ?? ''} ms',
                                ),
                                _buildStatRow(
                                  texts,
                                  colors,
                                  strings.reflexesMinReactionTime,
                                  '${_currentResult!.stats[strings.reflexesMinReactionTime] ?? ''} ms',
                                ),
                                _buildStatRow(
                                  texts,
                                  colors,
                                  strings.reflexesMaxReactionTime,
                                  '${_currentResult!.stats[strings.reflexesMaxReactionTime] ?? ''} ms',
                                ),
                                _buildStatRow(
                                  texts,
                                  colors,
                                  strings.reflexesFalseStarts,
                                  _currentResult!.stats[strings
                                          .reflexesFalseStarts] ??
                                      '',
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
                                      setState(() {
                                        _showResults = false;
                                        _currentResult = null;
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
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
                                      label: Text(
                                        strings.colorPodNext.toUpperCase(),
                                      ),
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
                                    style: texts.labelLarge?.copyWith(
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
                                  style: texts.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                  ),
                                )
                              else
                                ...topRecords.take(3).toList().asMap().entries.map((
                                  entry,
                                ) {
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
                                            '${_scoredValue(record.mode, record.primaryScore, record.stats, strings).toStringAsFixed(0)} pts',
                                            style: texts.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatDate(record.date),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_index/${widget.stimuliCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          '${strings.reflexesFalseStart}: $_falseStarts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _isCountingDown
                        ? AnimatedScale(
                            key: ValueKey(_countdown),
                            scale: 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            onEnd: () {
                              if (mounted) {
                                setState(() {});
                              }
                            },
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
                          )
                        : (widget.mode == _ReflexesMode.visual
                              ? _buildReactionTapButton(isVisual: true)
                              : (widget.mode == _ReflexesMode.auditory
                                    ? _buildReactionTapButton(isVisual: false)
                                    : Padding(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.xl,
                                        ),
                                        child: Text(
                                          strings.reflexesTapWhenReady,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ))),
                  ),
                ),
                const Gap(60),
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

  Widget _buildReactionTapButton({required bool isVisual}) {
    final strings = AppStrings.of(context);
    final visualReady = isVisual && _armed;
    final visualSignal = _visualSignalColor;
    final backColor = isVisual
        ? (visualReady ? const Color(0xFF245D28) : const Color(0xFF2B2B2B))
        : const Color(0xFF0E4B87);
    final glowColor = isVisual
        ? (visualSignal ?? const Color(0xFF3A3A3A))
        : const Color(0xFF1976D2);
    final topGradient = isVisual
        ? (visualSignal != null
              ? [
                  visualSignal.withValues(alpha: 0.8),
                  visualSignal,
                  visualSignal.withValues(alpha: 0.75),
                ]
              : const [Color(0xFF616161), Color(0xFF424242), Color(0xFF2E2E2E)])
        : const [Color(0xFF64B5F6), Color(0xFF1976D2), Color(0xFF1565C0)];
    final pressedGradient = isVisual
        ? (visualSignal != null
              ? [
                  visualSignal.withValues(alpha: 0.75),
                  visualSignal.withValues(alpha: 0.55),
                ]
              : const [Color(0xFF2E2E2E), Color(0xFF1F1F1F)])
        : const [Color(0xFF1565C0), Color(0xFF0D47A1)];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() => _buttonPressed = true);
            _tap();
          },
          onTapUp: (_) => setState(() => _buttonPressed = false),
          onTapCancel: () => setState(() => _buttonPressed = false),
          child: SizedBox(
            width: 290,
            height: 300,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 12,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backColor,
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
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.easeOut,
                  top: _buttonPressed ? 12 : 0,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _buttonPressed ? pressedGradient : topGradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(
                            alpha: _buttonPressed ? 0.18 : 0.28,
                          ),
                          blurRadius: _buttonPressed ? 12 : 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.3, -0.4),
                          radius: 0.9,
                          colors: [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'TAPPER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 38,
                            letterSpacing: 2.2,
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
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            isVisual
                ? strings.reflexesVisualPermanentInstruction
                : strings.reflexesAuditoryPermanentInstruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
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
}

