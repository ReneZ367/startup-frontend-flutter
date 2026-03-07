import 'package:flutter/material.dart';

import '../../../theme/theme_extensions.dart';
import '../api/test_api.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  dynamic _data;
  Object? _error;
  bool _loading = false;

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
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
