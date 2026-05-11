import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';

import 'package:thot/theme.dart';
import 'package:thot/utils/timer_sound.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/data/training_history.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/widgets/pro_badge.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/widgets/exercise_countdown_background.dart';

// ─── Couleurs disponibles ─────────────────────────────────────────────────────

class _PodColor {
  final String id;
  final Color color;
  const _PodColor({required this.id, required this.color});
}

const _kColors = <_PodColor>[
  _PodColor(id: 'red', color: Color(0xFFE53935)),
  _PodColor(id: 'blue', color: Color(0xFF1E88E5)),
  _PodColor(id: 'green', color: Color(0xFF43A047)),
  _PodColor(id: 'yellow', color: Color(0xFFFDD835)),
  _PodColor(id: 'orange', color: Color(0xFFFB8C00)),
  _PodColor(id: 'purple', color: Color(0xFF8E24AA)),
  _PodColor(id: 'pink', color: Color(0xFFEC407A)),
  _PodColor(id: 'mediumGray', color: Color(0xFF9E9E9E)),
  _PodColor(id: 'white', color: Color(0xFFF5F5F5)),
];

// ─── Formes disponibles ───────────────────────────────────────────────────────

class _PodShape {
  final String id;
  final IconData icon;
  const _PodShape({required this.id, required this.icon});
}

const _kShapes = <_PodShape>[
  _PodShape(id: 'square', icon: Icons.square),
  _PodShape(id: 'heart', icon: Icons.favorite),
  _PodShape(id: 'circle', icon: Icons.circle),
  _PodShape(id: 'triangle', icon: Icons.play_arrow_rounded),
  _PodShape(id: 'star', icon: Icons.star),
];

class _PodDirection {
  final String id;
  final IconData icon;
  const _PodDirection({required this.id, required this.icon});
}

const _kDirections = <_PodDirection>[
  _PodDirection(id: 'left', icon: Icons.arrow_back_rounded),
  _PodDirection(id: 'right', icon: Icons.arrow_forward_rounded),
  _PodDirection(id: 'up', icon: Icons.arrow_upward_rounded),
  _PodDirection(id: 'down', icon: Icons.arrow_downward_rounded),
  _PodDirection(id: 'center', icon: Icons.adjust_rounded),
];

// ─── Lettres et chiffres ──────────────────────────────────────────────────────

const _kLettersFR = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

const _kLettersEN = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

const _kLettersDE = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'ß',
];

const _kLettersIT = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

const _kLettersES = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'Ñ',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

List<String> _getLettersForLanguage(String languageCode) {
  switch (languageCode) {
    case 'fr':
      return _kLettersFR;
    case 'en':
      return _kLettersEN;
    case 'de':
      return _kLettersDE;
    case 'it':
      return _kLettersIT;
    case 'es':
      return _kLettersES;
    default:
      return _kLettersFR; // Default to French
  }
}

const _kDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

enum _Phase { countdown, running }

class _ColorPodExerciseResult {
  final Map<String, int> counts;
  final Map<String, int> shapeCounts;
  final Map<String, int> directionCounts;
  final Map<String, int> letterCounts;
  final Map<String, int> digitCounts;

  const _ColorPodExerciseResult({
    required this.counts,
    required this.shapeCounts,
    required this.directionCounts,
    required this.letterCounts,
    required this.digitCounts,
  });
}

// ─── Écran principal ──────────────────────────────────────────────────────────

class ColorPodScreen extends StatefulWidget {
  const ColorPodScreen({Key? key}) : super(key: key);

  @override
  State<ColorPodScreen> createState() => _ColorPodScreenState();
}

class _ColorPodScreenState extends State<ColorPodScreen> {
  List<TextSpan> _parseBoldText(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }

  // ── Config ───────────────────────────────────────────────────────────────────
  final Set<String> _selected = {};
  final Set<String> _selectedShapes = {};
  final Set<String> _selectedDirections = {};
  final Set<String> _selectedLetters = {};
  final Set<String> _selectedDigits = {};
  double _colorDuration = 2.0;
  double _colorDelay = 1.0;
  double _totalDuration = 30.0;

  // ── Results ───────────────────────────────────────────────────────────────────
  _ColorPodExerciseResult? _currentResult;
  bool _showingResults = false;

  // ── Helpers ──────────────────────────────────────────────────────────────────

  List<String> get _currentLetters =>
      _getLettersForLanguage(AppStrings.of(context).languageCode);

