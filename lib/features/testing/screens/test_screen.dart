import 'dart:async';

import 'package:flutter/material.dart';

import 'package:founta_app/core/network/api_error.dart';
import 'package:founta_app/core/network/health.dart';
import 'package:founta_app/features/testing/api/test_api.dart';
import 'package:founta_app/theme/app_theme_extension.dart';
import 'package:founta_app/theme/theme_extensions.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  dynamic _data;
  String? _error;
  bool _loading = false;
  bool? _backendUp;
  bool _backendChecking = false;
  Timer? _pollTimer;

  static const _pollInterval = Duration(seconds: 3);

  /// Border radius matching the app's card/container style (Material 3 default).
  static const _borderRadius = BorderRadius.all(Radius.circular(12));

  @override
  void initState() {
    super.initState();
    _checkBackend();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkBackend());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBackend() async {
    if (_backendChecking) return;
    setState(() => _backendChecking = true);
    final up = await checkBackendUp();
    if (!mounted) return;
    setState(() {
      _backendUp = up;
      _backendChecking = false;
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final data = await TestApi().getData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = parseApiError(e, fallbackPrefix: 'Request failed');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colorScheme = Theme.of(context).colorScheme;

    final cardShape = Theme.of(context).cardTheme.shape;
    final borderRadius = cardShape is RoundedRectangleBorder
        ? cardShape.borderRadius
        : _borderRadius;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: spacing.sm, horizontal: spacing.md),
              decoration: BoxDecoration(
                color: _backendUp == null
                    ? colorScheme.surfaceContainerHighest
                    : _backendUp!
                        ? Theme.of(context).extension<AppThemeExtension>()?.success.withOpacity(0.25) ?? colorScheme.primaryContainer
                        : colorScheme.errorContainer,
                borderRadius: borderRadius,
              ),
              child: Text(
                _backendUp == null
                    ? 'Checking...'
                    : _backendUp!
                        ? 'Backend up'
                        : 'Backend down',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _backendUp == null
                          ? colorScheme.onSurfaceVariant
                          : _backendUp!
                              ? Theme.of(context).extension<AppThemeExtension>()?.success ?? colorScheme.onPrimaryContainer
                              : colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: spacing.lg),
            FilledButton(
              onPressed: _loading ? null : _fetchData,
              child: Text(_loading ? 'Loading...' : 'Fetch data'),
            ),
            SizedBox(height: spacing.md),
            _UserDataCard(
              data: _data is Map<String, dynamic> ? _data as Map<String, dynamic> : null,
              loading: _loading,
            ),
            if (_error != null) ...[
              SizedBox(height: spacing.md),
              Text(
                'Error: $_error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }
}

const _displayFields = ['id', 'name', 'email', 'role'];

class _UserDataCard extends StatelessWidget {
  const _UserDataCard({this.data, this.loading = false});

  final Map<String, dynamic>? data;
  final bool loading;

  String _label(String key) {
    switch (key) {
      case 'id':
        return 'ID';
      case 'name':
        return 'Name';
      case 'email':
        return 'Email';
      case 'role':
        return 'Role';
      default:
        return key;
    }
  }

  String _value(String key) {
    if (loading) return '…';
    final v = data?[key];
    return v?.toString() ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _displayFields.length; i++) ...[
              Text(
                _label(_displayFields[i]),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: spacing.xs),
              SelectableText(
                _value(_displayFields[i]),
                style: theme.textTheme.bodyLarge,
              ),
              if (i < _displayFields.length - 1) SizedBox(height: spacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
