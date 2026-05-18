import 'package:flutter/material.dart';

import 'package:flutter_app/theme/app_theme_extension.dart';

/// Default seed color for Material 3 palette. Change for branding/tenant themes.
const Color _seedColor = Color(0xFF2196F3);

/// App theme: light and dark [ThemeData] with [AppThemeExtension].
/// For white-label/tenant themes, build [ThemeData] with a different seed
/// and optionally a custom [AppThemeExtension].
abstract final class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [AppThemeExtension.light(colorScheme)],
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [AppThemeExtension.dark(colorScheme)],
    );
  }
}
