part of '../flutter_tiktok_sdk.dart';

class TikTokLoginResult {
  const TikTokLoginResult({
    required this.status,
    this.authCode,
    this.codeVerifier,
    this.state,
    this.grantedPermissions,
    this.errorCode,
    this.errorMessage,
    this.errorDetails,
  });
  final TikTokLoginStatus status;
  final String? authCode;
  final String? codeVerifier;
  final String? state;
  final Set<TikTokPermissionType>? grantedPermissions;
  final String? errorCode;
  final String? errorMessage;
  final String? errorDetails;

  @override
  String toString() {
    return 'TikTokLoginResult{status: $status, authCode: $authCode, codeVerifier: $codeVerifier, state: $state, grantedPermissions: $grantedPermissions, errorCode: $errorCode, errorMessage: $errorMessage, errorDetails: $errorDetails}';
  }
}

enum TikTokLoginStatus {
  success,
  cancelled,
  error,
}
