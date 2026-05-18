import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_app/core/auth/auth_api.dart';
import 'package:flutter_app/core/network/api_client.dart';

import '../../support/http_stub_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthApi', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      onUnauthorized = null;
      onEmailNotVerified = null;
    });

    test('login sends expected payload and returns decoded data', () async {
      final adapter = StubHttpClientAdapter({
        'login': [const StubResponse(statusCode: 200, body: {'token': 'abc123'})],
      });
      apiClient.httpClientAdapter = adapter;

      final data = await AuthApi().login(
        email: 'dev@example.com',
        password: 'secret',
      );

      expect(data, {'token': 'abc123'});
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, 'login');
      expect(adapter.requests.single.data, {
        'email': 'dev@example.com',
        'password': 'secret',
        'device_name': 'flutter_app',
      });
    });

    test('register sends expected payload', () async {
      final adapter = StubHttpClientAdapter({
        'register': [const StubResponse(statusCode: 200, body: {'token': 'new-user-token'})],
      });
      apiClient.httpClientAdapter = adapter;

      await AuthApi().register(
        name: 'Senior Dev',
        email: 'senior@example.com',
        password: 'secret123',
        passwordConfirmation: 'secret123',
      );

      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, {
        'name': 'Senior Dev',
        'email': 'senior@example.com',
        'password': 'secret123',
        'password_confirmation': 'secret123',
        'device_name': 'flutter_app',
      });
    });

    test('fetchEmailVerificationStatus reads email_verified key', () async {
      final adapter = StubHttpClientAdapter({
        'user/account/email-verification': [
          const StubResponse(statusCode: 200, body: {'email_verified': false}),
        ],
      });
      apiClient.httpClientAdapter = adapter;

      final verified = await AuthApi().fetchEmailVerificationStatus();

      expect(verified, isFalse);
    });

    test('fetchEmailVerificationStatus supports legacy verified key', () async {
      final adapter = StubHttpClientAdapter({
        'user/account/email-verification': [
          const StubResponse(statusCode: 200, body: {'verified': true}),
        ],
      });
      apiClient.httpClientAdapter = adapter;

      final verified = await AuthApi().fetchEmailVerificationStatus();

      expect(verified, isTrue);
    });

    test('fetchEmailVerificationStatus defaults to true for unknown shape', () async {
      final adapter = StubHttpClientAdapter({
        'user/account/email-verification': [
          const StubResponse(statusCode: 200, body: {'foo': 'bar'}),
        ],
      });
      apiClient.httpClientAdapter = adapter;

      final verified = await AuthApi().fetchEmailVerificationStatus();

      expect(verified, isTrue);
    });
  });
}
