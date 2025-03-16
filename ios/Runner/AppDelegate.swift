import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let fileChannel = FlutterMethodChannel(name: "com.example.yourapp/file",
                                              binaryMessenger: controller.binaryMessenger)
        fileChannel.setMethodCallHandler { (call, result) in
            if call.method == "openFile" {
                if let fileContent = call.arguments as? String {
                    // Handle the file content in Flutter
                    self.handleFileContent(fileContent)
                }
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.pathExtension == "md" {
            let fileContent = try? String(contentsOf: url, encoding: .utf8)
            if let content = fileContent {
                let controller = window?.rootViewController as! FlutterViewController
                let fileChannel = FlutterMethodChannel(name: "com.example.yourapp/file",
                                                      binaryMessenger: controller.binaryMessenger)
                fileChannel.invokeMethod("openFile", arguments: content)
            }
        }
        return true
    }

    private func handleFileContent(_ content: String) {
        // Handle the file content in Flutter
    }
}