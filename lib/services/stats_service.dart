import 'package:thot/data/models.dart';

class StatsSnapshot {
  final int sessionCount;
  final int totalRounds;
  final double? averagePrecision;
  final Session? bestPrecisionSession;
  final Session? longestSession;
  final Session? lastSession;
  final int sessionsThisWeek;
  final int sessionsThisMonth;

  const StatsSnapshot({
    required this.sessionCount,
    required this.totalRounds,
    required this.averagePrecision,
    required this.bestPrecisionSession,
    required this.longestSession,
    required this.lastSession,
    required this.sessionsThisWeek,
    required this.sessionsThisMonth,
  });
}

class StatsService {
  String? _lastHash;
  StatsSnapshot? _lastSnapshot;

  StatsSnapshot buildSnapshot(List<Session> sessions) {
    final hash = _hashSessions(sessions);
    final cached = _lastSnapshot;
    if (_lastHash == hash && cached != null) return cached;

    final sessionsWithPrecision = sessions
        .where((session) => session.hasCountedPrecision)
        .toList(growable: false);
    final totalRounds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalRounds,
    );
    final averagePrecision = sessionsWithPrecision.isEmpty
        ? null
        : sessionsWithPrecision.fold<double>(
                0,
                (sum, session) => sum + session.averagePrecision,
              ) /
              sessionsWithPrecision.length;
    final bestPrecisionSession = sessionsWithPrecision.isEmpty
        ? null
        : ([...sessionsWithPrecision]..sort(
                (a, b) => b.averagePrecision.compareTo(a.averagePrecision),
              ))
              .first;
    final longestSession = sessions.isEmpty
        ? null
        : ([
            ...sessions,
          ]..sort((a, b) => b.totalRounds.compareTo(a.totalRounds))).first;
    final lastSession = sessions.isEmpty
        ? null
        : ([...sessions]..sort((a, b) => b.date.compareTo(a.date))).first;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month);
    final sessionsThisWeek = sessions
        .where((session) => !session.date.isBefore(startOfWeek))
        .length;
    final sessionsThisMonth = sessions
        .where((session) => !session.date.isBefore(startOfMonth))
        .length;

    final snapshot = StatsSnapshot(
      sessionCount: sessions.length,
      totalRounds: totalRounds,
      averagePrecision: averagePrecision,
      bestPrecisionSession: bestPrecisionSession,
      longestSession: longestSession,
      lastSession: lastSession,
      sessionsThisWeek: sessionsThisWeek,
      sessionsThisMonth: sessionsThisMonth,
    );
    _lastHash = hash;
    _lastSnapshot = snapshot;
    return snapshot;
  }

  String _hashSessions(List<Session> sessions) {
    return sessions
        .map(
          (session) => [
            session.id,
            session.date.toIso8601String(),
            session.totalRounds,
            session.exercises.length,
            session.hasCountedPrecision,
            session.averagePrecision.toStringAsFixed(4),
          ].join('|'),
        )
        .join('::');
  }
}
