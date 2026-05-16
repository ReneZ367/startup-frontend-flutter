import 'package:flutter_app/config/env.dart';

/// Application constants.
abstract final class Constants {
  Constants._();

  /// API base URL. Sourced from [Env.apiBaseUrl] (--dart-define=API_BASE_URL=...).
  static const String baseUrl = Env.apiBaseUrl;

  /// Base URL of the web app. Sourced from [Env.webAppUrl] (--dart-define=WEB_APP_URL=...).
  static const String webAppUrl = Env.webAppUrl;

  static const String privacyPolicyUrl = '${webAppUrl}privacy-policy';
  static const String impressumUrl = '${webAppUrl}terms-of-service';
}
