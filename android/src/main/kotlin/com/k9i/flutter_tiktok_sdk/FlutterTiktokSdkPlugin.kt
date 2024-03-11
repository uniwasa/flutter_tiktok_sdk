package com.k9i.flutter_tiktok_sdk

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import com.tiktok.open.sdk.auth.AuthApi
import com.tiktok.open.sdk.auth.AuthRequest
import com.tiktok.open.sdk.auth.utils.PKCEUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** FlutterTiktokSdkPlugin */
class FlutterTiktokSdkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
  PluginRegistry.NewIntentListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private var authApi: AuthApi? = null
  private var activity: Activity? = null
  private var activityPluginBinding: ActivityPluginBinding? = null
  private var loginResult: Result? = null
  private var clientKey: String? = null
  private var codeVerifier: String? = null
  private var redirectUrl: String? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.k9i/flutter_tiktok_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "setup" -> {
        val activity = activity
        if (activity == null) {
          result.error(
            "no_activity_found",
            "There is no valid Activity found to present TikTok SDK Login screen.",
            null
          )
          return
        }

        clientKey = call.argument<String>("clientKey")
        authApi = AuthApi(activity = activity)
        result.success(null)
      }
      "login" -> {
        val scope = call.argument<String>("scope")
        val redirectUrl = call.argument<String>("redirectUri")
        val state = call.argument<String>("state")
        val browserAuthEnabled = call.argument<Boolean>("browserAuthEnabled")
        val codeVerifier = PKCEUtils.generateCodeVerifier()
        val clientKey = this.clientKey

        if (clientKey == null) {
          result.error(
            "client_key_not_found",
            "Client key is not found. Please call setup method first.",
            null
          )
          return
        }
        if (scope == null || redirectUrl == null) {
          result.error(
            "invalid_parameters",
            "Required parameters are missing. Please check the parameters and try again.",
            null
          )
          return
        }

        // Store values for onNewIntent
        this.redirectUrl = redirectUrl
        this.codeVerifier = codeVerifier
        this.loginResult = result

        val request = AuthRequest(
          clientKey = clientKey,
          scope = scope,
          redirectUri = redirectUrl,
          state = state,
          codeVerifier = codeVerifier,
        )
        val authType =
          if (browserAuthEnabled == true) AuthApi.AuthMethod.ChromeTab else AuthApi.AuthMethod.TikTokApp

        authApi?.authorize(request, authType)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    bindActivityBinding(binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    unbindActivityBinding()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    bindActivityBinding(binding)
  }

  override fun onDetachedFromActivity() {
    unbindActivityBinding()
  }

  private fun bindActivityBinding(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityPluginBinding = binding
    binding.addOnNewIntentListener(this)
  }

  private fun unbindActivityBinding() {
    activityPluginBinding?.removeOnNewIntentListener(this)
    activity = null
    activityPluginBinding = null
  }

  override fun onNewIntent(intent: Intent): Boolean {
    val redirectUrl = redirectUrl
    redirectUrl ?: return true

    authApi?.getAuthResponseFromIntent(intent, redirectUrl = redirectUrl)?.let {
      val authCode = it.authCode
      if (authCode.isNotEmpty()) {
        val resultMap = mapOf(
          "authCode" to authCode,
          "state" to it.state,
          "grantedPermissions" to it.grantedPermissions,
          "codeVerifier" to codeVerifier
        )
        loginResult?.success(resultMap)
      } else {
        // Returns an error if authentication fails
        loginResult?.error(
          it.errorCode.toString(),
          it.errorMsg,
          it.authErrorDescription,
        )
      }
    }
    return true
  }
}
