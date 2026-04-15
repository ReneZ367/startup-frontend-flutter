import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:founta_app/core/network/api_client.dart';

import '../../support/http_stub_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('apiClient interceptors', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      onUnauthorized = null;
      onEmailNotVerified = null;
    });

    test('adds bearer token to authorized requests', () async {
      FlutterSecureStorage.setMockInitialValues({
        authTokenStorageKey: 'token-abc',
      });
      final adapter = StubHttpClientAdapter({
        'profile': [const StubResponse(statusCode: 200, body: {'id': 1})],
      });
      apiClient.httpClientAdapter = adapter;

      await apiClient.get('profile');

      expect(adapter.requests.single.headers['Authorization'], 'Bearer token-abc');
      expect(adapter.requests.single.extra['_tokenGeneration'], isA<int>());
    });

    test('401 clears token and calls onUnauthorized for non-login paths', () async {
      FlutterSecureStorage.setMockInitialValues({
        authTokenStorageKey: 'token-expired',
      });
      final adapter = StubHttpClientAdapter({
        'protected': [const StubResponse(statusCode: 401, body: {'message': 'Unauthenticated'})],
      });
      apiClient.httpClientAdapter = adapter;
      var unauthorizedCalled = false;
      onUnauthorized = () => unauthorizedCalled = true;
      final storage = const FlutterSecureStorage();

      await expectLater(apiClient.get('protected'), throwsA(isA<Exception>()));

      expect(await storage.read(key: authTokenStorageKey), isNull);
      expect(unauthorizedCalled, isTrue);
    });

    test('401 on login path does not clear token and does not call onUnauthorized', () async {
      FlutterSecureStorage.setMockInitialValues({
        authTokenStorageKey: 'keep-me',
      });
      final adapter = StubHttpClientAdapter({
        'login': [const StubResponse(statusCode: 401, body: {'message': 'Invalid'})],
      });
      apiClient.httpClientAdapter = adapter;
      var unauthorizedCalled = false;
      onUnauthorized = () => unauthorizedCalled = true;
      final storage = const FlutterSecureStorage();

      await expectLater(apiClient.post('login'), throwsA(isA<Exception>()));

      expect(await storage.read(key: authTokenStorageKey), 'keep-me');
      expect(unauthorizedCalled, isFalse);
    });

    test('403 EMAIL_NOT_VERIFIED calls onEmailNotVerified callback', () async {
      FlutterSecureStorage.setMockInitialValues({
        authTokenStorageKey: 'token-abc',
      });
      final adapter = StubHttpClientAdapter({
        'restricted': [
          const StubResponse(
            statusCode: 403,
            body: {'code': 'EMAIL_NOT_VERIFIED'},
          ),
        ],
      });
      apiClient.httpClientAdapter = adapter;
      Uri? callbackUri;
      onEmailNotVerified = (uri) => callbackUri = uri;

      await expectLater(apiClient.get('restricted'), throwsA(isA<Exception>()));

      expect(callbackUri, isNotNull);
      expect(callbackUri!.path, '/api/v1/restricted');
    });
  });
}
