import 'package:flutter_app/constants.dart';
import 'package:flutter_app/core/network/api_client.dart';

/// URL for the backend health check (Laravel /up at app root).
/// Uses the same host and scheme as [Constants.baseUrl] so it works in ddev (http) and prod.
String get _upUrl =>
    Uri.parse(Constants.baseUrl).replace(path: '/up').toString();

/// Calls the backend /up route. Returns true if the server responds successfully, false on error or timeout.
/// Call from anywhere (e.g. splash, settings, retry logic). No auth required.
Future<bool> checkBackendUp() async {
  try {
    await apiClient.get(_upUrl);
    return true;
  } catch (_) {
    return false;
  }
}
