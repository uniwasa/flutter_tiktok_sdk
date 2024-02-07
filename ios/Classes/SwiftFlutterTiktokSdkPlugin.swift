import Flutter
import TikTokOpenAuthSDK
import UIKit

public class SwiftFlutterTiktokSdkPlugin: NSObject, FlutterPlugin {
  private var authRequest: TikTokAuthRequest?

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

    let scopes = scope.split(separator: ",")
    let scopesSet = Set<String>(scopes.map { String($0) })
    let authRequest = TikTokAuthRequest(scopes: scopesSet, redirectURI: redirectURI)
    authRequest.isWebAuth = browserAuthEnabled
    self.authRequest = authRequest
    authRequest.send { [weak self] response in
      guard let self = self, let authRequest = response as? TikTokAuthResponse else { return }
      if authRequest.error == nil {
        let resultMap: [String: String?] = [
          "authCode": authRequest.authCode,
          "codeVerifier": self.authRequest?.pkce.codeVerifier,
          "state": authRequest.state,
          "grantedPermissions": (authRequest.grantedPermissions)?.joined(separator: ","),
        ]
        result(resultMap)
      } else {
        result(
          FlutterError(
            code: String(authRequest.errorCode.rawValue),
            message: authRequest.errorDescription,
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
