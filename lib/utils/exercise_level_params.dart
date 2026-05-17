/// Paramètres progressifs pour les 50 niveaux de chaque exercice.
library exercise_level_params;

// Progression linéaire : niveau 1 = difficile minimum, niveau 50 = difficile maximum.

// ─────────────────────────────────────────────
//  VISUAL TEST (Simple Reaction Time Go/No-Go)
//  Parameters: stimuliCount, minDelayMs, maxDelayMs
// ─────────────────────────────────────────────

({int stimuliCount, int minDelayMs, int maxDelayMs}) visualLevelParams(
  int level,
) {
  // Level 1: few stimuli, very long delays
  // Level 50: many stimuli, very short delays
  final t = (level - 1) / 49.0; // 0..1
  final stimuli = (8 + (t * 22)).round().clamp(8, 30);
  final minDelay = (3000 - t * 2200).round().clamp(800, 3000);
  final maxDelay = (5000 - t * 3000).round().clamp(2000, 5000);
  return (stimuliCount: stimuli, minDelayMs: minDelay, maxDelayMs: maxDelay);
}

// ─────────────────────────────────────────────
//  AUDITORY TEST
//  Same structure as visual
// ─────────────────────────────────────────────

({int stimuliCount, int minDelayMs, int maxDelayMs}) auditoryLevelParams(
  int level,
) {
  final t = (level - 1) / 49.0;
  final stimuli = (8 + (t * 22)).round().clamp(8, 30);
  final minDelay = (2500 - t * 1700).round().clamp(800, 2500);
  final maxDelay = (4500 - t * 2500).round().clamp(2000, 4500);
  return (stimuliCount: stimuli, minDelayMs: minDelay, maxDelayMs: maxDelay);
}

// ─────────────────────────────────────────────
//  MATH TEST
//  Parameters: durationSeconds, operatorMode, operandMax
//  Operators: 0=addSub, 1=addSubMul, 2=mixed
// ─────────────────────────────────────────────

({int durationSeconds, int operatorMode, int operandMax}) mathLevelParams(
  int level,
) {
  final t = (level - 1) / 49.0;

  // Operator progression
  int opMode;
  if (level <= 16) {
    opMode = 0; // add/sub only
  } else if (level <= 33) {
    opMode = 1; // add/sub/mul
  } else {
    opMode = 2; // all ops including div
  }

  // Duration increases slightly then stabilises
  final duration = (45 + (t * 75)).round().clamp(45, 120);

  // Operand range grows
  final operandMax = (10 + (t * 89)).round().clamp(10, 99);

  return (
    durationSeconds: duration,
    operatorMode: opMode,
    operandMax: operandMax,
  );
}

// ─────────────────────────────────────────────
//  MEMORY TEST
//  Parameters: sequenceLength, displayMs, rounds
// ─────────────────────────────────────────────

({int sequenceLength, int displayMs, int rounds}) memoryLevelParams(int level) {
  final t = (level - 1) / 49.0;

  // Sequence length: 3 → 12
  final seqLen = (3 + (t * 9)).round().clamp(3, 12);

  // Display time: 2500ms → 1000ms (shorter = harder)
  final displayMs = (2500 - t * 1500).round().clamp(1000, 2500);

  // Rounds: 4 → 12
  final rounds = (4 + (t * 8)).round().clamp(4, 12);

  return (sequenceLength: seqLen, displayMs: displayMs, rounds: rounds);
}

// ─────────────────────────────────────────────
//  STROOP TEST
//  Parameters: difficulty index (0=easy, 1=medium, 2=hard)
//  Mapped to existing _StroopDifficulty
// ─────────────────────────────────────────────

int stroopLevelDifficulty(int level) {
  if (level <= 17) return 0; // easy
  if (level <= 34) return 1; // medium
  return 2; // hard
}

// ─────────────────────────────────────────────
//  MOT TEST
//  Parameters: totalCircles, targetCount, trackingDurationMs,
//              speedPxPerSec, trials, circleDiameter, highlightDurationMs
// ─────────────────────────────────────────────

