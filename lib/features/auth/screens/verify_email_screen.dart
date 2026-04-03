import 'package:flutter/material.dart';

import 'package:founta_app/core/auth/auth_service.dart';
import 'package:founta_app/core/network/api_error.dart';
import 'package:founta_app/theme/theme_extensions.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _resendLoading = false;
  bool _checkLoading = false;
  String? _error;
  String? _checkError;
  String? _successMessage;
  String? _stillUnverifiedHint;

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String) return msg;
    }
    return data?.toString() ?? 'Verification link sent.';
  }

  Future<void> _resendEmail() async {
    setState(() {
      _error = null;
      _successMessage = null;
      _stillUnverifiedHint = null;
      _resendLoading = true;
    });
    try {
      final data = await authService.resendVerificationEmail();
      if (!mounted) return;
      setState(() => _successMessage = _extractMessage(data));
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _error = parseApiError(e, fallbackPrefix: 'Could not resend email'),
      );
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  Widget _buttonProgressOrLabel({
    required bool loading,
    required String label,
    required Color progressColor,
  }) {
    if (loading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: progressColor,
        ),
      );
    }
    return Text(label);
  }

  Future<void> _checkVerification() async {
    setState(() {
      _checkError = null;
      _stillUnverifiedHint = null;
      _checkLoading = true;
    });
    try {
      final verified = await authService.checkEmailVerificationNow();
      if (!mounted) return;
      if (!verified) {
        setState(
          () => _stillUnverifiedHint =
              'Your email is not verified yet. Open the link we sent, then try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _checkError = parseApiError(
          e,
          fallbackPrefix: 'Could not check verification',
        ),
      );
    } finally {
      if (mounted) setState(() => _checkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final spacing = context.appSpacing;
    final appTheme = context.appTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing.sm),
              Center(
                child: Container(
                  padding: EdgeInsets.all(spacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: spacing.xl),
              Text(
                'Verify your email',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                'We sent a link to your inbox. Open it to confirm your address, then continue below.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              SizedBox(height: spacing.lg),
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        _MessageBanner(
                          text: _error!,
                          color: colorScheme.error,
                          background: colorScheme.errorContainer
                              .withValues(alpha: 0.35),
                        ),
                        SizedBox(height: spacing.md),
                      ],
                      if (_checkError != null) ...[
                        _MessageBanner(
                          text: _checkError!,
                          color: colorScheme.error,
                          background: colorScheme.errorContainer
                              .withValues(alpha: 0.35),
                        ),
                        SizedBox(height: spacing.md),
                      ],
                      if (_stillUnverifiedHint != null) ...[
                        _MessageBanner(
                          text: _stillUnverifiedHint!,
                          color: colorScheme.onSurfaceVariant,
                          background: colorScheme.surfaceContainerHigh,
                        ),
                        SizedBox(height: spacing.md),
                      ],
                      if (_successMessage != null) ...[
                        _MessageBanner(
                          text: _successMessage!,
                          color: appTheme?.success ?? colorScheme.primary,
                          background: (appTheme?.success ?? colorScheme.primary)
                              .withValues(alpha: 0.12),
                        ),
                        SizedBox(height: spacing.md),
                      ],
                      OutlinedButton(
                        onPressed: (_resendLoading || _checkLoading)
                            ? null
                            : _resendEmail,
                        child: _buttonProgressOrLabel(
                          loading: _resendLoading,
                          label: 'Resend email',
                          progressColor: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      FilledButton(
                        onPressed: (_resendLoading || _checkLoading)
                            ? null
                            : _checkVerification,
                        child: _buttonProgressOrLabel(
                          loading: _checkLoading,
                          label: 'I have verified my email',
                          progressColor: colorScheme.onPrimary,
                        ),
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

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            color: color,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
