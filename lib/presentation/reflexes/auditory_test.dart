part of '../reflexes_screen.dart';

Future<_ReflexSessionRecord?> _startAuditoryTestLevel({
  required BuildContext context,
  required int level,
  required Map<String, List<_ReflexSessionRecord>> historyByMode,
  required void Function(_ReflexSessionRecord) onResultSaved,
}) async {
  final p = auditoryLevelParams(level);
  return Navigator.of(context).push<_ReflexSessionRecord>(
    PageRouteBuilder<_ReflexSessionRecord>(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => _ReactionRunScreen(
        mode: _ReflexesMode.auditory,
        history:
            historyByMode[_ReflexesMode.auditory.name] ??
            const <_ReflexSessionRecord>[],
        stimuliCount: p.stimuliCount,
        minDelayMs: p.minDelayMs,
        maxDelayMs: p.maxDelayMs,
        onResultSaved: onResultSaved,
        level: level,
      ),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}
