import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/timer_sound.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Timer tool used for training and session timing.
///
/// Google Play compliance notes:
/// - This screen requests microphone access only for optional, user-initiated
///   sound detection modes.
/// - Microphone access is never used in the background.
/// - No audio is recorded, stored, uploaded, or shared.
/// - Sound input is processed locally in real time only to detect a loud sound
///   threshold and trigger timer logic.
/// - If the user does not select a microphone-based mode, this screen works
///   without microphone access.
///
/// This screen does not perform subscription verification or remote networking.
/// Subscription status is handled elsewhere in the app.
class ShootingTimerScreen extends StatefulWidget {
  final bool embedded;

  const ShootingTimerScreen({super.key, this.embedded = false});

  @override
  State<ShootingTimerScreen> createState() => _ShootingTimerScreenState();
}

enum _TimerMode {
  simple,
  parTime,
  repeat,
  randomDelay,
  startAndMic,
  startAndShots,
}

typedef _TimerStats = ({
  Duration totalTime,
  Duration firstShot,
  Duration splitAverage,
  Duration splitMin,
  Duration splitMax,
  Duration splitStdDev,
});

class _ShootingTimerScreenState extends State<ShootingTimerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  SwitchThemeData _buildUnifiedSwitchTheme(
    BuildContext context,
    ColorScheme colors,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primary.withValues(alpha: isDark ? 0.45 : 0.35);
        }
        return colors.outline.withValues(alpha: 0.35);
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.onPrimary;
        }
        return isDark
            ? colors.onSurface.withValues(alpha: 0.70)
            : colors.secondary.withValues(alpha: 0.85);
      }),
    );
  }

  _TimerMode _mode = _TimerMode.simple;
  static const Duration _beepLead = Duration(milliseconds: 75);
  static final Random _random = Random();
  Duration _startDelay = const Duration(seconds: 3);
  Duration _parTime = const Duration(seconds: 5);
  Duration _cycleDuration = const Duration(seconds: 5);
  Duration _randomBase = const Duration(seconds: 3);
  int _repetitions = 1;
  int _currentRepetition = 0;

  bool _showRunPanel = false;

  bool _actionStarted = false;

  /// Stopwatch used locally to measure elapsed time after the start beep.
  final Stopwatch _shotStopwatch = Stopwatch();

  /// Stores locally computed shot timestamps for on-screen display only.
  /// No values are sent anywhere from this screen.
  final List<Duration> _shotTimes = [];
  DateTime? _lastShotAt;

  /// NoiseMeter provides live microphone amplitude readings.
  ///
  /// Compliance note:
  /// - Used only in optional microphone timer modes selected by the user.
  /// - Used only for threshold detection.
  /// - No raw audio files are saved.
  /// - No audio stream is uploaded or transmitted.
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  /// Detection threshold in decibels. Any microphone peak ≥ this value is
  /// treated as a shot. Lower value = more sensitive (triggers on softer
  /// sounds). Continuous to support auto-calibration from ambient noise.
  double _dbThreshold = 92.0;
  static const double _dbThresholdMin = 55.0;
  static const double _dbThresholdMax = 110.0;

  /// True while the auto-calibration routine is running and listening to the
  /// ambient noise. Used to disable the Auto button and show feedback.
  bool _isCalibrating = false;

  /// Drives the run panel scroll view so new shots in multi-hit mode remain
  /// visible (auto-scroll to bottom on each detected shot).
  final ScrollController _runPanelScrollController = ScrollController();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Visual feedback when the timer fires (sound / vibration event)
  bool _flashHighlight = false;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _running = false;
  bool _finished = false;
  bool _paused = false;
  bool _mainButtonPressed = false;
  bool _resetButtonPressed = false;

  bool _zeroBeepFired = false;
  int _countdown = 3;

  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;

  void _fireLeadBeepOnly() {
    _fireEvent(playSound: true, vibrate: false, flash: false);
  }

  // For Par Time: track whether we have entered the shooting window (after initial delay)
  bool _parWindowStarted = false;
  // For Repeat mode: track whether we are still in the initial delay before repetitions.
  bool _repeatInInitialDelay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _blinkAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    _blinkController.value = 1.0;
    _prepareFeedbackCapabilities();
  }

  Duration _currentDisplayDuration() {
    // Before timer start, show the configured duration for the current mode.
    if (!_running && !_finished && !_paused) {
      switch (_mode) {
        case _TimerMode.simple:
        case _TimerMode.randomDelay:
        case _TimerMode.startAndMic:
        case _TimerMode.startAndShots:
          return _startDelay;
        case _TimerMode.parTime:
          // Show the initial delay before the active window starts.
          return _startDelay;
        case _TimerMode.repeat:
          // Repeat mode also starts by showing the initial delay.
          return _startDelay;
      }
    }

    // Microphone reaction modes:
    // - before the beep: _remaining is a descending countdown
    // - after the beep: the main display shows locally measured elapsed time
    //   from the Stopwatch.
    if ((_mode == _TimerMode.startAndMic ||
            _mode == _TimerMode.startAndShots) &&
        _actionStarted) {
      final elapsed = _shotStopwatch.elapsed;
      return elapsed < Duration.zero ? Duration.zero : elapsed;
    }

    if (_mode == _TimerMode.parTime) {
      // In par time mode:
      // - show descending initial delay first
      // - then show ascending elapsed time inside the active window
      final total = _startDelay + _parTime;
      final rawElapsed = total - _remaining;
      final elapsed = rawElapsed < Duration.zero
          ? Duration.zero
          : (rawElapsed > total ? total : rawElapsed);
      if (elapsed < _startDelay) {
        return _startDelay - elapsed;
      } else {
        final rawWindowElapsed = elapsed - _startDelay;
        final windowElapsed = rawWindowElapsed < Duration.zero
            ? Duration.zero
            : (rawWindowElapsed > _parTime ? _parTime : rawWindowElapsed);
        return windowElapsed;
      }
    }

    // Other modes simply display the internal remaining countdown.
    return _remaining;
  }

  Future<void> _prepareFeedbackCapabilities() async {
    // Pre-warm sound so the first beep is not delayed.
    try {
      await TimerSound.warmUp();
    } catch (_) {}

    // If the device has no vibrator, disable vibration in UI state.
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (mounted && !hasVibrator) {
        setState(() {
          _vibrationEnabled = false;
        });
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _running) {
      _pauseTimer();
      unawaited(WakelockPlus.disable());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopNoiseListening();
    _shotStopwatch.stop();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(WakelockPlus.disable());
    _blinkController.dispose();
    _runPanelScrollController.dispose();
    super.dispose();
  }

  /// Runs a 3-second ambient noise sampling and sets the detection threshold
  /// just above the observed peak. Never records or transmits audio.
  Future<void> _runAutoCalibration() async {
    if (_isCalibrating) return;
    final strings = AppStrings.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    // Warn the user so they know not to move or make noise.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(strings.timerSensitivityCalibrateTitle),
        content: Text(strings.timerSensitivityCalibrateMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.timerMicConfirmationCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: Text(strings.timerSensitivityCalibrateStart),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Request mic permission only if not already granted. On iOS,
    // permission_handler's `.request()` can return a transient wrong status
    // even after the user tapped "Allow", which would abort calibration on
    // a phantom failure. We therefore trigger the system prompt when needed
    // but never block on its return value — NoiseMeter will throw later if
    // the mic is truly unavailable, and we catch that below.
    final currentStatus = await Permission.microphone.status;
    if (!currentStatus.isGranted && !currentStatus.isLimited) {
      await Permission.microphone.request();
    }
    if (!mounted) return;

    // Stop any active listener (we take exclusive access during calibration).
    _stopNoiseListening();
    _noiseMeter ??= NoiseMeter();

    setState(() => _isCalibrating = true);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(strings.timerSensitivityCalibrating),
        duration: const Duration(seconds: 3),
      ),
    );

    double peak = _dbThresholdMin;
    Object? calibrationError;
    StreamSubscription<NoiseReading>? sub;

    try {
      sub = _noiseMeter!.noise.listen(
        (NoiseReading reading) {
          final db = reading.maxDecibel;
          if (db.isFinite && db > peak) peak = db;
        },
        onError: (Object error) {
          calibrationError = error;
        },
        cancelOnError: false,
      );
      await Future<void>.delayed(const Duration(seconds: 3));

      if (calibrationError != null) {
        throw calibrationError!;
      }
    } catch (_) {
      if (mounted) {
        messenger?.showSnackBar(
          SnackBar(content: Text(strings.timerSensitivityCalibrationFailed)),
        );
        setState(() => _isCalibrating = false);
      }
      await sub?.cancel();
      return;
    }

    await sub.cancel();

    // Apply a safety headroom so normal ambient fluctuations don't trigger.
    const headroomDb = 6.0;
    final newThreshold = (peak + headroomDb).clamp(
      _dbThresholdMin + headroomDb,
      _dbThresholdMax - 1.0,
    );

    if (!mounted) return;
    setState(() {
      _dbThreshold = newThreshold;
      _isCalibrating = false;
    });
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          strings.timerSensitivityCalibrationDone(newThreshold.round()),
        ),
      ),
    );
  }

  Future<void> _startNoiseListening() async {
    _stopNoiseListening();
    _noiseMeter ??= NoiseMeter();

    try {
      _noiseSubscription = _noiseMeter!.noise.listen(
        (NoiseReading reading) {
          // Only listen while the timer is running and only after the active
          // phase has started.
          if (!_running || !_actionStarted) {
            return;
          }

          // Microphone is used only in the two explicit mic-based modes.
          if (_mode != _TimerMode.startAndMic &&
              _mode != _TimerMode.startAndShots) {
            return;
          }

          final threshold = _dbThreshold;
          final db = reading.maxDecibel;

          // Only the numeric threshold result is used.
          // No raw audio is stored.
          if (db >= threshold) {
            if (_mode == _TimerMode.startAndMic) {
              // In chronometer mode, the first qualifying sound stops the timer.
              _stopNoiseListening();
              _stopTimer();
              return;
            }

            final now = DateTime.now();
            final last = _lastShotAt;

            // Local debounce to prevent duplicate triggers for a single sound event.
            if (last != null && now.difference(last).inMilliseconds < 250) {
              return;
            }
            _lastShotAt = now;

            if (!_shotStopwatch.isRunning) {
              _shotStopwatch
                ..reset()
                ..start();
            }

            final elapsed = _shotStopwatch.elapsed;
            if (mounted) {
              setState(() {
                // Store only computed elapsed timestamps for display.
                _shotTimes.add(elapsed);
              });
              // Keep the latest shot visible: after the frame renders with the
              // new row, animate the scroll view to the bottom.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (!_runPanelScrollController.hasClients) return;
                _runPanelScrollController.animateTo(
                  _runPanelScrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                );
              });
            }
          }
        },
        onError: (error) {
          _stopNoiseListening();
          final strings = AppStrings.of(context);
          _showTimerSnack(strings.timerMicrophoneError);
        },
        cancelOnError: true,
      );
    } catch (error) {
      _stopNoiseListening();
      final strings = AppStrings.of(context);
      _showTimerSnack(strings.timerMicrophoneError);
    }
  }

  /// Stops the microphone stream subscription immediately.
  ///
  /// Compliance note:
  /// Microphone access is ended as soon as it is no longer needed.
  void _stopNoiseListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
  }

  /// Shows a snackbar message for timer-related notifications.
  void _showTimerSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Shows a confirmation dialog before activating microphone-based timer modes.
  ///
  /// This ensures users understand how the microphone will be used before
  /// requesting the system permission.
  Future<bool> _showMicrophoneConfirmationDialog() async {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(strings.timerMicConfirmationTitle),
              content: Text(strings.timerMicConfirmationMessage),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    strings.timerMicConfirmationCancel,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(strings.timerMicConfirmationContinue),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _startTimer() {
    _timer?.cancel();
    _stopNoiseListening();
    unawaited(WakelockPlus.enable());
    setState(() {
      _running = true;
      _paused = false;
      _finished = false;
      _currentRepetition = 0;
      _actionStarted = false;
      _zeroBeepFired = false;
      _shotTimes.clear();
      _lastShotAt = null;
      _shotStopwatch
        ..stop()
        ..reset();
      _parWindowStarted = false;
      _repeatInInitialDelay = _mode == _TimerMode.repeat;
      _remaining = _effectiveInitialDuration();
      _countdown = _effectiveInitialDuration().inSeconds.ceil();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      setState(() {
        // Update countdown integer for bounce animation
        final newCountdown = _remaining.inSeconds.ceil();
        if (newCountdown != _countdown && newCountdown >= 0) {
          _countdown = newCountdown;
        }

        // Microphone modes:
        // - countdown before start beep
        // - after the beep, run stopwatch and optionally listen to mic locally
        if (_mode == _TimerMode.startAndMic ||
            _mode == _TimerMode.startAndShots) {
          if (!_actionStarted) {
            final next = _remaining - const Duration(milliseconds: 20);
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;
              _actionStarted = true;
              _fireEvent(
                playSound: !_zeroBeepFired,
                vibrate: true,
                flash: true,
                onSoundReady: () {
                  _shotStopwatch
                    ..reset()
                    ..start();
                  // Délai pour éviter de capter le bip ou la vibration
                  Future.delayed(const Duration(milliseconds: 850), () {
                    if (mounted && _running) _startNoiseListening();
                  });
                },
              );
              _zeroBeepFired = true;
            } else {
              _remaining = next;
            }
            return;
          }

          // After the beep, timing is handled by Stopwatch and optional shot list.
          return;
        }

        // Par time: first countdown delay, then ascending window
        if (_mode == _TimerMode.parTime) {
          final next = _remaining - const Duration(milliseconds: 20);
          final total = _startDelay + _parTime;
          final previousRemaining = _remaining;
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            _fireEvent(playSound: !_zeroBeepFired, vibrate: true, flash: true);
            _zeroBeepFired = true;
            _running = false;
            _finished = true;
            return;
          }

          final prevElapsed = total - previousRemaining;
          final newElapsed = total - next;
          final wasInDelay = prevElapsed < _startDelay;
          final nowInWindow = newElapsed >= _startDelay;
          _remaining = next;

          if (!_parWindowStarted && wasInDelay && nowInWindow) {
            _parWindowStarted = true;
            _fireEvent(playSound: true, vibrate: true, flash: true);
          }
          return;
        }

        // Repeat mode: initial delay, then repeat cycle duration N times
        if (_mode == _TimerMode.repeat) {
          final next = _remaining - const Duration(milliseconds: 20);
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            _fireEvent(playSound: !_zeroBeepFired, vibrate: true, flash: true);
            _zeroBeepFired = true;

            if (_repeatInInitialDelay) {
              _repeatInInitialDelay = false;
              _currentRepetition = 0;
              _remaining = _cycleDuration;
              _zeroBeepFired = false;
              return;
            }
            if (_currentRepetition < _repetitions) {
              _currentRepetition += 1;
              _remaining = _cycleDuration;
              _zeroBeepFired = false;
            } else {
              t.cancel();
              _running = false;
              _finished = true;
              return;
            }
          } else {
            _remaining = next;
          }
          return;
        }

        // Random delay mode:
        // 1) start countdown
        // 2) random countdown between 50% and 100% of _randomBase
        // 3) end event and stop
        if (_mode == _TimerMode.randomDelay) {
          final next = _remaining - const Duration(milliseconds: 20);
          if (!_actionStarted) {
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;
              _actionStarted = true;

              _fireEvent(
                playSound: !_zeroBeepFired,
                vibrate: true,
                flash: true,
              );
              _zeroBeepFired = true;

              final baseMs = _randomBase.inMilliseconds;
              final minMs = (baseMs * 0.5).round();
              final maxMs = baseMs;
              final ms = minMs + _random.nextInt(max(1, maxMs - minMs));
              _remaining = Duration(milliseconds: ms);
              _zeroBeepFired = false;
            } else {
              _remaining = next;
            }
          } else {
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;

              _fireEvent(
                playSound: !_zeroBeepFired,
                vibrate: true,
                flash: true,
              );
              _zeroBeepFired = true;

              t.cancel();
              _running = false;
              _finished = true;
            } else {
              _remaining = next;
            }
          }
          return;
        }

        // Décompte mode: single countdown then event
        if (_mode == _TimerMode.simple) {
          final next = _remaining - const Duration(milliseconds: 20);
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            _fireEvent(playSound: !_zeroBeepFired, vibrate: true, flash: true);
            _zeroBeepFired = true;
            _running = false;
            _finished = true;
          } else {
            _remaining = next;
          }
        }
      });
    });
  }

  void _triggerFlashHighlight() {
    if (!mounted) return;
    setState(() => _flashHighlight = true);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (!mounted) return;
      setState(() => _flashHighlight = false);
    });
  }

  Future<void> _fireEvent({
    required bool playSound,
    required bool vibrate,
    required bool flash,
    VoidCallback? onSoundReady,
  }) async {
    // Immediate visual feedback.
    if (flash) {
      _triggerFlashHighlight();
    }

    // Local timer beep playback only.
    // No microphone recording is involved here.
    if (playSound && _soundEnabled) {
      () async {
        try {
          await TimerSound.play();
        } catch (_) {
        } finally {
          onSoundReady?.call();
        }
      }();
    } else {
      onSoundReady?.call();
    }

    // Local vibration feedback only.
    if (vibrate && _vibrationEnabled) {
      () async {
        try {
          final hasVibrator = await Vibration.hasVibrator();
          if (hasVibrator) {
            Vibration.vibrate(duration: 600);
          }
        } catch (_) {}
      }();
    }
  }

  Duration _effectiveInitialDuration() {
    switch (_mode) {
      case _TimerMode.simple:
        return _startDelay;
      case _TimerMode.parTime:
        return _startDelay + _parTime;
      case _TimerMode.repeat:
        return _startDelay;
      case _TimerMode.randomDelay:
        return _startDelay;
      case _TimerMode.startAndMic:
        return _startDelay;
      case _TimerMode.startAndShots:
        return _startDelay;
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _stopNoiseListening();
    unawaited(WakelockPlus.disable());
    _blinkController.stop();
    setState(() {
      _running = false;
      _paused = false;
      _zeroBeepFired = false;
      if ((_mode == _TimerMode.startAndMic ||
              _mode == _TimerMode.startAndShots) &&
          _actionStarted) {
        _finished = true;
      }
      _shotStopwatch.stop();
    });
  }

  void _pauseTimer() {
    if (!_running) return;
    _timer?.cancel();
    _stopNoiseListening();
    unawaited(WakelockPlus.disable());
    _blinkController.repeat(reverse: true);
    setState(() {
      _running = false;
      _paused = true;
    });
    _shotStopwatch.stop();
  }

  void _resumeTimer() {
    if (_running || !_paused) return;

    _blinkController.stop();
    _blinkController.value = 1.0;
    setState(() {
      _running = true;
      _paused = false;
    });

    // In microphone modes, if the action phase had already started,
    // resume only the local stopwatch and local microphone threshold listener.
    if ((_mode == _TimerMode.startAndMic ||
            _mode == _TimerMode.startAndShots) &&
        _actionStarted) {
      if (!_shotStopwatch.isRunning) {
        _shotStopwatch.start();
      }
      _startNoiseListening();
      return;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      setState(() {
        if (_mode == _TimerMode.startAndMic ||
            _mode == _TimerMode.startAndShots) {
          if (!_actionStarted) {
            final next = _remaining - const Duration(milliseconds: 20);
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;
              _actionStarted = true;
              _fireEvent(
                playSound: !_zeroBeepFired,
                vibrate: true,
                flash: true,
                onSoundReady: () {
                  _shotStopwatch
                    ..reset()
                    ..start();
                  // Délai pour éviter de capter le bip ou la vibration
                  Future.delayed(const Duration(milliseconds: 650), () {
                    if (mounted && _running) _startNoiseListening();
                  });
                },
              );
              _zeroBeepFired = true;
            } else {
              _remaining = next;
            }
            return;
          }

          return;
        }

        if (_mode == _TimerMode.parTime) {
          final next = _remaining - const Duration(milliseconds: 20);
          final total = _startDelay + _parTime;
          final previousRemaining = _remaining;
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            _fireEvent(playSound: !_zeroBeepFired, vibrate: true, flash: true);
            _zeroBeepFired = true;
            _running = false;
            _finished = true;
            return;
          }

          final prevElapsed = total - previousRemaining;
          final newElapsed = total - next;
          final wasInDelay = prevElapsed < _startDelay;
          final nowInWindow = newElapsed >= _startDelay;
          _remaining = next;

          if (!_parWindowStarted && wasInDelay && nowInWindow) {
            _parWindowStarted = true;
            _fireEvent(playSound: true, vibrate: true, flash: true);
          }
          return;
        }

        if (_mode == _TimerMode.repeat) {
          final next = _remaining - const Duration(milliseconds: 20);
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            _fireEvent(playSound: !_zeroBeepFired, vibrate: true, flash: true);
            _zeroBeepFired = true;

            if (_repeatInInitialDelay) {
              _repeatInInitialDelay = false;
              _currentRepetition = 1;
              _remaining = _cycleDuration;
              _zeroBeepFired = false;
            } else {
              if (_currentRepetition < _repetitions) {
                _currentRepetition += 1;
                _remaining = _cycleDuration;
                _zeroBeepFired = false;
              } else {
                t.cancel();
                _running = false;
                _finished = true;
              }
            }
          } else {
            _remaining = next;
          }
          return;
        }

        if (_mode == _TimerMode.randomDelay) {
          final next = _remaining - const Duration(milliseconds: 20);
          if (!_actionStarted) {
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;
              _actionStarted = true;

              _fireEvent(
                playSound: !_zeroBeepFired,
                vibrate: true,
                flash: true,
              );
              _zeroBeepFired = true;

              final baseMs = _randomBase.inMilliseconds;
              final minMs = (baseMs * 0.5).round();
              final maxMs = baseMs;
              final ms = minMs + _random.nextInt(max(1, maxMs - minMs));
              _remaining = Duration(milliseconds: ms);
              _zeroBeepFired = false;
            } else {
              _remaining = next;
            }
          } else {
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;

              _fireEvent(
                playSound: !_zeroBeepFired,
                vibrate: true,
                flash: true,
              );
              _zeroBeepFired = true;

              t.cancel();
              _running = false;
              _finished = true;
            } else {
              _remaining = next;
            }
          }
          return;
        }

        if (_mode == _TimerMode.simple) {
          final next = _remaining - const Duration(milliseconds: 20);
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            _fireEvent(playSound: !_zeroBeepFired, vibrate: true, flash: true);
            _zeroBeepFired = true;
            _running = false;
            _finished = true;
          } else {
            _remaining = next;
          }
        }
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _stopNoiseListening();
    _blinkController.stop();
    _blinkController.value = 1.0;
    setState(() {
      _running = false;
      _paused = false;
      _finished = false;
      _actionStarted = false;
      _zeroBeepFired = false;
      _shotTimes.clear();
      _remaining = _effectiveInitialDuration();
      _currentRepetition = 0;
      _parWindowStarted = false;
    });
    _shotStopwatch
      ..stop()
      ..reset();
  }

  bool _shouldShowMinutes() {
    final durations = [_startDelay, _parTime, _cycleDuration, _randomBase];
    final anyConfiguredOverMinute = durations.any(
      (d) => d.inMilliseconds >= 60000,
    );
    if (anyConfiguredOverMinute) return true;
    return _currentDisplayDuration().inMilliseconds >= 60000;
  }

  String _formatDuration(Duration d, {bool? showMinutes}) {
    final totalMs = d.inMilliseconds.clamp(0, 5999999);
    final totalSeconds = totalMs / 1000.0;
    final wholeSeconds = totalSeconds.floor();
    final centis = ((totalSeconds - wholeSeconds) * 100).round().clamp(0, 99);
    final cs = centis.toString().padLeft(2, '0');
    if (showMinutes ?? false) {
      final mins = wholeSeconds ~/ 60;
      final secs = (wholeSeconds.remainder(60)).toString().padLeft(2, '0');
      return '$mins:$secs.$cs';
    }
    return '$wholeSeconds.$cs';
  }

  String _formatDurationSeconds3(Duration d) {
    final seconds = d.inMicroseconds / Duration.microsecondsPerSecond;
    return '${seconds.toStringAsFixed(3)} s';
  }

  String _formatStdDev(Duration d) {
    final seconds = d.inMicroseconds / Duration.microsecondsPerSecond;
    return '±${seconds.toStringAsFixed(3)} s';
  }

  _TimerStats? _computeStats(List<Duration> shotTimes) {
    if (shotTimes.length < 2) return null;

    final splits = <Duration>[];
    for (var i = 1; i < shotTimes.length; i++) {
      final delta = shotTimes[i] - shotTimes[i - 1];
      splits.add(delta < Duration.zero ? Duration.zero : delta);
    }
    if (splits.isEmpty) return null;

    final splitUs = splits
        .map((d) => d.inMicroseconds.toDouble())
        .toList(growable: false);
    final meanUs = splitUs.reduce((a, b) => a + b) / splitUs.length;
    final varianceUs =
        splitUs
            .map((v) => pow(v - meanUs, 2).toDouble())
            .reduce((a, b) => a + b) /
        splitUs.length;
    final stdUs = sqrt(varianceUs);

    final sortedSplits = [...splits]..sort();

    return (
      totalTime: shotTimes.last,
      firstShot: shotTimes.first,
      splitAverage: Duration(microseconds: meanUs.round()),
      splitMin: sortedSplits.first,
      splitMax: sortedSplits.last,
      splitStdDev: Duration(microseconds: stdUs.round()),
    );
  }

  String _modeDescription(AppStrings strings) {
    return _mode == _TimerMode.simple
        ? strings.timerModeSimpleDescription
        : _mode == _TimerMode.parTime
        ? strings.timerModeParTimeDescription
        : _mode == _TimerMode.repeat
        ? strings.timerModeRepeatDescription
        : _mode == _TimerMode.randomDelay
        ? strings.timerModeRandomDelayDescription
        : _mode == _TimerMode.startAndMic
        ? strings.timerModeStartAndMicDescription
        : strings.timerModeStartAndShotsDescription;
  }

  String _modeExample(AppStrings strings) {
    return _mode == _TimerMode.simple
        ? strings.timerModeSimpleExample
        : _mode == _TimerMode.parTime
        ? strings.timerModeParTimeExample
        : _mode == _TimerMode.repeat
        ? strings.timerModeRepeatExample
        : _mode == _TimerMode.randomDelay
        ? strings.timerModeRandomDelayExample
        : _mode == _TimerMode.startAndMic
        ? strings.timerModeStartAndMicExample
        : strings.timerModeStartAndShotsExample;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = _computeStats(_shotTimes);

    if (provider.isTimerModeLockedForFree(_mode.name)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _timer?.cancel();
        _stopNoiseListening();
        _shotTimes.clear();
        _lastShotAt = null;
        _shotStopwatch
          ..stop()
          ..reset();
        setState(() {
          _mode = _TimerMode.simple;
          _running = false;
          _finished = false;
          _actionStarted = false;
          _remaining = Duration.zero;
          _currentRepetition = 0;
        });
      });
    }

    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    final configPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(AppSpacing.md),
        _SectionHeader(
          icon: Icons.timer_outlined,
          title: strings.timerModesTitle,
        ),
        const Gap(AppSpacing.md),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildModeChip(
              label: strings.timerModeSimple,
              mode: _TimerMode.simple,
              isLocked: false,
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeParTime,
              mode: _TimerMode.parTime,
              isLocked: provider.isTimerModeLockedForFree('parTime'),
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeRepeat,
              mode: _TimerMode.repeat,
              isLocked: provider.isTimerModeLockedForFree('repeat'),
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeRandomDelay,
              mode: _TimerMode.randomDelay,
              isLocked: provider.isTimerModeLockedForFree('randomDelay'),
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeStartAndMic,
              mode: _TimerMode.startAndMic,
              isLocked: false,
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeStartAndShots,
              mode: _TimerMode.startAndShots,
              isLocked: provider.isTimerModeLockedForFree('startAndShots'),
              colors: colors,
              textStyles: textStyles,
            ),
          ],
        ),
        const Gap(AppSpacing.md),
        Text(
          _modeDescription(strings),
          style: textStyles.bodySmall?.copyWith(
            color: colors.secondary,
            height: 1.3,
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          _modeExample(strings),
          style: textStyles.bodySmall?.copyWith(
            color: colors.secondary,
            fontStyle: FontStyle.italic,
          ),
        ),

        // Short on-screen disclosure for microphone modes.
        // This helps make microphone usage visible and understandable to users.
        if (_mode == _TimerMode.startAndMic ||
            _mode == _TimerMode.startAndShots) ...[
          const Gap(AppSpacing.xs),
          Text(
            strings.timerMicDisclaimerShort,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
        ],
        const Gap(AppSpacing.lg),
        _SectionHeader(
          icon: Icons.tune_rounded,
          title: strings.timerSettingsTitle,
        ),
        const Gap(AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? null
                : Border.all(color: LightColors.surfaceHighlight, width: 1.35),
            boxShadow: AppShadows.cardPremium,
          ),
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDecimalField(
                label: strings.timerStartDelayLabel,
                value: _startDelay.inMilliseconds / 1000.0,
                unitSuffix: ' s',
                onChanged: (v) {
                  setState(
                    () => _startDelay = Duration(
                      milliseconds: (v * 1000).round(),
                    ),
                  );
                },
                colors: colors,
                textStyles: textStyles,
              ),
              if (_mode == _TimerMode.parTime) ...[
                const Gap(AppSpacing.md),
                _buildDecimalField(
                  label: strings.timerParTimeLabel,
                  value: _parTime.inMilliseconds / 1000.0,
                  unitSuffix: ' s',
                  onChanged: (v) {
                    setState(
                      () =>
                          _parTime = Duration(milliseconds: (v * 1000).round()),
                    );
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
              ],
              if (_mode == _TimerMode.repeat) ...[
                const Gap(AppSpacing.md),
                _buildDecimalField(
                  label: strings.timerCycleDurationLabel,
                  value: _cycleDuration.inMilliseconds / 1000.0,
                  unitSuffix: ' s',
                  onChanged: (v) {
                    setState(
                      () => _cycleDuration = Duration(
                        milliseconds: (v * 1000).round(),
                      ),
                    );
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
                const Gap(AppSpacing.md),
                _buildNumberField(
                  label: strings.timerRepetitionsLabel,
                  value: _repetitions,
                  unitSuffix: '',
                  onChanged: (v) {
                    setState(() => _repetitions = v);
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
              ],
              if (_mode == _TimerMode.randomDelay) ...[
                const Gap(AppSpacing.md),
                _buildDecimalField(
                  label: strings.timerRandomBaseLabel,
                  value: _randomBase.inMilliseconds / 1000.0,
                  unitSuffix: ' s',
                  onChanged: (v) {
                    setState(
                      () => _randomBase = Duration(
                        milliseconds: (v * 1000).round(),
                      ),
                    );
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
              ],
              const Gap(AppSpacing.md),
              const Divider(height: 1),
              const Gap(AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.timerEnableSound,
                      style: textStyles.bodyMedium,
                    ),
                  ),
                  SwitchTheme(
                    data: _buildUnifiedSwitchTheme(context, colors),
                    child: Switch(
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                      activeThumbColor: colors.primary,
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.timerEnableVibration,
                      style: textStyles.bodyMedium,
                    ),
                  ),
                  SwitchTheme(
                    data: _buildUnifiedSwitchTheme(context, colors),
                    child: Switch(
                      value: _vibrationEnabled,
                      onChanged: (v) => setState(() => _vibrationEnabled = v),
                      activeThumbColor: colors.primary,
                    ),
                  ),
                ],
              ),
              if (_mode == _TimerMode.startAndMic ||
                  _mode == _TimerMode.startAndShots) ...[
                const Gap(AppSpacing.md),
                const Divider(height: 1),
                const Gap(AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.timerShotSensitivityLabel,
                        style: textStyles.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: strings.timerSensitivityAutoTooltip,
                      child: TextButton.icon(
                        onPressed: _isCalibrating ? null : _runAutoCalibration,
                        icon: _isCalibrating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.settings_voice_rounded,
                                size: 18,
                              ),
                        label: Text(strings.timerSensitivityAuto),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.xs),
                // Slider direction: left = less sensitive (high dB threshold),
                // right = more sensitive (low dB threshold). Internally we
                // store the dB threshold directly; the slider value is the
                // inverted position so that "right = more sensitive" feels
                // natural.
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    inactiveTrackColor: colors.primary.withValues(alpha: 0.22),
                    activeTrackColor: colors.primary,
                    thumbColor: colors.primary,
                    overlayColor: colors.primary.withValues(alpha: 0.14),
                    tickMarkShape: SliderTickMarkShape.noTickMark,
                  ),
                  child: Slider(
                    value: (_dbThresholdMax - _dbThreshold).clamp(
                      0.0,
                      _dbThresholdMax - _dbThresholdMin,
                    ),
                    min: 0,
                    max: _dbThresholdMax - _dbThresholdMin,
                    divisions: ((_dbThresholdMax - _dbThresholdMin) * 2)
                        .round(), // 0.5 dB steps
                    label: '${_dbThreshold.toStringAsFixed(1)} dB',
                    onChanged: (v) =>
                        setState(() => _dbThreshold = _dbThresholdMax - v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.timerSensitivityLess,
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                      Text(
                        '${_dbThreshold.toStringAsFixed(0)} dB',
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        strings.timerSensitivityMore,
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.md),
                Text(
                  strings.timerSensitivityHint,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.lg),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              _resetTimer();
              setState(() {
                _showRunPanel = true;
              });
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(strings.validate),
          ),
        ),
        const Gap(AppSpacing.lg),
      ],
    );

    final runPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(0, 40),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 130,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          style: (textStyles.displayLarge ?? const TextStyle())
                              .copyWith(
                                fontWeight: FontWeight.w900,
                                color: _flashHighlight
                                    ? colors.error
                                    : colors.onSurface,
                                fontSize:
                                    (textStyles.displayLarge?.fontSize ?? 48) *
                                    2.7,
                              ),
                          child: Text(
                            _formatDuration(
                              _currentDisplayDuration(),
                              showMinutes: _shouldShowMinutes(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.lg * 2),
        Transform.translate(
          offset: const Offset(-25, 40),
          child: Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                scale: _flashHighlight ? 1.03 : (_running ? 0.98 : 1.0),
                child: FadeTransition(
                  opacity: _blinkAnimation,
                  child: Builder(
                    builder: (context) {
                      final backColor = _paused
                          ? const Color(0xFF4B5563)
                          : (_running
                                ? const Color(0xFFB45309)
                                : const Color(0xFF15803D));
                      final topGradient = _paused
                          ? const [
                              Color(0xFF9CA3AF),
                              Color(0xFF6B7280),
                              Color(0xFF4B5563),
                            ]
                          : (_running
                                ? const [
                                    Color(0xFFFDE68A),
                                    Color(0xFFF59E0B),
                                    Color(0xFFD97706),
                                  ]
                                : const [
                                    Color(0xFF5BE07B),
                                    Color(0xFF22C55E),
                                    Color(0xFF16A34A),
                                  ]);
                      final pressedGradient = _paused
                          ? const [Color(0xFF6B7280), Color(0xFF4B5563)]
                          : (_running
                                ? const [Color(0xFFD97706), Color(0xFFB45309)]
                                : const [Color(0xFF16A34A), Color(0xFF15803D)]);
                      final glowColor = _paused
                          ? const Color(0xFF9CA3AF)
                          : (_running
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF22C55E));

                      return GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _mainButtonPressed = true),
                        onTapUp: (_) =>
                            setState(() => _mainButtonPressed = false),
                        onTapCancel: () =>
                            setState(() => _mainButtonPressed = false),
                        onTap: _running
                            ? _pauseTimer
                            : (_paused ? _resumeTimer : _startTimer),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: 10,
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: backColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: glowColor.withValues(
                                        alpha: _running ? 0.12 : 0.18,
                                      ),
                                      blurRadius: _running ? 10 : 14,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 90),
                              curve: Curves.easeOut,
                              top: _mainButtonPressed ? 10 : 0,
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _mainButtonPressed
                                        ? pressedGradient
                                        : topGradient,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.26),
                                    width: 2,
                                  ),
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
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _running
                                              ? strings.timerPauseButton
                                              : (_paused
                                                    ? strings.timerResumeButton
                                                    : strings.timerGoButton),
                                          style: textStyles.displaySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 3.2,
                                                color: Colors.white,
                                                fontSize:
                                                    (textStyles
                                                            .displaySmall
                                                            ?.fontSize ??
                                                        24) *
                                                    1.8,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(0),
        Transform.translate(
          offset: const Offset(-15, 60),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 120,
              width: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _resetButtonPressed = true),
                  onTapUp: (_) => setState(() => _resetButtonPressed = false),
                  onTapCancel: () =>
                      setState(() => _resetButtonPressed = false),
                  onTap: _resetTimer,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 8,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF171717),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 90),
                        curve: Curves.easeOut,
                        top: _resetButtonPressed ? 8 : 0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _resetButtonPressed
                                  ? const [Color(0xFF2B2B2B), Color(0xFF161616)]
                                  : const [
                                      Color(0xFF4A4A4A),
                                      Color(0xFF2B2B2B),
                                      Color(0xFF1F1F1F),
                                    ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1.6,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.3, -0.4),
                                radius: 0.9,
                                colors: [
                                  Colors.white.withValues(alpha: 0.18),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    strings.timerResetButton.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.labelLarge?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
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
            ),
          ),
        ),
        const Gap(20),
        if (_mode == _TimerMode.startAndShots && _shotTimes.isNotEmpty) ...[
          const Gap(AppSpacing.lg),
          Text(
            strings.timerShotTimesTitle,
            style: textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.secondary,
            ),
          ),
          const Gap(AppSpacing.sm),
          // Reserve some scroll room under the newest row so the auto-scroll
          // keeps it comfortably above the bottom edge instead of flush with it.
          // Implemented by wrapping the list in a Padding — see below.
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _shotTimes.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : Border(top: BorderSide(color: colors.outline)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${i + 1}',
                          style: textStyles.bodySmall?.copyWith(
                            color: colors.secondary,
                          ),
                        ),
                        Text(
                          _formatDuration(_shotTimes[i]),
                          style: textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Trailing breathing room below the newest shot row so auto-scroll
          // doesn't stop flush against the bottom edge.
          const Gap(AppSpacing.xl),

          if (!_running &&
              _finished &&
              _shotTimes.length >= 2 &&
              stats != null) ...[
            _StatsPanel(
              stats: stats,
              strings: strings,
              colors: colors,
              textStyles: textStyles,
              isDark: isDark,
              formatDuration: _formatDurationSeconds3,
              formatStdDev: _formatStdDev,
            ),
            const Gap(AppSpacing.xl),
          ],
        ],
      ],
    );

    final content = Column(
      children: [
        if (!widget.embedded) ...[
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
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              if (_showRunPanel)
                GestureDetector(
                  onTap: _running
                      ? null
                      : () {
                          _resetTimer();
                          setState(() => _showRunPanel = false);
                        },
                  child: Container(
                    width: 36,
                    height: 36,
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
                      size: 20,
                    ),
                  ),
                ),
              if (_showRunPanel) const Gap(AppSpacing.sm),
              Expanded(
                child: Row(
                  mainAxisAlignment: _showRunPanel
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        strings.timerToolTitle,
                        style: textStyles.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const Gap(6),
                    Tooltip(
                      message: strings.timerToolSubtitle,
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 4),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: textStyles.bodySmall?.copyWith(
                        color: colors.surface,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: colors.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.xs),
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Divider(color: colors.outline),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              if (!_showRunPanel) return;
              if (_running) return;
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 420) {
                _resetTimer();
                setState(() {
                  _showRunPanel = false;
                });
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final isRunPanel = (child.key as ValueKey?)?.value == true;
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(isRunPanel ? 1.0 : -1.0, 0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: SingleChildScrollView(
                key: ValueKey(_showRunPanel),
                controller: _showRunPanel ? _runPanelScrollController : null,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: _showRunPanel ? runPanel : configPanel,
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return Container(color: baseBackground, child: content);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }

  Widget _buildModeChip({
    required String label,
    required _TimerMode mode,
    required bool isLocked,
    required ColorScheme colors,
    required TextTheme textStyles,
  }) {
    final selected = _mode == mode;
    final showMic =
        mode == _TimerMode.startAndMic || mode == _TimerMode.startAndShots;
    final micColor = selected ? colors.onPrimary : colors.primary;
    final labelColor = selected
        ? colors.onPrimary
        : (isLocked ? colors.secondary : colors.onSurface);
    final labelUpper = label.toUpperCase();

    Future<void> onTap() async {
      if (isLocked) {
        context.push('/pro');
        return;
      }

      // The microphone permission is requested only when the user explicitly
      // selects a microphone-based timer mode.
      //
      // Compliance notes:
      // - Not requested on app launch
      // - Not requested for non-microphone modes
      // - Denial keeps the feature unavailable without blocking the rest of the app
      if ((mode == _TimerMode.startAndMic ||
              mode == _TimerMode.startAndShots) &&
          _mode != mode) {
        // Check current OS permission status. On iOS, permission_handler is
        // known to return a transient wrong status right after `.request()`
        // (even when the user tapped "Allow"). We therefore only use
        // permission_handler's status to decide whether to show the system
        // prompt — we NEVER block the mode switch on its result.
        // If permission is truly denied, `NoiseMeter` will fail cleanly at
        // listening time and we'll stop the timer with an error snackbar.
        final status = await Permission.microphone.status;

        if (!status.isGranted && !status.isLimited) {
          // Show our explanation dialog before triggering the system prompt.
          final confirmed = await _showMicrophoneConfirmationDialog();
          if (!confirmed) return;

          // Fire the system permission prompt. We intentionally ignore the
          // returned status on iOS because it can be a transient lie.
          await Permission.microphone.request();
        }
      }

      if (!mounted) return;
      _timer?.cancel();
      _stopNoiseListening();
      _shotTimes.clear();
      _lastShotAt = null;
      _shotStopwatch
        ..stop()
        ..reset();
      setState(() {
        _mode = mode;
        _running = false;
        _finished = false;
        _actionStarted = false;
        _remaining = Duration.zero;
        _currentRepetition = 0;
      });
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 52,
      decoration: BoxDecoration(
        color: selected ? colors.primary : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: colors.brightness == Brightness.dark
            ? Border.all(color: Colors.transparent, width: 1.5)
            : Border.all(
                color: selected
                    ? colors.primary.withValues(alpha: 0.8)
                    : LightColors.surfaceHighlight,
                width: 1.5,
              ),
        boxShadow: AppShadows.cardPremium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showMic) ...[
                  Icon(Icons.mic_rounded, size: 16, color: micColor),
                  const Gap(6),
                ],
                Text(
                  labelUpper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.labelLarge?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                if (isLocked) ...[
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: LightColors.surfaceHighlight,
                        width: 1.35,
                      ),
                    ),
                    child: Text(
                      AppStrings.of(context).proBadge,
                      style: textStyles.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onPrimary,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecimalField({
    required String label,
    required double value,
    required void Function(double) onChanged,
    required ColorScheme colors,
    required TextTheme textStyles,
    String unitSuffix = '',
    double min = 0.1,
    double max = 9999.0,
  }) {
    const iconConstraints = BoxConstraints(minWidth: 36, minHeight: 36);
    return Row(
      children: [
        Expanded(child: Text(label, style: textStyles.bodyMedium)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => onChanged((value - 1.0).clamp(min, max)),
              icon: const Icon(Icons.remove_circle_outline_rounded),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
              iconSize: 22,
            ),
            SizedBox(
              width: 64,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DecimalField(
                      value: value,
                      onChanged: onChanged,
                      textStyles: textStyles,
                      min: min,
                      max: max,
                    ),
                    if (unitSuffix.isNotEmpty)
                      Text(
                        unitSuffix,
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () => onChanged((value + 1.0).clamp(min, max)),
              icon: const Icon(Icons.add_circle_outline_rounded),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
              iconSize: 22,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required void Function(int) onChanged,
    required ColorScheme colors,
    required TextTheme textStyles,
    String unitSuffix = '',
    int min = 0,
    int max = 9999,
  }) {
    void submitValue(String raw) {
      final parsed = int.tryParse(raw.trim());
      if (parsed == null) {
        return;
      }
      final clamped = parsed.clamp(min, max);
      onChanged(clamped);
    }

    const iconConstraints = BoxConstraints(minWidth: 36, minHeight: 36);

    return Row(
      children: [
        Expanded(child: Text(label, style: textStyles.bodyMedium)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => onChanged((value - 1).clamp(min, max)),
              icon: const Icon(Icons.remove_circle_outline_rounded),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
              iconSize: 22,
            ),
            SizedBox(
              width: 52,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 22,
                          maxWidth: 44,
                        ),
                        child: TextFormField(
                          key: ValueKey('$label-$value-$unitSuffix'),
                          initialValue: value.toString(),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: submitValue,
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                    ),
                    if (unitSuffix.isNotEmpty)
                      Text(
                        unitSuffix,
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () => onChanged((value + 1).clamp(min, max)),
              icon: const Icon(Icons.add_circle_outline_rounded),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
              iconSize: 22,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({
    required this.stats,
    required this.strings,
    required this.colors,
    required this.textStyles,
    required this.isDark,
    required this.formatDuration,
    required this.formatStdDev,
  });

  final _TimerStats stats;
  final AppStrings strings;
  final ColorScheme colors;
  final TextTheme textStyles;
  final bool isDark;
  final String Function(Duration) formatDuration;
  final String Function(Duration) formatStdDev;

  Widget _statRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyles.labelMedium?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Gap(AppSpacing.md),
        Text(
          value,
          style: textStyles.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.cardPremium,
        border: Border.all(
          color: isDark ? colors.outline : LightColors.surfaceHighlight,
          width: isDark ? 1.0 : 1.35,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statRow(
            strings.timerStatsTotalTime,
            formatDuration(stats.totalTime),
          ),
          const Gap(AppSpacing.sm),
          _statRow(
            strings.timerStatsFirstShot,
            formatDuration(stats.firstShot),
          ),
          const Gap(AppSpacing.sm),
          _statRow(
            strings.timerStatsSplitAverage,
            formatDuration(stats.splitAverage),
          ),
          const Gap(AppSpacing.sm),
          _statRow(strings.timerStatsSplitMin, formatDuration(stats.splitMin)),
          const Gap(AppSpacing.sm),
          _statRow(strings.timerStatsSplitMax, formatDuration(stats.splitMax)),
          const Gap(AppSpacing.sm),
          _statRow(strings.timerStatsStdDev, formatStdDev(stats.splitStdDev)),
          const Gap(AppSpacing.lg),
          _HitFactorPanel(totalTime: stats.totalTime, strings: strings),
        ],
      ),
    );
  }
}

class _HitFactorPanel extends StatefulWidget {
  const _HitFactorPanel({required this.totalTime, required this.strings});

  final Duration totalTime;
  final AppStrings strings;

  @override
  State<_HitFactorPanel> createState() => _HitFactorPanelState();
}

class _HitFactorPanelState extends State<_HitFactorPanel> {
  bool _expanded = false;
  bool _isMajor = false;

  int _a = 0;
  int _c = 0;
  int _d = 0;
  int _m = 0;
  int _ns = 0;

  double? _score;
  double? _hitFactor;

  InputDecoration _numberDecoration() {
    return const InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      border: OutlineInputBorder(),
    );
  }

  Widget _numberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(
          width: 72,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _numberDecoration(),
            onChanged: (raw) {
              final parsed = int.tryParse(raw.trim()) ?? 0;
              onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }

  void _compute() {
    final coefA = 5;
    final coefC = _isMajor ? 4 : 3;
    final coefD = _isMajor ? 2 : 1;

    final score =
        (_a * coefA) + (_c * coefC) + (_d * coefD) + (_m * -10) + (_ns * -10);

    final totalSeconds =
        widget.totalTime.inMicroseconds / Duration.microsecondsPerSecond;
    final hf = totalSeconds > 0
        ? (max(0, score.toDouble()) / totalSeconds)
        : 0.0;

    setState(() {
      _score = score.toDouble();
      _hitFactor = hf;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: Icon(
            _expanded ? Icons.expand_less_rounded : Icons.calculate_rounded,
          ),
          label: Text(widget.strings.hitFactorOpenButton),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                child: SizeTransition(
                  sizeFactor: curved,
                  axisAlignment: -1.0,
                  child: child,
                ),
              ),
            );
          },
          child: _expanded
              ? Container(
                  key: const ValueKey('hf-open'),
                  margin: const EdgeInsets.only(top: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.strings.hitFactorTitle,
                        style: textStyles.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      _numberField(
                        label: widget.strings.hitFactorZoneA,
                        value: _a,
                        onChanged: (v) => _a = v,
                      ),
                      const Gap(AppSpacing.sm),
                      _numberField(
                        label: widget.strings.hitFactorZoneC,
                        value: _c,
                        onChanged: (v) => _c = v,
                      ),
                      const Gap(AppSpacing.sm),
                      _numberField(
                        label: widget.strings.hitFactorZoneD,
                        value: _d,
                        onChanged: (v) => _d = v,
                      ),
                      const Gap(AppSpacing.sm),
                      _numberField(
                        label: widget.strings.hitFactorMike,
                        value: _m,
                        onChanged: (v) => _m = v,
                      ),
                      const Gap(AppSpacing.sm),
                      _numberField(
                        label: widget.strings.hitFactorNoShoot,
                        value: _ns,
                        onChanged: (v) => _ns = v,
                      ),
                      const Gap(AppSpacing.md),
                      Row(
                        children: [
                          Text(
                            _isMajor
                                ? widget.strings.hitFactorMajor
                                : widget.strings.hitFactorMinor,
                            style: textStyles.labelMedium?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment<bool>(
                                value: true,
                                label: Text(widget.strings.hitFactorMajor),
                              ),
                              ButtonSegment<bool>(
                                value: false,
                                label: Text(widget.strings.hitFactorMinor),
                              ),
                            ],
                            selected: {_isMajor},
                            onSelectionChanged: (sel) {
                              setState(() {
                                _isMajor = sel.first;
                              });
                            },
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      FilledButton(
                        onPressed: _compute,
                        child: Text(widget.strings.hitFactorCompute),
                      ),
                      if (_score != null && _hitFactor != null) ...[
                        const Gap(AppSpacing.md),
                        Text(
                          '${widget.strings.hitFactorScoreLabel} : ${_score!.toStringAsFixed(0)}',
                          style: textStyles.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        Text(
                          '${widget.strings.hitFactorResultLabel} : ${_hitFactor!.toStringAsFixed(4)}',
                          style: textStyles.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('hf-closed')),
        ),
      ],
    );
  }
}

class _DecimalField extends StatefulWidget {
  final double value;
  final void Function(double) onChanged;
  final TextTheme textStyles;
  final double min;
  final double max;

  const _DecimalField({
    required this.value,
    required this.onChanged,
    required this.textStyles,
    this.min = 0.1,
    this.max = 9999.0,
  });

  @override
  State<_DecimalField> createState() => _DecimalFieldState();
}

class _DecimalFieldState extends State<_DecimalField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  static String _toDisplay(double v) {
    final ms = (v * 1000).round();
    if (ms % 1000 == 0) return (ms ~/ 1000).toString();
    if (ms % 100 == 0) return (ms / 1000).toStringAsFixed(1);
    return (ms / 1000).toStringAsFixed(2);
  }

  void _submit() {
    final raw = _ctrl.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(raw);
    if (parsed == null) {
      _ctrl.text = _toDisplay(widget.value);
      return;
    }
    final clamped = parsed.clamp(widget.min, widget.max);
    widget.onChanged(clamped);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _toDisplay(widget.value));
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) _submit();
    });
  }

  @override
  void didUpdateWidget(_DecimalField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = _toDisplay(widget.value);
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 22, maxWidth: 54),
        child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: widget.textStyles.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _submit(),
          onTapOutside: Platform.isAndroid ? (_) => _focus.unfocus() : null,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 20),
        const Gap(AppSpacing.sm),
        Text(
          title.toUpperCase(),
          style: textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: colors.onSurface.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}
