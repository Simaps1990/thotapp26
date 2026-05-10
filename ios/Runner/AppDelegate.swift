import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private func registerConfigChannel(pluginRegistry: FlutterPluginRegistry) {
    guard let registrar = pluginRegistry.registrar(forPlugin: "thot/config") else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "thot/config",
      binaryMessenger: registrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getRevenueCatApiKey":
        let value = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String
        result(value ?? "")
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Under UIScene (FlutterSceneDelegate), plugin registration happens in
    // `didInitializeImplicitFlutterEngine` below. Do not access
    // `window.rootViewController` here — it is not yet set and triggers a
    // Flutter deprecation warning (flutter-launch-rootvc).
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerConfigChannel(pluginRegistry: engineBridge.pluginRegistry)
  }
}