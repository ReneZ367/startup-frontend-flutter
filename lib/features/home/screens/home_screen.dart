import 'package:flutter/material.dart';

import 'package:flutter_app/theme/theme_extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.appSpacing.lg),
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: EdgeInsets.all(context.appSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.home_rounded,
                      size: 32,
                      color: context.appTheme?.primary ?? colorScheme.primary,
                    ),
                    SizedBox(width: context.appSpacing.sm),
                    Expanded(
                      child: Text(
                        'Welcome to Flutter',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
