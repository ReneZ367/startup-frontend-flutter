import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:founta_app/constants.dart';
import 'package:founta_app/core/network/api_error.dart';
import 'package:founta_app/enums/api_error_code_enum.dart';

/// Key used to read/write the auth token in secure storage. Use the same key when storing after login.
const String authTokenStorageKey = 'auth_token';

final _secureStorage = const FlutterSecureStorage();

/// Increment when token is written or cleared. Requests carry this; 401 only clears if it matches.
/// Call after writing token (login) and after clearing (logout). No token stored in request.
int _tokenGeneration = 0;
int get tokenGeneration => _tokenGeneration;
void bumpTokenGeneration() => _tokenGeneration++;

/// Called when a response has status 401 or 419 (session invalid). Set at app startup to e.g. navigate to login.
void Function()? onUnauthorized;

/// Optional hook when the API returns 403 with [ApiErrorCodeEnum.emailNotVerified]. Set in [main] if you want logging or navigation.
void Function(Uri requestUri)? onEmailNotVerified;

Dio _buildApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrlForDio,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: authTokenStorageKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          options.extra['_tokenGeneration'] = tokenGeneration;
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;

        // 403 must stay in this onError: Dio skips later interceptors after reject.
        if (status == 403) {
          if (parseKnownApiErrorCode(error.response?.data) ==
              ApiErrorCodeEnum.emailNotVerified) {
            onEmailNotVerified?.call(error.requestOptions.uri);
          }
          return handler.reject(error);
        }

        if (status != 401 && status != 419) return handler.reject(error);

        final path = error.requestOptions.path;
        if (path == 'login') return handler.reject(error);

        final sentGen = error.requestOptions.extra['_tokenGeneration'] as int?;
        if (sentGen == null || sentGen != tokenGeneration) {
          return handler.reject(error);
        }

        await _secureStorage.delete(key: authTokenStorageKey);
        bumpTokenGeneration();
        onUnauthorized?.call();
        return handler.reject(error);
      },
    ),
  );

  return dio;
}

/// Shared Dio instance for all API requests. Configure once; use everywhere.
final Dio apiClient = _buildApiClient();

/// Dio joins baseUrl + path; keep trailing slash so "login" becomes .../api/v1/login.
String get _baseUrlForDio => Constants.baseUrl.endsWith('/')
    ? Constants.baseUrl
    : '${Constants.baseUrl}/';
