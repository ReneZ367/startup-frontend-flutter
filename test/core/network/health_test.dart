import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:founta_app/core/network/api_client.dart';
import 'package:founta_app/core/network/health.dart';

import '../../support/http_stub_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('checkBackendUp', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      onUnauthorized = null;
      onEmailNotVerified = null;
    });

    test('returns true when backend responds successfully', () async {
      final adapter = StubHttpClientAdapter({
        '*': [const StubResponse(statusCode: 200, body: {'ok': true})],
      });
      apiClient.httpClientAdapter = adapter;

      final up = await checkBackendUp();

      expect(up, isTrue);
      expect(adapter.requests.single.uri.path, '/up');
    });

    test('returns false when backend returns an error response', () async {
      final adapter = StubHttpClientAdapter({
        '*': [const StubResponse(statusCode: 500, body: {'message': 'error'})],
      });
      apiClient.httpClientAdapter = adapter;

      final up = await checkBackendUp();

      expect(up, isFalse);
    });
  });
}
