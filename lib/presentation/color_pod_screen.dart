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
  int _remainingMs = 0;
  final Map<String, int> _counts = {};

  // ── Helpers ──────────────────────────────────────────────────────────────────

  List<_PodColor> get _available =>
      _kColors.where((c) => _selected.contains(c.id)).toList();

  String _label(AppStrings s, String id) {
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

  Color _contrastColor(Color bg) =>
      bg.computeLuminance() > 0.4 ? Colors.black : Colors.white;

  // ── Logique ──────────────────────────────────────────────────────────────────

  void _start() {
    if (_selected.isEmpty) return;
    _counts.clear();
    for (final c in _kColors) _counts[c.id] = 0;
setState(() { _phase = _Phase.countdown; _countdown = 3; });
    _runCountdown();
  }

void _runCountdown() {
    _timer?.cancel();
    _delayTimer?.cancel();
    _stopwatch?.stop();
    _stopwatch = null;
    // Affiche 3 → 2 → 1 → GO (500ms) → lance
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_countdown <= 1) {
        t.cancel();

        // Affiche GO pendant 500ms avec son
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

    // UI ticker: keeps remaining time progressing continuously (even on black screen)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_phase != _Phase.running) {
        t.cancel();
        return;
      }

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
    while (mounted && _phase == _Phase.running && token == _runToken) {
      if (_remainingMs <= 0) return;

      final list = _available;
      if (list.isEmpty) {
        _finish();
        return;
      }

      final picked = list[Random().nextInt(list.length)];
      setState(() {
        _currentColor = picked.color;
        _currentColorId = picked.id;
        _counts[picked.id] = (_counts[picked.id] ?? 0) + 1;
      });

      final displayMs = (_colorDuration * 1000).round();
      final delayMs = (_colorDelay * 1000).round();

      await Future.delayed(Duration(milliseconds: displayMs));
      if (!mounted || _phase != _Phase.running || token != _runToken) return;
      if (_remainingMs <= 0) return;

      setState(() {
        _currentColor = null;
        _currentColorId = null;
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
    setState(() { _phase = _Phase.stats; _currentColor = null; });
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
      duration: const Duration(milliseconds: 0),
      height: MediaQuery.of(context).size.height * 0.92,
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

          // Sélection couleurs
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(strings.colorPodColors, style: texts.labelLarge?.copyWith(
              fontWeight: FontWeight.w800, color: colors.secondary)),
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

          // Grille couleurs
          Wrap(spacing: 8, runSpacing: 8, children: _kColors.map((c) {
            final sel = _selected.contains(c.id);
            final isWhite = c.id == 'white';
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selected.remove(c.id); else _selected.add(c.id);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 64, height: 64,
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
                        size: 28)
                    : null,
              ),
            );
          }).toList()),
          const Gap(4),

          const Gap(AppSpacing.lg),

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
      Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$remainSec',
          style: TextStyle(
            fontSize: 100, fontWeight: FontWeight.w900,
            color: textColor.withValues(alpha: 0.85))),
        Text(strings.colorPodSecondsLeft,
          style: TextStyle(
            fontSize: 16, color: textColor.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600)),
      ])),
      Positioned(left: 0, right: 0, bottom: 0,
        child: LinearProgressIndicator(
          value: progress, minHeight: 6,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          color: isBlack ? Colors.white : textColor,
        )),
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

  // ── Stats ─────────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    final colors  = Theme.of(context).colorScheme;
    final texts   = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final total   = _counts.values.fold(0, (a, b) => a + b);
    final appeared = _kColors.where((c) => (_counts[c.id] ?? 0) > 0).toList();

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
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(children: [
              Text(strings.colorPodTotal(total),
                style: texts.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Gap(AppSpacing.lg),
              ...appeared.map((c) {
                final count = _counts[c.id] ?? 0;
                final pct = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: c.color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.outline),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_label(strings, c.id),
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
              }),
            ]),
          ),
          const Gap(AppSpacing.lg),
          Column(children: [
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: _reset,
                child: Text(strings.colorPodConfig),
              )),
              const Gap(AppSpacing.md),
              Expanded(child: FilledButton(
                onPressed: () {
                  _counts.clear();
                  for (final c in _kColors) _counts[c.id] = 0;
                  setState(() {
                    _phase = _Phase.countdown;
                    _countdown = 3;
                    _remainingMs = (_totalDuration * 1000).round();
                    _currentColor = null;
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