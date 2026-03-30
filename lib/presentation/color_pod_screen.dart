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
  _PodColor(id: 'pink',   color: Color(0xFFEC407A)),
  _PodColor(id: 'mediumGray', color: Color(0xFF9E9E9E)),
  _PodColor(id: 'white',  color: Color(0xFFF5F5F5)),
];

// ─── Formes disponibles ───────────────────────────────────────────────────────

class _PodShape {
  final String id;
  final IconData icon;
  const _PodShape({required this.id, required this.icon});
}

const _kShapes = <_PodShape>[
  _PodShape(id: 'square',   icon: Icons.square),
  _PodShape(id: 'heart',    icon: Icons.favorite),
  _PodShape(id: 'circle',   icon: Icons.circle),
  _PodShape(id: 'triangle', icon: Icons.play_arrow_rounded),
  _PodShape(id: 'star',     icon: Icons.star),
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
  final Set<String> _selected = {};
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
  Offset? _shapeAnchor;
  Offset? _letterAnchor;
  Offset? _digitAnchor;
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
      case 'pink': return s.colorPodPink;
      case 'mediumGray': return s.colorPodMediumGray;
      case 'white':  return s.colorPodWhite;
      case 'black':  return s.colorPodBlack;
      default:       return id;
    }
  }

  String _shapeLabel(AppStrings s, String id) {
    switch (id) {
      case 'circle':   return s.colorPodShapeCircle;
      case 'square':   return s.colorPodShapeSquare;
      case 'heart':    return s.colorPodShapeHeart;
      case 'triangle': return s.colorPodShapeTriangle;
      case 'star':     return s.colorPodShapeStar;
      default:         return id;
    }
  }

  IconData _shapeIcon(String id) {
    switch (id) {
      case 'circle':   return Icons.circle;
      case 'square':   return Icons.square;
      case 'heart':    return Icons.favorite;
      case 'triangle': return Icons.play_arrow_rounded;
      case 'star':     return Icons.star;
      default:         return Icons.circle;
    }
  }

  Widget _shapeGlyph({
    required String id,
    required Color color,
    required double size,
  }) {
    final isTriangle = id == 'triangle';
    final icon = Icon(
      _shapeIcon(id),
      color: color,
      size: isTriangle ? size * 1.35 : size,
    );
    if (!isTriangle) return icon;
    return Transform.rotate(
      angle: -pi / 2,
      child: icon,
    );
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

      final hasShape = shape != null;
      final hasLetter = letter != null;
      final hasDigit = digit != null;
      final shapeAnchor = hasShape
          ? _pickRandomAnchor(
              rng,
              minX: 0.24,
              maxX: 0.76,
              minY: 0.24,
              maxY: 0.70,
            )
          : null;
      final letterAnchor = hasLetter
          ? _pickRandomAnchor(
              rng,
              minX: 0.12,
              maxX: 0.88,
              minY: 0.18,
              maxY: 0.78,
              occupied: [if (shapeAnchor != null) shapeAnchor],
              minDistance: 0.28,
            )
          : null;
      final digitAnchor = hasDigit
          ? _pickRandomAnchor(
              rng,
              minX: 0.12,
              maxX: 0.88,
              minY: 0.18,
              maxY: 0.78,
              occupied: [
                if (shapeAnchor != null) shapeAnchor,
                if (letterAnchor != null) letterAnchor,
              ],
              minDistance: 0.22,
            )
          : null;

      setState(() {
        _currentColor = picked.color;
        _currentColorId = picked.id;
        _currentShape = shape;
        _currentLetter = letter;
        _currentDigit = digit;
        _shapeAnchor = shapeAnchor;
        _letterAnchor = letterAnchor;
        _digitAnchor = digitAnchor;
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
        _shapeAnchor = null;
        _letterAnchor = null;
        _digitAnchor = null;
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
      _shapeAnchor = null;
      _letterAnchor = null;
      _digitAnchor = null;
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
      _shapeAnchor = null;
      _letterAnchor = null;
      _digitAnchor = null;
      _countdown = 3;
      _remainingMs = 0;
    });
  }

  Offset _pickRandomAnchor(
    Random rng, {
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
    List<Offset> occupied = const [],
    double minDistance = 0.20,
  }) {
    bool inForbidden(Offset p) {
      final inStopZone = p.dx > 0.72 && p.dy < 0.22;
      final inBottomZone = p.dy > 0.84;
      return inStopZone || inBottomZone;
    }

    for (var i = 0; i < 80; i++) {
      final candidate = Offset(
        minX + rng.nextDouble() * (maxX - minX),
        minY + rng.nextDouble() * (maxY - minY),
      );
      if (inForbidden(candidate)) continue;
      final collides = occupied.any((o) => (candidate - o).distance < minDistance);
      if (!collides) return candidate;
    }

    return Offset((minX + maxX) / 2, (minY + maxY) / 2);
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

    if (landscape) {
      return ColoredBox(
        color: bgColor,
        child: SizedBox.expand(child: content),
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
    const selectorTileSize = 52.0;
    const selectorTileRadius = 10.0;
    const sectionBottomGap = AppSpacing.sm;

    Widget sectionLabel(String title) => Text(
      title,
      style: texts.labelLarge?.copyWith(
        fontWeight: FontWeight.w800, color: colors.secondary),
    );

    Widget sectionHeader({
      required String title,
      required VoidCallback onActivateAll,
      required VoidCallback onDeactivateAll,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          sectionLabel(title),
          Row(children: [
            TextButton(
              onPressed: onActivateAll,
              child: Text(
                strings.colorPodActivateAll,
                style: texts.labelSmall?.copyWith(color: colors.primary),
              ),
            ),
            TextButton(
              onPressed: onDeactivateAll,
              child: Text(
                strings.colorPodDeactivateAll,
                style: texts.labelSmall?.copyWith(color: colors.secondary),
              ),
            ),
          ]),
        ],
      );
    }

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
          sectionHeader(
            title: strings.colorPodColors,
            onActivateAll: () => setState(
              () => _selected.addAll(_kColors.map((c) => c.id)),
            ),
            onDeactivateAll: () => setState(() => _selected.clear()),
          ),
          const Gap(sectionBottomGap),
          toggleGrid(children: _kColors.map((c) {
            final sel = _selected.contains(c.id);
            final isWhite = c.id == 'white';
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selected.remove(c.id); else _selected.add(c.id);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: selectorTileSize,
                height: selectorTileSize,
                decoration: BoxDecoration(
                  color: c.color,
                  borderRadius: BorderRadius.circular(selectorTileRadius),
                  border: Border.all(
                    color: sel
                        ? colors.primary
                        : (isWhite ? colors.outline : Colors.transparent),
                    width: sel ? 2 : 1,
                  ),
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
          sectionHeader(
            title: strings.colorPodShapes,
            onActivateAll: () => setState(
              () => _selectedShapes.addAll(_kShapes.map((s) => s.id)),
            ),
            onDeactivateAll: () => setState(() => _selectedShapes.clear()),
          ),
          const Gap(sectionBottomGap),
          toggleGrid(children: _kShapes.map((s) {
            final sel = _selectedShapes.contains(s.id);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selectedShapes.remove(s.id);
                else _selectedShapes.add(s.id);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: selectorTileSize,
                height: selectorTileSize,
                decoration: BoxDecoration(
                  color: sel
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(selectorTileRadius),
                  border: Border.all(
                    color: sel ? colors.primary : colors.outline,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: _shapeGlyph(
                  id: s.id,
                  color: sel ? colors.primary : colors.secondary,
                  size: 28,
                ),
              ),
            );
          }).toList()),
          const Gap(AppSpacing.lg),

          // ── LETTRES ──────────────────────────────────────────────────────────
          sectionHeader(
            title: strings.colorPodLetters,
            onActivateAll: () => setState(() => _selectedLetters.addAll(_kLetters)),
            onDeactivateAll: () => setState(() => _selectedLetters.clear()),
          ),
          const Gap(sectionBottomGap),
          toggleGrid(children: _kLetters.map((l) {
            final sel = _selectedLetters.contains(l);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selectedLetters.remove(l);
                else _selectedLetters.add(l);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: selectorTileSize,
                height: selectorTileSize,
                decoration: BoxDecoration(
                  color: sel
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(selectorTileRadius),
                  border: Border.all(
                    color: sel ? colors.primary : colors.outline,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(l,
                    style: texts.labelLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: sel ? colors.primary : colors.secondary)),
                ),
              ),
            );
          }).toList()),
          const Gap(AppSpacing.lg),

          // ── CHIFFRES ─────────────────────────────────────────────────────────
          sectionHeader(
            title: strings.colorPodDigits,
            onActivateAll: () => setState(() => _selectedDigits.addAll(_kDigits)),
            onDeactivateAll: () => setState(() => _selectedDigits.clear()),
          ),
          const Gap(sectionBottomGap),
          toggleGrid(children: _kDigits.map((d) {
            final sel = _selectedDigits.contains(d);
            return GestureDetector(
              onTap: () => setState(() {
                if (sel) _selectedDigits.remove(d);
                else _selectedDigits.add(d);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: selectorTileSize,
                height: selectorTileSize,
                decoration: BoxDecoration(
                  color: sel
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(selectorTileRadius),
                  border: Border.all(
                    color: sel ? colors.primary : colors.outline,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(d,
                    style: texts.labelLarge?.copyWith(
                      fontSize: 24,
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
    final shapeColor = _currentColorId == 'white' ? Colors.black : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        const shapeBox = 220.0;
        const textBox = 92.0;

        Widget anchored({
          required Offset anchor,
          required double box,
          required Widget child,
        }) {
          final maxLeft = (constraints.maxWidth - box).clamp(0.0, double.infinity);
          final maxTop = (constraints.maxHeight - box).clamp(0.0, double.infinity);
          final left = (anchor.dx * constraints.maxWidth - box / 2).clamp(0.0, maxLeft);
          final top = (anchor.dy * constraints.maxHeight - box / 2).clamp(0.0, maxTop);
          return Positioned(left: left, top: top, child: SizedBox(width: box, height: box, child: Center(child: child)));
        }

        return Stack(children: [
          if (_currentShape != null && _shapeAnchor != null)
            anchored(
              anchor: _shapeAnchor!,
              box: shapeBox,
              child: _shapeGlyph(
                id: _currentShape!,
                size: 200,
                color: shapeColor.withValues(alpha: 0.82),
              ),
            ),

          if (_currentDigit != null && _digitAnchor != null)
            anchored(
              anchor: _digitAnchor!,
              box: textBox,
              child: Text(
                _currentDigit!,
                style: TextStyle(
                  fontSize: 86,
                  fontWeight: FontWeight.w900,
                  color: textColor.withValues(alpha: 0.95),
                ),
              ),
            ),

          if (_currentLetter != null && _letterAnchor != null)
            anchored(
              anchor: _letterAnchor!,
              box: textBox,
              child: Text(
                _currentLetter!,
                style: TextStyle(
                  fontSize: 86,
                  fontWeight: FontWeight.w900,
                  color: textColor.withValues(alpha: 0.95),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: isBlack ? Colors.white : textColor,
            ),
          ),

          Positioned(
            right: 14,
            bottom: 6,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 0),
              child: Text(
                '$remainSec',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),

          Positioned(
            top: 48,
            right: 20,
            child: SafeArea(
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  strings.colorPodStop,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ]);
      },
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
                      _shapeGlyph(
                        id: s.id,
                        size: 20,
                        color: colors.primary,
                      ),
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
            SizedBox(
              width: 56,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                child: Text(strings.colorPodConfig),
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: FilledButton(
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
                    _shapeAnchor = null;
                    _letterAnchor = null;
                    _digitAnchor = null;
                  });
                  _runCountdown();
                },
                child: Text(strings.colorPodRestart),
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