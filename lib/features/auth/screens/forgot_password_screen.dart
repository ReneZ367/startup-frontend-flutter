import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:founta_app/config/navigation/app_navigation_config.dart';
import 'package:founta_app/core/auth/auth_service.dart';
import 'package:founta_app/theme/theme_extensions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController(text: 'editor@example.com');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    setState(() => _isLoading = true);
    try {
      await authService.forgotPassword(email: _emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to email')),
      );
      context.go(AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      final message = e is DioException
          ? (e.response?.data?.toString() ??
              '${e.response?.statusCode ?? e.type}')
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $message')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final spacing = context.appSpacing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
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
                      Text(
                        'Enter your email address and we will send you a link to reset your password.',
                        style: textTheme.bodyMedium,
                      ),
                      SizedBox(height: spacing.md),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: spacing.lg),
                      FilledButton(
                        onPressed: _isLoading ? null : _sendResetLink,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Send Reset Link'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Back to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
