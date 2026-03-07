import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/navigation/app_navigation_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../theme/theme_extensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: spacing.lg),
            Text(
              'App preferences and configuration.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: spacing.lg),
            FilledButton.tonal(
              onPressed: () async {
                await authService.logout();
                if (!context.mounted) return;
                context.go(AppRoutes.login);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
