import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_app/core/auth/auth_service.dart';
import 'package:flutter_app/core/network/api_client.dart';

class _StubResponse {
  const _StubResponse({
    required this.statusCode,
    this.body,
  });

  final int statusCode;
  final Object? body;
}

class _StubHttpClientAdapter implements HttpClientAdapter {
  _StubHttpClientAdapter(this._responsesByPath);

  final Map<String, List<_StubResponse>> _responsesByPath;
  final Map<String, int> _indicesByPath = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    final list = _responsesByPath[path];
    if (list == null || list.isEmpty) {
      throw StateError('No stubbed response for path: $path');
    }

    final index = _indicesByPath[path] ?? 0;
    if (index >= list.length) {
      throw StateError('No more stubbed responses for path: $path');
    }
    _indicesByPath[path] = index + 1;
    final current = list[index];

    final bytes = switch (current.body) {
      null => Uint8List(0),
      final String s => Uint8List.fromList(utf8.encode(s)),
      _ => Uint8List.fromList(utf8.encode(jsonEncode(current.body))),
    };

    return ResponseBody.fromBytes(
      bytes,
      current.statusCode,
      headers: const {'content-type': ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService auth state', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('init keeps logged out when no token exists', () async {
      apiClient.httpClientAdapter = _StubHttpClientAdapter({});
      final service = AuthService();

      await service.init();

      expect(service.isLoggedIn.value, isFalse);
      expect(service.isEmailVerified.value, isTrue);
    });

    test('init logs in when token is valid and backend confirms', () async {
      FlutterSecureStorage.setMockInitialValues({
        authTokenStorageKey: 'token-123',
      });
      apiClient.httpClientAdapter = _StubHttpClientAdapter({
        'auth/check': [
          const _StubResponse(statusCode: 200, body: {'valid': true}),
        ],
        'user/account/email-verification': [
          const _StubResponse(statusCode: 200, body: {'email_verified': true}),
        ],
      });
      final service = AuthService();

      await service.init();

      expect(service.isLoggedIn.value, isTrue);
      expect(service.isEmailVerified.value, isTrue);
    });

    test('init clears invalid token when auth/check says invalid', () async {
      FlutterSecureStorage.setMockInitialValues({
        authTokenStorageKey: 'stale-token',
      });
      apiClient.httpClientAdapter = _StubHttpClientAdapter({
        'auth/check': [
          const _StubResponse(statusCode: 200, body: {'valid': false}),
        ],
      });
      final service = AuthService();
      final storage = const FlutterSecureStorage();

      await service.init();

      expect(service.isLoggedIn.value, isFalse);
      expect(await storage.read(key: authTokenStorageKey), isNull);
    });

    test('login stores token and sets auth state', () async {
      apiClient.httpClientAdapter = _StubHttpClientAdapter({
        'login': [
          const _StubResponse(statusCode: 200, body: {'token': 'new-token'}),
        ],
        'user/account/email-verification': [
          const _StubResponse(statusCode: 200, body: {'email_verified': true}),
        ],
      });
      final service = AuthService();
      final storage = const FlutterSecureStorage();

      await service.login(email: 'dev@example.com', password: 'secret');

      expect(service.isLoggedIn.value, isTrue);
      expect(service.isEmailVerified.value, isTrue);
      expect(await storage.read(key: authTokenStorageKey), 'new-token');
    });

    test('checkEmailVerificationNow returns false on EMAIL_NOT_VERIFIED', () async {
      apiClient.httpClientAdapter = _StubHttpClientAdapter({
        'user/account/email-verification': [
          const _StubResponse(
            statusCode: 403,
            body: {'code': 'EMAIL_NOT_VERIFIED'},
          ),
        ],
      });
      final service = AuthService();
      service.isLoggedIn.value = true;

      final verified = await service.checkEmailVerificationNow();

      expect(verified, isFalse);
      expect(service.isEmailVerified.value, isFalse);

      await service.logout();
    });

    test('logout clears local auth state even when API call fails', () async {
      FlutterSecureStorage.setMockInitialValues({
        authTokenStorageKey: 'token-before-logout',
      });
      apiClient.httpClientAdapter = _StubHttpClientAdapter({
        'logout': [
          const _StubResponse(statusCode: 500, body: {'message': 'error'}),
        ],
      });
      final service = AuthService();
      final storage = const FlutterSecureStorage();
      service.isLoggedIn.value = true;
      service.isEmailVerified.value = false;

      await service.logout();

      expect(service.isLoggedIn.value, isFalse);
      expect(service.isEmailVerified.value, isTrue);
      expect(await storage.read(key: authTokenStorageKey), isNull);
    });
  });
}
