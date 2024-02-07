import Flutter
import TikTokOpenAuthSDK
import UIKit

public class SwiftFlutterTiktokSdkPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.k9i/flutter_tiktok_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterTiktokSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setup":
      result(nil)
    case "login":
      login(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
      return
    }
  }

  func login(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError.nilArgument)
      return
    }

    guard let scope = args["scope"] as? String else {
      result(FlutterError.failedArgumentField("scope", type: String.self))
      return
    }

    guard let redirectURI = args["redirectUri"] as? String else {
      result(FlutterError.failedArgumentField("redirectURI", type: String.self))
      return
    }

    guard let browserAuthEnabled = args["browserAuthEnabled"] as? Bool else {
      result(FlutterError.failedArgumentField("browserAuthEnabled", type: Bool.self))
      return
    }

    guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
      result(nil)
      return
    }

    let scopes = Set(scope.split(separator: ",").map(String.init))
    let authRequest = TikTokAuthRequest(scopes: scopes, redirectURI: redirectURI)
    authRequest.isWebAuth = browserAuthEnabled

    authRequest.send { response in
      guard let authResponse = response as? TikTokAuthResponse else { return }
      if authResponse.errorCode == .noError {
        let resultMap: [String: String?] = [
          "authCode": authResponse.authCode,
          "codeVerifier": authRequest.pkce.codeVerifier,
          "state": authRequest.state,
          "grantedPermissions": (authResponse.grantedPermissions)?.joined(separator: ","),
        ]
        result(resultMap)
      } else {
        result(
          FlutterError(
            code: String(authResponse.errorCode.rawValue),
            message: authResponse.errorDescription,
            details: nil
          )
        )
      }
    }
  }
}

extension FlutterError {
  static let nilArgument = FlutterError(
    code: "argument.nil",
    message: "Expect an argument when invoking channel method, but it is nil.", details: nil
  )

  static func failedArgumentField<T>(_ fieldName: String, type: T.Type) -> FlutterError {
    return .init(
      code: "argument.failedField",
      message: "Expect a `\(fieldName)` field with type <\(type)> in the argument, "
        + "but it is missing or type not matched.",
      details: fieldName)
  }
}
