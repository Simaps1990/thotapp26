import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:vibration/vibration.dart';

import 'package:thot/theme.dart';
import 'package:thot/utils/timer_sound.dart';
import 'package:thot/l10n/app_strings.dart';

// ─── Couleurs disponibles ─────────────────────────────────────────────────────

class _PodColor {
  final String id;
  final Color color;
  const _PodColor({required this.id, required this.color});
}

const _kColors = <_PodColor>[
  _PodColor(id: 'red',    color: Color(0xFFE53935)),
  _PodColor(id: 'blue',   color: Color(0xFF1E88E5)),
  _PodColor(id: 'green',  color: Color(0xFF43A047)),
  _PodColor(id: 'yellow', color: Color(0xFFFDD835)),
  _PodColor(id: 'orange', color: Color(0xFFFB8C00)),
  _PodColor(id: 'purple', color: Color(0xFF8E24AA)),
  _PodColor(id: 'white',  color: Color(0xFFF5F5F5)),
];

// ─── Formes disponibles ───────────────────────────────────────────────────────

class _PodShape {
  final String id;
  final IconData icon;
  const _PodShape({required this.id, required this.icon});
}

const _kShapes = <_PodShape>[
  _PodShape(id: 'circle',   icon: Icons.circle),
  _PodShape(id: 'square',   icon: Icons.square),
  _PodShape(id: 'triangle', icon: Icons.change_history),
  _PodShape(id: 'star',     icon: Icons.star),
  _PodShape(id: 'diamond',  icon: Icons.diamond),
];

// ─── Lettres et chiffres ──────────────────────────────────────────────────────

const _kLetters = [
  'A','B','C','D','E','F','G','H','I','J','K','L','M',
  'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
];

const _kDigits = ['0','1','2','3','4','5','6','7','8','9'];

enum _Phase { config, countdown, running, stats }

// ─── Écran principal ──────────────────────────────────────────────────────────

class ColorPodScreen extends StatefulWidget {
  final bool embedded;
  const ColorPodScreen({Key? key, this.embedded = false}) : super(key: key);

  @override
  State<ColorPodScreen> createState() => _ColorPodScreenState();
}

class _ColorPodScreenState extends State<ColorPodScreen> {

  // ── Config ───────────────────────────────────────────────────────────────────
  final Set<String> _selected = {'red', 'blue', 'green', 'yellow'};
  final Set<String> _selectedShapes = {};
  final Set<String> _selectedLetters = {};
  final Set<String> _selectedDigits = {};
  double _colorDuration = 2.0;
  double _colorDelay    = 1.0;
  double _totalDuration = 30.0;

  // ── Runtime ──────────────────────────────────────────────────────────────────
  _Phase _phase = _Phase.config;
  int _countdown = 3;
  Timer? _timer;
  Timer? _delayTimer;
  Stopwatch? _stopwatch;
  int _runToken = 0;
  Color? _currentColor;
  String? _currentColorId;
  String? _currentShape;
  String? _currentLetter;
  String? _currentDigit;
  int _digitCorner = 0;
  int _letterCorner = 1;
  int _remainingMs = 0;
  final Map<String, int> _counts = {};
  final Map<String, int> _shapeCounts = {};
  final Map<String, int> _letterCounts = {};
  final Map<String, int> _digitCounts = {};

  // ── Helpers ──────────────────────────────────────────────────────────────────

  List<_PodColor> get _available =>
      _kColors.where((c) => _selected.contains(c.id)).toList();

  Color _contrastColor(Color bg) =>
      bg.computeLuminance() > 0.4 ? Colors.black : Colors.white;

  String _colorLabel(AppStrings s, String id) {
    switch (id) {
      case 'red':    return s.colorPodRed;
      case 'blue':   return s.colorPodBlue;
      case 'green':  return s.colorPodGreen;
      case 'yellow': return s.colorPodYellow;
      case 'orange': return s.colorPodOrange;
      case 'purple': return s.colorPodPurple;
      case 'white':  return s.colorPodWhite;
      case 'black':  return s.colorPodBlack;
      default:       return id;
    }
  }

