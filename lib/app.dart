import 'package:flutter/material.dart';

import 'package:flutter_app/config/router/app_router.dart';
import 'package:flutter_app/theme/app_theme.dart';

class FutterApp extends StatelessWidget {
  const FutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter();

    return MaterialApp.router(
      title: 'Futter App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
