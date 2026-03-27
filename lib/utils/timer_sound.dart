import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Gestion centralisée du bip de timer, avec une implémentation simple et
/// cross‑platform basée sur AudioPlayer.play(AssetSource(...)).
class TimerSound {
  static const String _assetPath = 'audio/Timercut.wav';

  // Player unique réutilisé, sans mode lowLatency ni seek/resume.
  static final AudioPlayer _player = AudioPlayer(playerId: 'timer_bip')
    ..setReleaseMode(ReleaseMode.stop);

  static bool _warmUpDone = false;
  static String? _lastDebugMessage;

  static String? get lastDebugMessage => _lastDebugMessage;

  static void _setDebug(String message) {
    _lastDebugMessage = message;
    debugPrint(message);
  }

  /// Prépare le player et vérifie que l’asset est accessible, sans lecture.
  static Future<void> warmUp() async {
    if (_warmUpDone) return;
    try {
      await _player.setSource(AssetSource(_assetPath));
      _warmUpDone = true;
      _setDebug('TimerSound warmUp OK: $_assetPath');
    } catch (e) {
      _warmUpDone = false;
      _setDebug('TimerSound warmUp ERROR: $e');
    }
  }

  /// Joue le bip du timer. Fonctionne même si warmUp() n’a pas été appelé.
  static Future<void> play() async {
    try {
      if (!_warmUpDone) {
        await warmUp();
      }

      // Lecture simple de l’asset. Pas de seek / resume, pas de lowLatency.
      await _player.play(AssetSource(_assetPath));
      _setDebug('TimerSound play OK');
    } catch (e) {
      _setDebug('TimerSound play ERROR: $e');
    }
  }

  /// Libère les ressources audio si nécessaire.
  static Future<void> dispose() async {
    try {
      await _player.dispose();
      _setDebug('TimerSound dispose OK');
    } catch (e) {
      _setDebug('TimerSound dispose ERROR: $e');
    }
  }
}
