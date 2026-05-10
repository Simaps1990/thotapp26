package fr.thotbook.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
  private val configChannelName = "thot/config"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, configChannelName)
        .setMethodCallHandler { call, result ->
          when (call.method) {
            "getRevenueCatApiKey" -> {
              val key = BuildConfig.REVENUECAT_API_KEY
              result.success(key)
            }
            else -> result.notImplemented()
          }
        }
  }
}