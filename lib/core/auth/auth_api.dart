import 'package:flutter_app/core/network/api.dart';

class AuthApi {
  static const String _deviceName = 'flutter_app';

  /// Parses `GET user/account/email-verification` (relative to the configured API base URL; e.g. `{ "email_verified": true, "email_verified_at": "..." }`).
  /// Use a path without a leading slash so Dio keeps the base URL path prefix (e.g. `.../api/v1/`).
  /// Falls back to legacy `verified` if present; otherwise returns `true` so the app stays usable when the shape differs.
  Future<bool> fetchEmailVerificationStatus() async {
    final data = await apiGet('user/account/email-verification');
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final emailVerified = map['email_verified'];
      if (emailVerified is bool) return emailVerified;
      final legacy = map['verified'];
      if (legacy is bool) return legacy;
    }
    return true;
  }

  /// Sends another verification email to the authenticated user. Returns decoded JSON (e.g. `message`).
  Future<dynamic> sendEmailVerificationNotification() async {
    return apiPost('email/verification-notification', {});
  }

  /// Returns the decoded response (e.g. { 'token': String, 'message': String }).
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    return apiPost('login', {
      'email': email,
      'password': password,
      'device_name': _deviceName,
    });
  }

  /// Registers a new user. Returns the decoded response (e.g. { 'token': String, 'message': String }).
  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return apiPost('register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_name': _deviceName,
    });
  }

  /// Sends a password reset link to the given email. Returns the decoded response.
  Future<dynamic> forgotPassword({required String email}) async {
    return apiPost('forgot-password', {'email': email});
  }

  /// Tells the server to invalidate the current token. Uses Bearer token from the interceptor.
  /// Backend may expect POST /logout; change to apiDelete('logout') if your API differs.
  Future<void> logout() async {
    await apiPost('logout', {});
  }
}
