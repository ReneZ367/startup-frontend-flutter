import '../../../core/network/api.dart';

class TestApi {
  /// Fetches data from the given endpoint. Uses the shared API client (auth token sent if present).
  Future<dynamic> getData() async {
    return apiGet('user');
  }
}
