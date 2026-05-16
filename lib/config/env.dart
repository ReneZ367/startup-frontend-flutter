/// Environment and build-time configuration.
///
/// Values come from [--dart-define](https://dart.dev/tools/dart-compile#dart-define)
/// so dev/staging/prod can be switched without code changes.
///
/// Example:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.example.com/v1/ --dart-define=WEB_APP_URL=https://app.example.com/
/// flutter build apk --dart-define=API_BASE_URL=... --dart-define=WEB_APP_URL=...
/// ```
abstract final class Env {
  Env._();

  /// API base URL (with trailing slash). Dio appends paths to this.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://flutter.ddev.site/api/v1/',
  );

  /// Base URL of the web app (trailing slash). Used for privacy policy, terms, etc.
  static const String webAppUrl = String.fromEnvironment(
    'WEB_APP_URL',
    defaultValue: 'https://flutter.ddev.site/',
  );
}
