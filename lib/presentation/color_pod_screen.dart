import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
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
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_countdown <= 1) {
        t.cancel();
        try { await TimerSound.play(); } catch (_) {}
        try {
          final ok = await Vibration.hasVibrator() ?? false;
          if (ok) Vibration.vibrate(duration: 600);
        } catch (_) {}
        if (!mounted) return;
        setState(() {
          _phase = _Phase.running;
          _remainingMs = (_totalDuration * 1000).round();
          _currentColor = null;
          _currentColorId = null;
        });
        _showNextColor();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _showNextColor() {
    if (_remainingMs <= 0) { _finish(); return; }
    final list = _available;
    final picked = list[Random().nextInt(list.length)];
    setState(() {
      _currentColor = picked.color;
      _currentColorId = picked.id;
      _counts[picked.id] = (_counts[picked.id] ?? 0) + 1;
    });

    final displayMs = (_colorDuration * 1000).round();
    final delayMs   = (_colorDelay   * 1000).round();
    const tickMs    = 50;
    int elapsed = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: tickMs), (t) {
      elapsed += tickMs;
      setState(() => _remainingMs = (_remainingMs - tickMs).clamp(0, 999999));
      if (_remainingMs <= 0) { t.cancel(); _finish(); return; }
      if (elapsed >= displayMs) {
        t.cancel();
        setState(() { _currentColor = null; _currentColorId = null; });
        _delayTimer = Timer(Duration(milliseconds: delayMs), () {
          if (_phase == _Phase.running && mounted) _showNextColor();
        });
      }
    });
  }

  void _finish() async {
    _timer?.cancel();
    _delayTimer?.cancel();
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
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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

    if (widget.embedded) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: bgColor,
        child: body,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: body,
    );
  }

  // ── Config ────────────────────────────────────────────────────────────────────

  Widget _buildConfig() {
    final colors  = Theme.of(context).colorScheme;
    final texts   = Theme.of(context).textTheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
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

          // Labels couleurs
          Wrap(spacing: 8, runSpacing: 4, children: _kColors.map((c) =>
            SizedBox(width: 64, child: Text(_label(strings, c.id),
              textAlign: TextAlign.center,
              style: texts.labelSmall?.copyWith(
                color: colors.secondary)))).toList()),

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
          _countdown > 0 ? '$_countdown' : 'GO',
          style: const TextStyle(
            fontSize: 120, fontWeight: FontWeight.w900,
            color: Colors.white, letterSpacing: -4,
          ),
        ),
        const Gap(16),
        Text(strings.colorPodPrepare,
          style: const TextStyle(
            fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600)),
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
        ]),
      )),
    ]);
  }
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