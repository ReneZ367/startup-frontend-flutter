import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/navigation/app_shell.dart';
import '../../config/navigation/app_navigation_config.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

GoRouter createAppRouter() {
  return GoRouter(
    routes: [
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
        ],
      ),
    ],
  );
}
