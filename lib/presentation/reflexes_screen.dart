import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';

import 'package:thot/l10n/app_strings.dart';
import 'package:thot/presentation/cognitive_drills_screen.dart';
import 'package:thot/presentation/exercise_levels_screen.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/timer_sound.dart';
import 'package:thot/utils/exercise_level_params.dart';
import 'package:thot/data/training_history.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/widgets/pro_badge.dart';
import 'package:thot/presentation/pro_screen.dart';

enum _ReflexesMode { visual, auditory, math, memory, stroop, mot }

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
      TabController(length: 6, vsync: this)..addListener(() {
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
      case null:
        break;
    }
  }

  List<_ReflexSessionRecord> _topModeRecords() {
    if (_mode == null) return const <_ReflexSessionRecord>[];
    var records = [
      ...(_historyByMode[_mode!.name] ?? const <_ReflexSessionRecord>[]),
    ];

    if (_mode == _ReflexesMode.stroop) {
      records = records
          .where((r) => r.primaryScore.isFinite && r.primaryScore > 50)
          .toList();
    }

    if (_mode == _ReflexesMode.visual ||
        _mode == _ReflexesMode.auditory ||
        _mode == _ReflexesMode.stroop) {
      records.sort((a, b) => a.primaryScore.compareTo(b.primaryScore));
    } else {
      records.sort((a, b) => b.primaryScore.compareTo(a.primaryScore));
    }

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
        final p = visualLevelParams(level);
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _ReactionRunScreen(
              mode: _ReflexesMode.visual,
              history:
                  _historyByMode[_ReflexesMode.visual.name] ??
                  const <_ReflexSessionRecord>[],
              stimuliCount: p.stimuliCount,
              minDelayMs: p.minDelayMs,
              maxDelayMs: p.maxDelayMs,
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
      case _ReflexesMode.auditory:
        final p = auditoryLevelParams(level);
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _ReactionRunScreen(
              mode: _ReflexesMode.auditory,
              history:
                  _historyByMode[_ReflexesMode.auditory.name] ??
                  const <_ReflexSessionRecord>[],
              stimuliCount: p.stimuliCount,
              minDelayMs: p.minDelayMs,
              maxDelayMs: p.maxDelayMs,
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
        // Use existing stroop flow but with difficulty from level
        final diff = stroopLevelDifficulty(level);
        setState(() => _stroopDifficulty = _StroopDifficulty.values[diff]);
        await _openStroopTest();
        return (score: null, closeAll: false, nextLevel: false);
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
    }

    if (result == null) return (score: null, closeAll: false, nextLevel: false);
    final stoppedEarly = result.stats['_stopped_early'] == '1';
    final closeAll = result.stats['_close_all'] == '1';
    final nextLevel = result.stats['_next_level'] == '1';
    if (!stoppedEarly && mounted) {
      final list = _historyByMode[mode.name] ?? [];
      // Only append if it wasn't already appended by onResultSaved
      if (list.isEmpty || list.first.date != result.date) {
        await _appendHistory(result);
      }
    }
    return (
      score: result.primaryScore,
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
    switch (mode) {
      case _ReflexesMode.visual:
        return starsForVisual;
      case _ReflexesMode.auditory:
        return starsForAuditory;
      case _ReflexesMode.math:
        return starsForMath;
      case _ReflexesMode.memory:
        return (s) => starsForMemory(s / 100.0);
      case _ReflexesMode.stroop:
        return starsForStroop;
      case _ReflexesMode.mot:
        return starsForMot;
    }
  }

  String Function(double) _scoreLabelForMode(_ReflexesMode mode) {
    switch (mode) {
      case _ReflexesMode.visual:
      case _ReflexesMode.auditory:
      case _ReflexesMode.stroop:
        return (s) => '${s.toStringAsFixed(0)} ms';
      case _ReflexesMode.math:
        return (s) => s.toStringAsFixed(0);
      case _ReflexesMode.memory:
        return (s) => '${s.toStringAsFixed(0)}%';
      case _ReflexesMode.mot:
        return (s) => s.toStringAsFixed(2);
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

  Future<void> _openStroopTest() async {
    final provider = context.read<ThotProvider>();
    if (provider.isToolLockedForFree('cognitive_drills')) {
      showProModal(context);
      return;
    }
    final result = await Navigator.of(context).push<Map<String, String>>(
      PageRouteBuilder<Map<String, String>>(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => const CognitiveDrillsScreen(
          stroopOnly: true,
          autoStartStroop: true,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
    if (!mounted || result == null) return;
    final stoppedEarly = result['_stopped_early'] == '1';
    if (!stoppedEarly) {
      await TrainingHistory.recordExerciseCompletion(_ReflexesMode.stroop.name);
    }
    if (mounted) setState(() {});
    final closeToTools = result['_close_tools'] == '1';
    if (closeToTools && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final map = <String, List<_ReflexSessionRecord>>{};
      for (final entry in decoded.entries) {
        final list = (entry.value as List?) ?? const [];
        map[entry.key] = list
            .whereType<Map>()
            .map(
              (e) =>
                  _ReflexSessionRecord.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }

      // Load Stroop data from cognitive_drill_score_history
      final stroopHistoryJson = prefs.getString(
        'cognitive_drill_score_history',
      );
      if (stroopHistoryJson != null) {
        try {
          final stroopRaw = jsonDecode(stroopHistoryJson);
          if (stroopRaw is! List) return;
          final strings = AppStrings.of(context);
          final stroopRecords = stroopRaw
              .whereType<Map<dynamic, dynamic>>()
              .where((e) => e['_modeKey'] == 'stroop')
              .map((e) {
                final avgStr = (e[strings.reflexesAvgReactionTime] ?? '')
                    .toString();
                final primaryFromAvg = _parseFirstNumberValue(avgStr);
                final primaryFromStored =
                    double.tryParse((e['_primary'] ?? '').toString()) ??
                    double.nan;
                final primary = primaryFromStored.isFinite
                    ? primaryFromStored
                    : (primaryFromAvg.isFinite ? primaryFromAvg : double.nan);
                return _ReflexSessionRecord(
                  mode: _ReflexesMode.stroop,
                  date:
                      DateTime.tryParse(e['date']?.toString() ?? '') ??
                      DateTime.now(),
                  primaryScore: primary,
                  stats: e.map<String, String>(
                    (key, value) =>
                        MapEntry(key.toString(), value?.toString() ?? ''),
                  ),
                );
              })
              .where(
                (record) =>
                    record.primaryScore.isFinite && record.primaryScore > 50,
              )
              .toList();
          map['stroop'] = stroopRecords;
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() => _historyByMode = map);
    } catch (_) {}
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(
        _historyByMode.map(
          (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
        ),
      ),
    );
  }

  Future<void> _appendHistory(_ReflexSessionRecord record) async {
    final key = record.mode.name;
    final list = [...(_historyByMode[key] ?? const <_ReflexSessionRecord>[])];
    list.insert(0, record);
    _historyByMode[key] = list.take(20).toList(growable: false);
    if (mounted) setState(() {});
    await _saveHistory();
    final stoppedEarly = record.stats['_stopped_early'] == '1';
    if (!stoppedEarly) {
      await TrainingHistory.recordExerciseCompletion(key);
    }
    if (mounted) {
      Provider.of<ThotProvider>(context, listen: false).checkAchievements();
    }
  }

  (int, int, int) _getReactionParams() {
    switch (_reactionDifficulty) {
      case _ReactionDifficulty.easy:
        return (10, 2000, 4000);
      case _ReactionDifficulty.medium:
        return (15, 1500, 5000);
      case _ReactionDifficulty.hard:
        return (20, 1000, 6000);
    }
  }

  _MathOperator _getMathOperator() {
    switch (_mathDifficulty) {
      case _MathDifficulty.easy:
        return _MathOperator.addSubOnly;
      case _MathDifficulty.medium:
        return _MathOperator.addSubMul;
      case _MathDifficulty.hard:
        return _MathOperator.mixed;
    }
  }

  (int, int) _getMathOperandRange() {
    // .$1 = max additions/soustractions, .$2 = max table multiplication/division
    switch (_mathDifficulty) {
      case _MathDifficulty.easy:
        return (50, 0);
      case _MathDifficulty.medium:
        return (99, 12);
      case _MathDifficulty.hard:
        return (99, 12);
    }
  }

  (int, int) _getMemoryParams() {
    switch (_memoryDifficulty) {
      case _MemoryDifficulty.easy:
        return (5, 1500);
      case _MemoryDifficulty.medium:
        return (7, 2500);
      case _MemoryDifficulty.hard:
        return (9, 3500);
    }
  }

  ({
    int totalCircles,
    int targetCount,
    int trackingDurationMs,
    double speedPxPerSec,
    int trials,
    double circleDiameter,
    int highlightDurationMs,
  })
  _getMotParams() {
    switch (_motDifficulty) {
      case _MotDifficulty.easy:
        return (
          totalCircles: 10,
          targetCount: 1,
          trackingDurationMs: 7000,
          speedPxPerSec: 100,
          trials: 6,
          circleDiameter: 42,
          highlightDurationMs: 1200,
        );
      case _MotDifficulty.medium:
        return (
          totalCircles: 10,
          targetCount: 3,
          trackingDurationMs: 8000,
          speedPxPerSec: 140,
          trials: 8,
          circleDiameter: 42,
          highlightDurationMs: 1000,
        );
      case _MotDifficulty.hard:
        return (
          totalCircles: 10,
          targetCount: 5,
          trackingDurationMs: 10000,
          speedPxPerSec: 180,
          trials: 10,
          circleDiameter: 42,
          highlightDurationMs: 700,
        );
    }
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
    if (_mode == null) return;
    _ReflexSessionRecord? result;
    switch (_mode!) {
      case _ReflexesMode.visual:
        final (stimuliCount, minDelayMs, maxDelayMs) = _getReactionParams();
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _ReactionRunScreen(
              mode: _ReflexesMode.visual,
              history:
                  _historyByMode[_ReflexesMode.visual.name] ??
                  const <_ReflexSessionRecord>[],
              stimuliCount: stimuliCount,
              minDelayMs: minDelayMs,
              maxDelayMs: maxDelayMs,
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
      case _ReflexesMode.auditory:
        final (stimuliCount, minDelayMs, maxDelayMs) = _getReactionParams();
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _ReactionRunScreen(
              mode: _ReflexesMode.auditory,
              history:
                  _historyByMode[_ReflexesMode.auditory.name] ??
                  const <_ReflexSessionRecord>[],
              stimuliCount: stimuliCount,
              minDelayMs: minDelayMs,
              maxDelayMs: maxDelayMs,
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
      case _ReflexesMode.math:
        final operatorMode = _getMathOperator();
        final (operandMax, _) = _getMathOperandRange();
        final mathDurationSeconds = _mathDifficulty == _MathDifficulty.easy
            ? 60
            : _mathDifficulty == _MathDifficulty.medium
            ? 90
            : 120;
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _MathRunScreen(
              durationSeconds: mathDurationSeconds,
              difficulty: _mathDifficulty,
              operatorMode: operatorMode,
              operandMax: operandMax,
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
        final (sequenceLength, displayMs) = _getMemoryParams();
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _MemoryRunScreen(
              difficulty: _memoryDifficulty,
              sequenceLength: sequenceLength,
              displayMs: displayMs,
              rounds: _memoryRounds,
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
      case _ReflexesMode.mot:
        final motParams = _getMotParams();
        result = await Navigator.of(context).push<_ReflexSessionRecord>(
          PageRouteBuilder<_ReflexSessionRecord>(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => _MotRunScreen(
              difficulty: _motDifficulty,
              totalCircles: motParams.totalCircles,
              targetCount: motParams.targetCount,
              trackingDurationMs: motParams.trackingDurationMs,
              speedPxPerSec: motParams.speedPxPerSec,
              trials: motParams.trials,
              circleDiameter: motParams.circleDiameter,
              highlightDurationMs: motParams.highlightDurationMs,
              history:
                  _historyByMode[_ReflexesMode.mot.name] ??
                  const <_ReflexSessionRecord>[],
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
        await _openStroopTest();
        return;
    }
    if (result != null) {
      final closeToTools = result.stats['_close_tools'] == '1';
      final cleanStats = Map<String, String>.from(result.stats)
        ..remove('_close_tools');
      final cleanResult = _ReflexSessionRecord(
        mode: result.mode,
        date: result.date,
        primaryScore: result.primaryScore,
        stats: cleanStats,
      );
      final stoppedEarly = cleanResult.stats['_stopped_early'] == '1';
      if (!stoppedEarly) {
        await _appendHistory(cleanResult);
      }
      if (!mounted) return;
      setState(() {});
      if (closeToTools && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
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

class _MemoryInputBoxesDisplay extends StatelessWidget {
  const _MemoryInputBoxesDisplay({
    required this.sequenceLength,
    required this.input,
    this.correctSequence,
    this.showResult = false,
  });

  final int sequenceLength;
  final String input;
  final String? correctSequence;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = sequenceLength <= 0 ? 1 : sequenceLength;
        const spacing = 6.0;
        final available = constraints.maxWidth - (spacing * 2 * count);
        final blockWidth = (available / count).clamp(28.0, 56.0);
        final blockHeight = blockWidth * 1.35;
        final fontSize = (blockWidth * 0.8).clamp(24.0, 44.0);
        final chars = input.characters.toList();
        final correct = correctSequence?.characters.toList() ?? [];

        Widget buildRow(List<String> digits, {bool isAnswer = false}) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final char = index < digits.length ? digits[index] : '';

              Color boxBg;
              Color borderColor;
              Color textColor;

              if (isAnswer) {
                // Always green for the reference answer row
                boxBg = const Color(0xFF0D3A28);
                borderColor = const Color(0xFF00C853);
                textColor = const Color(0xFF00E676);
              } else if (showResult && char.isNotEmpty) {
                final expectedChar = index < correct.length
                    ? correct[index]
                    : '';
                if (char == expectedChar) {
                  boxBg = const Color(0xFF0D3A28);
                  borderColor = const Color(0xFF00C853);
                  textColor = const Color(0xFF00E676);
                } else {
                  boxBg = const Color(0xFF4A1620);
                  borderColor = const Color(0xFFD32F2F);
                  textColor = const Color(0xFFFF5252);
                }
              } else {
                boxBg = const Color(0xFF1F1F1F);
                borderColor = const Color(0xFF4F4F4F);
                textColor = const Color(0xFFF2F2F2);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: spacing),
                child: Container(
                  width: blockWidth,
                  height: blockHeight,
                  decoration: BoxDecoration(
                    color: boxBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: borderColor,
                      width: isAnswer ? 2.0 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isAnswer
                            ? const Color(0xFF00C853).withValues(alpha: 0.22)
                            : Colors.black.withValues(alpha: 0.34),
                        blurRadius: isAnswer ? 10 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      char,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showResult && correctSequence != null) ...[
              // --- Reference answer boxes (always green) ---
              buildRow(correct, isAnswer: true),
              const SizedBox(height: 32),
              // --- Divider between answer and user input ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(
                  height: 1.5,
                  thickness: 1.5,
                  color: const Color(0xFF4F4F4F).withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 14),
              // --- User input label ---
              Text(
                'VOTRE RÉPONSE',
                style: TextStyle(
                  color: const Color(0xFFF2F2F2).withValues(alpha: 0.45),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // --- User input boxes ---
            buildRow(chars),
          ],
        );
      },
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
    this.isLocked = false,
    this.backgroundImage,
    this.mode,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isLocked;
  final ColorScheme colors;
  final TextTheme textStyles;
  final bool isDark;
  final String? backgroundImage;
  final _ReflexesMode? mode;

  @override
  State<_DrillCard> createState() => _DrillCardState();
}

class _DrillCardState extends State<_DrillCard>
    with SingleTickerProviderStateMixin {
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
    return Opacity(
      opacity: widget.isLocked ? 0.5 : 1.0,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.backgroundImage == null
                ? (widget.isSelected
                      ? LightColors.primary
                      : widget.colors.surface)
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
                      Colors.black.withValues(
                        alpha: widget.isSelected ? 0.18 : 0.38,
                      ),
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
                              final progress =
                                  (_shimmerAnimation.value + 1) / 2;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 22),
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
                              color: widget.backgroundImage != null
                                  ? Colors.white
                                  : (widget.isSelected
                                        ? Colors.white
                                        : widget.colors.onSurface),
                            ),
                          ),
                          if (widget.isLocked) ...[
                            const Gap(8),
                            const ProBadge(compact: true),
                          ],
                          const Gap(4),
                          Text(
                            widget.description,
                            style: widget.textStyles.bodySmall?.copyWith(
                              color: widget.backgroundImage != null
                                  ? Colors.white
                                  : (widget.isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : widget.colors.secondary),
                              shadows: widget.backgroundImage != null
                                  ? [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.85,
                                        ),
                                        blurRadius: 8,
                                        offset: Offset.zero,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.mode != null &&
                  TrainingHistory.hasExerciseToday(widget.mode!.name))
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: _DiagonalCornerClipper(),
                    child: Container(
                      width: 54,
                      height: 54,
                      color: LightColors.primary,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
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
          child: Column(children: children),
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
    required this.subtitle,
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
    return a.primaryScore.compareTo(b.primaryScore);
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
                        SizedBox(
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
                                    Icons.refresh_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    strings.colorPodRestart.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
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
                                            '${record.primaryScore.toStringAsFixed(1)} ms',
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
                center: Alignment.center,
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
            delay: 0,
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
        if (isVisual)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              strings.reflexesVisualPermanentInstruction,
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

class _MathRunScreen extends StatefulWidget {
  _MathRunScreen({
    this.onResultSaved,
    required this.durationSeconds,
    required this.difficulty,
    required this.operatorMode,
    required this.operandMax,
    this.level,
  });
  final int durationSeconds;
  final _MathDifficulty difficulty;
  final _MathOperator operatorMode;
  final int operandMax;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;
  @override
  State<_MathRunScreen> createState() => _MathRunScreenState();
}

class _MathRunScreenState extends State<_MathRunScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  final _questionStopwatch = Stopwatch();
  final _answerTimes = <int>[];
  Timer? _ticker;
  int _remaining = 0;
  int _left = 0;
  int _right = 0;
  String _operator = '+';
  int _expected = 0;
  String _input = '';
  int _correct = 0;
  int _wrong = 0;
  final Map<String, int> _operatorCounts = {'+': 0, '−': 0, '×': 0, '÷': 0};
  final Map<String, int> _operatorAnswered = {'+': 0, '−': 0, '×': 0, '÷': 0};
  final Map<String, int> _operatorCorrect = {'+': 0, '−': 0, '×': 0, '÷': 0};
  bool _showResults = false;
  _ReflexSessionRecord? _currentResult;
  String? _mathFeedback;
  Timer? _mathFeedbackTimer;
  late final AnimationController _mathFeedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        _finish();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _restartRun() {
    _ticker?.cancel();
    _questionStopwatch
      ..stop()
      ..reset();
    _remaining = widget.durationSeconds;
    _left = 0;
    _right = 0;
    _expected = 0;
    _input = '';
    _correct = 0;
    _wrong = 0;
    _answerTimes.clear();
    _operatorCounts
      ..update('+', (_) => 0)
      ..update('−', (_) => 0)
      ..update('×', (_) => 0)
      ..update('÷', (_) => 0);
    _operatorAnswered
      ..update('+', (_) => 0)
      ..update('−', (_) => 0)
      ..update('×', (_) => 0)
      ..update('÷', (_) => 0);
    _operatorCorrect
      ..update('+', (_) => 0)
      ..update('−', (_) => 0)
      ..update('×', (_) => 0)
      ..update('÷', (_) => 0);
    _nextQuestion();
    _startTicker();
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
    _remaining = widget.durationSeconds;
    _nextQuestion();
    _startTicker();
  }

  void _nextQuestion() {
    final _MathOperator op;
    switch (widget.operatorMode) {
      case _MathOperator.addSubOnly:
        op = _random.nextBool()
            ? _MathOperator.addition
            : _MathOperator.subtraction;
        break;
      case _MathOperator.addSubMul:
        final r = _random.nextInt(3);
        op = r == 0
            ? _MathOperator.addition
            : r == 1
            ? _MathOperator.subtraction
            : _MathOperator.multiplication;
        break;
      case _MathOperator.mixed:
        final r = _random.nextInt(4);
        op = r == 0
            ? _MathOperator.addition
            : r == 1
            ? _MathOperator.subtraction
            : r == 2
            ? _MathOperator.multiplication
            : _MathOperator.division;
        break;
      default:
        op = widget.operatorMode;
    }

    final addSubMax = widget.operandMax;
    final mulMax = 12;

    switch (op) {
      case _MathOperator.addition:
        _left = 1 + _random.nextInt(addSubMax);
        _right = 1 + _random.nextInt(addSubMax);
        _operator = '+';
        _expected = _left + _right;
        break;
      case _MathOperator.subtraction:
        _left = 1 + _random.nextInt(addSubMax);
        _right = 1 + _random.nextInt(addSubMax);
        if (_right > _left) {
          final t = _left;
          _left = _right;
          _right = t;
        }
        _operator = '−';
        _expected = _left - _right;
        break;
      case _MathOperator.multiplication:
        _left = 2 + _random.nextInt(mulMax - 1);
        _right = 2 + _random.nextInt(mulMax - 1);
        _operator = '×';
        _expected = _left * _right;
        break;
      case _MathOperator.division:
        final divisor = 2 + _random.nextInt(mulMax - 1);
        final quotient = 2 + _random.nextInt(mulMax - 1);
        _left = divisor * quotient;
        _right = divisor;
        _operator = '÷';
        _expected = quotient;
        break;
      default:
        _left = 1;
        _right = 1;
        _operator = '+';
        _expected = 2;
    }

    _operatorCounts[_operator] = (_operatorCounts[_operator] ?? 0) + 1;
    _input = '';
    _questionStopwatch
      ..reset()
      ..start();
    if (mounted) setState(() {});
  }

  void _submit() {
    if (_input.isEmpty) return;
    _questionStopwatch.stop();
    final value = int.tryParse(_input);
    final correct = value == _expected;
    _operatorAnswered[_operator] = _operatorAnswered[_operator]! + 1;
    if (correct) {
      _correct++;
      _operatorCorrect[_operator] = _operatorCorrect[_operator]! + 1;
    } else {
      _wrong++;
    }
    _answerTimes.add(_questionStopwatch.elapsedMilliseconds);
    setState(() => _mathFeedback = correct ? 'ok' : 'wrong');
    _mathFeedbackAnimationController.reset();
    _mathFeedbackAnimationController.forward();
    _mathFeedbackTimer?.cancel();
    _mathFeedbackTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _mathFeedback = null);
    });
    _nextQuestion();
  }

  void _finish() {
    final avg = _answerTimes.isEmpty
        ? 0.0
        : _answerTimes.reduce((a, b) => a + b) / _answerTimes.length;
    final strings = AppStrings.of(context);
    final avgSeconds = (avg / 1000).floor();
    final avgMs = (avg % 1000).toInt();

    final difficultyCoefficient = switch (widget.difficulty) {
      _MathDifficulty.easy => 1.0,
      _MathDifficulty.medium => 1.5,
      _MathDifficulty.hard => 2.0,
    };

    final timeFactor = avg > 0 ? 10000.0 / avg : 0.0;
    final weightedScore =
        (_correct * difficultyCoefficient * timeFactor) -
        (_wrong * difficultyCoefficient * 500);

    final difficultyLabel = switch (widget.difficulty) {
      _MathDifficulty.easy => strings.reflexesDifficultyEasy,
      _MathDifficulty.medium => strings.reflexesDifficultyMedium,
      _MathDifficulty.hard => strings.reflexesDifficultyHard,
    };

    final result = _ReflexSessionRecord(
      mode: _ReflexesMode.math,
      date: DateTime.now(),
      primaryScore: weightedScore,
      stats: {
        strings.reflexesMathCorrectAnswers: '$_correct',
        strings.reflexesMathWrongAnswers: '$_wrong',
        strings.reflexesAvgAnswerTime:
            '${avgSeconds}s ${avgMs.toString().padLeft(3, '0')}ms',
        '_op_add_total': '${_operatorAnswered['+']}',
        '_op_add_correct': '${_operatorCorrect['+']}',
        '_op_sub_total': '${_operatorAnswered['−']}',
        '_op_sub_correct': '${_operatorCorrect['−']}',
        '_op_mul_total': '${_operatorAnswered['×']}',
        '_op_mul_correct': '${_operatorCorrect['×']}',
        '_op_div_total': '${_operatorAnswered['÷']}',
        '_op_div_correct': '${_operatorCorrect['÷']}',
        'difficulty': difficultyLabel,
        'difficultyCoefficient': difficultyCoefficient.toString(),
        if (widget.level != null) '_level': widget.level.toString(),
      },
    );
    setState(() {
      _currentResult = result;
      _showResults = true;
    });
  }

  void _stop() {
    _ticker?.cancel();
    _questionStopwatch.stop();
    if (_correct > 0 || _wrong > 0) {
      final avg = _answerTimes.isEmpty
          ? 0.0
          : _answerTimes.reduce((a, b) => a + b) / _answerTimes.length;
      final strings = AppStrings.of(context);
      final avgSeconds = (avg / 1000).floor();
      final avgMs = (avg % 1000).toInt();

      final difficultyCoefficient = switch (widget.difficulty) {
        _MathDifficulty.easy => 1.0,
        _MathDifficulty.medium => 1.5,
        _MathDifficulty.hard => 2.0,
      };

      final timeFactor = avg > 0 ? 10000.0 / avg : 0.0;
      final weightedScore =
          (_correct * difficultyCoefficient * timeFactor) -
          (_wrong * difficultyCoefficient * 500);

      final difficultyLabel = switch (widget.difficulty) {
        _MathDifficulty.easy => strings.reflexesDifficultyEasy,
        _MathDifficulty.medium => strings.reflexesDifficultyMedium,
        _MathDifficulty.hard => strings.reflexesDifficultyHard,
      };

      final result = _ReflexSessionRecord(
        mode: _ReflexesMode.math,
        date: DateTime.now(),
        primaryScore: weightedScore,
        stats: {
          strings.reflexesMathCorrectAnswers: '$_correct',
          strings.reflexesMathWrongAnswers: '$_wrong',
          strings.reflexesAvgAnswerTime:
              '${avgSeconds}s ${avgMs.toString().padLeft(3, '0')}ms',
          '_op_add_total': '${_operatorAnswered['+']}',
          '_op_add_correct': '${_operatorCorrect['+']}',
          '_op_sub_total': '${_operatorAnswered['−']}',
          '_op_sub_correct': '${_operatorCorrect['−']}',
          '_op_mul_total': '${_operatorAnswered['×']}',
          '_op_mul_correct': '${_operatorCorrect['×']}',
          '_op_div_total': '${_operatorAnswered['÷']}',
          '_op_div_correct': '${_operatorCorrect['÷']}',
          'difficulty': difficultyLabel,
          'difficultyCoefficient': difficultyCoefficient.toString(),
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
      _ticker?.cancel();
      _questionStopwatch.stop();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _mathFeedbackTimer?.cancel();
    _mathFeedbackAnimationController.dispose();
    _questionStopwatch.stop();
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
      final baseBackground = Theme.of(context).scaffoldBackgroundColor;
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
                        Text(
                          strings.reflexesModeMath,
                          style: texts.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.secondary,
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        _buildStatRow(
                          texts,
                          colors,
                          strings.reflexesMathCorrectAnswers,
                          _currentResult!.stats[strings
                                  .reflexesMathCorrectAnswers] ??
                              '',
                        ),
                        _buildStatRow(
                          texts,
                          colors,
                          strings.reflexesMathWrongAnswers,
                          _currentResult!.stats[strings
                                  .reflexesMathWrongAnswers] ??
                              '',
                        ),
                        _buildStatRow(
                          texts,
                          colors,
                          strings.reflexesAvgAnswerTime,
                          _currentResult!.stats[strings
                                  .reflexesAvgAnswerTime] ??
                              '',
                        ),
                        const Gap(AppSpacing.lg),
                        Text(
                          strings.reflexesMathOperationsTitle,
                          style: texts.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.secondary,
                          ),
                        ),
                        const Gap(AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildOperationRow(
                                    texts,
                                    colors,
                                    '+',
                                    _currentResult!.stats,
                                  ),
                                  _buildOperationRow(
                                    texts,
                                    colors,
                                    '−',
                                    _currentResult!.stats,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 80,
                              color: colors.outline,
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildOperationRow(
                                    texts,
                                    colors,
                                    '×',
                                    _currentResult!.stats,
                                  ),
                                  _buildOperationRow(
                                    texts,
                                    colors,
                                    '÷',
                                    _currentResult!.stats,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.lg),
                        SizedBox(
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
                                          if (mounted) _restartRun();
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
                                    Icons.refresh_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    strings.colorPodRestart.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${strings.reflexesTimerLabel}: ${_remaining}s',
                        style: texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _stop,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        child: Text(
                          strings.colorPodStop,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      '${strings.hitFactorScoreLabel}: ${_correct - _wrong}',
                      style: texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                      key: ValueKey('score_$_correct-$_wrong'),
                    ),
                  ),
                  const Gap(AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 190,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 70),
                          child: Text(
                            '$_left $_operator $_right = ?',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (_mathFeedback != null)
                          Positioned(
                            top: 20,
                            child: AnimatedBuilder(
                              animation: _mathFeedbackAnimationController,
                              builder: (_, __) {
                                final t =
                                    _mathFeedbackAnimationController.value;
                                final appear = Curves.easeOutBack.transform(
                                  (t / 0.32).clamp(0.0, 1.0),
                                );
                                final vanish = ((t - 0.65) / 0.35).clamp(
                                  0.0,
                                  1.0,
                                );
                                final scale =
                                    0.72 + (appear * 0.28) - (vanish * 0.08);
                                final y = (16 * (1.0 - appear)) - (22 * vanish);
                                final opacity =
                                    ((1.0 - vanish) * (0.65 + 0.35 * appear))
                                        .clamp(0.0, 1.0)
                                        .toDouble();
                                final isOk = _mathFeedback == 'ok';
                                final accent = isOk
                                    ? const Color(0xFF00E676)
                                    : const Color(0xFFFF5252);
                                final bg = isOk
                                    ? const Color(0xFF0D3A28)
                                    : const Color(0xFF4A1620);
                                final textColor = isOk
                                    ? const Color(0xFFE8FFF4)
                                    : const Color(0xFFFFECEF);

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
                                              bg.withValues(alpha: 0.98),
                                              accent.withValues(alpha: 0.26),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          border: Border.all(
                                            color: accent.withValues(
                                              alpha: 0.55,
                                            ),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: accent.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 22,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.15,
                                              ),
                                              blurRadius: 14,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isOk
                                                  ? Icons.flash_on_rounded
                                                  : Icons.close_rounded,
                                              color: accent,
                                              size: 22,
                                            ),
                                            const Gap(8),
                                            Text(
                                              isOk
                                                  ? strings
                                                        .reflexesMathFeedbackOk
                                                        .toUpperCase()
                                                  : strings
                                                        .reflexesMathFeedbackWrong
                                                        .toUpperCase(),
                                              style: TextStyle(
                                                color: textColor,
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
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.xl),
                  Center(
                    child: Text(
                      _input.isEmpty ? '—' : _input,
                      style: TextStyle(
                        color: colors.primaryContainer,
                        fontWeight: FontWeight.w900,
                        fontSize: 64,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _NumericPad(
                    onDigit: (d) => setState(() => _input += d),
                    onBackspace: () {
                      if (_input.isEmpty) return;
                      setState(
                        () => _input = _input.substring(0, _input.length - 1),
                      );
                    },
                    onOk: _submit,
                    okLabel: 'OK',
                  ),
                  const Gap(AppSpacing.lg),
                ],
              ),
            ),
          ),
          Positioned(top: 20, right: 12, child: SizedBox.shrink()),
        ],
      ),
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

  Widget _buildOperationRow(
    TextTheme texts,
    ColorScheme colors,
    String operator,
    Map<String, String> stats,
  ) {
    final strings = AppStrings.of(context);
    final totalKey = operator == '+'
        ? '_op_add_total'
        : operator == '−'
        ? '_op_sub_total'
        : operator == '×'
        ? '_op_mul_total'
        : '_op_div_total';
    final correctKey = operator == '+'
        ? '_op_add_correct'
        : operator == '−'
        ? '_op_sub_correct'
        : operator == '×'
        ? '_op_mul_correct'
        : '_op_div_correct';
    final correct = int.tryParse(stats[correctKey] ?? '0') ?? 0;
    final answered = int.tryParse(stats[totalKey] ?? '0') ?? 0;
    final ratioText = '$correct / $answered';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                operator,
                style: texts.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operator == '+'
                      ? strings.reflexesMathOpAddition
                      : operator == '−'
                      ? strings.reflexesMathOpSubtraction
                      : operator == '×'
                      ? strings.reflexesMathOpMultiplication
                      : strings.reflexesMathOpDivision,
                  style: texts.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ratioText,
                  style: texts.bodySmall?.copyWith(color: colors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryRunScreen extends StatefulWidget {
  _MemoryRunScreen({
    this.onResultSaved,
    required this.difficulty,
    required this.sequenceLength,
    required this.displayMs,
    required this.rounds,
    this.level,
  });
  final _MemoryDifficulty difficulty;
  final int sequenceLength;
  final int displayMs;
  final int rounds;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;
  @override
  State<_MemoryRunScreen> createState() => _MemoryRunScreenState();
}

class _MemoryRunScreenState extends State<_MemoryRunScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _random = Random();
  List<int> _sequence = [];
  String _input = '';
  int _round = 1;
  int _correct = 0;
  int _maxLength = 0;
  bool _showSequence = true;
  String? _feedback;
  String? _memoryFeedback;
  Timer? _memoryFeedbackTimer;
  late final AnimationController _memoryFeedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
  bool _showResults = false;
  _ReflexSessionRecord? _currentResult;
  // For color-coded box feedback
  bool _showInputResult = false;
  String? _expectedSequenceStr;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _startRound();
  }

  Future<void> _startRound() async {
    _sequence = List.generate(
      widget.sequenceLength,
      (_) => _random.nextInt(10),
    );
    _input = '';
    _feedback = null;
    _showSequence = true;
    _showInputResult = false;
    _expectedSequenceStr = null;
    if (mounted) setState(() {});
    await Future.delayed(Duration(milliseconds: widget.displayMs));
    if (!mounted) return;
    setState(() => _showSequence = false);
  }

  Future<void> _submit() async {
    if (_showSequence) return;
    final expected = _sequence.join();
    final strings = AppStrings.of(context);
    final success = _input == expected;

    // Show color-coded result
    setState(() {
      _showInputResult = true;
      _expectedSequenceStr = expected;
    });

    if (success) {
      _correct++;
      _maxLength = max(_maxLength, widget.sequenceLength);
      _feedback = strings.reflexesMemoryCorrect;
      _memoryFeedback = 'ok';
    } else {
      var idx = 0;
      while (idx < _input.length &&
          idx < expected.length &&
          _input[idx] == expected[idx]) {
        idx++;
      }
      _feedback = '${strings.reflexesMemoryIncorrect} ${idx + 1}';
      _memoryFeedback = 'wrong';
    }
    _memoryFeedbackAnimationController.reset();
    _memoryFeedbackAnimationController.forward();
    _memoryFeedbackTimer?.cancel();
    _memoryFeedbackTimer = Timer(const Duration(milliseconds: 600), () {
      setState(() => _memoryFeedback = null);
    });

    setState(() {});
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_round >= widget.rounds) {
      final result = _ReflexSessionRecord(
        mode: _ReflexesMode.memory,
        date: DateTime.now(),
        primaryScore: _correct.toDouble(),
        stats: {
          strings.reflexesMemoryRounds: '${widget.rounds}',
          strings.reflexesMemoryCorrect: '$_correct',
          strings.reflexesMemoryMaxLength: '$_maxLength',
          strings.reflexesMemorySequenceLength: '${widget.sequenceLength}',
          if (widget.level != null) '_level': widget.level.toString(),
        },
      );
      setState(() {
        _currentResult = result;
        _showResults = true;
      });
      return;
    }

    _round++;
    _startRound();
  }

  void _restartRun() {
    _round = 1;
    _correct = 0;
    _maxLength = 0;
    _input = '';
    _feedback = null;
    _showSequence = true;
    _sequence = [];
    _startRound();
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

  void _stop() {
    if (_correct > 0) {
      final strings = AppStrings.of(context);
      final result = _ReflexSessionRecord(
        mode: _ReflexesMode.memory,
        date: DateTime.now(),
        primaryScore: _correct.toDouble(),
        stats: {
          strings.reflexesMemoryRounds: '${_round - 1}',
          strings.reflexesMemoryCorrect: '$_correct',
          strings.reflexesMemoryMaxLength: '$_maxLength',
          strings.reflexesMemorySequenceLength: '${widget.sequenceLength}',
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
      _stop();
    }
  }

  @override
  void dispose() {
    _memoryFeedbackTimer?.cancel();
    _memoryFeedbackAnimationController.dispose();
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
      final baseBackground = Theme.of(context).scaffoldBackgroundColor;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                strings.reflexesModeMemory,
                                style: texts.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.secondary,
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              ..._currentResult!.stats.entries
                                  .where((e) => !e.key.startsWith('_'))
                                  .map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              e.key,
                                              style: texts.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
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
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        SizedBox(
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
                                          if (mounted) _restartRun();
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
                                    Icons.refresh_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    strings.colorPodRestart.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${strings.reflexesMemoryRounds}: $_round/${widget.rounds}',
                        style: texts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _stop,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        child: Text(
                          strings.colorPodStop,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _showSequence
                      ? _MemorySequenceFlipDisplay(sequence: _sequence)
                      : Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            _MemoryInputBoxesDisplay(
                              sequenceLength: widget.sequenceLength,
                              input: _input,
                              correctSequence: _expectedSequenceStr,
                              showResult: _showInputResult,
                            ),
                            if (_memoryFeedback != null)
                              Positioned(
                                top: -78,
                                child: AnimatedBuilder(
                                  animation: _memoryFeedbackAnimationController,
                                  builder: (_, __) {
                                    final t = _memoryFeedbackAnimationController
                                        .value;
                                    final appear = Curves.easeOutBack.transform(
                                      (t / 0.32).clamp(0.0, 1.0),
                                    );
                                    final vanish = ((t - 0.65) / 0.35).clamp(
                                      0.0,
                                      1.0,
                                    );
                                    final scale =
                                        0.72 +
                                        (appear * 0.28) -
                                        (vanish * 0.08);
                                    final y =
                                        (16 * (1.0 - appear)) - (22 * vanish);
                                    final opacity =
                                        ((1.0 - vanish) *
                                                (0.65 + 0.35 * appear))
                                            .clamp(0.0, 1.0)
                                            .toDouble();
                                    final isOk = _memoryFeedback == 'ok';
                                    final accent = isOk
                                        ? const Color(0xFF00E676)
                                        : const Color(0xFFFF5252);
                                    final bg = isOk
                                        ? const Color(0xFF0D3A28)
                                        : const Color(0xFF4A1620);
                                    final textColor = isOk
                                        ? const Color(0xFFE8FFF4)
                                        : const Color(0xFFFFECEF);

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
                                                  bg.withValues(alpha: 0.98),
                                                  accent.withValues(
                                                    alpha: 0.26,
                                                  ),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(26),
                                              border: Border.all(
                                                color: accent.withValues(
                                                  alpha: 0.55,
                                                ),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accent.withValues(
                                                    alpha: 0.25,
                                                  ),
                                                  blurRadius: 22,
                                                  spreadRadius: 2,
                                                ),
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.15),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isOk
                                                      ? Icons.flash_on_rounded
                                                      : Icons.close_rounded,
                                                  color: accent,
                                                  size: 22,
                                                ),
                                                const Gap(8),
                                                Text(
                                                  isOk
                                                      ? strings
                                                            .reflexesMathFeedbackOk
                                                            .toUpperCase()
                                                      : strings
                                                            .reflexesMathFeedbackWrong
                                                            .toUpperCase(),
                                                  style: TextStyle(
                                                    color: textColor,
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
                          ],
                        ),
                  const Spacer(),
                  _NumericPad(
                    onDigit: (d) {
                      if (_showSequence) return;
                      setState(() => _input += d);
                    },
                    onBackspace: () {
                      if (_showSequence || _input.isEmpty) return;
                      setState(
                        () => _input = _input.substring(0, _input.length - 1),
                      );
                    },
                    onOk: () {
                      if (_showSequence) return;
                      _submit();
                    },
                    okLabel: 'OK',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemorySequenceFlipDisplay extends StatefulWidget {
  const _MemorySequenceFlipDisplay({required this.sequence});
  final List<int> sequence;

  @override
  State<_MemorySequenceFlipDisplay> createState() =>
      _MemorySequenceFlipDisplayState();
}

class _MemorySequenceFlipDisplayState extends State<_MemorySequenceFlipDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward();

  @override
  void didUpdateWidget(covariant _MemorySequenceFlipDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sequence.join() != widget.sequence.join()) {
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

  @override
  Widget build(BuildContext context) {
    final sequence = widget.sequence;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final count = sequence.isEmpty ? 1 : sequence.length;
                final spacing = 6.0;
                final available = constraints.maxWidth - (spacing * 2 * count);
                final blockWidth = (available / count).clamp(28.0, 56.0);
                final blockHeight = blockWidth * 1.35;
                final fontSize = (blockWidth * 0.8).clamp(24.0, 44.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sequence.asMap().entries.map((entry) {
                    final index = entry.key;
                    final digit = entry.value;
                    final count = sequence.length <= 1 ? 1 : sequence.length;
                    final start = (index / count) * 0.55;
                    final end = (start + 0.45).clamp(0.0, 1.0);
                    final segment = Interval(
                      start,
                      end,
                      curve: Curves.easeOutCubic,
                    ).transform(_ctrl.value);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing),
                      child: Opacity(
                        opacity: segment,
                        child: Transform.translate(
                          offset: Offset(0, (1 - segment) * 14),
                          child: Container(
                            width: blockWidth,
                            height: blockHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1F1F),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF4F4F4F),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.34),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$digit',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFF2F2F2),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NumericPad extends StatelessWidget {
  const _NumericPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onOk,
    required this.okLabel,
  });
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onOk;
  final String okLabel;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget key(
      String label,
      VoidCallback onTap, {
      Color? bg,
      Color? textColor,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: bg ?? colors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: row.map((v) => key(v, () => onDigit(v))).toList()),
        Row(
          children: [
            key('⌫', onBackspace),
            key('0', () => onDigit('0')),
            key(
              okLabel,
              onOk,
              bg: colors.primaryContainer,
              textColor: colors.onPrimaryContainer,
            ),
          ],
        ),
      ],
    );
  }
}

class _MotCircle {
  Offset position;
  Offset velocity;
  _MotCircle({required this.position, required this.velocity});
}

class _MotRunScreen extends StatefulWidget {
  _MotRunScreen({
    required this.difficulty,
    required this.totalCircles,
    required this.targetCount,
    required this.trackingDurationMs,
    required this.speedPxPerSec,
    required this.trials,
    required this.circleDiameter,
    required this.highlightDurationMs,
    this.history = const <_ReflexSessionRecord>[],
    this.onResultSaved,
    this.level,
  });
  final _MotDifficulty difficulty;
  final int totalCircles;
  final int targetCount;
  final int trackingDurationMs;
  final double speedPxPerSec;
  final int trials;
  final double circleDiameter;
  final int highlightDurationMs;
  final List<_ReflexSessionRecord> history;
  final void Function(_ReflexSessionRecord)? onResultSaved;
  final int? level;

  @override
  State<_MotRunScreen> createState() => _MotRunScreenState();
}

enum _MotPhase {
  countdown,
  memorize,
  tracking,
  identification,
  feedback,
  results,
}

class _MotRunScreenState extends State<_MotRunScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _random = Random();
  int _countdown = 3;
  bool _isCountingDown = true;
  _MotPhase _phase = _MotPhase.countdown;
  int _trial = 0;
  List<_MotCircle> _circles = [];
  Set<int> _targetIndices = {};
  Set<int> _selectedIndices = {};
  List<int> _trialScores = [];
  Ticker? _animationTicker;
  Timer? _timer;
  Timer? _phaseTimer;
  Timer? _blinkTimer;
  bool _showResults = false;
  _ReflexSessionRecord? _currentResult;
  String? _feedbackText;
  Color? _feedbackTextColor;
  Color? _feedbackBgColor;
  Color? _feedbackAccentColor;
  bool _isFeedbackSuccess = false;
  bool _keepLandscapeForNextLevel = false;
  late final AnimationController _feedbackAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
  Size? _gameZoneSize;
  bool _retryStartTrialScheduled = false;
  final _repaintNotifier = ValueNotifier<int>(0);

  int _compareScores(_ReflexSessionRecord a, _ReflexSessionRecord b) {
    return b.primaryScore.compareTo(a.primaryScore);
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
    _keepLandscapeForNextLevel = true;
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
    _feedbackAnimationController.addListener(() {
      if (!mounted) return;
      _repaintNotifier.value++;
    });
    WakelockPlus.enable();
    TimerSound.warmUp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      _startCountdown();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAnimationTicker();
    _timer?.cancel();
    _phaseTimer?.cancel();
    _blinkTimer?.cancel();
    _feedbackAnimationController.dispose();
    _repaintNotifier.dispose();
    WakelockPlus.disable();
    if (_keepLandscapeForNextLevel) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _countdown = 3;
    _isCountingDown = true;
    _phase = _MotPhase.countdown;
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
        _startMemorizePhase();
      }
    });
  }

  void _startMemorizePhase() {
    _phase = _MotPhase.memorize;
    _trial = 0;
    _trialScores.clear();
    _startTrial();
  }

  void _stop() {
    _timer?.cancel();
    _phaseTimer?.cancel();
    _blinkTimer?.cancel();
    _disposeAnimationTicker();
    _restorePortrait();
    Navigator.of(context).pop();
  }

  void _disposeAnimationTicker() {
    final ticker = _animationTicker;
    _animationTicker = null;
    ticker?.dispose();
  }

  Future<void> _restorePortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _startTrial() {
    _disposeAnimationTicker();
    _phaseTimer?.cancel();
    _phase = _MotPhase.memorize;
    _selectedIndices.clear();
    _circles.clear();
    _targetIndices.clear();

    if (_gameZoneSize == null) {
      if (!_retryStartTrialScheduled) {
        _retryStartTrialScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _retryStartTrialScheduled = false;
          if (!mounted) return;
          if (_phase == _MotPhase.memorize && _circles.isEmpty) {
            _startTrial();
          }
        });
      }
      return;
    }
    final padding = 0.0;
    final gameWidth = _gameZoneSize!.width - padding * 2;
    final gameHeight = _gameZoneSize!.height - padding * 2;
    final radius = widget.circleDiameter / 2;
    final minDistance = widget.circleDiameter * 1.2;

    for (int i = 0; i < widget.totalCircles; i++) {
      Offset? pos;
      int attempts = 0;
      while (pos == null && attempts < 200) {
        final x =
            padding +
            radius +
            _random.nextDouble() * (gameWidth - widget.circleDiameter);
        final y =
            padding +
            radius +
            _random.nextDouble() * (gameHeight - widget.circleDiameter);
        final candidate = Offset(x, y);
        bool valid = true;
        for (final circle in _circles) {
          if ((candidate - circle.position).distance < minDistance) {
            valid = false;
            break;
          }
        }
        if (valid) {
          pos = candidate;
        }
        attempts++;
      }
      if (pos == null) {
        _circles.clear();
        _startTrial();
        return;
      }
      _circles.add(_MotCircle(position: pos, velocity: Offset.zero));
    }

    final allIndices = List.generate(widget.totalCircles, (i) => i)
      ..shuffle(_random);
    _targetIndices = allIndices.take(widget.targetCount).toSet();

    if (mounted) setState(() {});

    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      setState(() {});
    });

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: widget.highlightDurationMs), () {
      _blinkTimer?.cancel();
      _blinkTimer = null;
      if (!mounted) return;
      _startTrackingPhase();
    });
  }

  void _startTrackingPhase() {
    _phase = _MotPhase.tracking;
    final angle = _random.nextDouble() * 2 * 3.14159;
    _circles.asMap().forEach((i, circle) {
      circle.velocity = Offset(
        widget.speedPxPerSec * cos(angle + i * 0.5),
        widget.speedPxPerSec * sin(angle + i * 0.5),
      );
    });
    if (mounted) setState(() {});

    _animationTicker = createTicker((elapsed) {
      if (!mounted) return;
      final dt = elapsed.inMicroseconds / 1000000.0 - (_lastFrameTime ?? 0);
      _lastFrameTime = elapsed.inMicroseconds / 1000000.0;

      if (_gameZoneSize == null) return;
      final padding = 0.0;
      final gameWidth = _gameZoneSize!.width - padding * 2;
      final gameHeight = _gameZoneSize!.height - padding * 2;
      final radius = widget.circleDiameter / 2;

      for (final circle in _circles) {
        circle.position += circle.velocity * dt;

        if (circle.position.dx - radius < padding) {
          circle.position = Offset(padding + radius, circle.position.dy);
          circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
        }
        if (circle.position.dx + radius > padding + gameWidth) {
          circle.position = Offset(
            padding + gameWidth - radius,
            circle.position.dy,
          );
          circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
        }
        if (circle.position.dy - radius < padding) {
          circle.position = Offset(circle.position.dx, padding + radius);
          circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
        }
        if (circle.position.dy + radius > padding + gameHeight) {
          circle.position = Offset(
            circle.position.dx,
            padding + gameHeight - radius,
          );
          circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
        }
      }

      for (int i = 0; i < _circles.length; i++) {
        for (int j = i + 1; j < _circles.length; j++) {
          final delta = _circles[i].position - _circles[j].position;
          final dist = delta.distance;
          if (dist < widget.circleDiameter && dist > 0.001) {
            final normal = delta / dist;
            final overlap = widget.circleDiameter - dist;

            _circles[i].position += normal * (overlap / 2);
            _circles[j].position -= normal * (overlap / 2);

            final relativeVel = _circles[i].velocity - _circles[j].velocity;
            final velAlongNormal =
                relativeVel.dx * normal.dx + relativeVel.dy * normal.dy;

            if (velAlongNormal > 0) continue;

            final impulse = normal * velAlongNormal;
            _circles[i].velocity -= impulse;
            _circles[j].velocity += impulse;
          }
        }
      }

      if (mounted) _repaintNotifier.value++;
    });
    _lastFrameTime = 0;
    _animationTicker!.start();

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: widget.trackingDurationMs), () {
      if (!mounted) return;
      _disposeAnimationTicker();
      _startIdentificationPhase();
    });
  }

  double? _lastFrameTime;

  void _startIdentificationPhase() {
    _phase = _MotPhase.identification;
    if (mounted) setState(() {});
  }

  void _handleCircleTap(Offset tapPosition) {
    if (_phase != _MotPhase.identification) return;
    final radius = widget.circleDiameter / 2;
    for (int i = 0; i < _circles.length; i++) {
      if ((tapPosition - _circles[i].position).distance <= radius) {
        setState(() {
          if (_selectedIndices.contains(i)) {
            _selectedIndices.remove(i);
          } else {
            _selectedIndices.add(i);
          }
          if (_selectedIndices.length == widget.targetCount) {
            _startFeedbackPhase();
          }
        });
        break;
      }
    }
  }

  void _startFeedbackPhase() {
    _phase = _MotPhase.feedback;
    final score = _selectedIndices.intersection(_targetIndices).length;
    _trialScores.add(score);

    final strings = AppStrings.of(context);
    _isFeedbackSuccess = score == widget.targetCount;
    if (_isFeedbackSuccess) {
      _feedbackText = strings.reflexesFeedbackCorrect;
      _feedbackTextColor = const Color(0xFFE8FFF4);
      _feedbackBgColor = const Color(0xFF0D3A28);
      _feedbackAccentColor = const Color(0xFF00E676);
    } else {
      _feedbackText = strings.reflexesFeedbackFalse;
      _feedbackTextColor = const Color(0xFFFFECEF);
      _feedbackBgColor = const Color(0xFF4A1620);
      _feedbackAccentColor = const Color(0xFFFF5252);
    }

    _feedbackAnimationController.reset();
    _feedbackAnimationController.forward();

    if (mounted) setState(() {});

    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (_trial < widget.trials - 1) {
        _trial++;
        _startTrial();
      } else {
        _finish();
      }
    });
  }

  Future<void> _finish() async {
    final strings = AppStrings.of(context);
    final totalPossible = widget.trials * widget.targetCount;
    final totalCorrect = _trialScores.fold<int>(0, (a, b) => a + b);
    final avgScore = _trialScores.isEmpty
        ? 0.0
        : totalCorrect / _trialScores.length;
    final successRate = totalPossible == 0
        ? 0.0
        : (totalCorrect / totalPossible) * 100;

    final result = _ReflexSessionRecord(
      mode: _ReflexesMode.mot,
      date: DateTime.now(),
      primaryScore: successRate,
      stats: {
        strings.reflexesMotTrialLabel: '${widget.trials}',
        strings.reflexesMotTargetsFound: '$totalCorrect / $totalPossible',
        strings.reflexesMotAvgScore: avgScore.toStringAsFixed(2),
        strings.reflexesMotSuccessRate: '${successRate.toStringAsFixed(1)} %',
        if (widget.level != null) '_level': widget.level.toString(),
      },
    );
    await _restorePortrait();
    setState(() {
      _currentResult = result;
      _phase = _MotPhase.results;
      _showResults = true;
    });
  }

  Color _getCircleColor(int index) {
    if (_phase == _MotPhase.memorize) {
      final isTarget = _targetIndices.contains(index);
      final blinkOn = (_blinkTimer?.tick ?? 0) % 2 == 0;
      return isTarget && blinkOn
          ? const Color(0xFFFF9800)
          : const Color(0xFFE0E0E0);
    } else if (_phase == _MotPhase.identification) {
      return _selectedIndices.contains(index)
          ? const Color(0xFF1E88E5)
          : const Color(0xFFE0E0E0);
    } else if (_phase == _MotPhase.feedback) {
      final isTarget = _targetIndices.contains(index);
      final isSelected = _selectedIndices.contains(index);
      if (!_isFeedbackSuccess && isSelected) return const Color(0xFFFF5252);
      if (isTarget && isSelected) return const Color(0xFF00E676);
      if (!isTarget && isSelected) return const Color(0xFFFF5252);
      if (isTarget && !isSelected) return const Color(0xFFFF9800);
      return const Color(0xFFE0E0E0);
    }
    return const Color(0xFFE0E0E0);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    if (_showResults && _currentResult != null) {
      return _buildResultsScaffold(context, strings, colors, textStyles);
    }

    return _buildGameScaffold(context, strings, colors, textStyles);
  }

  Widget _buildGameScaffold(
    BuildContext context,
    AppStrings strings,
    ColorScheme colors,
    TextTheme textStyles,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, 0.5),
                radius: 1.2,
                colors: [Color(0xFF2A3550), Color(0xFF1A1F2E)],
              ),
            ),
          ),
          const _ReflexSmokeBlob(
            top: -120,
            left: -100,
            size: 380,
            color: Color(0xFF3D2A55),
            delay: 0,
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
                    child: Text(
                      '${strings.reflexesMotTrialLabel} ${(_trial + 1)}/${widget.trials}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final zoneSize = constraints.biggest;
                      if (_gameZoneSize == null ||
                          (_gameZoneSize!.width - zoneSize.width).abs() > 0.5 ||
                          (_gameZoneSize!.height - zoneSize.height).abs() >
                              0.5) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _gameZoneSize = zoneSize;
                          });
                        });
                      }

                      return _isCountingDown
                          ? Center(
                              child: AnimatedScale(
                                key: ValueKey(_countdown),
                                scale: 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.elasticOut,
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
                              ),
                            )
                          : GestureDetector(
                              onTapDown: (details) =>
                                  _handleCircleTap(details.localPosition),
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _MotPainter(
                                  repaint: _repaintNotifier,
                                  circles: _circles,
                                  getCircleColor: _getCircleColor,
                                  circleDiameter: widget.circleDiameter,
                                  phase: _phase,
                                  selectedIndices: _selectedIndices,
                                  isFailureFeedback:
                                      _phase == _MotPhase.feedback &&
                                      !_isFeedbackSuccess,
                                  feedbackAnimValue:
                                      _feedbackAnimationController.value,
                                ),
                              ),
                            );
                    },
                  ),
                ),
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

  Widget _buildResultsScaffold(
    BuildContext context,
    AppStrings strings,
    ColorScheme colors,
    TextTheme textStyles,
  ) {
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(_currentResult),
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
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: Text(
                          strings.reflexesResultsTitle,
                          textAlign: TextAlign.center,
                          style: textStyles.titleLarge?.copyWith(
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
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.secondary,
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            ..._currentResult!.stats.entries
                                .where((e) => !e.key.startsWith('_'))
                                .map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            e.key,
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                ),
                                          ),
                                        ),
                                        const Gap(AppSpacing.md),
                                        Text(
                                          e.value,
                                          style: textStyles.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colors.onSurface,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  widget.onResultSaved?.call(_currentResult!);
                                  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.landscapeLeft,
                                    DeviceOrientation.landscapeRight,
                                  ]);
                                  SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.immersiveSticky,
                                  );
                                  setState(() {
                                    _showResults = false;
                                    _currentResult = null;
                                    _gameZoneSize = null;
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
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
                                  Icons.refresh_rounded,
                                  size: 20,
                                ),
                                label: Text(
                                  strings.colorPodRestart.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
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
                                label: Text(strings.colorPodNext.toUpperCase()),
                                iconAlignment: IconAlignment.end,
                              ),
                            ),
                          ],
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
                                Icon(
                                  Icons.emoji_events_rounded,
                                  color: colors.primary,
                                ),
                                const Gap(AppSpacing.sm),
                                Text(
                                  strings.reflexesTopThree,
                                  style: textStyles.labelLarge?.copyWith(
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
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.secondary,
                                ),
                              )
                            else
                              ...topRecords
                                  .take(3)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
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
                                              record.primaryScore
                                                  .toStringAsFixed(2),
                                              style: textStyles.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            _formatDate(record.date),
                                            style: textStyles.bodySmall
                                                ?.copyWith(
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
}

class _MotPainter extends CustomPainter {
  final ValueNotifier<int> repaint;
  final List<_MotCircle> circles;
  final Color Function(int) getCircleColor;
  final double circleDiameter;
  final _MotPhase phase;
  final Set<int> selectedIndices;
  final bool isFailureFeedback;
  final double feedbackAnimValue;

  _MotPainter({
    required this.repaint,
    required this.circles,
    required this.getCircleColor,
    required this.circleDiameter,
    required this.phase,
    required this.selectedIndices,
    required this.isFailureFeedback,
    required this.feedbackAnimValue,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = circleDiameter / 2;
    for (int i = 0; i < circles.length; i++) {
      final circle = circles[i];
      var position = circle.position;
      if (isFailureFeedback && selectedIndices.contains(i)) {
        final wave = sin(feedbackAnimValue * 20 * pi);
        position = Offset(position.dx + (wave * 4), position.dy);
      }
      final paint = Paint()
        ..color = getCircleColor(i)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MotPainter oldDelegate) {
    return true;
  }
}

class _ReflexSessionRecord {
  _ReflexSessionRecord({
    required this.mode,
    required this.date,
    required this.primaryScore,
    required this.stats,
  });
  final _ReflexesMode mode;
  final DateTime date;
  final double primaryScore;
  final Map<String, String> stats;

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'date': date.toIso8601String(),
    'primaryScore': primaryScore,
    'stats': stats,
  };
  factory _ReflexSessionRecord.fromJson(Map<String, dynamic> json) =>
      _ReflexSessionRecord(
        mode: _ReflexesMode.values.firstWhere(
          (e) => e.name == (json['mode'] ?? 'visual'),
          orElse: () => _ReflexesMode.visual,
        ),
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        primaryScore: (json['primaryScore'] as num?)?.toDouble() ?? 0,
        stats: json['stats'] is Map
            ? (json['stats'] as Map<dynamic, dynamic>).map<String, String>(
                (key, value) =>
                    MapEntry(key.toString(), value?.toString() ?? ''),
              )
            : const <String, String>{},
      );
  String primaryLabel(AppStrings strings) {
    switch (mode) {
      case _ReflexesMode.visual:
      case _ReflexesMode.auditory:
        return '${strings.reflexesAvgReactionTime}: ${stats['avg'] ?? '0'} ms';
      case _ReflexesMode.math:
        return '${strings.reflexesMathCorrectAnswers}: ${stats['correct'] ?? '0'}';
      case _ReflexesMode.memory:
        return '${strings.reflexesMemoryMaxLength}: ${stats['maxLength'] ?? '0'}';
      case _ReflexesMode.stroop:
        return '${strings.hitFactorScoreLabel}: ${primaryScore.toStringAsFixed(1)}';
      case _ReflexesMode.mot:
        return '${strings.reflexesMotSuccessRate}: ${primaryScore.toStringAsFixed(1)} %';
    }
  }
}

class _ReflexSmokeBlob extends StatefulWidget {
  const _ReflexSmokeBlob({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
    this.delay = 0,
  });
  final double? top, left, right, bottom;
  final double size;
  final Color color;
  final int delay;
  @override
  State<_ReflexSmokeBlob> createState() => _ReflexSmokeBlobState();
}

class _ReflexSmokeBlobState extends State<_ReflexSmokeBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = _ctrl.value;
            return Transform.translate(
              offset: Offset(30 * (t - 0.5), 30 * (t - 0.5)),
              child: Transform.scale(
                scale: 0.9 + 0.2 * t,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.5 - 0.25 * t),
                        widget.color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
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

Future<int?> showDifficultyPicker({
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(opt.level),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? LightColors.primary.withValues(alpha: 0.08)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? LightColors.primary
                              : colors.outline.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(3, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  i < opt.level
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 20,
                                  color: isSelected
                                      ? LightColors.primary
                                      : colors.secondary,
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
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                  ),
                                ),
                                if (opt.subtitle.isNotEmpty) ...[
                                  const Gap(2),
                                  Text(
                                    opt.subtitle,
                                    style: textStyles.bodySmall?.copyWith(
                                      color: colors.secondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: LightColors.primary,
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

class _DiagonalCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final cornerRadius = 16.0;

    path.moveTo(0, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

extension on _ReactionDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _ReactionDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _ReactionDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _ReactionDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _MathOperator {
  String label(AppStrings s) {
    switch (this) {
      case _MathOperator.addition:
        return '+';
      case _MathOperator.subtraction:
        return '−';
      case _MathOperator.multiplication:
        return '×';
      case _MathOperator.division:
        return '÷';
      case _MathOperator.mixed:
        return s.reflexesModeMixed;
      case _MathOperator.addSubOnly:
        return '+ −';
      case _MathOperator.addSubMul:
        return '+ − ×';
    }
  }
}

extension on _MathDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _MathDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _MathDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _MathDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _MemoryDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _MemoryDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _MemoryDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _MemoryDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _StroopDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _StroopDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _StroopDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _StroopDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

extension on _MotDifficulty {
  String label(AppStrings s) {
    switch (this) {
      case _MotDifficulty.easy:
        return s.reflexesDifficultyEasy;
      case _MotDifficulty.medium:
        return s.reflexesDifficultyMedium;
      case _MotDifficulty.hard:
        return s.reflexesDifficultyHard;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  _LevelsPanelBody — grille 50 niveaux intégrée au bottom sheet
// ─────────────────────────────────────────────────────────────

class _LevelsPanelBody extends StatefulWidget {
  const _LevelsPanelBody({
    required this.modeKey,
    required this.mode,
    required this.description,
    required this.infoTooltip,
    required this.colors,
    required this.textStyles,
    required this.onStartLevel,
    required this.starsCalculator,
    required this.scoreLabel,
  });

  final String modeKey;
  final _ReflexesMode mode;
  final String description;
  final String infoTooltip;
  final ColorScheme colors;
  final TextTheme textStyles;
  final Future<({double? score, bool closeAll, bool nextLevel})> Function(
    int level,
  )
  onStartLevel;
  final int Function(double score) starsCalculator;
  final String Function(double score) scoreLabel;

  @override
  State<_LevelsPanelBody> createState() => _LevelsPanelBodyState();
}

class _LevelsPanelBodyState extends State<_LevelsPanelBody> {
  static const int _kTotal = 50;

  Map<int, ExerciseLevelRecord> _records = {};
  bool _loading = true;
  int? _runningLevel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_LevelsPanelBody old) {
    super.didUpdateWidget(old);
    if (old.modeKey != widget.modeKey) _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final records = await loadLevelRecords(widget.modeKey);
    if (mounted)
      setState(() {
        _records = records;
        _loading = false;
      });

    // Auto-scroll to the current unlocked level after render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final unlocked = _unlockedUpTo;
      final row = (unlocked - 1) ~/ 5;
      if (row > 2) {
        final screenWidth = MediaQuery.of(context).size.width;
        final gridWidth = screenWidth - 32; // AppSpacing.md * 2
        final itemWidth = (gridWidth - 32) / 5; // 4 * crossAxisSpacing(8)
        final itemHeight = itemWidth / 0.82; // childAspectRatio
        final rowHeight = itemHeight + 8; // mainAxisSpacing

        // Target offset to show the row somewhat in the middle or top
        final targetOffset = (row - 1) * rowHeight;
        final maxScroll = _scrollController.position.maxScrollExtent;

        _scrollController.animateTo(
          targetOffset.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  int get _unlockedUpTo {
    if (_records.isEmpty) return 1;
    int maxLevel = 1;
    for (final lvl in _records.keys) {
      if (lvl > maxLevel) maxLevel = lvl;
    }
    return (maxLevel + 1).clamp(1, _kTotal);
  }

  int get _earnedStars {
    int total = 0;
    for (final record in _records.values) {
      total += widget.starsCalculator(record.score);
    }
    return total;
  }

  int get _maxStarsAtCurrentAdvancement {
    return _unlockedUpTo * 3;
  }

  Future<void> _play(int level) async {
    if (level > _unlockedUpTo) return;
    setState(() => _runningLevel = level);
    final result = await widget.onStartLevel(level);
    if (!mounted) return;
    setState(() => _runningLevel = null);
    if (result.score != null && result.score! >= 0) {
      final record = ExerciseLevelRecord(
        level: level,
        score: result.score!,
        date: DateTime.now(),
      );
      await saveLevelRecord(widget.modeKey, record, _records);
      if (mounted) {
        await _load();
      }
    }
    if (!mounted) return;
    if (result.closeAll) {
      // Close the entire levels panel
      Navigator.of(context).pop();
      return;
    }
    if (result.nextLevel) {
      final nextLvl = level + 1;
      if (nextLvl <= _kTotal && nextLvl <= _unlockedUpTo) {
        _play(nextLvl);
      }
    }
  }

  List<TextSpan> _parseBold(String text, TextStyle base) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > last)
        spans.add(TextSpan(text: text.substring(last, m.start), style: base));
      spans.add(
        TextSpan(
          text: m.group(1),
          style: base.copyWith(fontWeight: FontWeight.bold),
        ),
      );
      last = m.end;
    }
    if (last < text.length)
      spans.add(TextSpan(text: text.substring(last), style: base));
    return spans;
  }

  Widget _buildDescription() {
    final base =
        widget.textStyles.bodyMedium?.copyWith(
          color: widget.colors.onSurface,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(color: widget.colors.onSurface, height: 1.4);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.colors.outline.withValues(alpha: 0.35),
        ),
      ),
      child: RichText(
        text: TextSpan(children: _parseBold(widget.description, base)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unlocked = _unlockedUpTo;

    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Text(
                  '${_records.length} / $_kTotal',
                  style: widget.textStyles.labelMedium?.copyWith(
                    color: LightColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _records.length / _kTotal,
                      minHeight: 4,
                      backgroundColor: widget.colors.outline.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        LightColors.primary,
                      ),
                    ),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: LightColors.primary,
                    ),
                    const Gap(2),
                    Text(
                      '$_earnedStars / $_maxStarsAtCurrentAdvancement',
                      style: widget.textStyles.labelMedium?.copyWith(
                        color: LightColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          // Description de l'exercice
          if (widget.description.isNotEmpty) ...[
            _buildDescription(),
            const Gap(AppSpacing.sm),
          ],
          // Grid
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.82,
              ),
              itemCount: _kTotal,
              itemBuilder: (ctx, index) {
                final level = index + 1;
                final isUnlocked = level <= unlocked;
                final record = _records[level];
                final stars = record != null
                    ? widget.starsCalculator(record.score)
                    : 0;
                final isRunning = _runningLevel == level;

                return _LevelCell(
                  level: level,
                  isUnlocked: isUnlocked,
                  stars: stars,
                  bestScore: record != null
                      ? widget.scoreLabel(record.score)
                      : null,
                  isRunning: isRunning,
                  onTap: isUnlocked ? () => _play(level) : null,
                  colors: widget.colors,
                  textStyles: widget.textStyles,
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCell extends StatelessWidget {
  const _LevelCell({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.bestScore,
    required this.isRunning,
    required this.onTap,
    required this.colors,
    required this.textStyles,
    required this.isDark,
  });

  final int level;
  final bool isUnlocked;
  final int stars;
  final String? bestScore;
  final bool isRunning;
  final VoidCallback? onTap;
  final ColorScheme colors;
  final TextTheme textStyles;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasRecord = bestScore != null;

    Color bg;
    Color borderColor;
    Color textColor;

    if (!isUnlocked) {
      bg = isDark
          ? colors.surface.withValues(alpha: 0.4)
          : const Color(0xFFF0F0F0);
      borderColor = colors.outline.withValues(alpha: 0.18);
      textColor = colors.onSurface.withValues(alpha: 0.28);
    } else if (hasRecord) {
      bg = colors.surface;
      borderColor = LightColors.primary.withValues(alpha: 0.55);
      textColor = colors.onSurface;
    } else {
      bg = colors.surface;
      borderColor = LightColors.primary;
      textColor = colors.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isRunning ? LightColors.primary.withValues(alpha: 0.15) : bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isRunning ? LightColors.primary : borderColor,
            width: isRunning ? 2.0 : 1.2,
          ),
          boxShadow: isUnlocked && !isRunning
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isRunning
            ? const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LightColors.primary,
                    ),
                  ),
                ),
              )
            : !isUnlocked
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: colors.onSurface.withValues(alpha: 0.22),
                  ),
                  const Gap(2),
                  Text(
                    '$level',
                    style: textStyles.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final filled = i < stars;
                        return Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 11,
                          color: filled
                              ? const Color(0xFFFFC107)
                              : colors.onSurface.withValues(alpha: 0.18),
                        );
                      }),
                    ),
                    const Gap(3),
                    Text(
                      '$level',
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    if (bestScore != null) ...[
                      const Gap(2),
                      Text(
                        bestScore!,
                        style: textStyles.labelSmall?.copyWith(
                          color: colors.secondary,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
