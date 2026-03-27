package fr.thotbook.app

import android.media.AudioManager
import android.media.ToneGenerator
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
  private val channelName = "thot/sound"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        .setMethodCallHandler { call, result ->
          when (call.method) {
            "beep" -> {
              try {
                val toneGen = ToneGenerator(AudioManager.STREAM_MUSIC, 100)
                toneGen.startTone(ToneGenerator.TONE_PROP_BEEP, 200)
                toneGen.release()
                result.success(true)
              } catch (e: Exception) {
                result.error("BEEP_FAILED", e.message, null)
              }
            }

            else -> result.notImplemented()
          }
        }
  }
}