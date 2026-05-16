import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_app/core/network/api.dart';
import 'package:flutter_app/core/network/api_client.dart';

import '../../support/http_stub_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('api helpers', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      onUnauthorized = null;
      onEmailNotVerified = null;
    });

    test('apiGet returns response data and forwards query params', () async {
      final adapter = StubHttpClientAdapter({
        'users': [const StubResponse(statusCode: 200, body: {'items': [1, 2, 3]})],
      });
      apiClient.httpClientAdapter = adapter;

      final data = await apiGet('users', params: {'page': 2});

      expect(data, {'items': [1, 2, 3]});
      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.queryParameters['page'], 2);
    });

    test('apiPost returns response data', () async {
      final adapter = StubHttpClientAdapter({
        'items': [const StubResponse(statusCode: 200, body: {'created': true})],
      });
      apiClient.httpClientAdapter = adapter;

      final data = await apiPost('items', {'name': 'item'});

      expect(data, {'created': true});
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, {'name': 'item'});
    });

    test('apiPut returns response data', () async {
      final adapter = StubHttpClientAdapter({
        'items/42': [const StubResponse(statusCode: 200, body: {'updated': true})],
      });
      apiClient.httpClientAdapter = adapter;

      final data = await apiPut('items/42', {'name': 'updated'});

      expect(data, {'updated': true});
      expect(adapter.requests.single.method, 'PUT');
    });

    test('apiPatch returns response data', () async {
      final adapter = StubHttpClientAdapter({
        'items/42': [const StubResponse(statusCode: 200, body: {'patched': true})],
      });
      apiClient.httpClientAdapter = adapter;

      final data = await apiPatch('items/42', {'name': 'patched'});

      expect(data, {'patched': true});
      expect(adapter.requests.single.method, 'PATCH');
    });

    test('apiDelete returns response data', () async {
      final adapter = StubHttpClientAdapter({
        'items/42': [const StubResponse(statusCode: 200, body: {'deleted': true})],
      });
      apiClient.httpClientAdapter = adapter;

      final data = await apiDelete('items/42');

      expect(data, {'deleted': true});
      expect(adapter.requests.single.method, 'DELETE');
    });
  });
}
