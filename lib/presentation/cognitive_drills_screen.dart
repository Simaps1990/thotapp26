import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/timer_sound.dart';

enum _CognitiveDrillMode { direction, stroop }
enum _DirectionSubMode { fourArrows, leftRight, leftCenterRight, upDown, upDownCenter }
enum _StroopDifficulty { easy, medium, hard }
enum _StroopInkColor { red, blue, green, yellow }

class CognitiveDrillsScreen extends StatefulWidget {
  final bool stroopOnly;
  final bool autoStartStroop;

  const CognitiveDrillsScreen({
    super.key,
    this.stroopOnly = false,
    this.autoStartStroop = false,
  });
  @override
  State<CognitiveDrillsScreen> createState() => _CognitiveDrillsScreenState();
}

class _CognitiveDrillsScreenState extends State<CognitiveDrillsScreen> {
  _CognitiveDrillMode? _mode;
  _DirectionSubMode _directionSubMode = _DirectionSubMode.fourArrows;
  _StroopDifficulty _stroopDifficulty = _StroopDifficulty.easy;
  _StroopDifficulty _directionDifficulty = _StroopDifficulty.medium;
  List<Map<String, String>> _scoreHistory = [];
  static const String _scoreHistoryKey = 'cognitive_drill_score_history';

  @override
  void initState() {
    super.initState();
    if (widget.stroopOnly) {
      _mode = _CognitiveDrillMode.stroop;
    }
    _loadScoreHistory();
    if (widget.stroopOnly && widget.autoStartStroop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _start();
        }
      });
    }
  }

  Future<void> _loadScoreHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_scoreHistoryKey);
    if (historyJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        setState(() {
          _scoreHistory = decoded
              .whereType<Map>()
              .map((e) => e.map(
                    (key, value) => MapEntry(
                      key.toString(),
                      value?.toString() ?? '',
                    ),
                  ))
              .toList();
        });
      } catch (_) {}
    }
  }

  double _parseFirstNumber(String value) {
    final m = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(value);
    if (m == null) return double.infinity;
    return double.tryParse(m.group(1) ?? '') ?? double.infinity;
  }

  double _extractPrimaryScore(
    _CognitiveDrillMode mode,
    Map<String, String> stats,
    AppStrings strings,
  ) {
    switch (mode) {
      case _CognitiveDrillMode.direction:
        return _parseFirstNumber(stats[strings.cognitiveDrillResultsTotalDuration] ?? '');
      case _CognitiveDrillMode.stroop:
        final avgReaction = _parseFirstNumber(stats[strings.reflexesAvgReactionTime] ?? '');
        if (avgReaction.isFinite) return avgReaction;
        final conflict = _parseFirstNumber(stats[strings.cognitiveDrillStroopAvgConflict] ?? '');
        if (conflict.isFinite) return conflict;
        return _parseFirstNumber(stats[strings.cognitiveDrillStroopAvgCongruent] ?? '');
    }
  }

  Future<void> _saveScore(
    _CognitiveDrillMode mode,
    String modeLabel,
    String difficulty,
    Map<String, String> stats,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final strings = AppStrings.of(context);
    final primary = _extractPrimaryScore(mode, stats, strings);
    final entry = {
      '_modeKey': mode.name,
      'mode': modeLabel,
      'modeLabel': modeLabel,
      'difficulty': difficulty,
      'date': DateTime.now().toString().substring(0, 16),
      '_primary': primary.isFinite ? primary.toStringAsFixed(3) : '9999.000',
      ...stats,
    };
    setState(() {
      _scoreHistory.insert(0, entry);
      if (_scoreHistory.length > 10) _scoreHistory.removeLast();
    });
    await prefs.setString(_scoreHistoryKey, jsonEncode(_scoreHistory));
  }

  Future<void> _start() async {
    final mode = widget.stroopOnly ? _CognitiveDrillMode.stroop : _mode;
    if (mode == null) return;
    final strings = AppStrings.of(context);
    final result = await Navigator.of(context).push<Map<String, String>>(
      PageRouteBuilder<Map<String, String>>(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) {
          switch (mode) {
            case _CognitiveDrillMode.direction:
              return _StroopRunScreen(
                difficulty: _stroopDifficulty,
                history: _scoreHistory,
              );
            case _CognitiveDrillMode.stroop:
              return _StroopRunScreen(
                difficulty: _stroopDifficulty,
                history: _scoreHistory,
              );
          }
        },
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
    if (!mounted) return;
    if (result == null) {
      if (widget.stroopOnly && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }
    final closeToTools = result['_close_tools'] == '1';
    final cleanResult = Map<String, String>.from(result)..remove('_close_tools');
    final stoppedEarly = cleanResult['_stopped_early'] == '1';
    final modeLabel = strings.cognitiveDrillModeStroop;
    final difficultyLabel = _stroopDifficulty == _StroopDifficulty.easy
        ? strings.cognitiveDrillDifficultyEasy
        : _stroopDifficulty == _StroopDifficulty.medium
            ? strings.cognitiveDrillDifficultyMedium
            : strings.cognitiveDrillDifficultyHard;
    if (!stoppedEarly) {
      await _saveScore(mode, modeLabel, difficultyLabel, cleanResult);
    }
    if (!mounted) return;
    setState(() {});
    if (widget.stroopOnly && Navigator.canPop(context)) {
      if (closeToTools) {
        Navigator.pop(context, {'_close_tools': '1'});
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _showStroopDifficultyDialog(BuildContext context, AppStrings strings) async {
    final result = await _showDifficultyPicker(
      context: context,
      title: strings.cognitiveDrillDifficultyLabel,
      currentLevel: _stroopDifficulty.index + 1,
      options: [
        _DifficultyOption(
          label: strings.cognitiveDrillDifficultyEasy,
          subtitle: strings.cognitiveDrillStroopEasyCriteria,
          level: 1,
        ),
        _DifficultyOption(
          label: strings.cognitiveDrillDifficultyMedium,
          subtitle: strings.cognitiveDrillStroopMediumCriteria,
          level: 2,
        ),
        _DifficultyOption(
          label: strings.cognitiveDrillDifficultyHard,
          subtitle: strings.cognitiveDrillStroopHardCriteria,
          level: 3,
        ),
      ],
    );
    if (result != null && mounted) {
      setState(() => _stroopDifficulty = _StroopDifficulty.values[result - 1]);
    }
  }

  void _showDirectionSubmodeDialog(BuildContext context, AppStrings strings) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.cognitiveDrillDirectionSubmodeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.control_camera_rounded, color: colors.primary),
              title: Text(strings.cognitiveDrillDirectionSubmode4Arrows),
              subtitle: Text(strings.cognitiveDrillDirectionSubmode4ArrowsDesc, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionSubMode == _DirectionSubMode.fourArrows
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionSubMode = _DirectionSubMode.fourArrows);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz_rounded, color: colors.primary),
              title: Text(strings.cognitiveDrillDirectionSubmodeLeftRight),
              subtitle: Text(strings.cognitiveDrillDirectionSubmodeLeftRightDesc, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionSubMode == _DirectionSubMode.leftRight
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionSubMode = _DirectionSubMode.leftRight);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz_rounded, color: colors.primary),
              title: Text(strings.cognitiveDrillDirectionSubmodeLeftCenterRight),
              subtitle: Text(strings.cognitiveDrillDirectionSubmodeLeftCenterRightDesc, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionSubMode == _DirectionSubMode.leftCenterRight
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionSubMode = _DirectionSubMode.leftCenterRight);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_vert_rounded, color: colors.primary),
              title: Text(strings.cognitiveDrillDirectionSubmodeUpDown),
              subtitle: Text(strings.cognitiveDrillDirectionSubmodeUpDownDesc, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionSubMode == _DirectionSubMode.upDown
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionSubMode = _DirectionSubMode.upDown);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_vert_rounded, color: colors.primary),
              title: Text(strings.cognitiveDrillDirectionSubmodeUpDownCenter),
              subtitle: Text(strings.cognitiveDrillDirectionSubmodeUpDownCenterDesc, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionSubMode == _DirectionSubMode.upDownCenter
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionSubMode = _DirectionSubMode.upDownCenter);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectionDifficultyDialog(BuildContext context, AppStrings strings) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.cognitiveDrillDifficultyLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(strings.cognitiveDrillDifficultyEasy),
              subtitle: Text(strings.cognitiveDrillDirectionEasyCriteria, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionDifficulty == _StroopDifficulty.easy
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionDifficulty = _StroopDifficulty.easy);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(strings.cognitiveDrillDifficultyMedium),
              subtitle: Text(strings.cognitiveDrillDirectionMediumCriteria, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionDifficulty == _StroopDifficulty.medium
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionDifficulty = _StroopDifficulty.medium);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(strings.cognitiveDrillDifficultyHard),
              subtitle: Text(strings.cognitiveDrillDirectionHardCriteria, style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
              trailing: _directionDifficulty == _StroopDifficulty.hard
                  ? Icon(Icons.check_circle, color: colors.primary)
                  : null,
              onTap: () {
                setState(() => _directionDifficulty = _StroopDifficulty.hard);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stroopOnly) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(),
      );
    }

    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: baseBackground,
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
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              strings.cognitiveDrillsTitle.toUpperCase(),
                              style: textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                            const Gap(4),
                            Tooltip(
                              message: strings.cognitiveDrillsInfo,
                              triggerMode: TooltipTriggerMode.tap,
                              showDuration: const Duration(seconds: 4),
                              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.onSurface.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: textStyles.bodySmall?.copyWith(color: colors.surface),
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
                        child: Padding(
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(color: colors.outline.withValues(alpha: 0.45)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: AppSpacing.md, left: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DrillCard(
                        title: strings.cognitiveDrillModeStroop,
                        description: strings.cognitiveDrillModeStroopCardDescription,
                        icon: Icons.psychology,
                        onTap: () => setState(() => _mode = _CognitiveDrillMode.stroop),
                        isSelected: _mode == _CognitiveDrillMode.stroop,
                        colors: colors,
                        textStyles: textStyles,
                        isDark: isDark,
                        backgroundImage: 'assets/images/stroop.webp',
                      ),
                      if (_mode == _CognitiveDrillMode.stroop) ...[
                        const Gap(AppSpacing.md),
                        _SettingsGroup(
                          title: strings.cognitiveDrillSettingsTitle,
                          children: [
                            _SettingsItem(
                              icon: Icons.speed,
                              label: strings.cognitiveDrillDifficultyLabel,
                              subtitle: _stroopDifficulty == _StroopDifficulty.easy ? strings.cognitiveDrillDifficultyEasy : _stroopDifficulty == _StroopDifficulty.medium ? strings.cognitiveDrillDifficultyMedium : strings.cognitiveDrillDifficultyHard,
                              onTap: () => _showStroopDifficultyDialog(context, strings),
                              trailing: Icon(Icons.chevron_right_rounded, color: colors.onSurface.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.xl),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _start,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(strings.timerStartButton.toUpperCase()),
                          ),
                        ),
                        const Gap(AppSpacing.xl),
                      ],
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

class _DrillCard extends StatefulWidget {
  const _DrillCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.isSelected,
    required this.colors,
    required this.textStyles,
    required this.isDark,
    this.backgroundImage,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final ColorScheme colors;
  final TextTheme textStyles;
  final bool isDark;
  final String? backgroundImage;

  @override
  State<_DrillCard> createState() => _DrillCardState();
}

class _DrillCardState extends State<_DrillCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    
    if (widget.isSelected) {
      _shimmerController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(_DrillCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _shimmerController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.backgroundImage == null
              ? (widget.isSelected ? LightColors.primary : widget.colors.surface)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? widget.colors.outline.withValues(alpha: 0.3)
                : LightColors.surfaceHighlight,
            width: 1,
          ),
          boxShadow: AppShadows.cardPremium,
          image: widget.backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(widget.backgroundImage!),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: widget.isSelected ? 0.3 : 0.6),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
            if (widget.isSelected && widget.backgroundImage != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final progress = (_shimmerAnimation.value + 1) / 2;
                            final travel = constraints.maxWidth + 180;
                            final dx = (progress * travel) - 90;

                            return Transform.translate(
                              offset: Offset(dx, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 180,
                                  height: constraints.maxHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withValues(alpha: 0.18),
                                        Colors.white.withValues(alpha: 0.06),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.35, 0.65, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            Padding(
              padding: AppSpacing.paddingLg,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isSelected ? LightColors.primary.withValues(alpha: 0.3) : LightColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isSelected ? Colors.white : LightColors.primary,
                      size: 24,
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: widget.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.backgroundImage != null ? Colors.white : (widget.isSelected ? Colors.white : widget.colors.onSurface),
                            shadows: widget.backgroundImage != null ? [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          widget.description,
                          style: widget.textStyles.bodySmall?.copyWith(
                            color: widget.backgroundImage != null ? Colors.white.withValues(alpha: 0.9) : (widget.isSelected ? Colors.white.withValues(alpha: 0.8) : widget.colors.secondary),
                            shadows: widget.backgroundImage != null ? [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isSelected)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: textStyles.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.secondary,
          ),
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: 0.72)
                  : LightColors.surfaceHighlight,
              width: 1.35,
            ),
            boxShadow: AppShadows.cardPremium,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Icon(icon, color: colors.primary, size: 22),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: textStyles.bodySmall?.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _DirectionRunScreen extends StatefulWidget {
  const _DirectionRunScreen({required this.subMode, required this.difficulty, required this.history});
  final _DirectionSubMode subMode;
  final _StroopDifficulty difficulty;
  final List<Map<String, String>> history;
  @override
  State<_DirectionRunScreen> createState() => _DirectionRunScreenState();
}

class _DirectionRunScreenState extends State<_DirectionRunScreen> with WidgetsBindingObserver {
  final _random = Random();
  int _countdown = 3;
  bool _running = false;
  dynamic _stimulus;
  Stopwatch? _sw;
  Timer? _timer;
  final Map<String, int> _arrowCounts = {
    'up': 0,
    'down': 0,
    'left': 0,
    'right': 0,
  };
  bool _showResults = false;
  Map<String, String>? _currentResult;
  bool _aborted = false;

  double _parsePrimary(Map<String, String> entry) {
    return double.tryParse(entry['_primary'] ?? '') ?? double.infinity;
  }

  String _fmtDate(String value) => value.replaceFirst('-', '/').replaceFirst('-', '/');

  List<Map<String, String>> _top3(AppStrings strings) {
    final items = widget.history
        .where((e) => e['_modeKey'] == _CognitiveDrillMode.direction.name)
        .map((e) => Map<String, String>.from(e))
        .toList();
    final current = _currentResult;
    if (current != null) {
      items.add({
        '_modeKey': _CognitiveDrillMode.direction.name,
        'modeLabel': strings.cognitiveDrillModeDirection,
        'date': DateTime.now().toString().substring(0, 16),
        '_primary': (_parseFirstNumber(current[strings.cognitiveDrillResultsTotalDuration] ?? '')).toStringAsFixed(3),
        ...current,
      });
    }
    items.sort((a, b) => _parsePrimary(a).compareTo(_parsePrimary(b)));
    return items.take(3).toList();
  }

  double _parseFirstNumber(String value) {
    final m = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(value);
    if (m == null) return double.infinity;
    return double.tryParse(m.group(1) ?? '') ?? double.infinity;
  }

  int _getCount() => widget.difficulty == _StroopDifficulty.easy ? 10 : widget.difficulty == _StroopDifficulty.medium ? 15 : 20;
  int _getMs() => widget.difficulty == _StroopDifficulty.easy ? 1500 : widget.difficulty == _StroopDifficulty.medium ? 1200 : 900;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _countdownLoop();
  }
  Future<void> _countdownLoop() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
        try { await TimerSound.play(); } catch (_) {}
        try { if (await Vibration.hasVibrator()) Vibration.vibrate(duration: 200); } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 450));
        if (!mounted) return;
        setState(() => _running = true);
        _sw = Stopwatch()..start();
        _run();
      } else { setState(() => _countdown--); }
    });
  }
  Future<void> _run() async {
    final ms = _getMs();
    for (var i = 0; i < _getCount(); i++) {
      if (_aborted || !mounted) return;
      final stim = _pick();
      setState(() => _stimulus = stim);
      if (stim is IconData) {
        if (stim == Icons.arrow_upward_rounded) _arrowCounts['up'] = _arrowCounts['up']! + 1;
        if (stim == Icons.arrow_downward_rounded) _arrowCounts['down'] = _arrowCounts['down']! + 1;
        if (stim == Icons.arrow_back_rounded) _arrowCounts['left'] = _arrowCounts['left']! + 1;
        if (stim == Icons.arrow_forward_rounded) _arrowCounts['right'] = _arrowCounts['right']! + 1;
      }
      await Future.delayed(Duration(milliseconds: ms));
      if (_aborted || !mounted) return;
      setState(() => _stimulus = null);
      await Future.delayed(const Duration(seconds: 2));
    }
    if (_aborted || !mounted) return;
    final strings = AppStrings.of(context);
    final stats = <String, String>{
      strings.cognitiveDrillResultsStimuliCount: '${_getCount()}',
      strings.cognitiveDrillResultsStimulusDuration: _fmt(Duration(milliseconds: ms)),
      strings.cognitiveDrillResultsTotalDuration: _fmt(_sw?.elapsed ?? Duration.zero),
      strings.directionArrowsUp: '${_arrowCounts['up']}',
      strings.directionArrowsDown: '${_arrowCounts['down']}',
      strings.directionArrowsLeft: '${_arrowCounts['left']}',
      strings.directionArrowsRight: '${_arrowCounts['right']}',
    };
    setState(() {
      _currentResult = stats;
      _showResults = true;
    });
  }
  void _stop() {
    _aborted = true;
    _timer?.cancel();
    _sw?.stop();
    if (!mounted) return;
    if (_arrowCounts.values.any((v) => v > 0)) {
      final strings = AppStrings.of(context);
      final stats = <String, String>{
        strings.cognitiveDrillResultsStimuliCount: '${_arrowCounts.values.reduce((a, b) => a + b)}',
        strings.cognitiveDrillResultsTotalDuration: _fmt(_sw?.elapsed ?? Duration.zero),
        strings.directionArrowsUp: '${_arrowCounts['up']}',
        strings.directionArrowsDown: '${_arrowCounts['down']}',
        strings.directionArrowsLeft: '${_arrowCounts['left']}',
        strings.directionArrowsRight: '${_arrowCounts['right']}',
      };
      setState(() {
        _currentResult = stats;
        _showResults = true;
      });
    } else {
      Navigator.pop(context);
    }
  }
  dynamic _pick() {
    switch (widget.subMode) {
      case _DirectionSubMode.fourArrows:
        return [Icons.arrow_upward_rounded, Icons.arrow_downward_rounded, Icons.arrow_back_rounded, Icons.arrow_forward_rounded][_random.nextInt(4)];
      case _DirectionSubMode.leftRight:
        return [Icons.arrow_back_rounded, Icons.arrow_forward_rounded][_random.nextInt(2)];
      case _DirectionSubMode.leftCenterRight:
        return [Icons.arrow_back_rounded, Icons.remove_rounded, Icons.arrow_forward_rounded][_random.nextInt(3)];
      case _DirectionSubMode.upDown:
        return [Icons.arrow_upward_rounded, Icons.arrow_downward_rounded][_random.nextInt(2)];
      case _DirectionSubMode.upDownCenter:
        return [Icons.arrow_upward_rounded, Icons.remove_rounded, Icons.arrow_downward_rounded][_random.nextInt(3)];
    }
  }
  String _fmt(Duration d) => '${(d.inMilliseconds / 1000).toStringAsFixed(2)} s';
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Pause clean en background : annule timers + stopwatch, ferme l'écran 
      // sans afficher de résultats partiels (le user revient et voit 
      // l'écran outils, pas un récap inattendu).
      _aborted = true;
      _timer?.cancel();
      _sw?.stop();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    _sw?.stop();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final texts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    
    if (_showResults && _currentResult != null) {
      final top3 = _top3(strings);
      final baseBackground = Theme.of(context).scaffoldBackgroundColor;
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: MediaQuery.of(context).size.height * 0.86,
            decoration: BoxDecoration(
              color: baseBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(_currentResult),
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
                      strings.cognitiveDrillResultTitle,
                      textAlign: TextAlign.center,
                      style: texts.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(_currentResult),
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
                            strings.cognitiveDrillResultsTitle,
                            style: texts.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.secondary,
                            ),
                          ),
                          const Gap(AppSpacing.md),
                          ..._currentResult!.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Text(
                                  e.value,
                                  style: texts.titleMedium?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    if (_arrowCounts.values.any((v) => v > 0))
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
                              strings.cognitiveDrillDirectionArrowsBreakdown,
                              style: texts.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.secondary,
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            ...[
                              ('up', Icons.arrow_upward_rounded, strings.directionArrowsUp),
                              ('down', Icons.arrow_downward_rounded, strings.directionArrowsDown),
                              ('left', Icons.arrow_back_rounded, strings.directionArrowsLeft),
                              ('right', Icons.arrow_forward_rounded, strings.directionArrowsRight),
                            ].where((e) => (_arrowCounts[e.$1] ?? 0) > 0).map((e) {
                              final count = _arrowCounts[e.$1] ?? 0;
                              final total = _arrowCounts.values.fold<int>(0, (a, b) => a + b);
                              final pct = total == 0 ? 0.0 : count / total;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: Row(
                                  children: [
                                    Icon(e.$2, color: colors.primary, size: 22),
                                    const Gap(AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(e.$3, style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                              Text('$count × (${(pct * 100).toStringAsFixed(0)}%)', style: texts.bodySmall?.copyWith(color: colors.secondary)),
                                            ],
                                          ),
                                          const Gap(4),
                                          LinearProgressIndicator(
                                            value: pct,
                                            backgroundColor: colors.outline.withValues(alpha: 0.2),
                                            color: colors.primary,
                                            minHeight: 6,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    const Gap(AppSpacing.lg),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _showResults = false;
                            _currentResult = null;
                            _aborted = false;
                            _countdown = 3;
                            _running = false;
                            _stimulus = null;
                            _arrowCounts.updateAll((key, value) => 0);
                            _sw = null;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _countdownLoop();
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
                              Icon(Icons.emoji_events_rounded, color: colors.primary),
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
                          if (top3.isEmpty)
                            Text(strings.cognitiveDrillNoScores, style: texts.bodyMedium?.copyWith(color: colors.secondary))
                          else
                            ...top3.asMap().entries.map((entry) {
                              final index = entry.key;
                              final row = entry.value;
                              final medalColor = index == 0
                                  ? const Color(0xFFFFC107)
                                  : index == 1
                                      ? const Color(0xFFB0BEC5)
                                      : const Color(0xFFCD7F32);
                              final score = _parsePrimary(row);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: Row(
                                  children: [
                                    Icon(Icons.workspace_premium_rounded, color: medalColor, size: 20),
                                    const Gap(AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        score.isFinite ? '${score.toStringAsFixed(2)} s' : '—',
                                        style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Text(
                                      _fmtDate(row['date'] ?? ''),
                                      style: texts.bodySmall?.copyWith(color: colors.secondary),
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
    
    return Scaffold(backgroundColor: Colors.black, body: Stack(children: [
      _LandscapeWrapper(color: Colors.black, child: _running ? _DirectionStimulusView(stimulus: _stimulus) : _ExerciseCountdown(value: _countdown, title: strings.cognitiveDrillModeDirection)),
      Positioned(top: 20, right: 12, child: SafeArea(child: TextButton(onPressed: _stop, child: Text(strings.colorPodStop, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 14)))))
    ]));
  }
}

class _StroopRunScreen extends StatefulWidget {
  const _StroopRunScreen({required this.difficulty, required this.history});
  final _StroopDifficulty difficulty;
  final List<Map<String, String>> history;
  @override State<_StroopRunScreen> createState() => _StroopRunScreenState();
}

class _StroopRunScreenState extends State<_StroopRunScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  int _countdown = 3;
  bool _running = false;
  Timer? _timer;
  Stopwatch? _rt;
  _StroopInkColor? _word;
  _StroopInkColor? _ink;
  bool _congruent = false;
  bool _responded = false;
  final _cong = <Duration>[];
  final _conf = <Duration>[];
  final _reactionTimes = <Duration>[];
  int _responses = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  final Map<String, int> _wordCounts = {
    'red': 0,
    'blue': 0,
    'green': 0,
    'yellow': 0,
  };
  final Map<String, int> _inkCounts = {
    'red': 0,
    'blue': 0,
    'green': 0,
    'yellow': 0,
  };
  bool _showResults = false;
  Map<String, String>? _currentResult;
  bool _aborted = false;
  late final AnimationController _feedbackAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  String? _answerFeedbackText;
  Color? _answerFeedbackTextColor;
  Color? _answerFeedbackBgColor;
  Color? _answerFeedbackAccentColor;
  Completer<void> _responseCompleter = Completer<void>();
  bool? _lastAnswerCorrect;
  int _lastResponseMs = 0;
  int _stimuliShown = 0;

  double _parsePrimary(Map<String, String> entry) {
    return double.tryParse(entry['_primary'] ?? '') ?? double.infinity;
  }

  String _fmtDate(String value) => value.replaceFirst('-', '/').replaceFirst('-', '/');

  double _parseFirstNumber(String value) {
    final m = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(value);
    if (m == null) return double.infinity;
    return double.tryParse(m.group(1) ?? '') ?? double.infinity;
  }

  List<Map<String, String>> _top3(AppStrings strings) {
    final items = widget.history
        .where((e) => e['_modeKey'] == _CognitiveDrillMode.stroop.name)
        .map((e) => Map<String, String>.from(e))
        .where((e) {
          final p = _parsePrimary(e);
          return p.isFinite && p > 50;
        })
        .toList();
    final current = _currentResult;
    if (current != null) {
      final primary = _parseFirstNumber(current[strings.reflexesAvgReactionTime] ?? '');
      if (primary.isFinite && primary > 50) {
        items.add({
          '_modeKey': _CognitiveDrillMode.stroop.name,
          'modeLabel': strings.cognitiveDrillModeStroop,
          'date': DateTime.now().toString().substring(0, 16),
          '_primary': primary.toStringAsFixed(3),
          ...current,
        });
      }
    }
    items.sort((a, b) => _parsePrimary(a).compareTo(_parsePrimary(b)));
    return items.take(3).toList();
  }
  
  int _getCount() => widget.difficulty == _StroopDifficulty.easy ? 15 : widget.difficulty == _StroopDifficulty.medium ? 20 : 25;

  void _closeToTools() {
    final current = _currentResult;
    if (current == null) {
      Navigator.of(context).pop();
      return;
    }
    final payload = Map<String, String>.from(current)..['_close_tools'] = '1';
    Navigator.of(context).pop(payload);
  }

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _loop();
  }
  Future<void> _loop() async { _timer = Timer.periodic(const Duration(seconds: 1), (t) async { if (_countdown <= 1) { t.cancel(); setState(() => _countdown = 0); try { await TimerSound.play(); } catch (_) {} await Future.delayed(const Duration(milliseconds: 450)); if (!mounted) return; setState(() { _running = true; _stimuliShown = 0; }); _run(); } else { setState(() => _countdown--); } }); }
  Future<void> _run() async {
    for (var i = 0; i < _getCount(); i++) {
      if (_aborted || !mounted) break;
      final stim = _pick(i);
      _word = stim.$1; _ink = stim.$2; _congruent = stim.$3; _responded = false;
      _lastResponseMs = 0;
      _rt = Stopwatch()..start();
      _wordCounts[_word!.name] = _wordCounts[_word!.name]! + 1;
      _inkCounts[_ink!.name] = _inkCounts[_ink!.name]! + 1;
      _stimuliShown = i + 1;
      if (mounted) setState(() {});
      
      _responseCompleter = Completer<void>();
      final responseFuture = _responseCompleter.future;
      
      await responseFuture;
      if (_aborted || !mounted) break;
      
      _rt?.stop();
      _showAnswerFeedback(_lastAnswerCorrect ?? false, _lastResponseMs);
      await Future.delayed(const Duration(seconds: 1));
      if (_aborted || !mounted) break;
      
      if (mounted) {
        setState(() {
          _answerFeedbackText = null;
          _word = null;
          _ink = null;
        });
      }
      await Future.delayed(const Duration(milliseconds: 180));
    }
    if (_aborted || !mounted) return;
    final strings = AppStrings.of(context);
    final shown = _wordCounts.values.fold<int>(0, (a, b) => a + b);
    final stats = <String, String>{
      'mode': 'stroop',
      'difficulty': widget.difficulty.name,
      strings.cognitiveDrillResultsStimuliCount: '$shown',
      strings.cognitiveDrillResultsResponses: '$_responses',
      strings.reflexesAvgReactionTime: _avgMs(_reactionTimes),
      strings.reflexesMathCorrectAnswers: '$_correctAnswers',
      strings.reflexesMathWrongAnswers: '$_wrongAnswers',
      strings.cognitiveDrillStroopAvgCongruent: _avg(_cong),
      strings.cognitiveDrillStroopAvgConflict: _avg(_conf),
      strings.stroopWordsRed: '${_wordCounts['red']}',
      strings.stroopWordsBlue: '${_wordCounts['blue']}',
      strings.stroopWordsGreen: '${_wordCounts['green']}',
      strings.stroopWordsYellow: '${_wordCounts['yellow']}',
      strings.stroopInkRed: '${_inkCounts['red']}',
      strings.stroopInkBlue: '${_inkCounts['blue']}',
      strings.stroopInkGreen: '${_inkCounts['green']}',
      strings.stroopInkYellow: '${_inkCounts['yellow']}',
    };
    setState(() {
      _currentResult = stats;
      _showResults = true;
    });
  }
  void _stop() {
    _aborted = true;
    _timer?.cancel();
    _rt?.stop();
    if (!mounted) return;
    if (_wordCounts.values.any((v) => v > 0)) {
      final strings = AppStrings.of(context);
      final stats = <String, String>{
        'mode': 'stroop',
        'difficulty': widget.difficulty.name,
        strings.cognitiveDrillResultsStimuliCount: '${_wordCounts.values.reduce((a, b) => a + b)}',
        strings.cognitiveDrillResultsResponses: '$_responses',
        strings.reflexesAvgReactionTime: _avgMs(_reactionTimes),
        strings.reflexesMathCorrectAnswers: '$_correctAnswers',
        strings.reflexesMathWrongAnswers: '$_wrongAnswers',
        strings.cognitiveDrillStroopAvgCongruent: _avg(_cong),
        strings.cognitiveDrillStroopAvgConflict: _avg(_conf),
        strings.stroopWordsRed: '${_wordCounts['red']}',
        strings.stroopWordsBlue: '${_wordCounts['blue']}',
        strings.stroopWordsGreen: '${_wordCounts['green']}',
        strings.stroopWordsYellow: '${_wordCounts['yellow']}',
        strings.stroopInkRed: '${_inkCounts['red']}',
        strings.stroopInkBlue: '${_inkCounts['blue']}',
        strings.stroopInkGreen: '${_inkCounts['green']}',
        strings.stroopInkYellow: '${_inkCounts['yellow']}',
        '_stopped_early': '1',
      };
      setState(() {
        _currentResult = stats;
        _showResults = true;
      });
    } else {
      Navigator.pop(context);
    }
  }
  (_StroopInkColor, _StroopInkColor, bool) _pick(int i) {
    // Ratio de congruence selon difficulté :
    // Easy 60% congruents, Medium 50%, Hard 30%
    final congruentRatio = widget.difficulty == _StroopDifficulty.easy
        ? 0.60
        : widget.difficulty == _StroopDifficulty.medium
            ? 0.50
            : 0.30;
    final congruent = _random.nextDouble() < congruentRatio;
    final ink = _StroopInkColor.values[_random.nextInt(4)];
    if (congruent) return (ink, ink, true);
    final words = _StroopInkColor.values.where((e) => e != ink).toList();
    return (words[_random.nextInt(words.length)], ink, false);
  }
  void _respond(_StroopInkColor selectedColor) {
    if (!_running || _word == null || _ink == null || _responded) return;
    _responded = true;
    _responses++;
    if (_rt == null) {
      _rt = Stopwatch()..start();
    }
    final d = _rt?.elapsed ?? Duration.zero;
    _lastResponseMs = d.inMilliseconds;
    _rt?.stop();
    final isCorrect = selectedColor == _ink;
    _lastAnswerCorrect = isCorrect;
    if (isCorrect) {
      _correctAnswers++;
      // Only add reaction times that are realistic (> 50ms) to avoid 0ms or anomalous values
      if (d.inMilliseconds > 50) {
        _reactionTimes.add(d);
        (_congruent ? _cong : _conf).add(d);
      }
    } else {
      _wrongAnswers++;
    }
    if (!_responseCompleter.isCompleted) {
      _responseCompleter.complete();
    }
    setState(() {});
  }

  void _showAnswerFeedback(bool isCorrect, int ms) {
    setState(() {
      _answerFeedbackText = isCorrect ? 'BONNE REPONSE • $ms ms' : 'MAUVAISE REPONSE • $ms ms';
      _answerFeedbackTextColor = isCorrect ? const Color(0xFFE8FFF4) : const Color(0xFFFFECEF);
      _answerFeedbackBgColor = isCorrect ? const Color(0xFF0D402A) : const Color(0xFF4C1621);
      _answerFeedbackAccentColor = isCorrect ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    });
    _feedbackAnimationController.reset();
    _feedbackAnimationController.forward();
  }

  String _avgMs(List<Duration> list) {
    if (list.isEmpty) return '—';
    final avgMs = list.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds) / list.length;
    return '${avgMs.toStringAsFixed(0)} ms';
  }

  String _avg(List<Duration> l) => l.isEmpty ? '—' : '${(l.fold<int>(0, (a, b) => a + b.inMilliseconds) / l.length / 1000).toStringAsFixed(2)} s';

  Widget _buildAnswerButton(
    AppStrings strings,
    _StroopInkColor color,
  ) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: FilledButton(
          onPressed: (_running && _ink != null) ? () => _respond(color) : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.black.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            _stroopColorLabel(strings, color).toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBubble({
    required String text,
    required Color? textColor,
    required Color? bgColor,
    required Color? accentColor,
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: _feedbackAnimationController,
      builder: (_, __) {
        final t = _feedbackAnimationController.value;
        final appear = Curves.easeOutBack.transform((t / 0.32).clamp(0.0, 1.0));
        final vanish = ((t - 0.65) / 0.35).clamp(0.0, 1.0);
        final scale = 0.72 + (appear * 0.28) - (vanish * 0.08);
        final opacity = ((1.0 - vanish) * (0.65 + 0.35 * appear)).clamp(0.0, 1.0).toDouble();
        final y = (16 * (1.0 - appear)) - (22 * vanish);
        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, y),
            child: Opacity(
              opacity: opacity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (bgColor ?? const Color(0xFF1E2432)).withValues(alpha: 0.98),
                      (accentColor ?? const Color(0xFF00E676)).withValues(alpha: 0.26),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (accentColor ?? Colors.white).withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (accentColor ?? Colors.black).withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 1.5,
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
                    Icon(icon, color: accentColor, size: 18),
                    const Gap(6),
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _aborted = true;
      _timer?.cancel();
      _rt?.stop();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  @override void dispose() {
    _timer?.cancel();
    _rt?.stop();
    _feedbackAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }
  @override Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final texts = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final showChoices = _running && _ink != null;
    
    if (_showResults && _currentResult != null) {
      final top3 = _top3(strings);
      final baseBackground = Theme.of(context).scaffoldBackgroundColor;
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
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: LightColors.iconInactive.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
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
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: LightColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Gap(AppSpacing.sm),
                            Expanded(
                              child: Text(
                                strings.reflexesResultsTitle,
                                textAlign: TextAlign.center,
                                style: texts.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _closeToTools,
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
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Divider(color: colors.outline),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: AppSpacing.paddingLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          strings.cognitiveDrillResultsStimuliCount,
                                          style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        _currentResult![strings.cognitiveDrillResultsStimuliCount] ?? '0',
                                        style: texts.titleMedium?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          strings.reflexesAvgReactionTime,
                                          style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        _currentResult![strings.reflexesAvgReactionTime] ?? '—',
                                        style: texts.titleMedium?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          strings.reflexesMathCorrectAnswers,
                                          style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        _currentResult![strings.reflexesMathCorrectAnswers] ?? '0',
                                        style: texts.titleMedium?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          strings.reflexesMathWrongAnswers,
                                          style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        _currentResult![strings.reflexesMathWrongAnswers] ?? '0',
                                        style: texts.titleMedium?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          strings.reflexesDifficultyLabel,
                                          style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      Text(
                                        widget.difficulty == _StroopDifficulty.easy
                                            ? strings.reflexesDifficultyEasy
                                            : widget.difficulty == _StroopDifficulty.medium
                                                ? strings.reflexesDifficultyMedium
                                                : strings.reflexesDifficultyHard,
                                        style: texts.titleMedium?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.lg),
                            SizedBox(
                              height: 52,
                              child: FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _showResults = false;
                                    _currentResult = null;
                                    _aborted = false;
                                    _countdown = 3;
                                    _running = false;
                                    _word = null;
                                    _ink = null;
                                    _responded = false;
                                    _responses = 0;
                                    _correctAnswers = 0;
                                    _wrongAnswers = 0;
                                    _reactionTimes.clear();
                                    _cong.clear();
                                    _conf.clear();
                                    _wordCounts.updateAll((key, value) => 0);
                                    _inkCounts.updateAll((key, value) => 0);
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) _loop();
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
                                      Icon(Icons.emoji_events_rounded, color: colors.primary),
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
                                  if (top3.isEmpty)
                                    Text(
                                      strings.cognitiveDrillNoScores,
                                      style: texts.bodyMedium?.copyWith(color: colors.secondary),
                                    )
                                  else
                                    ...top3.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final row = entry.value;
                                      final medalColor = index == 0
                                          ? const Color(0xFFFFC107)
                                          : index == 1
                                              ? const Color(0xFFB0BEC5)
                                              : const Color(0xFFCD7F32);
                                      final score = _parsePrimary(row);
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                        child: Row(
                                          children: [
                                            Icon(Icons.workspace_premium_rounded, color: medalColor, size: 20),
                                            const Gap(AppSpacing.sm),
                                            Expanded(
                                              child: Text(
                                                score.isFinite ? '${score.toStringAsFixed(0)} ms' : '—',
                                                style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                            Text(
                                              _fmtDate(row['date'] ?? ''),
                                              style: texts.bodySmall?.copyWith(color: colors.secondary),
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

    Color _getHardModeBackground() {
      if (widget.difficulty != _StroopDifficulty.hard) return Colors.black;
      if (_ink == null) return Colors.black;
      final allColors = [
        const Color(0xFFE53935), // red
        const Color(0xFF1E88E5), // blue
        const Color(0xFF43A047), // green
        const Color(0xFFFDD835), // yellow
      ];
      
      final currentColor = _stroopColor(_ink!);
      final availableColors = allColors.where((c) => c != currentColor).toList();
      return availableColors[_random.nextInt(availableColors.length)];
    }
    
    final hardBg = _getHardModeBackground();
    return Scaffold(
      backgroundColor: hardBg,
      body: Stack(
        children: [
          _LandscapeWrapper(
            color: hardBg,
            child: Column(
              children: [
                Expanded(
                  child: _running
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.linear,
                          switchOutCurve: Curves.linear,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                              child: child,
                            );
                          },
                          child: _word == null || _ink == null
                              ? const SizedBox.expand(key: ValueKey('stroop-empty'))
                              : _StroopStimulusView(
                                  key: ValueKey('stroop-${_stimuliShown}-${_word!.name}-${_ink!.name}'),
                                  word: _word,
                                  ink: _ink,
                                ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final maxHeight = constraints.maxHeight;
                            final targetNumberSize = _countdown > 0 ? 160.0 : 120.0;
                            final numberFontSize = min(targetNumberSize, maxHeight * 0.62);
                            final prepareFontSize = min(18.0, max(14.0, maxHeight * 0.075));
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
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
                                              style: TextStyle(
                                                fontSize: numberFontSize,
                                                fontWeight: FontWeight.w900,
                                                color: _countdown > 0 ? Colors.white : Colors.greenAccent,
                                                letterSpacing: -4,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (_countdown > 0) ...[
                                      const Gap(12),
                                      Text(
                                        strings.colorPodPrepare,
                                        style: TextStyle(
                                          fontSize: prepareFontSize,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: _running ? AppSpacing.sm : 0,
                  ),
                  child: SizedBox(
                    height: _running ? 22 : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOut,
                      opacity: showChoices ? 1 : 0,
                      child: Text(
                        strings.cognitiveDrillModeStroopDescription,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      _running ? AppSpacing.sm : 0,
                      AppSpacing.lg,
                      _running ? AppSpacing.lg : 0,
                    ),
                    child: SizedBox(
                      height: _running ? 52 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOut,
                        opacity: showChoices ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !showChoices,
                          child: Row(
                            children: [
                              _buildAnswerButton(strings, _StroopInkColor.red),
                              const Gap(AppSpacing.sm),
                              _buildAnswerButton(strings, _StroopInkColor.blue),
                              const Gap(AppSpacing.sm),
                              _buildAnswerButton(strings, _StroopInkColor.green),
                              const Gap(AppSpacing.sm),
                              _buildAnswerButton(strings, _StroopInkColor.yellow),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 12,
            child: SafeArea(
              child: _running
                  ? Text(
                      '$_stimuliShown/${_getCount()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          if (_answerFeedbackText != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: const Alignment(0, -0.62),
                  child: _buildFeedbackBubble(
                    text: _answerFeedbackText!,
                    textColor: _answerFeedbackTextColor,
                    bgColor: _answerFeedbackBgColor,
                    accentColor: _answerFeedbackAccentColor,
                    icon: Icons.flash_on_rounded,
                  ),
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
}

class _ExerciseCountdown extends StatelessWidget {
  const _ExerciseCountdown({required this.value, required this.title});
  final int value; final String title;
  @override Widget build(BuildContext context) { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w700)), const Gap(24), Text('$value', style: const TextStyle(color: Colors.white, fontSize: 110, fontWeight: FontWeight.w900))])); }
}

class _DirectionStimulusView extends StatefulWidget {
  const _DirectionStimulusView({required this.stimulus});
  final dynamic stimulus;
  @override
  State<_DirectionStimulusView> createState() => _DirectionStimulusViewState();
}

class _DirectionStimulusViewState extends State<_DirectionStimulusView> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_DirectionStimulusView old) {
    super.didUpdateWidget(old);
    if (old.stimulus != widget.stimulus) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Offset _offsetForArrow(IconData icon, double t) {
    double phase1 = (t / 0.25).clamp(0.0, 1.0);
    double phase3 = ((t - 0.65) / 0.35).clamp(0.0, 1.0);
    
    double dx = 0, dy = 0;
    if (icon == Icons.arrow_upward_rounded) {
      dy = -1.0;
    } else if (icon == Icons.arrow_downward_rounded) {
      dy = 1.0;
    } else if (icon == Icons.arrow_back_rounded) {
      dx = -1.0;
    } else if (icon == Icons.arrow_forward_rounded) {
      dx = 1.0;
    }
    final entryX = -dx * 200 * (1 - phase1);
    final entryY = -dy * 200 * (1 - phase1);
    final exitX = dx * 300 * phase3;
    final exitY = dy * 300 * phase3;
    return Offset(entryX + exitX, entryY + exitY);
  }

  double _opacityForArrow(double t) {
    if (t < 0.1) return t * 10;
    if (t > 0.9) return 1 - (t - 0.9) * 10;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final stim = widget.stimulus;
    if (stim == null) return const SizedBox.expand();
    if (stim is! IconData) return const SizedBox.expand();
    if (stim == Icons.remove_rounded) {
      return Center(child: Icon(stim, color: Colors.white, size: 220));
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final offset = _offsetForArrow(stim, t);
        final opacity = _opacityForArrow(t);
        return Center(
          child: Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: opacity,
              child: Icon(stim, color: Colors.white, size: 220),
            ),
          ),
        );
      },
    );
  }
}

class _StroopStimulusView extends StatelessWidget {
  const _StroopStimulusView({super.key, required this.word, required this.ink});
  final _StroopInkColor? word; final _StroopInkColor? ink;
  @override Widget build(BuildContext context) {
    if (word == null || ink == null) return const SizedBox.expand();
    final strings = AppStrings.of(context);
    return Center(
      child: Transform.translate(
        offset: const Offset(0, 52),
        child: Text(
          _stroopName(strings, word!),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _stroopColor(ink!),
            fontSize: 110,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeWrapper extends StatefulWidget {
  const _LandscapeWrapper({required this.color, required this.child});
  final Color color; final Widget child;
  @override State<_LandscapeWrapper> createState() => _LandscapeWrapperState();
}

class _LandscapeWrapperState extends State<_LandscapeWrapper> {
  @override void initState() { super.initState(); SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]); }
  @override void dispose() { SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); super.dispose(); }
  @override Widget build(BuildContext context) => ColoredBox(color: widget.color, child: SizedBox.expand(child: widget.child));
}

class _DifficultyOption {
  const _DifficultyOption({
    required this.label,
    required this.subtitle,
    required this.level,
  });
  final String label;
  final String subtitle;
  final int level;
}

Future<int?> _showDifficultyPicker({
  required BuildContext context,
  required String title,
  required List<_DifficultyOption> options,
  required int currentLevel,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _DifficultyPickerSheet(
      title: title,
      options: options,
      currentLevel: currentLevel,
    ),
  );
}

class _DifficultyPickerSheet extends StatelessWidget {
  const _DifficultyPickerSheet({
    required this.title,
    required this.options,
    required this.currentLevel,
  });

  final String title;
  final List<_DifficultyOption> options;
  final int currentLevel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LightColors.iconInactive.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: options.map((opt) {
                final isSelected = opt.level == currentLevel;
                final levelColor = opt.level == 1
                    ? const Color(0xFF66BB6A)
                    : opt.level == 2
                        ? const Color(0xFFFFB300)
                        : const Color(0xFFEF5350);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(opt.level),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? LightColors.primary
                              : (isDark
                                  ? colors.outline.withValues(alpha: 0.3)
                                  : LightColors.surfaceHighlight),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: AppShadows.cardPremium,
                      ),
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(3, (i) {
                              final filled = i < opt.level;
                              return Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Container(
                                  width: 4,
                                  height: 6 + ((2 - i) * 4).toDouble(),
                                  decoration: BoxDecoration(
                                    color: filled
                                        ? levelColor
                                        : colors.outline.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const Gap(AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.label,
                                  style: textStyles.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                  ),
                                ),
                                if (opt.subtitle.isNotEmpty) ...[
                                  const Gap(4),
                                  Text(
                                    opt.subtitle,
                                    style: textStyles.bodySmall?.copyWith(
                                      color: colors.secondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Gap(AppSpacing.md),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? LightColors.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? LightColors.primary
                                    : colors.outline.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

Color _stroopColor(_StroopInkColor color) {
  switch (color) {
    case _StroopInkColor.red: return const Color(0xFFE53935);
    case _StroopInkColor.blue: return const Color(0xFF1E88E5);
    case _StroopInkColor.green: return const Color(0xFF43A047);
    case _StroopInkColor.yellow: return const Color(0xFFFDD835);
  }
}

String _stroopName(AppStrings strings, _StroopInkColor color) {
  switch (color) {
    case _StroopInkColor.red: return strings.colorPodRed.toUpperCase();
    case _StroopInkColor.blue: return strings.colorPodBlue.toUpperCase();
    case _StroopInkColor.green: return strings.colorPodGreen.toUpperCase();
    case _StroopInkColor.yellow: return strings.colorPodYellow.toUpperCase();
  }
}

String _stroopColorLabel(AppStrings strings, _StroopInkColor color) {
  switch (color) {
    case _StroopInkColor.red: return strings.colorPodRed;
    case _StroopInkColor.blue: return strings.colorPodBlue;
    case _StroopInkColor.green: return strings.colorPodGreen;
    case _StroopInkColor.yellow: return strings.colorPodYellow;
  }
}