({
  int totalCircles,
  int targetCount,
  int trackingDurationMs,
  double speedPxPerSec,
  int trials,
  double circleDiameter,
  int highlightDurationMs,
})
motLevelParams(int level) {
  final t = (level - 1) / 49.0;

  // Total circles: 6 → 12
  final totalCircles = (6 + (t * 6)).round().clamp(6, 12);

  // Target count: 1 → 6
  final targetCount = (1 + (t * 5)).round().clamp(1, (totalCircles - 1));

  // Tracking duration: 4000ms → 12000ms
  final trackingMs = (4000 + (t * 8000)).round().clamp(4000, 12000);

  // Speed: 70 → 220 px/s
  final speed = 70 + t * 150;

  // Trials: 4 → 12
  final trials = (4 + (t * 8)).round().clamp(4, 12);

  // Circle diameter: 50 → 36 (smaller = harder)
  final diameter = 50.0 - t * 14.0;

  // Highlight duration: 1500 → 600ms
  final highlightMs = (1500 - t * 900).round().clamp(600, 1500);

  return (
    totalCircles: totalCircles,
    targetCount: targetCount,
    trackingDurationMs: trackingMs,
    speedPxPerSec: speed,
    trials: trials,
    circleDiameter: diameter,
    highlightDurationMs: highlightMs,
  );
}

// ─────────────────────────────────────────────
//  DISSOCIATION TEST
//  Parameters: durationSeconds, tempoMs, tempoToleranceMs,
//              stimulusMinDelayMs, stimulusMaxDelayMs, noGoRatio,
//              enableRuleSwitch, ruleSwitchEveryMs, enableDualTempo,
//              secondaryTempoMs, maxMissedTempo
// ─────────────────────────────────────────────

({
  int durationSeconds,
  int tempoMs,
  int tempoToleranceMs,
  int stimulusMinDelayMs,
  int stimulusMaxDelayMs,
  double noGoRatio,
  bool enableRuleSwitch,
  int ruleSwitchEveryMs,
  int maxMissedTempo,
})
dissociationLevelParams(int level) {
  final t = (level - 1) / 49.0; // 0..1

  // Duration: 30s -> 75s
  final durationSeconds = (30 + (t * 45)).round().clamp(30, 75);

  // Tempo: 1200ms -> 550ms (faster = harder)
  final tempoMs = (1200 - (t * 650)).round().clamp(550, 1200);

  // Tempo tolerance: 260ms -> 110ms (stricter = harder)
  final tempoToleranceMs = (260 - (t * 150)).round().clamp(110, 260);

  // Stimulus delays: 1800-3200ms -> 650-1300ms (faster = harder)
  final stimulusMinDelayMs = (1800 - (t * 1150)).round().clamp(650, 1800);
  final stimulusMaxDelayMs = (3200 - (t * 1900)).round().clamp(1300, 3200);

  // No-Go ratio: 0.15 -> 0.45
  final noGoRatio = 0.15 + (t * 0.30);

  // Rule switching: enabled from level 21
  final enableRuleSwitch = level >= 21;

  // Rule switch interval: 12s -> 6s (more frequent = harder)
  final ruleSwitchEveryMs = enableRuleSwitch
      ? (12000 - ((level - 21) / 29.0 * 6000)).round().clamp(6000, 12000)
      : 0;

  // Max missed tempo before penalty: 3 -> 1 (stricter = harder)
  final maxMissedTempo = (3 - (t * 2)).round().clamp(1, 3);

  return (
    durationSeconds: durationSeconds,
    tempoMs: tempoMs,
    tempoToleranceMs: tempoToleranceMs,
    stimulusMinDelayMs: stimulusMinDelayMs,
    stimulusMaxDelayMs: stimulusMaxDelayMs,
    noGoRatio: noGoRatio,
    enableRuleSwitch: enableRuleSwitch,
    ruleSwitchEveryMs: ruleSwitchEveryMs,
    maxMissedTempo: maxMissedTempo,
  );
}
