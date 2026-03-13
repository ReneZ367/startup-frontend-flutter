import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:founta_app/config/navigation/app_navigation_config.dart';
import 'package:founta_app/core/auth/auth_service.dart';
import 'package:founta_app/core/network/api_error.dart';
import 'package:founta_app/theme/theme_extensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'editor@example.com');
  final _passwordController = TextEditingController(text: '11111111');
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final spacing = context.appSpacing;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.lg),
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: EdgeInsets.all(spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        onChanged: (_) {
                          if (_loginError != null) setState(() => _loginError = null);
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: spacing.md),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        autocorrect: false,
                        onChanged: (_) {
                          if (_loginError != null) setState(() => _loginError = null);
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (_loginError != null) ...[
                        SizedBox(height: spacing.sm),
                        Text(
                          _loginError!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                      SizedBox(height: spacing.lg),
                      FilledButton(
                        onPressed: () async {
                          setState(() => _loginError = null);
                          try {
                            await authService.login(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login OK')),
                            );
                            context.go(AppRoutes.home);
                          } catch (e) {
                            if (!context.mounted) return;
                            setState(() => _loginError = parseApiError(e, fallbackPrefix: 'Login failed'));
                          }
                        },
                        child: const Text('Sign in'),
                      ),
                      SizedBox(height: spacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            child: const Text('Forgot Password?'),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
