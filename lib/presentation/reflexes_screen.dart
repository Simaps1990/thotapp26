import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';

import 'package:thot/l10n/app_strings.dart';
import 'package:thot/presentation/exercise_levels_screen.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/timer_sound.dart';
import 'package:thot/utils/exercise_level_params.dart';
import 'package:thot/data/training_history.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/widgets/exercise_countdown_background.dart';
import 'package:thot/presentation/pro_screen.dart';

part 'reflexes/result_widgets.dart';
part 'reflexes/shared_widgets.dart';
part 'reflexes/levels_panel.dart';
part 'reflexes/visual_test.dart';
part 'reflexes/auditory_test.dart';
part 'reflexes/math_test.dart';
part 'reflexes/memory_test.dart';
part 'reflexes/stroop_test.dart';
part 'reflexes/mot_test.dart';
part 'reflexes/dissociation_test.dart';

enum _ReflexesMode { visual, auditory, math, memory, stroop, mot, dissociation }

enum _ReactionDifficulty { easy, medium, hard }

enum _MathDifficulty { easy, medium, hard }

enum _MathOperator {
  addition,
  subtraction,
  multiplication,
  division,
  mixed,
  addSubOnly,
  addSubMul,
}

enum _MemoryDifficulty { easy, medium, hard }

enum _StroopDifficulty { easy, medium, hard }

enum _StroopInkColor { red, blue, green, yellow }

enum _MotDifficulty { easy, medium, hard }

class ReflexesScreen extends StatefulWidget {
  const ReflexesScreen({super.key});

  @override
  State<ReflexesScreen> createState() => _ReflexesScreenState();
}

