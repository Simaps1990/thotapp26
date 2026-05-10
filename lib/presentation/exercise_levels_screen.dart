import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thot/theme.dart';

// ─────────────────────────────────────────────
//  Shared data model
// ─────────────────────────────────────────────

class ExerciseLevelRecord {
  final int level;
  final double score;
  final DateTime date;

  const ExerciseLevelRecord({
    required this.level,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'level': level,
        'score': score,
        'date': date.toIso8601String(),
      };

  factory ExerciseLevelRecord.fromJson(Map<String, dynamic> j) =>
      ExerciseLevelRecord(
        level: j['level'] as int? ?? 1,
        score: (j['score'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Shared prefs helper – call once per mode key.
Future<Map<int, ExerciseLevelRecord>> loadLevelRecords(String modeKey) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('exercise_levels_$modeKey');
  if (raw == null) return {};
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    final map = <int, ExerciseLevelRecord>{};
    for (final e in decoded) {
      final r = ExerciseLevelRecord.fromJson(Map<String, dynamic>.from(e as Map));
      map[r.level] = r; // keep best – handled by save
    }
    return map;
  } catch (_) {
    return {};
  }
}

Future<void> saveLevelRecord(String modeKey, ExerciseLevelRecord record,
    Map<int, ExerciseLevelRecord> current) async {
  final existing = current[record.level];
  if (existing == null || record.score > existing.score) {
    current[record.level] = record;
  }
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      'exercise_levels_$modeKey',
      jsonEncode(current.values.map((r) => r.toJson()).toList()));
}

// ─────────────────────────────────────────────
//  Star rating helpers
// ─────────────────────────────────────────────

/// 0–3 stars based on score thresholds (lower = better for reaction time,
/// higher = better for scores).
int starsForVisual(double avgMs) {
  if (avgMs <= 0) return 0;
  if (avgMs < 230) return 3;
  if (avgMs < 320) return 2;
  return 1;
}

int starsForAuditory(double avgMs) {
  if (avgMs <= 0) return 0;
  if (avgMs < 190) return 3;
  if (avgMs < 270) return 2;
  return 1;
}

int starsForMath(double weightedScore) {
  if (weightedScore <= 0) return 0;
  if (weightedScore >= 30000) return 3;
  if (weightedScore >= 15000) return 2;
  return 1;
}

int starsForMemory(double correctRatio) {
  if (correctRatio <= 0) return 0;
  if (correctRatio >= 0.85) return 3;
  if (correctRatio >= 0.60) return 2;
  return 1;
}

int starsForStroop(double avgMs) {
  if (avgMs <= 0) return 0;
  if (avgMs < 600) return 3;
  if (avgMs < 900) return 2;
  return 1;
}

int starsForMot(double successRate) {
  if (successRate <= 0) return 0;
  if (successRate >= 95) return 3;
  if (successRate >= 70) return 2;
  return 1;
}

// ─────────────────────────────────────────────
//  Main screen
// ─────────────────────────────────────────────

class ExerciseLevelsScreen extends StatefulWidget {
  final String modeKey;
  final String title;
  final String description;
  final String instructions;
  final String? backgroundImage;
  final IconData icon;
  final Future<double?> Function(BuildContext context, int level) onStartLevel;
  final int Function(double score) starsCalculator;
  final String Function(double score) scoreLabel;

  const ExerciseLevelsScreen({
    super.key,
    required this.modeKey,
    required this.title,
    required this.description,
    required this.instructions,
    required this.icon,
    required this.onStartLevel,
    required this.starsCalculator,
    required this.scoreLabel,
    this.backgroundImage,
  });

  @override
  State<ExerciseLevelsScreen> createState() => _ExerciseLevelsScreenState();
}

class _ExerciseLevelsScreenState extends State<ExerciseLevelsScreen> {
  static const int kTotalLevels = 50;

  Map<int, ExerciseLevelRecord> _records = {};
  bool _loading = true;
  int? _selectedLevel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await loadLevelRecords(widget.modeKey);
    if (!mounted) return;
    setState(() {
      _records = r;
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final unlocked = _unlockedUpTo;
      final row = (unlocked - 1) ~/ 5;
      if (row > 0) {
        // Estimate row height + spacing. Item aspect ratio is ~0.82, 5 items per row.
        // Assuming typical screen width of ~400, item width is ~70, height is ~85.
        // Let's use an approximate row height of 100 to jump.
        final targetOffset = (row * 100.0) - 50.0;
        if (targetOffset > 0) {
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _unlockedUpTo {
    if (_records.isEmpty) return 1;
    int max = 1;
    for (final level in _records.keys) {
      if (level > max) max = level;
    }
    return min(max + 1, kTotalLevels);
  }

  Future<void> _playLevel(int level) async {
    if (level > _unlockedUpTo) return;

    setState(() => _selectedLevel = level);
    final score = await widget.onStartLevel(context, level);
    if (!mounted) return;
    setState(() => _selectedLevel = null);

    if (score != null && score >= 0) {
      final record = ExerciseLevelRecord(
        level: level,
        score: score,
        date: DateTime.now(),
      );
      await saveLevelRecord(widget.modeKey, record, _records);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: baseBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colors, textStyles, isDark),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLevelsGrid(colors, textStyles, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors, TextTheme textStyles, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade300 : LightColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.black : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Text(
                  widget.title.toUpperCase(),
                  style: textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LightColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_records.length} / $kTotalLevels',
                      style: textStyles.labelMedium?.copyWith(
                        color: LightColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(6),
                    Builder(
                      builder: (ctx) {
                        int totalStars = 0;
                        for (final r in _records.values) {
                          totalStars += widget.starsCalculator(r.score);
                        }
                        int maxPossibleStars = _unlockedUpTo * 3;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                            const Gap(2),
                            Text(
                              '$totalStars / $maxPossibleStars',
                              style: textStyles.labelMedium?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Text(
            widget.description,
            style: textStyles.bodySmall?.copyWith(
              color: colors.secondary,
            ),
          ),
          if (widget.instructions.isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: colors.primary),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      widget.instructions,
                      style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Gap(AppSpacing.md),
          Divider(color: colors.outline.withValues(alpha: 0.45)),
        ],
      ),
    );
  }

  Widget _buildLevelsGrid(ColorScheme colors, TextTheme textStyles, bool isDark) {
    final unlockedUpTo = _unlockedUpTo;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: kTotalLevels,
      itemBuilder: (ctx, index) {
        final level = index + 1;
        final isUnlocked = level <= unlockedUpTo;
        final record = _records[level];
        final stars = record != null ? widget.starsCalculator(record.score) : 0;
        final isSelected = _selectedLevel == level;

        return _LevelTile(
          level: level,
          isUnlocked: isUnlocked,
          stars: stars,
          bestScore: record != null ? widget.scoreLabel(record.score) : null,
          isSelected: isSelected,
          onTap: isUnlocked ? () => _playLevel(level) : null,
          colors: colors,
          textStyles: textStyles,
          isDark: isDark,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Level tile
// ─────────────────────────────────────────────

class _LevelTile extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final int stars;
  final String? bestScore;
  final bool isSelected;
  final VoidCallback? onTap;
  final ColorScheme colors;
  final TextTheme textStyles;
  final bool isDark;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.bestScore,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    required this.textStyles,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecord = bestScore != null;
    final isPerfect = stars == 3;

    Color bg;
    Color borderColor;
    Color textColor;

    if (!isUnlocked) {
      bg = isDark
          ? colors.surface.withValues(alpha: 0.4)
          : const Color(0xFFF0F0F0);
      borderColor = colors.outline.withValues(alpha: 0.2);
      textColor = colors.onSurface.withValues(alpha: 0.3);
    } else if (isPerfect) {
      bg = const Color(0xFF1B3A2A);
      borderColor = const Color(0xFF00C853);
      textColor = const Color(0xFF00E676);
    } else if (hasRecord) {
      bg = isDark ? colors.surface : colors.surface;
      borderColor = LightColors.primary.withValues(alpha: 0.55);
      textColor = colors.onSurface;
    } else {
      bg = isDark ? colors.surface : colors.surface;
      borderColor = LightColors.primary;
      textColor = colors.onSurface;
    }

    if (isSelected) {
      borderColor = LightColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? LightColors.primary
                : borderColor,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isUnlocked && !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : isSelected
                  ? [
                      BoxShadow(
                        color: LightColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
        ),
        child: Stack(
          children: [
            // Lock overlay
            if (!isUnlocked)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: colors.onSurface.withValues(alpha: 0.25),
                    ),
                    const Gap(2),
                    Text(
                      '$level',
                      style: textStyles.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stars
                    _buildStars(stars),
                    const Gap(4),
                    // Level number
                    Text(
                      '$level',
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        fontSize: 15,
                      ),
                    ),
                    if (bestScore != null) ...[
                      const Gap(2),
                      Text(
                        bestScore!,
                        style: textStyles.labelSmall?.copyWith(
                          color: isPerfect
                              ? const Color(0xFF00E676)
                              : colors.secondary,
                          fontSize: 9,
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
            // Loading indicator
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: LightColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(LightColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStars(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < count;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 12,
          color: filled ? const Color(0xFFFFC107) : colors.onSurface.withValues(alpha: 0.2),
        );
      }),
    );
  }
}
