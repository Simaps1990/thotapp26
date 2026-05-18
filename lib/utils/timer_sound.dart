import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerSound {
  static const String _assetPath = 'audio/Timercut.wav';

  static final AudioPlayer _player = AudioPlayer(playerId: 'timer_bip')
    ..setReleaseMode(ReleaseMode.stop);

  static bool _warmUpDone = false;
  static bool _isPlaying = false;
  static String? _lastDebugMessage;

  static String? get lastDebugMessage => _lastDebugMessage;

  static void _setDebug(String message) {
    _lastDebugMessage = message;
    debugPrint(message);
  }

  static Future<void> warmUp() async {
    if (_warmUpDone) return;
    try {
      // iOS: bypass silent switch — un test auditif DOIT jouer même en silencieux.
      // respectSilence: false (défaut) → AVAudioSessionCategory.playback.
      await _player.setAudioContext(
        AudioContextConfig(respectSilence: false).build(),
      );
      await _player.setSource(AssetSource(_assetPath));
      _warmUpDone = true;
      _setDebug('TimerSound warmUp OK: $_assetPath');
    } catch (e) {
      _warmUpDone = false;
      _setDebug('TimerSound warmUp ERROR: $e');
    }
  }

  static Future<void> play() async {
    if (_isPlaying) return;
    _isPlaying = true;
    try {
      if (!_warmUpDone) {
        await warmUp();
      }

      await _player.stop();
      await _player.play(AssetSource(_assetPath));
      _setDebug('TimerSound play OK');
    } catch (e) {
      _setDebug('TimerSound play ERROR: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 200), () {
        _isPlaying = false;
      });
    }
  }

  static Future<void> dispose() async {
    try {
      await _player.dispose();
      _setDebug('TimerSound dispose OK');
    } catch (e) {
      _setDebug('TimerSound dispose ERROR: $e');
    }
  }
}
