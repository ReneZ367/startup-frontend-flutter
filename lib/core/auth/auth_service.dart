import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_app/core/auth/auth_api.dart';
import 'package:flutter_app/core/network/api.dart';
import 'package:flutter_app/core/network/api_client.dart';
import 'package:flutter_app/core/network/api_error.dart';
import 'package:flutter_app/enums/api_error_code_enum.dart';

bool _isEmailNotVerifiedForbidden(DioException e) {
  return e.response?.statusCode == 403 &&
      parseKnownApiErrorCode(e.response?.data) ==
          ApiErrorCodeEnum.emailNotVerified;
}

/// Owns app auth state and login/logout. Single source of truth for "is the user logged in?".
/// Use [authService] and call [AuthService.init] in main before runApp.
class AuthService {
  AuthService() : _storage = const FlutterSecureStorage();

  static const Duration _emailVerificationPollInterval = Duration(seconds: 3);

  final FlutterSecureStorage _storage;
  Timer? _emailVerificationPollTimer;
  bool _emailVerificationPollInFlight = false;

  /// Listen to this for redirect (e.g. go_router refreshListenable). True = logged in, false = logged out.
  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  /// Whether the current account email is verified (`GET` email verification on launch and after login).
  /// When [isLoggedIn] is true and this is false, the router shows `/verify-email` only.
  final ValueNotifier<bool> isEmailVerified = ValueNotifier<bool>(true);

  /// Call once at app startup. If a token exists, calls auth/check to validate it;
  /// only sets [isLoggedIn] true when the backend returns valid. Clears token on 401/error.
  /// When valid, calls [AuthApi.fetchEmailVerificationStatus] to set [isEmailVerified].
  Future<void> init() async {
    isEmailVerified.value = true;
    final token = await _storage.read(key: authTokenStorageKey);
    if (token == null || token.isEmpty) {
      isLoggedIn.value = false;
      _reconcileEmailVerificationPolling();
      return;
    }
    try {
      final data = await apiGet('auth/check');
      final valid = data is Map && (data['valid'] == true);
      isLoggedIn.value = valid;
      if (!valid) {
        await _storage.delete(key: authTokenStorageKey);
        bumpTokenGeneration();
        _reconcileEmailVerificationPolling();
        return;
      }
      await _syncEmailVerificationFromApi();
    } catch (_) {
      await _storage.delete(key: authTokenStorageKey);
      bumpTokenGeneration();
      isLoggedIn.value = false;
      isEmailVerified.value = true;
      _reconcileEmailVerificationPolling();
    }
  }

  /// Invoked when the API returns 403 with EMAIL_NOT_VERIFIED. Keeps the session; gates the shell.
  void notifyEmailNotVerified() {
    if (!isLoggedIn.value) return;
    isEmailVerified.value = false;
    _reconcileEmailVerificationPolling();
  }

  /// Re-runs the verification-status request (e.g. after the user taps "I've verified").
  Future<void> refreshEmailVerificationStatus() =>
      _syncEmailVerificationFromApi();

  /// Calls [AuthApi.fetchEmailVerificationStatus] and updates [isEmailVerified].
  /// Returns `true` if verified (router leaves `/verify-email`). Returns `false` if still unverified,
  /// including 403 `EMAIL_NOT_VERIFIED`. Rethrows on other failures so the UI can show an error
  /// without clearing the verification gate.
  Future<bool> checkEmailVerificationNow() async {
    try {
      final verified = await AuthApi().fetchEmailVerificationStatus();
      isEmailVerified.value = verified;
      return verified;
    } on DioException catch (e) {
      if (_isEmailNotVerifiedForbidden(e)) {
        isEmailVerified.value = false;
        return false;
      }
      rethrow;
    } finally {
      _reconcileEmailVerificationPolling();
    }
  }

  /// POST `email/verification-notification` — resend verification email (authenticated).
  Future<dynamic> resendVerificationEmail() async {
    return AuthApi().sendEmailVerificationNotification();
  }

  Future<void> _syncEmailVerificationFromApi() async {
    try {
      final verified = await AuthApi().fetchEmailVerificationStatus();
      isEmailVerified.value = verified;
    } on DioException catch (e) {
      if (_isEmailNotVerifiedForbidden(e)) {
        isEmailVerified.value = false;
        return;
      }
      isEmailVerified.value = true;
    } catch (_) {
      isEmailVerified.value = true;
    } finally {
      _reconcileEmailVerificationPolling();
    }
  }

  void _reconcileEmailVerificationPolling() {
    final shouldPoll = isLoggedIn.value && !isEmailVerified.value;
    if (shouldPoll) {
      _emailVerificationPollTimer ??= Timer.periodic(
        _emailVerificationPollInterval,
        (_) => _onEmailVerificationPollTick(),
      );
    } else {
      _emailVerificationPollTimer?.cancel();
      _emailVerificationPollTimer = null;
    }
  }

  Future<void> _onEmailVerificationPollTick() async {
    if (!isLoggedIn.value || isEmailVerified.value) return;
    if (_emailVerificationPollInFlight) return;
    _emailVerificationPollInFlight = true;
    try {
      await _syncEmailVerificationFromApi();
    } finally {
      _emailVerificationPollInFlight = false;
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
    await _syncEmailVerificationFromApi();
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
    isEmailVerified.value = true;
    _reconcileEmailVerificationPolling();
  }
}

/// Single app-wide instance. Call [AuthService.init] in main before runApp.
final authService = AuthService();
