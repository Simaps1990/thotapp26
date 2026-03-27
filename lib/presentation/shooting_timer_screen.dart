import 'dart:async';
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

/// Simple shooting timer panel displayed as a bottom sheet, similar to DiagnosticScreen.
class ShootingTimerScreen extends StatefulWidget {
  const ShootingTimerScreen({Key? key}) : super(key: key);

  @override
  State<ShootingTimerScreen> createState() => _ShootingTimerScreenState();
}

enum _TimerMode { simple, parTime, repeat, randomDelay, startAndMic, startAndShots }

class _ShootingTimerScreenState extends State<ShootingTimerScreen> {
  _TimerMode _mode = _TimerMode.simple;
  static const Duration _beepLead = Duration(milliseconds: 300);
  Duration _startDelay = const Duration(seconds: 3);
  Duration _parTime = const Duration(seconds: 5);
  Duration _cycleDuration = const Duration(seconds: 5);
  Duration _randomBase = const Duration(seconds: 3);
  int _repetitions = 1;
  int _currentRepetition = 0;

  bool _showRunPanel = false;

  bool _actionStarted = false;

  final Stopwatch _shotStopwatch = Stopwatch();
  final List<Duration> _shotTimes = [];
  DateTime? _lastShotAt;

  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  int _dbSensitivityLevel = 2; // 0..4 from coarse to very fine

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool _settingsExpanded = false;

  // Visual feedback when the timer fires (sound / vibration event)
  bool _flashHighlight = false;

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _running = false;
  bool _finished = false;
  bool _paused = false;

