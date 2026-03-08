import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    let channel = FlutterMethodChannel(
      name: "tourist_safety_app/maps_config",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "setMapsApiKey" {
        guard let args = call.arguments as? [String: Any],
              let apiKey = args["apiKey"] as? String, !apiKey.isEmpty else {
          result(FlutterError(code: "INVALID_ARGS", message: "apiKey required", details: nil))
          return
        }
        GMSServices.provideAPIKey(apiKey)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
