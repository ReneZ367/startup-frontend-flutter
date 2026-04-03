import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:founta_app/components/navigation/app_shell.dart';
import 'package:founta_app/config/navigation/app_navigation_config.dart';
import 'package:founta_app/core/auth/auth_service.dart';
import 'package:founta_app/features/auth/screens/forgot_password_screen.dart';
import 'package:founta_app/features/auth/screens/login_screen.dart';
import 'package:founta_app/features/auth/screens/register_screen.dart';
import 'package:founta_app/features/auth/screens/verify_email_screen.dart';
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

/// Logged-out users only see public routes. Logged-in unverified users only see verify-email.
String? _redirectForAuth(BuildContext _, GoRouterState state) {
  final isLoggedIn = authService.isLoggedIn.value;
  final location = state.matchedLocation;

  if (!isLoggedIn) {
    return _publicPaths.contains(location) ? null : AppRoutes.login;
  }

  final needsVerification = !authService.isEmailVerified.value;
  if (needsVerification) {
    return location == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
  }

  if (location == AppRoutes.verifyEmail || _publicPaths.contains(location)) {
    return _defaultAuthPath;
  }
  return null;
}

GoRouter createAppRouter() {
  return GoRouter(
    refreshListenable: Listenable.merge([
      authService.isLoggedIn,
      authService.isEmailVerified,
    ]),
    redirect: _redirectForAuth,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => const MaterialPage(child: LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => const MaterialPage(child: RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) =>
            const MaterialPage(child: ForgotPasswordScreen()),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: 'verifyEmail',
        pageBuilder: (context, state) =>
            const MaterialPage(child: VerifyEmailScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) =>
                const MaterialPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) =>
                const MaterialPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: AppRoutes.test,
            name: 'test',
            pageBuilder: (context, state) =>
                const MaterialPage(child: TestScreen()),
          ),
        ],
      ),
    ],
  );
}
