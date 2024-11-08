import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, GenAIWrapperDelegate{
    private var eventSink: FlutterEventSink?
    
    private let METHOD_CHANNEL = "com.example.flutter.flutter_gen_ai_demo/channel/method"
    private let EVENT_CHANNEL = "com.example.flutter.flutter_gen_ai_demo/channel/event"
    
    var genAIWrapper: GenAIWrapper?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        genAIWrapper = GenAIWrapper()
        genAIWrapper?.delegate = self;
        
        let methodChannel = FlutterMethodChannel(name: METHOD_CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
        methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            switch call.method {
            case "load":
                if let path = call.arguments as? String {
                    self.handleLoadModel(path: path, result: result)
                }
            case "inference":
                self.handleInference(call: call, result: result)
            case "unload":
                self.handleUnloadModel(result: result)
            default:
                result(FlutterError(code: "UNAVAILABLE", message: "No such method", details: nil))
            }
        }
        
        let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
        eventChannel.setStreamHandler(self)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func handleLoadModel(path: String, result: FlutterResult) {
        do {
            try genAIWrapper?.load(path)
            result("LOADED")
        } catch {
            result(FlutterError(code: "LOAD_FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    private func handleInference(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let prompt = args["prompt"] as? String,
              let params = args["params"] as? [String: Double] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments received", details: nil))
            return
        }
        
        let paramsDict: [String: NSNumber] = params.mapValues { NSNumber(value: $0) }
        let success = genAIWrapper?.inference(prompt, withParams: paramsDict) ?? false
        
        if success {
            result("DONE")
        } else {
            result(FlutterError(code: "INFERENCE_FAILED", message: "Prompt generation failed", details: nil))
        }
    }
    
    func didGenerateToken(_ token: String) {
        if let eventSink = eventSink {
            eventSink(token)
        }
    }
    
    private func handleUnloadModel(result: FlutterResult) {
        genAIWrapper?.unload()
        result("UNLOADED")
    }
}

extension AppDelegate: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
