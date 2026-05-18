import 'package:flutter/material.dart';

import 'package:flutter_app/app.dart';
import 'package:flutter_app/core/auth/auth_service.dart';
import 'package:flutter_app/core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authService.init();
  onUnauthorized = () => authService.logout();
  onEmailNotVerified = (uri) {
    debugPrint('[ApiClient] 403 EMAIL_NOT_VERIFIED $uri');
    authService.notifyEmailNotVerified();
  };
  runApp(const FlutterApp());
}
