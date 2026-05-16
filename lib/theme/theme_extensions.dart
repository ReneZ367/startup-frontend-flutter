import 'package:flutter/material.dart';

import 'package:flutter_app/theme/app_theme_extension.dart';

/// Convenience getters for app theme from [BuildContext].
/// Use in widgets: `context.appTheme`, `context.appSpacing`.
extension ThemeContext on BuildContext {
  /// App theme extension. Null if theme was not built with [AppThemeExtension].
  AppThemeExtension? get appTheme => Theme.of(this).extension<AppThemeExtension>();

  /// App spacing tokens. Never null; falls back to [AppSpacing.standard].
  AppSpacing get appSpacing => appTheme?.spacing ?? AppSpacing.standard;
}