  String _colorLabel(AppStrings s, String id) {
    switch (id) {
      case 'red':
        return s.colorPodRed;
      case 'blue':
        return s.colorPodBlue;
      case 'green':
        return s.colorPodGreen;
      case 'yellow':
        return s.colorPodYellow;
      case 'orange':
        return s.colorPodOrange;
      case 'purple':
        return s.colorPodPurple;
      case 'pink':
        return s.colorPodPink;
      case 'mediumGray':
        return s.colorPodMediumGray;
      case 'white':
        return s.colorPodWhite;
      case 'black':
        return s.colorPodBlack;
      default:
        return id;
    }
  }

  String _directionLabel(AppStrings s, String id) {
    switch (id) {
      case 'left':
        return s.colorPodDirectionLeft;
      case 'right':
        return s.colorPodDirectionRight;
      case 'up':
        return s.colorPodDirectionUp;
      case 'down':
        return s.colorPodDirectionDown;
      case 'center':
        return s.colorPodDirectionCenter;
      default:
        return id;
    }
  }

  String _shapeLabel(AppStrings s, String id) {
    switch (id) {
      case 'circle':
        return s.colorPodShapeCircle;
      case 'square':
        return s.colorPodShapeSquare;
      case 'heart':
        return s.colorPodShapeHeart;
      case 'triangle':
        return s.colorPodShapeTriangle;
      case 'star':
        return s.colorPodShapeStar;
      default:
        return id;
    }
  }

