import Flutter
import UIKit
#if canImport(FoundationModels)
import FoundationModels
#endif

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeLlmBridge") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "meallog_ai/native_llm",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isSupported":
        result(Self.isSystemModelAvailable)
      case "prepare":
        if Self.isSystemModelAvailable {
          result(nil)
        } else {
          result(FlutterError(code: "MODEL_NOT_READY", message: "Apple Intelligenceを利用できません", details: nil))
        }
      case "generate":
        guard
          let arguments = call.arguments as? [String: Any],
          let prompt = arguments["prompt"] as? String
        else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "promptが必要です", details: nil))
          return
        }
        Self.generate(prompt: prompt, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

  }

  private static var isSystemModelAvailable: Bool {
#if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      return SystemLanguageModel.default.availability == .available
    }
#endif
    return false
  }

  private static func generate(prompt: String, result: @escaping FlutterResult) {
#if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      Task {
        do {
          let session = LanguageModelSession(model: SystemLanguageModel.default)
          let response = try await session.respond(to: prompt)
          result(response.content)
        } catch {
          result(FlutterError(code: "GENERATION_FAILED", message: error.localizedDescription, details: nil))
        }
      }
      return
    }
#endif
    result(FlutterError(code: "MODEL_UNAVAILABLE", message: "Apple Intelligenceを利用できません", details: nil))
  }
}
