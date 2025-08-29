import UIKit
import Flutter
import GooglePlaces
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Info.plist에서 API Key 읽어오기 (Google Places만 사용)
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String {
      GMSPlacesClient.provideAPIKey(apiKey)
    }

    GeneratedPluginRegistrant.register(with: self)

    // Ensure notifications show while app is in foreground (iOS 10+)
    UNUserNotificationCenter.current().delegate = self

    // MethodChannel to query iOS notification authorization status
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app.notificationStatus",
                                         binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        if call.method == "getAuthorizationStatus" {
          UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .authorized: status = "authorized"
            case .provisional: status = "provisional"
            case .ephemeral: status = "ephemeral"
            case .denied: status = "denied"
            case .notDetermined: status = "notDetermined"
            @unknown default: status = "unknown"
            }
            result(status)
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Foreground notification presentation options (banner/list/sound)
  override public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              willPresent notification: UNNotification,
                                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .list, .sound, .badge])
  }
}