  IconData _shapeIcon(String id) {
    switch (id) {
      case 'circle':
        return Icons.circle;
      case 'square':
        return Icons.square;
      case 'heart':
        return Icons.favorite;
      case 'triangle':
        return Icons.play_arrow_rounded;
      case 'star':
        return Icons.star;
      default:
        return Icons.circle;
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
    return Transform.rotate(angle: -pi / 2, child: icon);
  }

  // ── Logique ──────────────────────────────────────────────────────────────────

  Future<void> _start() async {
    if (_selected.isEmpty) return;

    final result = await Navigator.of(context, rootNavigator: true)
        .push<_ColorPodExerciseResult>(
          MaterialPageRoute(
            builder: (_) => _ColorPodExerciseScreen(
              selected: Set<String>.from(_selected),
              selectedShapes: Set<String>.from(_selectedShapes),
              selectedDirections: Set<String>.from(_selectedDirections),
              selectedLetters: Set<String>.from(_selectedLetters),
              selectedDigits: Set<String>.from(_selectedDigits),
              colorDuration: _colorDuration,
              colorDelay: _colorDelay,
              totalDuration: _totalDuration,
            ),
          ),
        );

    if (!mounted || result == null) return;

    await TrainingHistory.recordExerciseCompletion('color_pod');
    if (!mounted) return;

    setState(() {
      _currentResult = result;
      _showingResults = true;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _showingResults ? _buildResultsView() : _buildConfig(),
    );
  }

  // ── Config ────────────────────────────────────────────────────────────────────

  Widget _buildConfig() {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = context.read<ThotProvider>();
    const selectorTileSize = 52.0;
    const selectorTileRadius = 10.0;
    const sectionBottomGap = 4.0; // Réduit de AppSpacing.sm (~16px) à 4px
    const sectionGap = 16.0; // Réduit de AppSpacing.lg (~24px) à 16px

    final shapesLocked = provider.isColorPodSubModeLockedForFree('shapes');
    final lettersLocked = provider.isColorPodSubModeLockedForFree('letters');
    final numbersLocked = provider.isColorPodSubModeLockedForFree('numbers');

    Widget sectionLabel(String title) => Text(
      title,
      style: texts.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: colors.secondary,
      ),
    );

    Widget sectionHeader({
      required String title,
      required VoidCallback onActivateAll,
      required VoidCallback onDeactivateAll,
      bool isLocked = false,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              sectionLabel(title),
              if (isLocked) ...[
                const SizedBox(width: 8),
                const ProBadge(compact: true),
              ],
            ],
          ),
          if (!isLocked)
            Row(
              children: [
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
              ],
            ),
        ],
      );
    }

    Widget toggleGrid({required List<Widget> children}) =>
        Wrap(spacing: 6, runSpacing: 6, children: children);

    return Column(
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
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        strings.colorPodToolTitle,
                        style: texts.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const Gap(6),
                    Tooltip(
                      richMessage: TextSpan(
                        children: _parseBoldText(
                          strings.colorPodToolTooltip,
                          texts.bodySmall?.copyWith(color: colors.surface) ??
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                        ),
                      ),
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 6),
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
              // Icône en forme de V pour fermer
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── COULEURS ─────────────────────────────────────────────────────────
                sectionHeader(
                  title: strings.colorPodColors,
                  onActivateAll: () => setState(
                    () => _selected.addAll(_kColors.map((c) => c.id)),
                  ),
                  onDeactivateAll: () => setState(() => _selected.clear()),
                ),
                const Gap(sectionBottomGap),
                toggleGrid(
                  children: _kColors.map((c) {
                    final sel = _selected.contains(c.id);
                    final isWhite = c.id == 'white';
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (sel)
                          _selected.remove(c.id);
                        else
                          _selected.add(c.id);
                      }),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: sel ? 1.0 : 0.6,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: selectorTileSize,
                          height: selectorTileSize,
                          decoration: BoxDecoration(
                            color: c.color,
                            borderRadius: BorderRadius.circular(
                              selectorTileRadius,
                            ),
                            border: Border.all(
                              color: sel
                                  ? colors.primary
                                  : (isWhite
                                        ? colors.outline
                                        : Colors.transparent),
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: sel
                              ? Icon(
                                  Icons.check_rounded,
                                  color: (c.id == 'white' || c.id == 'yellow')
                                      ? Colors.black
                                      : Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Gap(sectionGap),

                sectionHeader(
                  title: strings.colorPodDirections,
                  onActivateAll: () => setState(
                    () => _selectedDirections.addAll(
                      _kDirections.map((d) => d.id),
                    ),
                  ),
                  onDeactivateAll: () =>
                      setState(() => _selectedDirections.clear()),
                ),
                const Gap(sectionBottomGap),
                toggleGrid(
                  children: _kDirections.map((d) {
                    final sel = _selectedDirections.contains(d.id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (sel) {
                          _selectedDirections.remove(d.id);
                        } else {
                          _selectedDirections.add(d.id);
                        }
                      }),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: sel ? 1.0 : 0.6,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: selectorTileSize,
                          height: selectorTileSize,
                          decoration: BoxDecoration(
                            color: sel
                                ? colors.primary.withValues(alpha: 0.12)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(
                              selectorTileRadius,
                            ),
                            border: Border.all(
                              color: sel ? colors.primary : colors.outline,
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            d.icon,
                            color: sel ? colors.primary : colors.secondary,
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Gap(sectionGap),

                // ── FORMES ───────────────────────────────────────────────────────────
                sectionHeader(
                  title: strings.colorPodShapes,
                  isLocked: shapesLocked,
                  onActivateAll: () => setState(
                    () => _selectedShapes.addAll(_kShapes.map((s) => s.id)),
                  ),
                  onDeactivateAll: () =>
                      setState(() => _selectedShapes.clear()),
                ),
                const Gap(sectionBottomGap),
                GestureDetector(
                  onTap: shapesLocked ? () => showProModal(context) : null,
                  child: Opacity(
                    opacity: shapesLocked ? 0.4 : 1.0,
                    child: IgnorePointer(
                      ignoring: shapesLocked,
                      child: toggleGrid(
                        children: _kShapes.map((s) {
                          final sel = _selectedShapes.contains(s.id);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel)
                                _selectedShapes.remove(s.id);
                              else
                                _selectedShapes.add(s.id);
                            }),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: sel ? 1.0 : 0.6,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: selectorTileSize,
                                height: selectorTileSize,
                                decoration: BoxDecoration(
                                  color: sel
                                      ? colors.primary.withValues(alpha: 0.12)
                                      : colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    selectorTileRadius,
                                  ),
                                  border: Border.all(
                                    color: sel
                                        ? colors.primary
                                        : colors.outline,
                                    width: sel ? 2 : 1,
                                  ),
                                ),
                                child: _shapeGlyph(
                                  id: s.id,
                                  color: sel
                                      ? colors.primary
                                      : colors.secondary,
                                  size: 28,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const Gap(sectionGap),

                // ── LETTRES ──────────────────────────────────────────────────────────
                sectionHeader(
                  title: strings.colorPodLetters,
                  isLocked: lettersLocked,
                  onActivateAll: () =>
                      setState(() => _selectedLetters.addAll(_currentLetters)),
                  onDeactivateAll: () =>
                      setState(() => _selectedLetters.clear()),
                ),
                const Gap(sectionBottomGap),
                GestureDetector(
                  onTap: lettersLocked ? () => showProModal(context) : null,
                  child: Opacity(
                    opacity: lettersLocked ? 0.4 : 1.0,
                    child: IgnorePointer(
                      ignoring: lettersLocked,
                      child: toggleGrid(
                        children: _currentLetters.map((l) {
                          final sel = _selectedLetters.contains(l);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel)
                                _selectedLetters.remove(l);
                              else
                                _selectedLetters.add(l);
                            }),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: sel ? 1.0 : 0.6,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: selectorTileSize,
                                height: selectorTileSize,
                                decoration: BoxDecoration(
                                  color: sel
                                      ? colors.primary.withValues(alpha: 0.12)
                                      : colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    selectorTileRadius,
                                  ),
                                  border: Border.all(
                                    color: sel
                                        ? colors.primary
                                        : colors.outline,
                                    width: sel ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    l,
                                    style: texts.labelLarge?.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: sel
                                          ? colors.primary
                                          : colors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const Gap(sectionGap),

                // ── CHIFFRES ─────────────────────────────────────────────────────────
                sectionHeader(
                  title: strings.colorPodDigits,
                  isLocked: numbersLocked,
                  onActivateAll: () =>
                      setState(() => _selectedDigits.addAll(_kDigits)),
                  onDeactivateAll: () =>
                      setState(() => _selectedDigits.clear()),
                ),
                const Gap(sectionBottomGap),
                GestureDetector(
                  onTap: numbersLocked ? () => showProModal(context) : null,
                  child: Opacity(
                    opacity: numbersLocked ? 0.4 : 1.0,
                    child: IgnorePointer(
                      ignoring: numbersLocked,
                      child: toggleGrid(
                        children: _kDigits.map((d) {
                          final sel = _selectedDigits.contains(d);
                          return GestureDetector(
                            onTap: () => setState(() {
                              if (sel)
                                _selectedDigits.remove(d);
                              else
                                _selectedDigits.add(d);
                            }),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: sel ? 1.0 : 0.6,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: selectorTileSize,
                                height: selectorTileSize,
                                decoration: BoxDecoration(
                                  color: sel
                                      ? colors.primary.withValues(alpha: 0.12)
                                      : colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    selectorTileRadius,
                                  ),
                                  border: Border.all(
                                    color: sel
                                        ? colors.primary
                                        : colors.outline,
                                    width: sel ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    d,
                                    style: texts.labelLarge?.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: sel
                                          ? colors.primary
                                          : colors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const Gap(sectionGap),

                // ── Sliders ──────────────────────────────────────────────────────────
                _SliderField(
                  label: strings.colorPodColorDuration,
                  value: _colorDuration,
                  min: 0.5,
                  max: 10.0,
                  divisions: 19,
                  unit: 's',
                  onChanged: (v) => setState(() => _colorDuration = v),
                  colors: colors,
                  texts: texts,
                ),
                const Gap(AppSpacing.md),
                _SliderField(
                  label: strings.colorPodDelay,
                  value: _colorDelay,
                  min: 0.0,
                  max: 5.0,
                  divisions: 20,
                  unit: 's',
                  onChanged: (v) => setState(() => _colorDelay = v),
                  colors: colors,
                  texts: texts,
                ),
                const Gap(AppSpacing.md),
                _SliderField(
                  label: strings.colorPodTotalDuration,
                  value: _totalDuration,
                  min: 10.0,
                  max: 300.0,
                  divisions: 29,
                  unit: 's',
                  onChanged: (v) => setState(() => _totalDuration = v),
                  colors: colors,
                  texts: texts,
                ),
                const Gap(AppSpacing.xl),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _selected.isEmpty ? null : _start,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(strings.colorPodLaunch.toUpperCase()),
                  ),
                ),
                const Gap(AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Results View ────────────────────────────────────────────────────────────────

  Widget _buildResultsView() {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final result = _currentResult!;

    final totalColors = result.counts.values.fold(0, (a, b) => a + b);
    final totalShapes = result.shapeCounts.values.fold(0, (a, b) => a + b);
    final totalDirections = result.directionCounts.values.fold(
      0,
      (a, b) => a + b,
    );
    final totalLetters = result.letterCounts.values.fold(0, (a, b) => a + b);
    final totalDigits = result.digitCounts.values.fold(0, (a, b) => a + b);
    final appearedColors = _kColors
        .where((c) => (result.counts[c.id] ?? 0) > 0)
        .toList();
    final appearedShapes = _kShapes
        .where((s) => (result.shapeCounts[s.id] ?? 0) > 0)
        .toList();
    final appearedDirections = _kDirections
        .where((d) => (result.directionCounts[d.id] ?? 0) > 0)
        .toList();
    final appearedLetters = _currentLetters
        .where((l) => (result.letterCounts[l] ?? 0) > 0)
        .toList();
    final appearedDigits = _kDigits
        .where((d) => (result.digitCounts[d] ?? 0) > 0)
        .toList();

    Widget shapeGlyph({
      required String id,
      required Color color,
      required double size,
    }) {
      final isTriangle = id == 'triangle';
      IconData icon;
      switch (id) {
        case 'circle':
          icon = Icons.circle;
          break;
        case 'square':
          icon = Icons.square;
          break;
        case 'heart':
          icon = Icons.favorite;
          break;
        case 'triangle':
          icon = Icons.play_arrow_rounded;
          break;
        case 'star':
          icon = Icons.star;
          break;
        default:
          icon = Icons.circle;
      }

      final widget = Icon(
        icon,
        color: color,
        size: isTriangle ? size * 1.35 : size,
      );

      if (!isTriangle) return widget;
      return Transform.rotate(angle: -pi / 2, child: widget);
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: texts.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.secondary,
                ),
              ),
              const Gap(AppSpacing.md),
              ...rows,
            ],
          ),
        ),
      );
    }

    Widget distributionRow({
      Widget? leading,
      required String label,
      required int count,
      required int total,
      required Color progressColor,
    }) {
      final pct = total == 0 ? 0.0 : count / total;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          children: [
            if (leading != null) ...[
              SizedBox(width: 30, child: Center(child: leading)),
              const Gap(AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: texts.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$count × (${(pct * 100).toStringAsFixed(0)}%)',
                        style: texts.bodySmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  LinearProgressIndicator(
                    value: pct,
                    backgroundColor: colors.outline.withValues(alpha: 0.2),
                    color: progressColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
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
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showingResults = false;
                    _currentResult = null;
                  });
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
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  strings.colorPodResults,
                  textAlign: TextAlign.center,
                  style: texts.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
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
                statCard(
                  strings.colorPodColors,
                  appearedColors.map((c) {
                    final count = result.counts[c.id] ?? 0;
                    final pct = totalColors == 0 ? 0.0 : count / totalColors;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c.color,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.outline),
                            ),
                          ),
                          const Gap(AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _colorLabel(strings, c.id),
                                      style: texts.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '$count × (${(pct * 100).toStringAsFixed(0)}%)',
                                      style: texts.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(4),
                                LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: colors.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                  color: c.id == 'white'
                                      ? colors.secondary
                                      : c.color,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (appearedShapes.isNotEmpty)
                  statCard(
                    strings.colorPodShapes,
                    appearedShapes.map((s) {
                      final count = result.shapeCounts[s.id] ?? 0;
                      return distributionRow(
                        leading: shapeGlyph(
                          id: s.id,
                          size: 20,
                          color: colors.primary,
                        ),
                        label: _shapeLabel(strings, s.id),
                        count: count,
                        total: totalShapes,
                        progressColor: colors.primary,
                      );
                    }).toList(),
                  ),
                if (appearedDirections.isNotEmpty)
                  statCard(
                    strings.colorPodDirections,
                    appearedDirections.map((d) {
                      final count = result.directionCounts[d.id] ?? 0;
                      return distributionRow(
                        leading: Icon(d.icon, size: 22, color: colors.primary),
                        label: _directionLabel(strings, d.id),
                        count: count,
                        total: totalDirections,
                        progressColor: colors.primary,
                      );
                    }).toList(),
                  ),
                if (appearedLetters.isNotEmpty)
                  statCard(
                    strings.colorPodLetters,
                    appearedLetters.map((l) {
                      final count = result.letterCounts[l] ?? 0;
                      return distributionRow(
                        label: l,
                        count: count,
                        total: totalLetters,
                        progressColor: colors.primary,
                      );
                    }).toList(),
                  ),
                if (appearedDigits.isNotEmpty)
                  statCard(
                    strings.colorPodDigits,
                    appearedDigits.map((d) {
                      final count = result.digitCounts[d] ?? 0;
                      return distributionRow(
                        label: d,
                        count: count,
                        total: totalDigits,
                        progressColor: colors.primary,
                      );
                    }).toList(),
                  ),
                const Gap(AppSpacing.md),
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () {
                            setState(() {
                              _showingResults = false;
                              _currentResult = null;
                            });
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary.withValues(
                              alpha: 0.72,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            strings.colorPodConfig.toUpperCase(),
                            style: texts.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _showingResults = false;
                              _currentResult = null;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) _start();
                            });
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(strings.colorPodRestart.toUpperCase()),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Wrapper paysage ──────────────────────────────────────────────────────────

class _ColorPodExerciseScreen extends StatefulWidget {
  final Set<String> selected;
  final Set<String> selectedShapes;
  final Set<String> selectedDirections;
  final Set<String> selectedLetters;
  final Set<String> selectedDigits;
  final double colorDuration;
  final double colorDelay;
  final double totalDuration;

  const _ColorPodExerciseScreen({
    required this.selected,
    required this.selectedShapes,
    required this.selectedDirections,
    required this.selectedLetters,
    required this.selectedDigits,
    required this.colorDuration,
    required this.colorDelay,
    required this.totalDuration,
  });

  @override
  State<_ColorPodExerciseScreen> createState() =>
      _ColorPodExerciseScreenState();
}

class _ColorPodExerciseScreenState extends State<_ColorPodExerciseScreen>
    with WidgetsBindingObserver {
  _Phase _phase = _Phase.countdown;
  int _countdown = 3;
  Timer? _timer;
  Timer? _delayTimer;
  Stopwatch? _stopwatch;
  int _runToken = 0;

  Color? _currentColor;
  String? _currentColorId;
  String? _currentShape;
  String? _currentDirection;
  String? _currentLetter;
  String? _currentDigit;
  Offset? _shapeAnchor;
  Offset? _directionAnchor;
  Offset? _letterAnchor;
  Offset? _digitAnchor;
  int _remainingMs = 0;

  final Map<String, int> _counts = {};
  final Map<String, int> _shapeCounts = {};
  final Map<String, int> _directionCounts = {};
  final Map<String, int> _letterCounts = {};
  final Map<String, int> _digitCounts = {};

  List<_PodColor> get _available =>
      _kColors.where((c) => widget.selected.contains(c.id)).toList();

  Color _contrastColor(Color bg) =>
      bg.computeLuminance() > 0.4 ? Colors.black : Colors.white;

  IconData _shapeIcon(String id) {
    switch (id) {
      case 'circle':
        return Icons.circle;
      case 'square':
        return Icons.square;
      case 'heart':
        return Icons.favorite;
      case 'triangle':
        return Icons.play_arrow_rounded;
      case 'star':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }

  IconData _directionIcon(String id) {
    switch (id) {
      case 'left':
        return Icons.arrow_back_rounded;
      case 'right':
        return Icons.arrow_forward_rounded;
      case 'up':
        return Icons.arrow_upward_rounded;
      case 'down':
        return Icons.arrow_downward_rounded;
      case 'center':
        return Icons.adjust_rounded;
      default:
        return Icons.adjust_rounded;
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
    return Transform.rotate(angle: -pi / 2, child: icon);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    for (final c in _kColors) {
      _counts[c.id] = 0;
    }
    for (final s in _kShapes) {
      _shapeCounts[s.id] = 0;
    }
    for (final d in _kDirections) {
      _directionCounts[d.id] = 0;
    }
    // L'initialisation des lettres se fera dans didChangeDependencies
    for (final d in _kDigits) {
      _digitCounts[d] = 0;
    }
    _runCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialisation des compteurs de lettres basée sur la langue du contexte
    final letters = _getLettersForLanguage(AppStrings.of(context).languageCode);
    if (_letterCounts.isEmpty) {
      for (final l in letters) {
        _letterCounts[l] = 0;
      }
    }
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

        unawaited(TimerSound.play());
        unawaited(() async {
          try {
            final ok = await Vibration.hasVibrator();
            if (ok) unawaited(Vibration.vibrate(duration: 300));
          } catch (_) {}
        }());

        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;

        setState(() {
          _phase = _Phase.running;
          _remainingMs = (widget.totalDuration * 1000).round();
          _currentColor = null;
          _currentColorId = null;
          _currentShape = null;
          _currentDirection = null;
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

    final totalMs = (widget.totalDuration * 1000).round();
    _stopwatch = Stopwatch()..start();

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
    final rng = Random();

    while (mounted && _phase == _Phase.running && token == _runToken) {
      if (_remainingMs <= 0) return;

      final list = _available;
      if (list.isEmpty) {
        _finish();
        return;
      }

      final picked = list[rng.nextInt(list.length)];

      String? shape;
      if (widget.selectedShapes.isNotEmpty) {
        final shapeList = widget.selectedShapes.toList();
        shape = shapeList[rng.nextInt(shapeList.length)];
      }

      String? letter;
      if (widget.selectedLetters.isNotEmpty) {
        final letterList = widget.selectedLetters.toList();
        letter = letterList[rng.nextInt(letterList.length)];
      }

      String? digit;
      if (widget.selectedDigits.isNotEmpty) {
        final digitList = widget.selectedDigits.toList();
        digit = digitList[rng.nextInt(digitList.length)];
      }

      String? direction;
      if (widget.selectedDirections.isNotEmpty) {
        final directionList = widget.selectedDirections.toList();
        direction = directionList[rng.nextInt(directionList.length)];
      }

      final shapeAnchor = shape != null
          ? _pickRandomAnchor(
              rng,
              minX: 0.24,
              maxX: 0.76,
              minY: 0.24,
              maxY: 0.70,
            )
          : null;

      final letterAnchor = letter != null
          ? _pickRandomAnchor(
              rng,
              minX: 0.12,
              maxX: 0.88,
              minY: 0.18,
              maxY: 0.78,
              occupied: [if (shapeAnchor != null) shapeAnchor],
              minDistance: 0.32,
            )
          : null;

      final digitAnchor = digit != null
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
              minDistance: 0.26,
            )
          : null;

      final directionAnchor = direction != null
          ? _pickRandomAnchor(
              rng,
              minX: 0.12,
              maxX: 0.88,
              minY: 0.18,
              maxY: 0.78,
              occupied: [
                if (shapeAnchor != null) shapeAnchor,
                if (letterAnchor != null) letterAnchor,
                if (digitAnchor != null) digitAnchor,
              ],
              minDistance: 0.26,
            )
          : null;

      setState(() {
        _currentColor = picked.color;
        _currentColorId = picked.id;
        _currentShape = shape;
        _currentDirection = direction;
        _currentLetter = letter;
        _currentDigit = digit;
        _shapeAnchor = shapeAnchor;
        _directionAnchor = directionAnchor;
        _letterAnchor = letterAnchor;
        _digitAnchor = digitAnchor;

        _counts[picked.id] = (_counts[picked.id] ?? 0) + 1;
        if (shape != null) {
          _shapeCounts[shape] = (_shapeCounts[shape] ?? 0) + 1;
        }
        if (direction != null) {
          _directionCounts[direction] = (_directionCounts[direction] ?? 0) + 1;
        }
        if (letter != null) {
          _letterCounts[letter] = (_letterCounts[letter] ?? 0) + 1;
        }
        if (digit != null) {
          _digitCounts[digit] = (_digitCounts[digit] ?? 0) + 1;
        }
      });

      final displayMs = (widget.colorDuration * 1000).round();
      final delayMs = (widget.colorDelay * 1000).round();

      await Future<void>.delayed(Duration(milliseconds: displayMs));
      if (!mounted || _phase != _Phase.running || token != _runToken) return;
      if (_remainingMs <= 0) return;

      setState(() {
        _currentColor = null;
        _currentColorId = null;
        _currentShape = null;
        _currentDirection = null;
        _currentLetter = null;
        _currentDigit = null;
        _shapeAnchor = null;
        _directionAnchor = null;
        _letterAnchor = null;
        _digitAnchor = null;
      });

      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
  }

  Future<void> _finish() async {
    _timer?.cancel();
    _delayTimer?.cancel();
    _stopwatch?.stop();

    try {
      await TimerSound.play();
    } catch (_) {}

    try {
      final ok = await Vibration.hasVibrator();
      if (ok) unawaited(Vibration.vibrate(duration: 800));
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pop(
      _ColorPodExerciseResult(
        counts: Map<String, int>.from(_counts),
        shapeCounts: Map<String, int>.from(_shapeCounts),
        directionCounts: Map<String, int>.from(_directionCounts),
        letterCounts: Map<String, int>.from(_letterCounts),
        digitCounts: Map<String, int>.from(_digitCounts),
      ),
    );
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
      final collides = occupied.any(
        (o) => (candidate - o).distance < minDistance,
      );
      if (!collides) return candidate;
    }

    return Offset((minX + maxX) / 2, (minY + maxY) / 2);
  }

  Widget _buildCountdown() {
    final strings = AppStrings.of(context);

    return ExerciseCountdownBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
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
                        style: const TextStyle(
                          fontSize: 160,
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
                const Gap(16),
                Text(
                  strings.colorPodPrepare,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunning() {
    final strings = AppStrings.of(context);
    final totalMs = (widget.totalDuration * 1000).round();
    final elapsed = totalMs - _remainingMs;
    final progress = (elapsed / totalMs).clamp(0.0, 1.0);
    final remainSec = (_remainingMs / 1000).ceil();
    final isBlack = _currentColor == null;
    final isYellow = _currentColorId == 'yellow';
    final isGray = _currentColorId == 'mediumGray';
    final textColor = isBlack
        ? Colors.white
        : (isYellow || isGray ? Colors.black : _contrastColor(_currentColor!));
    final shapeColor = isYellow || isGray || _currentColorId == 'white'
        ? Colors.black
        : Colors.white;

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const shapeBox = 220.0;
          const textBox = 100.0;

          Widget anchored({
            required Offset anchor,
            required double box,
            required Widget child,
          }) {
            final margin = 8.0;
            final safeMaxLeft = (constraints.maxWidth - box - margin).clamp(
              0.0,
              double.infinity,
            );
            final safeMaxTop = (constraints.maxHeight - box - margin).clamp(
              0.0,
              double.infinity,
            );
            final left = (anchor.dx * constraints.maxWidth - box / 2).clamp(
              margin,
              safeMaxLeft,
            );
            final top = (anchor.dy * constraints.maxHeight - box / 2).clamp(
              margin,
              safeMaxTop,
            );

            return Positioned(
              left: left,
              top: top,
              child: SizedBox(
                width: box,
                height: box,
                child: Center(child: child),
              ),
            );
          }

          return Stack(
            children: [
              if (_currentShape != null && _shapeAnchor != null)
                anchored(
                  anchor: _shapeAnchor!,
                  box: shapeBox,
                  child: _shapeGlyph(
                    id: _currentShape!,
                    size: 200,
                    color: shapeColor,
                  ),
                ),
              if (_currentDigit != null && _digitAnchor != null)
                anchored(
                  anchor: _digitAnchor!,
                  box: textBox,
                  child: Text(
                    _currentDigit!,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: textColor.withValues(alpha: 0.95),
                      height: 1.0,
                    ),
                  ),
                ),
              if (_currentDirection != null && _directionAnchor != null)
                anchored(
                  anchor: _directionAnchor!,
                  box: textBox,
                  child: Icon(
                    _directionIcon(_currentDirection!),
                    size: 88,
                    color: textColor.withValues(alpha: 0.95),
                  ),
                ),
              if (_currentLetter != null && _letterAnchor != null)
                anchored(
                  anchor: _letterAnchor!,
                  box: textBox,
                  child: Text(
                    _currentLetter!,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: textColor.withValues(alpha: 0.95),
                      height: 1.0,
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
                top: 20,
                right: 12,
                child: SafeArea(
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      strings.colorPodStop,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _phase == _Phase.running
        ? (_currentColor ?? Colors.black)
        : Colors.black;

    Widget body;
    switch (_phase) {
      case _Phase.countdown:
        body = _buildCountdown();
        break;
      case _Phase.running:
        body = _buildRunning();
        break;
    }

    return Scaffold(
      backgroundColor: bgColor,
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
          child: _LandscapeWrapper(color: bgColor, child: body),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      _delayTimer?.cancel();
      _stopwatch?.stop();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _delayTimer?.cancel();
    _stopwatch?.stop();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }
}

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
  Widget build(BuildContext context) => SizedBox.expand(
    child: ColoredBox(color: widget.color, child: widget.child),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(1)} $unit',
                style: texts.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: colors.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$min $unit',
              style: texts.labelSmall?.copyWith(color: colors.secondary),
            ),
            Text(
              '$max $unit',
              style: texts.labelSmall?.copyWith(color: colors.secondary),
            ),
          ],
        ),
      ],
    );
  }
}
