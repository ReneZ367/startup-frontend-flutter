import 'package:founta_app/core/network/api_client.dart';

/// GET [endpoint]. Optional [params] as query parameters.
Future<dynamic> apiGet(String endpoint, {Map<String, dynamic>? params}) async {
  final response = await apiClient.get(endpoint, queryParameters: params);
  return response.data;
}

/// POST [endpoint] with JSON [data].
Future<dynamic> apiPost(String endpoint, dynamic data) async {
  final response = await apiClient.post(endpoint, data: data);
  return response.data;
}

/// PUT [endpoint] with JSON [data].
Future<dynamic> apiPut(String endpoint, dynamic data) async {
  final response = await apiClient.put(endpoint, data: data);
  return response.data;
}

/// DELETE [endpoint].
Future<dynamic> apiDelete(String endpoint) async {
  final response = await apiClient.delete(endpoint);
  return response.data;
}

/// PATCH [endpoint] with JSON [data].
Future<dynamic> apiPatch(String endpoint, dynamic data) async {
  final response = await apiClient.patch(endpoint, data: data);
  return response.data;
}
