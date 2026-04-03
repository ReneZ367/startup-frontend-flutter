import 'package:flutter/material.dart';

import 'package:founta_app/app.dart';
import 'package:founta_app/core/auth/auth_service.dart';
import 'package:founta_app/core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authService.init();
  onUnauthorized = () => authService.logout();
  onEmailNotVerified = (uri) {
    debugPrint('[ApiClient] 403 EMAIL_NOT_VERIFIED $uri');
    authService.notifyEmailNotVerified();
  };
  runApp(const FountaApp());
}
