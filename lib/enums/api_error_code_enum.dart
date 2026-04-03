/// Mirrors [App\Enums\ApiErrorCodeEnum](PHP) — same wire values as the API.
/// Values without Dart handling yet are still parsed by [parseKnownApiErrorCode] for callers/tests.
enum ApiErrorCodeEnum {
  emailNotVerified('EMAIL_NOT_VERIFIED'),
  /// Parsed from JSON; add interceptor/UI handling when the app needs it.
  unauthorized('UNAUTHORIZED');

  const ApiErrorCodeEnum(this.value);

  /// String stored/sent by the backend (e.g. JSON `"code": "EMAIL_NOT_VERIFIED"`).
  final String value;
}