  String _shapeLabel(AppStrings s, String id) {
    switch (id) {
      case 'circle':   return s.colorPodShapeCircle;
      case 'square':   return s.colorPodShapeSquare;
      case 'triangle': return s.colorPodShapeTriangle;
      case 'star':     return s.colorPodShapeStar;
      case 'diamond':  return s.colorPodShapeDiamond;
      default:         return id;
    }
  }

  IconData _shapeIcon(String id) {
    switch (id) {
      case 'circle':   return Icons.circle;
      case 'square':   return Icons.square;
      case 'triangle': return Icons.change_history;
      case 'star':     return Icons.star;
      case 'diamond':  return Icons.diamond;
      default:         return Icons.circle;
    }
  }

  // ── Logique ──────────────────────────────────────────────────────────────────

  void _start() {
    if (_selected.isEmpty) return;
    _counts.clear();
    _shapeCounts.clear();
    _letterCounts.clear();
    _digitCounts.clear();
    for (final c in _kColors) _counts[c.id] = 0;
    for (final s in _kShapes) _shapeCounts[s.id] = 0;
    for (final l in _kLetters) _letterCounts[l] = 0;
    for (final d in _kDigits) _digitCounts[d] = 0;
    setState(() { _phase = _Phase.countdown; _countdown = 3; });
    _runCountdown();
  }

  void _runCountdown() {
    _timer?.cancel();
    _delayTimer?.cancel();
    _stopwatch?.stop();
    _stopwatch = null;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
        try { await TimerSound.play(); } catch (_) {}
        try {
          final ok = await Vibration.hasVibrator() ?? false;
          if (ok) Vibration.vibrate(duration: 300);
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        setState(() {
          _phase = _Phase.running;
          _remainingMs = (_totalDuration * 1000).round();
          _currentColor = null;
          _currentColorId = null;
          _currentShape = null;
          _currentLetter = null;
          _currentDigit = null;
        });
        _startRun();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _startRun() {
    _timer?.cancel();
    _delayTimer?.cancel();
    final totalMs = (_totalDuration * 1000).round();
    _stopwatch = Stopwatch()..start();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_phase != _Phase.running) { t.cancel(); return; }
      final elapsed = _stopwatch?.elapsedMilliseconds ?? 0;
      final remaining = (totalMs - elapsed).clamp(0, totalMs);
      if (remaining != _remainingMs) {
        setState(() => _remainingMs = remaining);
      }
      if (remaining <= 0) {
        t.cancel();
        _finish();
      }
    });