  bool _zeroBeepFired = false;

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
    _prepareFeedbackCapabilities();
  }

  Duration _currentDisplayDuration() {
    // Avant le démarrage du timer, on affiche toujours la valeur configurée.
    if (!_running && !_finished && !_paused) {
      switch (_mode) {
        case _TimerMode.simple:
        case _TimerMode.randomDelay:
        case _TimerMode.startAndMic:
        case _TimerMode.startAndShots:
          return _startDelay;
        case _TimerMode.parTime:
          // L'utilisateur voit le délai avant départ.
          return _startDelay;
        case _TimerMode.repeat:
          // Pour les répétitions, on affiche aussi le délai avant départ.
          return _startDelay;
      }
    }

    // Modes "réaction au bip" (startAndMic) et "chaque coup compte" (startAndShots) :
    // - avant le bip: _remaining sert de compte à rebours descendant
    // - après le bip (_actionStarted = true): le grand compteur affiche le temps
    //   montant du Stopwatch.
    if ((_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) &&
        _actionStarted) {
      final elapsed = _shotStopwatch.elapsed;
      return elapsed < Duration.zero ? Duration.zero : elapsed;
    }

    if (_mode == _TimerMode.parTime) {
      // Pour le par time en cours de fonctionnement, on affiche :
      // - le délai initial en décompte descendant
      // - puis la fenêtre de tir en compteur montant.
      final total = _startDelay + _parTime;
      final rawElapsed = total - _remaining;
      final elapsed = rawElapsed < Duration.zero
          ? Duration.zero
          : (rawElapsed > total ? total : rawElapsed);
      if (elapsed < _startDelay) {
        // Toujours dans le délai initial : on montre le temps restant.
        return _startDelay - elapsed;
      } else {
        // Dans la fenêtre de tir : temps écoulé depuis le début de la fenêtre.
        final rawWindowElapsed = elapsed - _startDelay;
        final windowElapsed = rawWindowElapsed < Duration.zero
            ? Duration.zero
            : (rawWindowElapsed > _parTime ? _parTime : rawWindowElapsed);
        return windowElapsed;
      }
    }

    // Autres modes : on montre simplement le temps restant interne.
    return _remaining;
  }

  Future<void> _prepareFeedbackCapabilities() async {
    // Pre-warm sound so first beep is not delayed
    try {
      await TimerSound.warmUp();
    } catch (_) {}

    // If device has no vibrator, reflect that in the toggle state
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (mounted && !hasVibrator) {
        setState(() {
          _vibrationEnabled = false;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopNoiseListening();
    super.dispose();
  }

  double _dbThresholdForLevel(int level) {
    switch (level) {
      case 0:
        return 92.0; // very tolerant (needs loud shot)
      case 1:
        return 88.0;
      case 2:
        return 84.0;
      case 3:
        return 80.0;
      case 4:
      default:
        return 76.0; // very sensitive
    }
  }

  Future<void> _startNoiseListening() async {
    _stopNoiseListening();
    _noiseMeter ??= NoiseMeter();

    try {
      _noiseSubscription = _noiseMeter!.noise.listen(
        (NoiseReading reading) {
          if (!_running || !_actionStarted) {
            return;
          }

          if (_mode != _TimerMode.startAndMic && _mode != _TimerMode.startAndShots) {
            return;
          }

          final threshold = _dbThresholdForLevel(_dbSensitivityLevel);
          final db = reading.maxDecibel;
          if (db >= threshold) {
            if (_mode == _TimerMode.startAndMic) {
              _stopNoiseListening();
              _stopTimer();
              return;
            }

            final now = DateTime.now();
            final last = _lastShotAt;
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
                _shotTimes.add(elapsed);
              });
            }
          }
        },
        onError: (_) {
          _stopNoiseListening();
        },
        cancelOnError: true,
      );
    } catch (_) {
      _stopNoiseListening();
    }
  }

  void _stopNoiseListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _stopNoiseListening();
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
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        // Reaction to beep / Each shot counts: countdown start delay, then run stopwatch / accumulate shots
        if (_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) {
          if (!_actionStarted) {
            final next = _remaining - const Duration(milliseconds: 100);
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
              if (_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) {
                _shotStopwatch
                  ..reset()
                  ..start();
              }
              _startNoiseListening();
            } else {
              _remaining = next;
            }
            return;
          }

          // After the beep, for reaction/each-shot-counts we simply let the
          // stopwatch / shot list handle time; _remaining is not used.
          return;
        }

        // Par time: first countdown delay, then ascending window
        if (_mode == _TimerMode.parTime) {
          final next = _remaining - const Duration(milliseconds: 100);
          final total = _startDelay + _parTime;
          final previousRemaining = _remaining;
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            // We have reached the end of the par window: final event.
            _fireEvent(
              playSound: !_zeroBeepFired,
              vibrate: true,
              flash: true,
            );
            _zeroBeepFired = true;
            _running = false;
            _finished = true;
            return;
          }

          // Check transition from delay to shooting window
          final prevElapsed = total - previousRemaining;
          final newElapsed = total - next;
          final wasInDelay = prevElapsed < _startDelay;
          final nowInWindow = newElapsed >= _startDelay;
          _remaining = next;

          if (!_parWindowStarted && wasInDelay && nowInWindow) {
            _parWindowStarted = true;
            // Entering shooting window: beep + vibrate + flash/zoom
            _fireEvent(playSound: true, vibrate: true, flash: true);
          }
          return;
        }

        // Repeat: countdown startDelay once, then cycleDuration repeated N times
        if (_mode == _TimerMode.repeat) {
          final next = _remaining - const Duration(milliseconds: 100);
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            // Fin d'un compte à rebours (délai initial ou cycle)
            _fireEvent(
              playSound: !_zeroBeepFired,
              vibrate: true,
              flash: true,
            );
            _zeroBeepFired = true;

            if (_repeatInInitialDelay) {
              // On vient de finir le délai avant départ : entrer dans le
              // cycle de répétitions.
              _repeatInInitialDelay = false;
              _currentRepetition = 0;
              _remaining = _cycleDuration;
              _zeroBeepFired = false;
              return;
            }
            // On vient de terminer un cycle.
            if (_currentRepetition < _repetitions) {
              // Il reste des répétitions à effectuer : on relance un cycle.
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

        // Random delay mode :
        // 1) décompte de départ (_startDelay), à zéro : bip+vibration+flash
        // 2) décompte aléatoire entre 50% et 100% de _randomBase, à zéro :
        //    bip+vibration+flash puis arrêt complet.
        if (_mode == _TimerMode.randomDelay) {
          final next = _remaining - const Duration(milliseconds: 100);
          if (!_actionStarted) {
            // Phase 1 : décompte avant départ
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;
              _actionStarted = true;

              // Arrivée à zéro : bip + vibration + flash
              _fireEvent(
                playSound: !_zeroBeepFired,
                vibrate: true,
                flash: true,
              );
              _zeroBeepFired = true;

              // Phase 2 : démarrer le délai aléatoire entre 50% et 100% de _randomBase
              final baseMs = _randomBase.inMilliseconds;
              final minMs = (baseMs * 0.5).round();
              final maxMs = baseMs;
              final ms = minMs + Random().nextInt(max(1, maxMs - minMs));
              _remaining = Duration(milliseconds: ms);
              _zeroBeepFired = false;
            } else {
              _remaining = next;
            }
          } else {
            // Phase 2 : décompte aléatoire
            if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
              _zeroBeepFired = true;
              _fireLeadBeepOnly();
            }
            if (next <= Duration.zero) {
              _remaining = Duration.zero;

              // Fin du délai aléatoire : bip + vibration + flash puis stop
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

        // Simple mode: one countdown then event
        if (_mode == _TimerMode.simple) {
          final next = _remaining - const Duration(milliseconds: 100);
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            _fireEvent(
              playSound: !_zeroBeepFired,
              vibrate: true,
              flash: true,
            );
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

  Future<void> _fireEvent({required bool playSound, required bool vibrate, required bool flash}) async {
    // Feedback visuel immédiat.
    if (flash) {
      _triggerFlashHighlight();
    }

    // Son : bip court dédié au timer, basé sur Timercut.wav préchargé.
    if (playSound && _soundEnabled) {
      () async {
        try {
          await TimerSound.play();
        } catch (_) {}
      }();
    }

    // Vibration en tâche de fond.
    if (vibrate && _vibrationEnabled) {
      () async {
        try {
          final hasVibrator = await Vibration.hasVibrator() ?? false;
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
        // We represent par time as a single countdown from total duration
        return _startDelay + _parTime;
      case _TimerMode.repeat:
        // First phase is an initial delay before repetitions
        return _startDelay;
      case _TimerMode.randomDelay:
        // First phase: countdown before random delay
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
    setState(() {
      _running = false;
      _paused = false;
      _zeroBeepFired = false;
      if ((_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) && _actionStarted) {
        _finished = true;
      }
      _shotStopwatch.stop();
    });
  }

  void _pauseTimer() {
    if (!_running) return;
    _timer?.cancel();
    _stopNoiseListening();
    setState(() {
      _running = false;
      _paused = true;
      // On ne marque pas comme terminé : on fige l'état courant.
    });
    _shotStopwatch.stop();
  }

  void _resumeTimer() {
    if (_running || !_paused) return;

    setState(() {
      _running = true;
      _paused = false;
    });

    // Si on était en mode "réaction" et que l'action a démarré (après le bip),
    // on relance le stopwatch + l'écoute micro, mais on ne touche pas à _remaining.
    if ((_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) &&
        _actionStarted) {
      if (!_shotStopwatch.isRunning) {
        _shotStopwatch.start();
      }
      _startNoiseListening();
      return;
    }

    // Sinon: modes à décompte -> on reprend la périodique depuis _remaining.
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        if (_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) {
          if (!_actionStarted) {
            final next = _remaining - const Duration(milliseconds: 100);
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
              _shotStopwatch
                ..reset()
                ..start();
              _startNoiseListening();
            } else {
              _remaining = next;
            }
            return;
          }

          // After the beep, for reaction/each-shot-counts we simply let the
          // stopwatch / shot list handle time; _remaining is not used.
          return;
        }

        if (_mode == _TimerMode.parTime) {
          final next = _remaining - const Duration(milliseconds: 100);
          final total = _startDelay + _parTime;
          final previousRemaining = _remaining;
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            _fireEvent(
              playSound: !_zeroBeepFired,
              vibrate: true,
              flash: true,
            );
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
          final next = _remaining - const Duration(milliseconds: 100);
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
          final next = _remaining - const Duration(milliseconds: 100);
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
              final ms = minMs + Random().nextInt(max(1, maxMs - minMs));
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
          final next = _remaining - const Duration(milliseconds: 100);
          if (!_zeroBeepFired && next <= _beepLead && next > Duration.zero) {
            _zeroBeepFired = true;
            _fireLeadBeepOnly();
          }
          if (next <= Duration.zero) {
            _remaining = Duration.zero;
            t.cancel();
            _fireEvent(
              playSound: !_zeroBeepFired,
              vibrate: true,
              flash: true,
            );
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

  String _formatDuration(Duration d) {
    final totalSeconds = d.inMilliseconds / 1000.0;
    final seconds = totalSeconds.floor();
    final centis = ((totalSeconds - seconds) * 100).round().clamp(0, 99);
    final s = seconds.remainder(60).toString().padLeft(2, '0');
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final cs = centis.toString().padLeft(2, '0');
    return '$m:$s.$cs';
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
    final isPremium = provider.isPremium;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isPremium && _mode != _TimerMode.simple) {
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
        Text(
          strings.timerModesTitle,
          style: textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.secondary,
          ),
        ),
        const Gap(AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
              isLocked: !isPremium,
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeRepeat,
              mode: _TimerMode.repeat,
              isLocked: !isPremium,
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeRandomDelay,
              mode: _TimerMode.randomDelay,
              isLocked: !isPremium,
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeStartAndMic,
              mode: _TimerMode.startAndMic,
              isLocked: !isPremium,
              colors: colors,
              textStyles: textStyles,
            ),
            _buildModeChip(
              label: strings.timerModeStartAndShots,
              mode: _TimerMode.startAndShots,
              isLocked: !isPremium,
              colors: colors,
              textStyles: textStyles,
            ),
          ],
        ),
        const Gap(AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                _modeDescription(strings),
                style: textStyles.bodySmall?.copyWith(
                  color: colors.secondary,
                ),
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.xs),
        Text(
          _modeExample(strings),
          style: textStyles.bodySmall?.copyWith(
            color: colors.secondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) ...[
          const Gap(AppSpacing.xs),
          Text(
            strings.timerMicDisclaimerShort,
            style: textStyles.bodySmall?.copyWith(
              color: colors.secondary,
            ),
          ),
        ],
        const Gap(AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? null
                : Border.all(
                    color: LightColors.surfaceHighlight,
                    width: 1.35,
                  ),
            boxShadow: AppShadows.cardPremium,
          ),
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.timerSettingsTitle,
                style: textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const Gap(AppSpacing.md),
              _buildNumberField(
                label: strings.timerStartDelayLabel,
                value: _startDelay.inSeconds,
                unitSuffix: ' s',
                onChanged: (v) {
                  setState(() => _startDelay = Duration(seconds: v));
                },
                colors: colors,
                textStyles: textStyles,
              ),
              if (_mode == _TimerMode.parTime) ...[
                const Gap(AppSpacing.sm),
                _buildNumberField(
                  label: strings.timerParTimeLabel,
                  value: _parTime.inSeconds,
                  unitSuffix: ' s',
                  onChanged: (v) {
                    setState(() => _parTime = Duration(seconds: v));
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
              ],
              if (_mode == _TimerMode.repeat) ...[
                const Gap(AppSpacing.sm),
                _buildNumberField(
                  label: strings.timerCycleDurationLabel,
                  value: _cycleDuration.inSeconds,
                  unitSuffix: ' s',
                  onChanged: (v) {
                    setState(() => _cycleDuration = Duration(seconds: v));
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
                const Gap(AppSpacing.sm),
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
                const Gap(AppSpacing.sm),
                _buildNumberField(
                  label: strings.timerRandomBaseLabel,
                  value: _randomBase.inSeconds,
                  unitSuffix: ' s',
                  onChanged: (v) {
                    setState(() => _randomBase = Duration(seconds: v));
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
              ],
              if (_mode == _TimerMode.startAndMic || _mode == _TimerMode.startAndShots) ...[
                const Gap(AppSpacing.md),
                Text(
                  strings.timerShotSensitivityLabel,
                  style: textStyles.bodySmall,
                ),
                Slider(
                  value: _dbSensitivityLevel.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: _dbSensitivityLevel.toString(),
                  onChanged: (v) => setState(() => _dbSensitivityLevel = v.round()),
                ),
                Text(
                  strings.timerSensitivityHint,
                  style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                ),
              ],
              const Gap(AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.timerEnableSound),
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.timerEnableVibration),
                value: _vibrationEnabled,
                onChanged: (v) => setState(() => _vibrationEnabled = v),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.lg),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: () {
              _resetTimer();
              setState(() {
                _showRunPanel = true;
              });
            },
            child: Text(strings.validate),
          ),
        ),
      ],
    );

    final runPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Transform.translate(
          offset: const Offset(0, 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.cardPremium,
                ),
                child: FilledButton.icon(
                  onPressed: _running
                      ? null
                      : () {
                          _resetTimer();
                          setState(() {
                            _showRunPanel = false;
                          });
                        },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                  ),
                  label: Text(
                    strings.previous,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.primary,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(0),
        Center(
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(0, 25),
                child: SizedBox(
                  height: 130,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      style: (textStyles.displayLarge ?? const TextStyle())
                          .copyWith(
                        fontWeight: FontWeight.w900,
                        color: _flashHighlight ? colors.error : colors.onSurface,
                        fontSize: (textStyles.displayLarge?.fontSize ?? 48) * 2.2,
                      ),
                      child: Text(_formatDuration(_currentDisplayDuration())),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(AppSpacing.lg),
        Transform.translate(
          offset: const Offset(-45, 20),
          child: Center(
            child: SizedBox(
              width: 232,
              height: 232,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                scale: _flashHighlight
                    ? 1.03
                    : (_running ? 0.98 : 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_paused ? const Color(0xFFF59E0B) : Colors.green)
                                .withValues(alpha: _running ? 0.12 : 0.18),
                        blurRadius: _running ? 10 : 14,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        spreadRadius: 0,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            if (_paused) ...[
                              const Color(0xFFFDE68A),
                              const Color(0xFFF59E0B),
                              const Color(0xFFD97706),
                            ] else ...[
                              const Color(0xFF5BE07B),
                              const Color(0xFF22C55E),
                              const Color(0xFF16A34A),
                            ],
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.26),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: _running
                            ? _pauseTimer
                            : (_paused ? _resumeTimer : _startTimer),
                        child: Center(
                          child: Text(
                            _running
                                ? strings.timerPauseButton
                                : (_paused
                                    ? strings.timerResumeButton
                                    : strings.timerStartButton.toUpperCase()),
                            style: textStyles.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.2,
                              color: Colors.white,
                              fontSize: _paused
                                  ? (textStyles.displaySmall?.fontSize ?? 24) * 0.82
                                  : textStyles.displaySmall?.fontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(0),
        Transform.translate(
          offset: const Offset(-15, -20),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 100,
              width: 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3A3A3A),
                      Color(0xFF1F1F1F),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _resetTimer,
                    customBorder: const CircleBorder(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          : Border(
                              top: BorderSide(
                                color: colors.outline,
                              ),
                            ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${i + 1}',
                          style: textStyles.bodySmall?.copyWith(color: colors.secondary),
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
        ],
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // Ouvre la fenêtre plus haut dans l'écran en mode déployé
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSpacing.md),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.timerToolTitle,
                    style: textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.timerToolSubtitle,
                style: textStyles.bodySmall?.copyWith(
                  color: colors.secondary,
                ),
              ),
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
                  padding: _showRunPanel
                      ? const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        )
                      : const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                  child: _showRunPanel ? runPanel : configPanel,
                ),
              ),
            ),
          ),
        ],
      ),
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
    final showMic = mode == _TimerMode.startAndMic || mode == _TimerMode.startAndShots;
    final micColor = selected ? colors.onPrimary : colors.primary;
    return ChoiceChip(
      label: isLocked
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showMic) ...[
                  Icon(
                    Icons.mic_rounded,
                    size: 16,
                    color: micColor,
                  ),
                  const Gap(6),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            )
          : (showMic
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mic_rounded,
                      size: 16,
                      color: micColor,
                    ),
                    const Gap(6),
                    Text(label),
                  ],
                )
              : Text(label)),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) async {
        if (isLocked) {
          context.push('/pro');
          return;
        }
        if ((mode == _TimerMode.startAndMic || mode == _TimerMode.startAndShots) && _mode != mode) {
          final status = await Permission.microphone.request();
          if (!status.isGranted) {
            if (mounted) {
              final strings = AppStrings.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.timerMicPermissionDenied)),
              );
            }
            return;
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
      },
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      labelStyle: textStyles.bodySmall?.copyWith(
        color: selected
            ? colors.onPrimary
            : (isLocked ? colors.secondary : colors.onSurface),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: selected ? colors.primary : colors.outline,
          width: 1.2,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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

    const iconConstraints = BoxConstraints(
      minWidth: 36,
      minHeight: 36,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyles.bodyMedium,
          ),
        ),
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
              width: 74,
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
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: textStyles.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                        style: textStyles.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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
