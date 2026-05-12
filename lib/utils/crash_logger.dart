import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight crash logger that persists Flutter framework errors and
/// uncaught Dart errors to a local file (`<ApplicationSupport>/crash_log.jsonl`).
///
/// One JSON object per line. The file is rotated when it exceeds 256 KB
/// (oldest half discarded). Settings can offer "Export crash log" via
/// share_plus.
abstract final class CrashLogger {
  static const int _maxBytes = 256 * 1024;
  static File? _logFile;

  /// Wraps the entire app body with global error handlers. Must be called
  /// from `main()` BEFORE `runApp(...)`. Example:
  /// ```dart
  /// void main() {
  ///   CrashLogger.runGuarded(() async {
  ///     WidgetsFlutterBinding.ensureInitialized();
  ///     // ... app init
  ///     runApp(const MyApp());
  ///   });
  /// }
  /// ```
  static void runGuarded(FutureOr<void> Function() appBody) {
    runZonedGuarded<Future<void>>(
      () async {
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          unawaited(
            _log(
              type: 'flutter_error',
              error: details.exceptionAsString(),
              stackTrace: details.stack?.toString() ?? '',
              library: details.library ?? '',
              context: details.context?.toString() ?? '',
            ),
          );
        };
        PlatformDispatcher.instance.onError = (error, stack) {
          unawaited(
            _log(
              type: 'platform_dispatcher',
              error: error.toString(),
              stackTrace: stack.toString(),
            ),
          );
          return false;
        };
        await appBody();
      },
      (error, stack) {
        unawaited(
          _log(
            type: 'zone_error',
            error: error.toString(),
            stackTrace: stack.toString(),
          ),
        );
      },
    );
  }

  static Future<File> _getLogFile() async {
    if (_logFile != null) return _logFile!;
    if (kIsWeb) {
      throw UnsupportedError('CrashLogger not supported on web');
    }
    final dir = await getApplicationSupportDirectory();
    _logFile = File('${dir.path}/crash_log.jsonl');
    return _logFile!;
  }

  static Future<void> _log({
    required String type,
    required String error,
    required String stackTrace,
    String library = '',
    String context = '',
  }) async {
    if (kIsWeb) {
      debugPrint('[CrashLogger:$type] $error\n$stackTrace');
      return;
    }
    try {
      final entry = <String, dynamic>{
        'ts': DateTime.now().toUtc().toIso8601String(),
        'type': type,
        'error': error,
        'library': library,
        'context': context,
        'stack': stackTrace,
        'platform': defaultTargetPlatform.name,
        'mode': kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug'),
      };
      final line = '${jsonEncode(entry)}\n';
      final file = await _getLogFile();
      await _maybeRotate(file);
      await file.writeAsString(line, mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint('[CrashLogger] failed to persist log: $e');
    }
  }

  static Future<void> _maybeRotate(File file) async {
    try {
      if (!await file.exists()) return;
      final size = await file.length();
      if (size <= _maxBytes) return;
      final raw = await file.readAsString();
      final keepFrom = raw.length ~/ 2;
      final cut = raw.indexOf('\n', keepFrom);
      final kept = cut >= 0 ? raw.substring(cut + 1) : '';
      await file.writeAsString(kept, flush: true);
    } catch (_) {}
  }

  static Future<String> readLog() async {
    if (kIsWeb) return '';
    try {
      final file = await _getLogFile();
      if (!await file.exists()) return '';
      return file.readAsString();
    } catch (_) {
      return '';
    }
  }

  static Future<String?> get logFilePath async {
    if (kIsWeb) return null;
    try {
      final file = await _getLogFile();
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    if (kIsWeb) return;
    try {
      final file = await _getLogFile();
      if (await file.exists()) {
        await file.writeAsString('', flush: true);
      }
    } catch (_) {}
  }

  static Future<void> logWarning({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    return _log(
      type: 'warning',
      error: error == null ? message : '$message — $error',
      stackTrace: stackTrace?.toString() ?? '',
    );
  }
}
