import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/config/navigation/app_navigation_config.dart';
import 'package:flutter_app/core/auth/auth_service.dart';
import 'package:flutter_app/core/network/api_error.dart';
import 'package:flutter_app/theme/app_theme_extension.dart';
import 'package:flutter_app/theme/theme_extensions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController(text: 'editor@example.com');
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String) return msg;
    }
    return data?.toString() ?? 'Request sent.';
  }

  Future<void> _sendResetLink() async {
    setState(() {
      _error = null;
      _successMessage = null;
      _isLoading = true;
    });
    try {
      final data = await authService.forgotPassword(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _successMessage = _extractMessage(data));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = parseApiError(e));
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
                        onChanged: (_) {
                          if (_error != null || _successMessage != null) {
                            setState(() {
                              _error = null;
                              _successMessage = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                          errorText: _error,
                        ),
                      ),
                      if (_successMessage != null) ...[
                        SizedBox(height: spacing.md),
                        Container(
                          padding: EdgeInsets.all(spacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                    .extension<AppThemeExtension>()
                                    ?.success
                                    .withOpacity(0.25) ??
                                colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _successMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                      .extension<AppThemeExtension>()
                                      ?.success ??
                                  colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
