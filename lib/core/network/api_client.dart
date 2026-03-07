import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants.dart';

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

/// Shared Dio instance for all API requests. Configure once; use everywhere.
final Dio apiClient = Dio(
  BaseOptions(
    baseUrl: _baseUrlForDio,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ),
)
  ..interceptors.add(
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
        if (status != 401 && status != 419) return handler.reject(error);

        final path = error.requestOptions.path;
        if (path == 'login') return handler.reject(error);

        final sentGen = error.requestOptions.extra['_tokenGeneration'] as int?;
        if (sentGen == null || sentGen != tokenGeneration) return handler.reject(error);

        await _secureStorage.delete(key: authTokenStorageKey);
        bumpTokenGeneration();
        onUnauthorized?.call();
        return handler.reject(error);
      },
    ),
  );

/// Dio joins baseUrl + path; keep trailing slash so "login" becomes .../api/v1/login.
String get _baseUrlForDio =>
    Constants.baseUrl.endsWith('/')
        ? Constants.baseUrl
        : '${Constants.baseUrl}/';
