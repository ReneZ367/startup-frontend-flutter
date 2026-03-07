import '../network/api.dart';

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

  /// Tells the server to invalidate the current token. Uses Bearer token from the interceptor.
  /// Backend may expect POST /logout; change to apiDelete('logout') if your API differs.
  Future<void> logout() async {
    await apiPost('logout', {});
  }
}
