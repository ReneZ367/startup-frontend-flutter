import 'package:flutter/material.dart';

import 'package:founta_app/config/router/app_router.dart';
import 'package:founta_app/theme/app_theme.dart';

class FountaApp extends StatelessWidget {
  const FountaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter();

    return MaterialApp.router(
      title: 'Founta App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
