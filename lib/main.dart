import 'package:flutter/material.dart';

import 'app.dart';
import 'core/auth/auth_service.dart';
import 'core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await authService.init();
  onUnauthorized = () => authService.logout();
  runApp(const FountaApp());
}
