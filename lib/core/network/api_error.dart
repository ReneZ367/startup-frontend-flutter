import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:flutter_app/enums/api_error_code_enum.dart';

final Map<String, ApiErrorCodeEnum> _apiErrorCodeByWireValue = {
  for (final v in ApiErrorCodeEnum.values) v.value: v,
};

/// Parses machine-readable `code` / `error_code` / `error` from a JSON body
/// (same top-level shape as [parseApiError]: `message`, `errors`, …).
String? _readApiMachineCode(dynamic data) {
  var d = data;
  if (d is String) {
    try {
      d = jsonDecode(d);
    } catch (_) {
      return null;
    }
  }
  if (d is! Map) return null;
  final map = Map<String, dynamic>.from(d);
  for (final key in const ['code', 'error_code', 'error']) {
    final v = map[key];
    if (v is String && v.isNotEmpty) return v.trim();
  }
  return null;
}

/// JSON body (map or JSON string) mapped to a known [ApiErrorCodeEnum], or null if missing or unknown.
ApiErrorCodeEnum? parseKnownApiErrorCode(dynamic data) {
  final raw = _readApiMachineCode(data);
  if (raw == null || raw.isEmpty) return null;
  return _apiErrorCodeByWireValue[raw];
}

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
