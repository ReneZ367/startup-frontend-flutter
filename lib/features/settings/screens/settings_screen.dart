import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_app/config/navigation/app_navigation_config.dart';
import 'package:flutter_app/constants.dart';
import 'package:flutter_app/core/auth/auth_service.dart';
import 'package:flutter_app/features/settings/api/delete_account_api.dart';
import 'package:flutter_app/theme/theme_extensions.dart';

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Ignore: can fail in simulator or when no browser (e.g. channel-error on iOS)
  }
}

Future<void> _confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete account'),
      content: const Text(
        'This will permanently delete your account and all data. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (!context.mounted || confirmed != true) return;
  try {
    await DeleteAccountApi().deleteAccount();
    await authService.logout();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete account. Please try again.')),
    );
  }
}

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
            SizedBox(height: spacing.md),
            OutlinedButton(
              onPressed: () => _confirmDeleteAccount(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
              ),
              child: const Text('Delete account'),
            ),
            SizedBox(height: spacing.lg),
            OutlinedButton.icon(
              onPressed: () => _openUrl(Constants.privacyPolicyUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Privacy policy'),
            ),
            SizedBox(height: spacing.sm),
            OutlinedButton.icon(
              onPressed: () => _openUrl(Constants.impressumUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Impressum'),
            ),
          ],
        ),
      ),
    );
  }
}
