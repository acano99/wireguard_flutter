import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller : FlutterViewController = windows?.rootViewController as! FlutterViewController 
    let binaryMessenger = controller.binaryMessenger

    let wireguardImpl = WireGuardImpl()
    WireGuardHostApiSetup(binaryMessenger, wireguardImpl)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
