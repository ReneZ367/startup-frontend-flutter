import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:founta_app/core/auth/auth_api.dart';
import 'package:founta_app/core/network/api.dart';
import 'package:founta_app/core/network/api_client.dart';

/// Owns app auth state and login/logout. Single source of truth for "is the user logged in?".
/// Use [authService] and call [AuthService.init] in main before runApp.
class AuthService {
  AuthService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  /// Listen to this for redirect (e.g. go_router refreshListenable). True = logged in, false = logged out.
  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  /// Call once at app startup. If a token exists, calls auth/check to validate it;
  /// only sets [isLoggedIn] true when the backend returns valid. Clears token on 401/error.
  Future<void> init() async {
    final token = await _storage.read(key: authTokenStorageKey);
    if (token == null || token.isEmpty) {
      isLoggedIn.value = false;
      return;
    }
    try {
      final data = await apiGet('auth/check');
      final valid = data is Map && (data['valid'] == true);
      isLoggedIn.value = valid;
      if (!valid) {
        await _storage.delete(key: authTokenStorageKey);
        bumpTokenGeneration();
      }
    } catch (_) {
      await _storage.delete(key: authTokenStorageKey);
      bumpTokenGeneration();
      isLoggedIn.value = false;
    }
  }

  /// Calls API, stores token, sets [isLoggedIn] to true. Throws on API error.
  Future<void> login({required String email, required String password}) async {
    final data = await AuthApi().login(email: email, password: password);
    await _handleAuthResponse(data);
  }

  /// Calls API to register, stores token if returned, sets [isLoggedIn] to true.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await AuthApi().register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    await _handleAuthResponse(data);
  }

  /// Requests a password reset link. Returns the API response (e.g. { 'message': String }).
  Future<dynamic> forgotPassword({required String email}) async {
    return AuthApi().forgotPassword(email: email);
  }

  Future<void> _handleAuthResponse(dynamic data) async {
    final token = data is Map ? data['token'] as String? : null;
    if (token == null || token.isEmpty) {
      throw StateError('Auth response had no token');
    }
    await _storage.write(key: authTokenStorageKey, value: token);
    bumpTokenGeneration();
    isLoggedIn.value = true;
  }

  /// Calls API to invalidate token (best effort), then clears local token and sets [isLoggedIn] to false.
  /// Call on "Log out" or wire to [onUnauthorized].
  Future<void> logout() async {
    try {
      await AuthApi().logout();
    } catch (_) {
      // Still clear locally if server is unreachable or returns an error
    }
    await _storage.delete(key: authTokenStorageKey);
    bumpTokenGeneration();
    isLoggedIn.value = false;
  }
}

/// Single app-wide instance. Call [AuthService.init] in main before runApp.
final authService = AuthService();
