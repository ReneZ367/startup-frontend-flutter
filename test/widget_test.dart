import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/app.dart';
import 'package:flutter_app/core/auth/auth_service.dart';

void main() {
  testWidgets('App loads and shows shell with Home', (WidgetTester tester) async {
    authService.isLoggedIn.value = true;
    authService.isEmailVerified.value = true;
    addTearDown(() {
      authService.isLoggedIn.value = false;
      authService.isEmailVerified.value = true;
    });

    await tester.pumpWidget(const FlutterApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
  });
}
