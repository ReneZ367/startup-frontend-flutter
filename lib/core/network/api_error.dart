import 'package:dio/dio.dart';

/// Parses API validation error from [DioException].
///
/// Expects Laravel-style response:
/// ```json
/// {
///   "message": "The given data was invalid.",
///   "errors": { "field": ["Error message."] }
/// }
/// ```
///
/// Returns the first error message from [errors], else [message], else a generic
/// string using [fallbackPrefix] (e.g. "Login failed", "Registration failed").
String parseApiError(Object e, {String fallbackPrefix = 'Failed'}) {
  if (e is! DioException) return e.toString();
  final data = e.response?.data;
  if (data is! Map<String, dynamic>) {
    return '$fallbackPrefix: ${e.response?.statusCode ?? e.type}';
  }
  final errors = data['errors'];
  if (errors is Map<String, dynamic>) {
    for (final fieldErrors in errors.values) {
      if (fieldErrors is List && fieldErrors.isNotEmpty) {
        final msg = fieldErrors.first;
        if (msg is String) return msg;
      }
    }
  }
  final message = data['message'];
  if (message is String) return message;
  return '$fallbackPrefix: ${e.response?.statusCode ?? e.type}';
}
