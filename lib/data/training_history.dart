import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TrainingHistory {
  TrainingHistory._();

  static const _key = 'reflexes_training_history_v1';

  /// Notifie les widgets qui écoutent les changements (home screen, etc.)
  static final ValueNotifier<int> updates = ValueNotifier<int>(0);

  // Format: 'YYYY-MM-DD' -> Set of exercise modes completed that day
  static Map<String, Set<String>> _dailyTraining = {};
  static Timer? _rolloverTimer;

  static DateTime _nextRolloverInstant() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 0, 1);
  }

  static void _scheduleRolloverRefresh() {
    _rolloverTimer?.cancel();
    final next = _nextRolloverInstant();
    final delay = next.difference(DateTime.now());

    _rolloverTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () {
        updates.value++;
        _scheduleRolloverRefresh();
      },
    );
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load training history
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _dailyTraining = decoded.map((k, v) => MapEntry(
          k,
          (v as List).cast<String>().toSet(),
        ));
      } catch (e) {
        _dailyTraining = {};
      }
    }

    _scheduleRolloverRefresh();
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save training history
    await prefs.setString(_key, jsonEncode(
      _dailyTraining.map((k, v) => MapEntry(k, v.toList()))
    ));
  }

  static Future<void> clear() async {
    _dailyTraining = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    updates.value++;
  }

  static String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static Future<void> recordExerciseCompletion(String mode) async {
    final today = _getTodayKey();
    _dailyTraining.putIfAbsent(today, () => <String>{});
    _dailyTraining[today]!.add(mode);
    await save();
    _scheduleRolloverRefresh();
    updates.value++;
  }

  static bool hasExerciseToday(String mode) {
    final today = _getTodayKey();
    return _dailyTraining[today]?.contains(mode) ?? false;
  }

  static List<bool> getWeeklyTraining() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final weekly = <bool>[];
    
    for (int i = 0; i < 7; i++) {
      final day = DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i)));
      weekly.add((_dailyTraining[day]?.length ?? 0) > 0);
    }
    
    return weekly;
  }

  static bool hasAnyTraining() {
    return _dailyTraining.isNotEmpty;
  }

  static int getWeeklyStreak() {
    final now = DateTime.now();
    int streak = 0;
    DateTime current = now;
    
    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(current);
      if (_dailyTraining[key]?.isNotEmpty ?? false) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  static int getTotalTrainingCount() {
    return _dailyTraining.values.fold(0, (sum, modes) => sum + modes.length);
  }
}
