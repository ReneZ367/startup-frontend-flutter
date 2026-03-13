import 'package:founta_app/core/network/api.dart';

class AuthApi {
  static const String _deviceName = 'founta_app';

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