    final token = ++_runToken;
    _runColorLoop(token);
  }

  Future<void> _runColorLoop(int token) async {
    final rng = Random();
    while (mounted && _phase == _Phase.running && token == _runToken) {
      if (_remainingMs <= 0) return;

      final list = _available;
      if (list.isEmpty) { _finish(); return; }

      final picked = list[rng.nextInt(list.length)];

      String? shape;
      if (_selectedShapes.isNotEmpty) {
        final shapeList = _selectedShapes.toList();
        shape = shapeList[rng.nextInt(shapeList.length)];
      }

      String? letter;
      if (_selectedLetters.isNotEmpty) {
        final letterList = _selectedLetters.toList();
        letter = letterList[rng.nextInt(letterList.length)];
      }

      String? digit;
      if (_selectedDigits.isNotEmpty) {
        final digitList = _selectedDigits.toList();
        digit = digitList[rng.nextInt(digitList.length)];
      }

      final corners = [0, 1, 2, 3]..shuffle(rng);

      setState(() {
        _currentColor = picked.color;
        _currentColorId = picked.id;
        _currentShape = shape;
        _currentLetter = letter;
        _currentDigit = digit;
        _digitCorner = corners[0];
        _letterCorner = corners[1];
        _counts[picked.id] = (_counts[picked.id] ?? 0) + 1;
        if (shape != null) _shapeCounts[shape] = (_shapeCounts[shape] ?? 0) + 1;
        if (letter != null) _letterCounts[letter] = (_letterCounts[letter] ?? 0) + 1;
        if (digit != null) _digitCounts[digit] = (_digitCounts[digit] ?? 0) + 1;
      });

      final displayMs = (_colorDuration * 1000).round();
      final delayMs = (_colorDelay * 1000).round();

      await Future.delayed(Duration(milliseconds: displayMs));
      if (!mounted || _phase != _Phase.running || token != _runToken) return;
      if (_remainingMs <= 0) return;

      setState(() {
        _currentColor = null;
        _currentColorId = null;
        _currentShape = null;
        _currentLetter = null;
        _currentDigit = null;
      });

      await Future.delayed(Duration(milliseconds: delayMs));
    }
  }

  void _finish() async {
    _timer?.cancel();
    _delayTimer?.cancel();
    _stopwatch?.stop();
    try { await TimerSound.play(); } catch (_) {}
    try {
      final ok = await Vibration.hasVibrator() ?? false;
      if (ok) Vibration.vibrate(duration: 800);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _phase = _Phase.stats;
      _currentColor = null;
      _currentShape = null;
      _currentLetter = null;
      _currentDigit = null;
    });
  }

  void _reset() {
    _timer?.cancel();
    _delayTimer?.cancel();
    _stopwatch?.stop();
    _stopwatch = null;
    _runToken++;
    setState(() {
      _phase = _Phase.config;
      _currentColor = null;
      _currentColorId = null;
      _currentShape = null;
      _currentLetter = null;
      _currentDigit = null;
      _countdown = 3;
      _remainingMs = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _delayTimer?.cancel();
    _stopwatch?.stop();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool landscape =
        _phase == _Phase.countdown || _phase == _Phase.running;
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    Color bgColor;
    if (_phase == _Phase.running) {
      bgColor = _currentColor ?? Colors.black;
    } else if (_phase == _Phase.countdown) {
      bgColor = Colors.black;
    } else {
      bgColor = baseBackground;
    }

    Widget body;
    switch (_phase) {
      case _Phase.config:    body = _buildConfig();    break;
      case _Phase.countdown: body = _buildCountdown(); break;
      case _Phase.running:   body = _buildRunning();   break;
      case _Phase.stats:     body = _buildStats();     break;
    }

    final content = landscape
        ? _LandscapeWrapper(color: bgColor, child: body)
        : body;

    if (widget.embedded) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        color: landscape ? Colors.transparent : bgColor,
        child: content,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: landscape ? Colors.transparent : bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }

  // ── Config ────────────────────────────────────────────────────────────────────

  Widget _buildConfig() {
    final colors  = Theme.of(context).colorScheme;
    final texts   = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    Widget sectionLabel(String title) => Text(
      title,
      style: texts.labelLarge?.copyWith(
        fontWeight: FontWeight.w800, color: colors.secondary),
    );

    Widget toggleGrid({required List<Widget> children}) =>
        Wrap(spacing: 6, runSpacing: 6, children: children);

    return Column(children: [
      const Gap(10),
      Container(
        width: 42, height: 5,
        decoration: BoxDecoration(
          color: colors.outline.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      const Gap(12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(children: [
          Expanded(child: Text(strings.colorPodToolTitle,
            style: texts.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Align(alignment: Alignment.centerLeft,
          child: Text(strings.colorPodToolSubtitle,
            style: texts.bodySmall?.copyWith(color: colors.secondary))),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Divider(color: colors.outline),
      ),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // ── COULEURS ─────────────────────────────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            sectionLabel(strings.colorPodColors),
            Row(children: [
              TextButton(
                onPressed: () => setState(
                  () => _selected.addAll(_kColors.map((c) => c.id))),
                child: Text(strings.colorPodActivateAll,
                  style: texts.labelSmall?.copyWith(color: colors.primary))),
              TextButton(
                onPressed: () => setState(() => _selected.clear()),
                child: Text(strings.colorPodDeactivateAll,
                  style: texts.labelSmall?.copyWith(color: colors.secondary))),
            ]),
          ]),
          const Gap(AppSpacing.sm),
          Wrap(spacing: 8, runSpacing: 8, children: _kColors.map((c) {
            final sel = _selected.contains(c.id);
            final isWhite = c.id == 'white';
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selected.remove(c.id); else _selected.add(c.id);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: c.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? colors.primary
                        : (isWhite ? colors.outline : Colors.transparent),
                    width: sel ? 3 : 1,
                  ),
                  boxShadow: sel
                      ? [BoxShadow(
                          color: colors.primary.withValues(alpha: 0.4),
                          blurRadius: 8)]
                      : null,
                ),
                child: sel
                    ? Icon(Icons.check_rounded,
                        color: (c.id == 'white' || c.id == 'yellow')
                            ? Colors.black
                            : Colors.white,
                        size: 24)
                    : null,
              ),
            );
          }).toList()),
          const Gap(AppSpacing.lg),

          // ── FORMES ───────────────────────────────────────────────────────────
          sectionLabel(strings.colorPodShapes),
          const Gap(AppSpacing.sm),
          toggleGrid(children: _kShapes.map((s) {
            final sel = _selectedShapes.contains(s.id);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selectedShapes.remove(s.id);
                else _selectedShapes.add(s.id);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: sel
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? colors.primary : colors.outline,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Icon(s.icon,
                  color: sel ? colors.primary : colors.secondary,
                  size: 28),
              ),
            );
          }).toList()),
          const Gap(AppSpacing.lg),

          // ── LETTRES ──────────────────────────────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            sectionLabel(strings.colorPodLetters),
            Row(children: [
              TextButton(
                onPressed: () => setState(
                  () => _selectedLetters.addAll(_kLetters)),
                child: Text(strings.colorPodActivateAll,
                  style: texts.labelSmall?.copyWith(color: colors.primary))),
              TextButton(
                onPressed: () => setState(() => _selectedLetters.clear()),
                child: Text(strings.colorPodDeactivateAll,
                  style: texts.labelSmall?.copyWith(color: colors.secondary))),
            ]),
          ]),
          const Gap(AppSpacing.sm),
          toggleGrid(children: _kLetters.map((l) {
            final sel = _selectedLetters.contains(l);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selectedLetters.remove(l);
                else _selectedLetters.add(l);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: sel
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: sel ? colors.primary : colors.outline,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(l,
                    style: texts.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: sel ? colors.primary : colors.secondary)),
                ),
              ),
            );
          }).toList()),
          const Gap(AppSpacing.lg),

          // ── CHIFFRES ─────────────────────────────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            sectionLabel(strings.colorPodDigits),
            Row(children: [
              TextButton(
                onPressed: () => setState(
                  () => _selectedDigits.addAll(_kDigits)),
                child: Text(strings.colorPodActivateAll,
                  style: texts.labelSmall?.copyWith(color: colors.primary))),
              TextButton(
                onPressed: () => setState(() => _selectedDigits.clear()),
                child: Text(strings.colorPodDeactivateAll,
                  style: texts.labelSmall?.copyWith(color: colors.secondary))),
            ]),
          ]),
          const Gap(AppSpacing.sm),
          toggleGrid(children: _kDigits.map((d) {
            final sel = _selectedDigits.contains(d);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selectedDigits.remove(d);
                else _selectedDigits.add(d);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: sel
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: sel ? colors.primary : colors.outline,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(d,
                    style: texts.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: sel ? colors.primary : colors.secondary)),
                ),
              ),
            );
          }).toList()),
          const Gap(AppSpacing.lg),

          // ── Sliders ──────────────────────────────────────────────────────────
          _SliderField(
            label: strings.colorPodColorDuration,
            value: _colorDuration,
            min: 0.5, max: 10.0, divisions: 19, unit: 's',
            onChanged: (v) => setState(() => _colorDuration = v),
            colors: colors, texts: texts,
          ),
          const Gap(AppSpacing.md),
          _SliderField(
            label: strings.colorPodDelay,
            value: _colorDelay,
            min: 0.0, max: 5.0, divisions: 20, unit: 's',
            onChanged: (v) => setState(() => _colorDelay = v),
            colors: colors, texts: texts,
          ),
          const Gap(AppSpacing.md),
          _SliderField(
            label: strings.colorPodTotalDuration,
            value: _totalDuration,
            min: 10.0, max: 300.0, divisions: 29, unit: 's',
            onChanged: (v) => setState(() => _totalDuration = v),
            colors: colors, texts: texts,
          ),
          const Gap(AppSpacing.xl),

          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _selected.isEmpty ? null : _start,
              child: Text(strings.colorPodLaunch),
            ),
          ),
        ]),
      )),
    ]);
  }

  // ── Countdown ─────────────────────────────────────────────────────────────────

  Widget _buildCountdown() {
    final strings = AppStrings.of(context);
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _countdown > 0 ? '$_countdown' : 'GO !',
          style: TextStyle(
            fontSize: _countdown > 0 ? 160 : 120,
            fontWeight: FontWeight.w900,
            color: _countdown > 0 ? Colors.white : Colors.greenAccent,
            letterSpacing: -4,
          ),
        ),
        if (_countdown > 0) ...[
          const Gap(16),
          Text(strings.colorPodPrepare,
            style: const TextStyle(
              fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600)),
        ],
      ],
    ));
  }

  // ── Running ───────────────────────────────────────────────────────────────────

  Widget _buildRunning() {
    final strings  = AppStrings.of(context);
    final totalMs  = (_totalDuration * 1000).round();
    final elapsed  = totalMs - _remainingMs;
    final progress = (elapsed / totalMs).clamp(0.0, 1.0);
    final remainSec = (_remainingMs / 1000).ceil();
    final isBlack  = _currentColor == null;
    final textColor = isBlack ? Colors.white : _contrastColor(_currentColor!);

    return Stack(children: [
      // Large shape in center
      if (_currentShape != null)
        Center(
          child: Icon(
            _shapeIcon(_currentShape!),
            size: 220,
            color: textColor.withValues(alpha: 0.70),
          ),
        ),

      // Timer display
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$remainSec',
          style: TextStyle(
            fontSize: 80, fontWeight: FontWeight.w900,
            color: textColor.withValues(alpha: 0.90))),
        Text(strings.colorPodSecondsLeft,
          style: TextStyle(
            fontSize: 14, color: textColor.withValues(alpha: 0.60),
            fontWeight: FontWeight.w600)),
      ])),

      // Digit in corner
      if (_currentDigit != null)
        _cornerWidget(_digitCorner,
          Text(_currentDigit!,
            style: TextStyle(
              fontSize: 64, fontWeight: FontWeight.w900,
              color: textColor.withValues(alpha: 0.95)))),

      // Letter in another corner
      if (_currentLetter != null)
        _cornerWidget(_letterCorner,
          Text(_currentLetter!,
            style: TextStyle(
              fontSize: 64, fontWeight: FontWeight.w900,
              color: textColor.withValues(alpha: 0.95)))),

      // Progress bar
      Positioned(left: 0, right: 0, bottom: 0,
        child: LinearProgressIndicator(
          value: progress, minHeight: 6,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          color: isBlack ? Colors.white : textColor,
        )),

      // Stop button
      Positioned(top: 48, right: 20,
        child: SafeArea(child: TextButton(
          onPressed: _finish,
          child: Text(strings.colorPodStop,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w900, fontSize: 14)),
        ))),
    ]);
  }

  Widget _cornerWidget(int corner, Widget child) {
    const double offset = 36.0;
    return Positioned(
      top:    (corner == 0 || corner == 1) ? offset : null,
      bottom: (corner == 2 || corner == 3) ? offset : null,
      left:   (corner == 0 || corner == 2) ? offset : null,
      right:  (corner == 1 || corner == 3) ? offset : null,
      child: child,
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    final colors  = Theme.of(context).colorScheme;
    final texts   = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final totalColors    = _counts.values.fold(0, (a, b) => a + b);
    final appearedColors  = _kColors.where((c) => (_counts[c.id] ?? 0) > 0).toList();
    final appearedShapes  = _kShapes.where((s) => (_shapeCounts[s.id] ?? 0) > 0).toList();
    final appearedLetters = _kLetters.where((l) => (_letterCounts[l] ?? 0) > 0).toList();
    final appearedDigits  = _kDigits.where((d) => (_digitCounts[d] ?? 0) > 0).toList();

    Widget statCard(String title, List<Widget> rows) {
      if (rows.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title, style: texts.labelLarge?.copyWith(
              fontWeight: FontWeight.w800, color: colors.secondary)),
            const Gap(AppSpacing.md),
            ...rows,
          ]),
        ),
      );
    }

    return Column(children: [
      const Gap(10),
      Container(width: 42, height: 5,
        decoration: BoxDecoration(
          color: colors.outline.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(999))),
      const Gap(12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(strings.colorPodResults,
          style: texts.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Divider(color: colors.outline),
      ),
      Expanded(child: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

          // Colors card
          statCard(strings.colorPodColors, appearedColors.map((c) {
            final count = _counts[c.id] ?? 0;
            final pct = totalColors == 0 ? 0.0 : count / totalColors;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: c.color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.outline),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_colorLabel(strings, c.id),
                          style: texts.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700)),
                        Text('$count × (${(pct * 100).toStringAsFixed(0)}%)',
                          style: texts.bodySmall?.copyWith(
                            color: colors.secondary)),
                      ]),
                    const Gap(4),
                    LinearProgressIndicator(
                      value: pct,
                      backgroundColor: colors.outline.withValues(alpha: 0.2),
                      color: c.id == 'white' ? colors.secondary : c.color,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ])),
              ]),
            );
          }).toList()),

          // Shapes card
          if (appearedShapes.isNotEmpty)
            statCard(strings.colorPodShapes, appearedShapes.map((s) {
              final count = _shapeCounts[s.id] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(s.icon, size: 20, color: colors.primary),
                      const Gap(8),
                      Text(_shapeLabel(strings, s.id),
                        style: texts.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                    ]),
                    Text('$count ×',
                      style: texts.bodySmall?.copyWith(color: colors.secondary)),
                  ],
                ),
              );
            }).toList()),

          // Letters card
          if (appearedLetters.isNotEmpty)
            statCard(strings.colorPodLetters, [
              Wrap(spacing: 8, runSpacing: 8,
                children: appearedLetters.map((l) {
                  final count = _letterCounts[l] ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(children: [
                      Text(l, style: texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900, color: colors.primary)),
                      Text('×$count',
                        style: texts.labelSmall?.copyWith(color: colors.secondary)),
                    ]),
                  );
                }).toList()),
            ]),

          // Digits card
          if (appearedDigits.isNotEmpty)
            statCard(strings.colorPodDigits, [
              Wrap(spacing: 8, runSpacing: 8,
                children: appearedDigits.map((d) {
                  final count = _digitCounts[d] ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(children: [
                      Text(d, style: texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900, color: colors.primary)),
                      Text('×$count',
                        style: texts.labelSmall?.copyWith(color: colors.secondary)),
                    ]),
                  );
                }).toList()),
            ]),

          const Gap(AppSpacing.md),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: _reset,
              child: Text(strings.colorPodConfig),
            )),
            const Gap(AppSpacing.md),
            Expanded(child: FilledButton(
              onPressed: () {
                _counts.clear();
                _shapeCounts.clear();
                _letterCounts.clear();
                _digitCounts.clear();
                for (final c in _kColors) _counts[c.id] = 0;
                for (final s in _kShapes) _shapeCounts[s.id] = 0;
                for (final l in _kLetters) _letterCounts[l] = 0;
                for (final d in _kDigits) _digitCounts[d] = 0;
                setState(() {
                  _phase = _Phase.countdown;
                  _countdown = 3;
                  _remainingMs = (_totalDuration * 1000).round();
                  _currentColor = null;
                  _currentShape = null;
                  _currentLetter = null;
                  _currentDigit = null;
                });
                _runCountdown();
              },
              child: Text(strings.colorPodRestart),
            )),
          ]),
          const Gap(AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.handyman_outlined),
              label: Text(strings.navToolsLabel),
            ),
          ),
        ]),
      )),
    ]);
  }
}

// ─── Wrapper paysage ──────────────────────────────────────────────────────────

class _LandscapeWrapper extends StatefulWidget {
  final Color color;
  final Widget child;
  const _LandscapeWrapper({required this.color, required this.child});

  @override
  State<_LandscapeWrapper> createState() => _LandscapeWrapperState();
}

class _LandscapeWrapperState extends State<_LandscapeWrapper> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: widget.color,
    child: widget.child,
  );
}

// ─── Slider avec label et valeur ──────────────────────────────────────────────

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final ValueChanged<double> onChanged;
  final ColorScheme colors;
  final TextTheme texts;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
    required this.colors,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
          style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)} $unit',
            style: texts.labelLarge?.copyWith(
              fontWeight: FontWeight.w800, color: colors.primary)),
        ),
      ]),
      Slider(
        value: value, min: min, max: max, divisions: divisions,
        onChanged: onChanged,
        activeColor: colors.primary,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$min $unit',
          style: texts.labelSmall?.copyWith(color: colors.secondary)),
        Text('$max $unit',
          style: texts.labelSmall?.copyWith(color: colors.secondary)),
      ]),
    ]);
  }
}