class _ReflexesScreenState extends State<ReflexesScreen>
    with SingleTickerProviderStateMixin {
  static const _historyKey = 'reflexes_benchmark_history_v1';

  late final TabController _tabController =
      TabController(length: 7, vsync: this)..addListener(() {
        if (_tabController.indexIsChanging) return;
        setState(() => _mode = _ReflexesMode.values[_tabController.index]);
      });

  _ReflexesMode? _mode;
  bool _showModePanel = false;
  bool _showLevelsPanel = false;
  _ReactionDifficulty _reactionDifficulty = _ReactionDifficulty.medium;
  _MathDifficulty _mathDifficulty = _MathDifficulty.easy;
  _MemoryDifficulty _memoryDifficulty = _MemoryDifficulty.easy;
  _StroopDifficulty _stroopDifficulty = _StroopDifficulty.medium;
  _MotDifficulty _motDifficulty = _MotDifficulty.medium;
  final int _memoryRounds = 6;
  Map<String, List<_ReflexSessionRecord>> _historyByMode = {};

  // ignore: unused_element
  void _openModePanel(_ReflexesMode mode) {
    setState(() {
      _mode = mode;
      _showModePanel = true;
      _showLevelsPanel = false;
    });
  }

  void _closeModePanel() {
    setState(() {
      _showModePanel = false;
      _showLevelsPanel = false;
    });
  }

  void _openLevelsPanelForMode(_ReflexesMode mode) {
    final provider = context.read<ThotProvider>();
    if (provider.isReflexesModeLockedForFree(mode.name)) {
      showProModal(context);
      return;
    }
    setState(() {
      _mode = mode;
      _showModePanel = false;
      _showLevelsPanel = true;
    });
  }

  void _closeLevelsPanel() {
    setState(() {
      _showLevelsPanel = false;
    });
  }

  String _selectedModeDescription(AppStrings strings) {
    switch (_mode) {
      case _ReflexesMode.visual:
        return strings.reflexesModeVisualDescription;
      case _ReflexesMode.auditory:
        return '${strings.reflexesModeAuditoryDescription}\n\n${strings.reflexesModeAuditoryWarning}';
      case _ReflexesMode.math:
        return strings.reflexesModeMathDescription;
      case _ReflexesMode.memory:
        return strings.reflexesModeMemoryDescription;
      case _ReflexesMode.stroop:
        return strings.cognitiveDrillModeStroopDescription;
      case _ReflexesMode.mot:
        return strings.reflexesModeMotDescription;
      case _ReflexesMode.dissociation:
        return strings.reflexesModeDissociationDescription;
      case null:
        return '';
    }
  }

  String _selectedModeTooltip(AppStrings strings) {
    switch (_mode) {
      case _ReflexesMode.visual:
        return strings.reflexesModeVisualInfoTooltip;
      case _ReflexesMode.auditory:
        return strings.reflexesModeAuditoryInfoTooltip;
      case _ReflexesMode.math:
        return strings.reflexesModeMathInfoTooltip;
      case _ReflexesMode.memory:
        return strings.reflexesModeMemoryInfoTooltip;
      case _ReflexesMode.stroop:
        return strings.cognitiveDrillModeStroopInfoTooltip;
      case _ReflexesMode.mot:
        return strings.reflexesModeMotInfoTooltip;
      case _ReflexesMode.dissociation:
        return strings.reflexesModeDissociationInfoTooltip;
      case null:
        return '';
    }
  }

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

  Widget _buildRichTooltip({
    required Widget child,
    required String message,
    required TextStyle? textStyle,
    required Color bgColor,
    required double borderRadius,
  }) {
    final effectiveStyle =
        textStyle ?? const TextStyle(color: Colors.white, fontSize: 12);
    return Tooltip(
      richMessage: TextSpan(children: _parseBoldText(message, effectiveStyle)),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 8),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      preferBelow: true,
      verticalOffset: 20,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }

  String _modeTooltip(AppStrings strings) {
    if (_showLevelsPanel) {
      switch (_mode) {
        case _ReflexesMode.stroop:
          return strings.cognitiveDrillModeStroopInfoTooltip;
        case _ReflexesMode.visual:
          return strings.reflexesModeVisualInfoTooltip;
        case _ReflexesMode.auditory:
          return strings.reflexesModeAuditoryInfoTooltip;
        case _ReflexesMode.math:
          return strings.reflexesModeMathInfoTooltip;
        case _ReflexesMode.memory:
          return strings.reflexesModeMemoryInfoTooltip;
        case _ReflexesMode.mot:
          return strings.reflexesModeMotInfoTooltip;
        case _ReflexesMode.dissociation:
          return strings.reflexesModeDissociationInfoTooltip;
        default:
          return strings.reflexesToolSubtitle;
      }
    }
    if (!_showModePanel) return strings.reflexesToolSubtitle;
    switch (_mode) {
      case _ReflexesMode.stroop:
        return strings.cognitiveDrillModeStroopInfoTooltip;
      case _ReflexesMode.visual:
        return strings.reflexesModeVisualInfoTooltip;
      case _ReflexesMode.auditory:
        return strings.reflexesModeAuditoryInfoTooltip;
      case _ReflexesMode.math:
        return strings.reflexesModeMathInfoTooltip;
      case _ReflexesMode.memory:
        return strings.reflexesModeMemoryInfoTooltip;
      case _ReflexesMode.mot:
        return strings.reflexesModeMotInfoTooltip;
      case _ReflexesMode.dissociation:
        return strings.reflexesModeDissociationInfoTooltip;
      default:
        return strings.reflexesToolSubtitle;
    }
  }

  String _selectedModeTitle(AppStrings strings) {
    switch (_mode) {
      case _ReflexesMode.visual:
        return strings.reflexesModeVisualHeader;
      case _ReflexesMode.auditory:
        return strings.reflexesModeAuditoryHeader;
      case _ReflexesMode.math:
        return strings.reflexesModeMathHeader;
      case _ReflexesMode.memory:
        return strings.reflexesModeMemoryHeader;
      case _ReflexesMode.stroop:
        return strings.cognitiveDrillModeStroopHeader;
      case _ReflexesMode.mot:
        return strings.reflexesModeMotHeader;
      case _ReflexesMode.dissociation:
        return strings.reflexesModeDissociationHeader;
      case null:
        return '';
    }
  }

  String _levelsPanelTitle(AppStrings strings) {
    switch (_mode) {
      case _ReflexesMode.visual:
        return strings.reflexesModeVisual;
      case _ReflexesMode.auditory:
        return strings.reflexesModeAuditory;
      case _ReflexesMode.math:
        return strings.reflexesModeMath;
      case _ReflexesMode.memory:
        return strings.reflexesModeMemory;
      case _ReflexesMode.stroop:
        return strings.cognitiveDrillModeStroop;
      case _ReflexesMode.mot:
        return strings.reflexesModeMot;
      case _ReflexesMode.dissociation:
        return strings.reflexesModeDissociation;
      case null:
        return '';
    }
  }

  String _selectedDifficultyLabel(AppStrings strings) {
    switch (_mode) {
      case _ReflexesMode.visual:
      case _ReflexesMode.auditory:
        return _reactionDifficulty.label(strings);
      case _ReflexesMode.math:
        return _mathDifficulty.label(strings);
      case _ReflexesMode.memory:
        return _memoryDifficulty.label(strings);
      case _ReflexesMode.stroop:
        return _stroopDifficulty.label(strings);
      case _ReflexesMode.mot:
        return _motDifficulty.label(strings);
      case _ReflexesMode.dissociation:
        return strings.reflexesDifficultyLabel;
      case null:
        return '';
    }
  }

  void _openSelectedDifficultyDialog(AppStrings strings) {
    switch (_mode) {
      case _ReflexesMode.visual:
      case _ReflexesMode.auditory:
        _showReactionDifficultyDialog(context, strings);
        break;
      case _ReflexesMode.math:
        _showMathDifficultyDialog(context, strings);
        break;
      case _ReflexesMode.memory:
        _showMemoryDifficultyDialog(context, strings);
        break;
      case _ReflexesMode.stroop:
        _showStroopDifficultyDialog(context, strings);
        break;
      case _ReflexesMode.mot:
        _showMotDifficultyDialog(context, strings);
        break;
      case _ReflexesMode.dissociation:
        // Uses 50-levels grid, no difficulty dialog needed
        break;
      case null:
        break;
    }
  }

  List<_ReflexSessionRecord> _topModeRecords() {
    if (_mode == null) return const <_ReflexSessionRecord>[];
    final strings = AppStrings.of(context);
    var records = [
      ...(_historyByMode[_mode!.name] ?? const <_ReflexSessionRecord>[]),
    ];

    if (_mode == _ReflexesMode.stroop) {
      records = records
          .where((r) => r.primaryScore.isFinite && r.primaryScore > 50)
          .toList();
    }

    records.sort(
      (a, b) => _scoredValue(
        b.mode,
        b.primaryScore,
        b.stats,
        strings,
      ).compareTo(_scoredValue(a.mode, a.primaryScore, a.stats, strings)),
    );

    return records;
  }

  double _parseFirstNumberValue(String value) {
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(value);
    if (match == null) return double.nan;
    return double.tryParse(match.group(1) ?? '') ?? double.nan;
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  Widget _buildSelectionPanel(
    AppStrings strings,
    ColorScheme colors,
    TextTheme textStyles,
    bool isDark,
  ) {
    final provider = context.read<ThotProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DrillCard(
          title: strings.reflexesModeVisual,
          description: strings.reflexesModeVisualCardDescription,
          icon: Icons.visibility,
          onTap: () => _openLevelsPanelForMode(_ReflexesMode.visual),
          isSelected: false,
          isLocked: provider.isReflexesModeLockedForFree('visual'),
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
          backgroundImage: 'assets/images/visuel.webp',
          mode: _ReflexesMode.visual,
        ),
        const Gap(AppSpacing.md),
        _DrillCard(
          title: strings.reflexesModeAuditory,
          description: strings.reflexesModeAuditoryCardDescription,
          icon: Icons.hearing,
          onTap: () => _openLevelsPanelForMode(_ReflexesMode.auditory),
          isSelected: false,
          isLocked: provider.isReflexesModeLockedForFree('auditory'),
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
          backgroundImage: 'assets/images/auditif.webp',
          mode: _ReflexesMode.auditory,
        ),
        const Gap(AppSpacing.md),
        _DrillCard(
          title: strings.reflexesModeMath,
          description: strings.reflexesModeMathCardDescription,
          icon: Icons.calculate,
          onTap: () => _openLevelsPanelForMode(_ReflexesMode.math),
          isSelected: false,
          isLocked: provider.isReflexesModeLockedForFree('math'),
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
          backgroundImage: 'assets/images/calcul.webp',
          mode: _ReflexesMode.math,
        ),
        const Gap(AppSpacing.md),
        _DrillCard(
          title: strings.reflexesModeMemory,
          description: strings.reflexesModeMemoryCardDescription,
          icon: Icons.psychology,
          onTap: () => _openLevelsPanelForMode(_ReflexesMode.memory),
          isSelected: false,
          isLocked: provider.isReflexesModeLockedForFree('memory'),
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
          backgroundImage: 'assets/images/memoire.webp',
          mode: _ReflexesMode.memory,
        ),
        const Gap(AppSpacing.md),
        _DrillCard(
          title: strings.cognitiveDrillModeStroop,
          description: strings.cognitiveDrillModeStroopCardDescription,
          icon: Icons.psychology_alt,
          onTap: () => _openLevelsPanelForMode(_ReflexesMode.stroop),
          isSelected: false,
          isLocked: provider.isReflexesModeLockedForFree('stroop'),
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
          backgroundImage: 'assets/images/stroop.webp',
          mode: _ReflexesMode.stroop,
        ),
        const Gap(AppSpacing.md),
        _DrillCard(
          title: strings.reflexesModeMot,
          description: strings.reflexesModeMotCardDescription,
          icon: Icons.track_changes_rounded,
          onTap: () => _openLevelsPanelForMode(_ReflexesMode.mot),
          isSelected: false,
          isLocked: provider.isReflexesModeLockedForFree('mot'),
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
          backgroundImage: 'assets/images/MOT.webp',
          mode: _ReflexesMode.mot,
        ),
        const Gap(AppSpacing.md),
        _DrillCard(
          title: strings.reflexesModeDissociation,
          description: strings.reflexesModeDissociationCardDescription,
          icon: Icons.sync_alt_rounded,
          onTap: () => _openLevelsPanelForMode(_ReflexesMode.dissociation),
          isSelected: false,
          isLocked: provider.isReflexesModeLockedForFree('dissociation'),
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
          backgroundImage: 'assets/images/dissociation.webp',
          mode: _ReflexesMode.dissociation,
        ),
        const Gap(AppSpacing.xl),
      ],
    );
  }

  /// Launches the actual exercise for a given mode + level.
  /// Returns the primary score and navigation flags.
  Future<({double? score, bool closeAll, bool nextLevel})> _startLevel(
    _ReflexesMode mode,
    int level,
  ) async {
    _ReflexSessionRecord? result;
    switch (mode) {
      case _ReflexesMode.visual:
        result = await _startVisualTestLevel(
          context: context,
          level: level,
          historyByMode: _historyByMode,
          onResultSaved: _appendHistory,
        );
        break;
      case _ReflexesMode.auditory:
        result = await _startAuditoryTestLevel(
          context: context,
          level: level,
          historyByMode: _historyByMode,
          onResultSaved: _appendHistory,
        );
        break;
      case _ReflexesMode.math:
        final p = mathLevelParams(level);
        final opMode = p.operatorMode == 0
            ? _MathOperator.addSubOnly
            : p.operatorMode == 1
            ? _MathOperator.addSubMul
            : _MathOperator.mixed;
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _MathRunScreen(
              durationSeconds: p.durationSeconds,
              difficulty: p.operatorMode == 0
                  ? _MathDifficulty.easy
                  : p.operatorMode == 1
                  ? _MathDifficulty.medium
                  : _MathDifficulty.hard,
              operatorMode: opMode,
              operandMax: p.operandMax,
              history:
                  _historyByMode[_ReflexesMode.math.name] ??
                  const <_ReflexSessionRecord>[],
              onResultSaved: _appendHistory,
              level: level,
            ),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            ),
          ),
        );
        break;
      case _ReflexesMode.memory:
        final p = memoryLevelParams(level);
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _MemoryRunScreen(
              difficulty: _MemoryDifficulty.easy,
              sequenceLength: p.sequenceLength,
              displayMs: p.displayMs,
              rounds: p.rounds,
              history:
                  _historyByMode[_ReflexesMode.memory.name] ??
                  const <_ReflexSessionRecord>[],
              onResultSaved: _appendHistory,
              level: level,
            ),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            ),
          ),
        );
        break;
      case _ReflexesMode.stroop:
        final diff = stroopLevelDifficulty(level);
        setState(() => _stroopDifficulty = _StroopDifficulty.values[diff]);
        final strings = AppStrings.of(context);
        final stroopResult = await _openStroopTest(level: level);
        if (stroopResult == null) {
          return (score: null, closeAll: false, nextLevel: false);
        }
        final stoppedEarly = stroopResult.stats['_stopped_early'] == '1';
        final closeAll = stroopResult.stats['_close_tools'] == '1';
        if (stoppedEarly) {
          return (score: null, closeAll: closeAll, nextLevel: false);
        }
        final score = _parseFirstNumberValue(
          stroopResult.stats[strings.reflexesAvgReactionTime] ?? '',
        );
        final finalScore = _scoredValue(
          _ReflexesMode.stroop,
          score,
          stroopResult.stats,
          strings,
        );
        return (
          score: finalScore.isFinite ? finalScore : null,
          closeAll: closeAll,
          nextLevel: stroopResult.stats['_next_level'] == '1',
        );
      case _ReflexesMode.mot:
        final p = motLevelParams(level);
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _MotRunScreen(
              difficulty: _MotDifficulty.easy,
              totalCircles: p.totalCircles,
              targetCount: p.targetCount,
              trackingDurationMs: p.trackingDurationMs,
              speedPxPerSec: p.speedPxPerSec,
              trials: p.trials,
              circleDiameter: p.circleDiameter,
              highlightDurationMs: p.highlightDurationMs,
              history:
                  _historyByMode[_ReflexesMode.mot.name] ??
                  const <_ReflexSessionRecord>[],
              onResultSaved: _appendHistory,
              level: level,
            ),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            ),
          ),
        );
        break;
      case _ReflexesMode.dissociation:
        result = await _startDissociationTestLevel(
          context: context,
          level: level,
          historyByMode: _historyByMode,
          onResultSaved: _appendHistory,
        );
        break;
    }

    if (result == null) return (score: null, closeAll: false, nextLevel: false);
    final strings = AppStrings.of(context);
    final stoppedEarly = result.stats['_stopped_early'] == '1';
    final closeAll = result.stats['_close_all'] == '1';
    final nextLevel = result.stats['_next_level'] == '1';
    if (!stoppedEarly && mounted) {
      final list = _historyByMode[mode.name] ?? [];
      // Only append if it wasn't already appended by onResultSaved
      if (list.isEmpty || list.first.date != result.date) {
        await _appendHistory(result);
      }
      await TrainingHistory.recordExerciseCompletion(mode.name);
    }
    return (
      score: _scoredValue(mode, result.primaryScore, result.stats, strings),
      closeAll: closeAll,
      nextLevel: nextLevel,
    );
  }

  Future<void> _showStroopDifficultyDialog(
    BuildContext context,
    AppStrings strings,
  ) async {
    final result = await showDifficultyPicker(
      context: context,
      title: strings.reflexesDifficultyLabel,
      currentLevel: _stroopDifficulty.index + 1,
      options: [
        _DifficultyOption(
          label: strings.reflexesDifficultyEasy,
          subtitle: strings.cognitiveDrillStroopEasyCriteria,
          level: 1,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyMedium,
          subtitle: strings.cognitiveDrillStroopMediumCriteria,
          level: 2,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyHard,
          subtitle: strings.cognitiveDrillStroopHardCriteria,
          level: 3,
        ),
      ],
    );
    if (result != null && mounted) {
      setState(() => _stroopDifficulty = _StroopDifficulty.values[result - 1]);
    }
  }

  Future<void> _showMotDifficultyDialog(
    BuildContext context,
    AppStrings strings,
  ) async {
    final result = await showDifficultyPicker(
      context: context,
      title: strings.reflexesDifficultyLabel,
      currentLevel: _motDifficulty.index + 1,
      options: [
        _DifficultyOption(
          label: strings.reflexesDifficultyEasy,
          subtitle: strings.reflexesMotEasyCriteria,
          level: 1,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyMedium,
          subtitle: strings.reflexesMotMediumCriteria,
          level: 2,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyHard,
          subtitle: strings.reflexesMotHardCriteria,
          level: 3,
        ),
      ],
    );
    if (result != null && mounted) {
      setState(() => _motDifficulty = _MotDifficulty.values[result - 1]);
    }
  }

  // ── Inline 50-levels grid panel ──
  Widget _buildLevelsPanel(
    AppStrings strings,
    ColorScheme colors,
    TextTheme textStyles,
  ) {
    if (_mode == null) return const SizedBox();
    return _LevelsPanelBody(
      modeKey: _mode!.name,
      mode: _mode!,
      description: _selectedModeDescription(strings),
      infoTooltip: _selectedModeTooltip(strings),
      colors: colors,
      textStyles: textStyles,
      onStartLevel: (level) => _startLevel(_mode!, level),
      starsCalculator: _starsCalcForMode(_mode!),
      scoreLabel: _scoreLabelForMode(_mode!),
    );
  }

  int Function(double) _starsCalcForMode(_ReflexesMode mode) {
    // Delegates to the top-level _starsForScore() to guarantee result page
    // and level grid always show the same star count for the same score.
    return _starsForScore;
  }

  String Function(double) _scoreLabelForMode(_ReflexesMode mode) {
    switch (mode) {
      case _ReflexesMode.visual:
      case _ReflexesMode.auditory:
      case _ReflexesMode.stroop:
        return (s) => '${s.toStringAsFixed(0)} pts';
      case _ReflexesMode.math:
        return (s) => '${s.toStringAsFixed(0)} pts';
      case _ReflexesMode.memory:
        return (s) => '${s.toStringAsFixed(0)} pts';
      case _ReflexesMode.mot:
        return (s) => '${s.toStringAsFixed(0)} pts';
      case _ReflexesMode.dissociation:
        return (s) => '${s.toStringAsFixed(0)} pts';
    }
  }

  Widget _buildModePanel(
    AppStrings strings,
    ColorScheme colors,
    TextTheme textStyles,
  ) {
    final records = _topModeRecords();
    final descriptionStyle =
        textStyles.bodyMedium?.copyWith(
          color: colors.onSurface,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(
          color: colors.onSurface,
          height: 1.35,
          fontWeight: FontWeight.w500,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.reflexesModeDescriptionLabel,
          style: textStyles.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.secondary,
          ),
        ),
        const Gap(AppSpacing.xs),
        RichText(
          text: TextSpan(
            children: _parseBoldText(
              _selectedModeDescription(strings),
              descriptionStyle,
            ),
          ),
        ),
        const Gap(AppSpacing.md),
        _SettingsGroup(
          title: strings.reflexesSettingsTitle,
          children: [
            _SettingsItem(
              icon: Icons.speed_rounded,
              label: strings.reflexesDifficultyLabel,
              subtitle: _selectedDifficultyLabel(strings),
              onTap: () => _openSelectedDifficultyDialog(strings),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.md),
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
        const Gap(AppSpacing.md),
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
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
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.secondary,
                    ),
                  ),
                  if (_mode == _ReflexesMode.math) ...[
                    const Gap(AppSpacing.xs),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(strings.reflexesTopThree),
                            content: Text(
                              strings.reflexesMathScoringExplanation,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(strings.close),
                              ),
                            ],
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: colors.secondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(AppSpacing.md),
              if (records.isEmpty)
                Text(
                  strings.reflexesNoSessions,
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.secondary,
                  ),
                )
              else
                ...records.take(3).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  final medalColor = index == 0
                      ? const Color(0xFFFFC107)
                      : index == 1
                      ? const Color(0xFFB0BEC5)
                      : const Color(0xFFCD7F32);

                  final avgTime =
                      record.stats[strings.reflexesAvgAnswerTime] ?? '';
                  final difficulty = record.stats['difficulty'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                            difficulty.isNotEmpty
                                ? '$avgTime ($difficulty)'
                                : avgTime,
                            style: textStyles.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(record.date),
                          style: textStyles.bodySmall?.copyWith(
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
        const Gap(AppSpacing.xl),
        const Gap(AppSpacing.xl),
      ],
    );
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final loaded = <String, List<_ReflexSessionRecord>>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is List) {
          loaded[entry.key.toString()] = value
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (e) =>
                    _ReflexSessionRecord.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }
      }
      if (!mounted) return;
      setState(() => _historyByMode = loaded);
    } catch (_) {}
  }

  Future<void> _appendHistory(_ReflexSessionRecord record) async {
    final updated = Map<String, List<_ReflexSessionRecord>>.from(
      _historyByMode,
    );
    final list = <_ReflexSessionRecord>[
      record,
      ...(updated[record.mode.name] ?? const <_ReflexSessionRecord>[]),
    ];
    updated[record.mode.name] = list.take(30).toList();
    setState(() => _historyByMode = updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(
        updated.map(
          (key, value) =>
              MapEntry(key, value.map((record) => record.toJson()).toList()),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTrainingHistory();
    _loadHistory();
    TrainingHistory.updates.addListener(_onTrainingHistoryUpdate);
  }

  void _onTrainingHistoryUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadTrainingHistory() async {
    await TrainingHistory.load();
    if (!mounted) return;
    setState(() {});
  }

  Future<_ReflexSessionRecord?> _openStroopTest({int? level}) async {
    final provider = context.read<ThotProvider>();
    if (provider.isReflexesModeLockedForFree(_ReflexesMode.stroop.name)) {
      showProModal(context);
      return null;
    }
    final navigator = Navigator.of(context);
    final result = await navigator.push<_ReflexSessionRecord>(
      PageRouteBuilder<_ReflexSessionRecord>(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => _StroopRunScreen(
          difficulty: _stroopDifficulty,
          history:
              _historyByMode[_ReflexesMode.stroop.name] ??
              const <_ReflexSessionRecord>[],
          level: level,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
    if (!mounted || result == null) return result;
    final stoppedEarly = result.stats['_stopped_early'] == '1';
    if (!stoppedEarly) {
      await _appendHistory(result);
      await TrainingHistory.recordExerciseCompletion(_ReflexesMode.stroop.name);
    }
    if (mounted) setState(() {});
    final closeToTools = result.stats['_close_tools'] == '1';
    if (closeToTools && navigator.canPop()) {
      navigator.pop();
    }
    return result;
  }

  Future<void> _showReactionDifficultyDialog(
    BuildContext context,
    AppStrings strings,
  ) async {
    final result = await showDifficultyPicker(
      context: context,
      title: strings.reflexesDifficultyLabel,
      currentLevel: _reactionDifficulty.index + 1,
      options: [
        _DifficultyOption(
          label: strings.reflexesDifficultyEasy,
          subtitle: strings.reflexesReactionEasyCriteria,
          level: 1,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyMedium,
          subtitle: strings.reflexesReactionMediumCriteria,
          level: 2,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyHard,
          subtitle: strings.reflexesReactionHardCriteria,
          level: 3,
        ),
      ],
    );
    if (result != null && mounted) {
      setState(
        () => _reactionDifficulty = _ReactionDifficulty.values[result - 1],
      );
    }
  }

  Future<void> _showMathDifficultyDialog(
    BuildContext context,
    AppStrings strings,
  ) async {
    final result = await showDifficultyPicker(
      context: context,
      title: strings.reflexesDifficultyLabel,
      currentLevel: _mathDifficulty.index + 1,
      options: [
        _DifficultyOption(
          label: strings.reflexesDifficultyEasy,
          subtitle: strings.reflexesMathEasyCriteria,
          level: 1,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyMedium,
          subtitle: strings.reflexesMathMediumCriteria,
          level: 2,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyHard,
          subtitle: strings.reflexesMathHardCriteria,
          level: 3,
        ),
      ],
    );
    if (result != null && mounted) {
      setState(() => _mathDifficulty = _MathDifficulty.values[result - 1]);
    }
  }

  Future<void> _showMemoryDifficultyDialog(
    BuildContext context,
    AppStrings strings,
  ) async {
    final result = await showDifficultyPicker(
      context: context,
      title: strings.reflexesDifficultyLabel,
      currentLevel: _memoryDifficulty.index + 1,
      options: [
        _DifficultyOption(
          label: strings.reflexesDifficultyEasy,
          subtitle: strings.reflexesMemoryEasyCriteria,
          level: 1,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyMedium,
          subtitle: strings.reflexesMemoryMediumCriteria,
          level: 2,
        ),
        _DifficultyOption(
          label: strings.reflexesDifficultyHard,
          subtitle: strings.reflexesMemoryHardCriteria,
          level: 3,
        ),
      ],
    );
    if (result != null && mounted) {
      setState(() => _memoryDifficulty = _MemoryDifficulty.values[result - 1]);
    }
  }

  Future<void> _start() async {
    final mode = _mode;
    if (mode == null) return;
    _openLevelsPanelForMode(mode);
  }

  @override
  void dispose() {
    _tabController.dispose();
    TrainingHistory.updates.removeListener(_onTrainingHistoryUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
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
                    if (_showModePanel || _showLevelsPanel)
                      GestureDetector(
                        onTap: _showLevelsPanel
                            ? _closeLevelsPanel
                            : _closeModePanel,
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
                    if (_showModePanel || _showLevelsPanel)
                      const Gap(AppSpacing.sm),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: (_showModePanel || _showLevelsPanel)
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              _showLevelsPanel
                                  ? _levelsPanelTitle(strings)
                                  : _showModePanel
                                  ? _selectedModeTitle(strings)
                                  : strings.reflexesAndCognitionTitle,
                              style: textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          const Gap(4),
                          _buildRichTooltip(
                            message: _modeTooltip(strings),
                            textStyle: textStyles.bodySmall?.copyWith(
                              color: colors.surface,
                            ),
                            bgColor: colors.onSurface.withValues(alpha: 0.88),
                            borderRadius: 10,
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  final isPanel = (child.key as ValueKey?)?.value == true;
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(isPanel ? 1.0 : -1.0, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _showLevelsPanel
                    ? _buildLevelsPanel(strings, colors, textStyles)
                    : SingleChildScrollView(
                        key: ValueKey('${_showModePanel}_${_showLevelsPanel}'),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.lg +
                              MediaQuery.viewInsetsOf(context).bottom,
                        ),
                        child: _showModePanel
                            ? _buildModePanel(strings, colors, textStyles)
                            : _buildSelectionPanel(
                                strings,
                                colors,
                                textStyles,
                                isDark,
                              ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





