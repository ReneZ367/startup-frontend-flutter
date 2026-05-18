import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/config/navigation/app_navigation_config.dart';
import 'package:flutter_app/theme/theme_extensions.dart';

/// App shell: shared layout (AppBar + drawer or bottom nav) around route content.
/// Navigation style is controlled by [AppNavigationConfig.navigationType].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    switch (AppNavigationConfig.navigationType) {
      case AppNavigationType.drawer:
        return _ScaffoldWithDrawer(child: child);
      case AppNavigationType.bottom:
        return _ScaffoldWithBottomNav(child: child);
    }
  }
}

class _ScaffoldWithDrawer extends StatelessWidget {
  const _ScaffoldWithDrawer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final title = _titleForPath(location);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: _NavDrawer(currentPath: location),
      body: child,
    );
  }
}

class _ScaffoldWithBottomNav extends StatelessWidget {
  const _ScaffoldWithBottomNav({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexForPath(location);
    final items = AppNavigationConfig.navItems;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex.clamp(0, items.length - 1),
        onDestinationSelected: (index) {
          context.go(items[index].path);
        },
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavDrawer extends StatelessWidget {
  const _NavDrawer({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final drawerColor =
        context.appTheme?.drawerHeader ?? Theme.of(context).colorScheme.primary;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: drawerColor),
            child: const Text(
              'Flutter',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ...AppNavigationConfig.navItems.map((item) {
            final selected = _pathsMatch(currentPath, item.path);
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: selected,
              onTap: () {
                context.go(item.path);
                if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

String _titleForPath(String path) {
  for (final item in AppNavigationConfig.navItems) {
    if (_pathsMatch(path, item.path)) return item.label;
  }
  return 'Flutter';
}

int _indexForPath(String path) {
  final i = AppNavigationConfig.navItems.indexWhere(
    (item) => _pathsMatch(path, item.path),
  );
  return i >= 0 ? i : 0;
}

bool _pathsMatch(String a, String b) {
  final an = a == '/' ? '/' : a.replaceFirst(RegExp(r'/+$'), '');
  final bn = b == '/' ? '/' : b.replaceFirst(RegExp(r'/+$'), '');
  return an == bn;
}
