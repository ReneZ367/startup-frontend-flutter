import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:founta_app/components/navigation/app_shell.dart';
import 'package:founta_app/config/navigation/app_navigation_config.dart';
import 'package:founta_app/core/auth/auth_service.dart';
import 'package:founta_app/features/auth/screens/forgot_password_screen.dart';
import 'package:founta_app/features/auth/screens/login_screen.dart';
import 'package:founta_app/features/auth/screens/register_screen.dart';
import 'package:founta_app/features/home/screens/home_screen.dart';
import 'package:founta_app/features/settings/screens/settings_screen.dart';
import 'package:founta_app/features/testing/screens/test_screen.dart';

/// Paths that are allowed when the user is not logged in. All other paths require login.
const _publicPaths = [
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
];

/// Path to send logged-in users to when they hit a public-only path (e.g. login).
const _defaultAuthPath = AppRoutes.home;

GoRouter createAppRouter() {
  return GoRouter(
    refreshListenable: authService.isLoggedIn,
    redirect: (context, state) {
      final isLoggedIn = authService.isLoggedIn.value;
      final location = state.matchedLocation;
      // Not logged in: only allow public paths (e.g. login). Everything else -> login.
      if (!isLoggedIn && !_publicPaths.contains(location)) {
        return AppRoutes.login;
      }
      // Logged in and on a public-only path (e.g. login) -> send to app.
      if (isLoggedIn && _publicPaths.contains(location)) {
        return _defaultAuthPath;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (_, __) => const MaterialPage(child: LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (_, __) => const MaterialPage(child: RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (_, __) => const MaterialPage(child: ForgotPasswordScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (_, __) => const MaterialPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (_, __) => const MaterialPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: AppRoutes.test,
            name: 'test',
            pageBuilder: (_, __) => const MaterialPage(child: TestScreen()),
          ),
        ],
      ),
    ],
  );
}
