package fr.thotbook.app

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
  private val configChannelName = "thot/config"
  private var configChannel: MethodChannel? = null
  private var pendingWidgetRoute: String? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    pendingWidgetRoute = intent?.getStringExtra("thot_widget_route")
    configChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, configChannelName)
    configChannel
        ?.setMethodCallHandler { call, result ->
          when (call.method) {
            "getRevenueCatApiKey" -> {
              val key = BuildConfig.REVENUECAT_API_KEY
              result.success(key)
            }
            "consumeWidgetRoute" -> {
              val route = pendingWidgetRoute
              pendingWidgetRoute = null
              result.success(route)
            }
            else -> result.notImplemented()
          }
        }
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
    val route = intent.getStringExtra("thot_widget_route") ?: return
    pendingWidgetRoute = route
    configChannel?.invokeMethod("onWidgetRoute", route)
  }
}