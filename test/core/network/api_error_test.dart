import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/core/network/api_error.dart';
import 'package:flutter_app/enums/api_error_code_enum.dart';

void main() {
  group('parseKnownApiErrorCode', () {
    test('maps known code from map payload', () {
      final code = parseKnownApiErrorCode({
        'code': 'EMAIL_NOT_VERIFIED',
      });

      expect(code, ApiErrorCodeEnum.emailNotVerified);
    });

    test('maps known code from JSON string payload', () {
      final code = parseKnownApiErrorCode(
        '{"error_code":"UNAUTHORIZED"}',
      );

      expect(code, ApiErrorCodeEnum.unauthorized);
    });

    test('returns null for unknown code', () {
      final code = parseKnownApiErrorCode({'code': 'SOMETHING_ELSE'});
      expect(code, isNull);
    });

    test('reads code from error key', () {
      final code = parseKnownApiErrorCode({'error': 'EMAIL_NOT_VERIFIED'});
      expect(code, ApiErrorCodeEnum.emailNotVerified);
    });

    test('returns null for malformed JSON string payload', () {
      final code = parseKnownApiErrorCode('{"code":"EMAIL_NOT_VERIFIED"');
      expect(code, isNull);
    });
  });

  group('parseApiError', () {
    test('returns first field validation message when present', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: 'register'),
        response: Response(
          requestOptions: RequestOptions(path: 'register'),
          statusCode: 422,
          data: {
            'message': 'The given data was invalid.',
            'errors': {
              'email': ['The email has already been taken.'],
            },
          },
        ),
      );

      final message = parseApiError(exception, fallbackPrefix: 'Registration failed');
      expect(message, 'The email has already been taken.');
    });

    test('falls back to top-level message when no errors object exists', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: 'login'),
        response: Response(
          requestOptions: RequestOptions(path: 'login'),
          statusCode: 401,
          data: {
            'message': 'Invalid credentials.',
          },
        ),
      );

      final message = parseApiError(exception, fallbackPrefix: 'Login failed');
      expect(message, 'Invalid credentials.');
    });

    test('uses fallback prefix with status when body is not a map', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: 'login'),
        response: Response(
          requestOptions: RequestOptions(path: 'login'),
          statusCode: 500,
          data: 'Server exploded',
        ),
      );

      final message = parseApiError(exception, fallbackPrefix: 'Login failed');
      expect(message, 'Login failed: 500');
    });

    test('returns non-Dio error as string', () {
      final message = parseApiError(StateError('Something broke'));
      expect(message, 'Bad state: Something broke');
    });

    test('falls back to top-level message when validation list first item is not string', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: 'register'),
        response: Response(
          requestOptions: RequestOptions(path: 'register'),
          statusCode: 422,
          data: {
            'message': 'The provided payload is invalid.',
            'errors': {
              'email': [12345],
            },
          },
        ),
      );

      final message = parseApiError(exception, fallbackPrefix: 'Registration failed');
      expect(message, 'The provided payload is invalid.');
    });

    test('uses exception type in fallback when status is missing', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: 'register'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = parseApiError(exception, fallbackPrefix: 'Registration failed');
      expect(message, 'Registration failed: DioExceptionType.connectionTimeout');
    });
  });
}
