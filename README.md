# flutter_tiktok_sdk

A Flutter plugin that lets developers access TikTok's native SDKs in Flutter apps with Dart

Native SDK documentation 👉 https://developers.tiktok.com/doc/getting-started-create-an-app/

# iOS Configuration

Go to https://developers.tiktok.com/doc/mobile-sdk-ios-quickstart/

### Step 1: Configure TikTok App Settings for iOS

Go to TikTok Developer App Registration Page to create your app. After approval, you will get the Client Key and Client Secret.

### Step 2: Add Login Kit to your app

Then add Login Kit to your app by navigating to the Manage apps page, and clicking + Add products.

### Step 3: Register a redirect URI (must be a Universal Link)

You must also register a redirect URI on the TikTok for Developers website. This redirect URI is used to verify your application, as well as to callback to your application with an authorization response. This redirect URI must be a universal link with an https scheme and your app must support associated domains.

### Step 4: Configure Xcode Project

Configure Info.plist

```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tiktokopensdk</string>
    <string>tiktoksharesdk</string>
    <string>snssdk1180</string>
    <string>snssdk1233</string>
</array>
<key>TikTokClientKey</key>
<string>$TikTokClientKey</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>$TikTokClientKey</string>
    </array>
  </dict>
</array>
```

### Step 3: Edit AppDelegate.swift

Add the following code to your AppDelegate.swift file.

```
import UIKit
import Flutter
// Add this line
import TikTokOpenSDKCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Add this line
    if TikTokURLHandler.handleOpenURL(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Add this line
    if TikTokURLHandler.handleOpenURL(userActivity.webpageURL) {
      return true
    }
    return super.application(
      application, continue: userActivity, restorationHandler: restorationHandler)
  }
}

```

# Android Configuration

Go to https://developers.tiktok.com/doc/mobile-sdk-android-quickstart/

### Step 1: Configure TikTok App Settings for Android

Use the Developer Portal to apply for Android client_key and client_secret access. Upon application approval, the Developer Portal will provide access to these keys.

### Step 2: Add Login Kit to your app

Then add Login Kit to your app by navigating to the Manage apps page, and clicking + Add products.

### Step 3: Register a redirect URI (must be a App Link)

You must also register a redirect URI on the TikTok for Developers website. This redirect URI is used to verify your application, as well as to callback to your application with an authorization response. This redirect URI must be a App link with an https scheme.

### Step 4: Edit Your Manifest

Due to changes in Android 11 regarding package visibility, when impementing Tiktok SDK for devices targeting Android 11 and higher, add the following to the Android Manifest file:

```
<queries>
    <package android:name="com.zhiliaoapp.musically" />
    <package android:name="com.ss.android.ugc.trill" />
</queries>
```

# Example code

See the example directory for a complete sample app using flutter_tiktok_sdk.

[example](https://github.com/K9i-0/flutter_tiktok_sdk/tree/main/example)

# Maintenance Status of this Repository

This package was originally developed when I needed TikTok authentication for an application at my previous job. However, since I've changed jobs, I no longer have a use for the TikTok SDK. As such, my motivation to proactively add new features has decreased. That said, I'm open to reviewing pull requests if anyone wishes to contribute.

Additionally, if someone with high motivation wishes to fork this repository and develop a successor package (e.g., flutter_tiktok_sdk_plus), you are more than welcome. Should that happen, I will take measures to ensure that users are aware of the successor package.
