import 'package:flutter/material.dart';

/// Route path constants. Single source of truth for URLs.
abstract final class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
}

/// Defines how main navigation is rendered (drawer vs bottom bar).
/// Change this to switch layout without touching shell implementation.
enum AppNavigationType {
  drawer,
  bottom,
}

/// One entry in the app navigation (drawer or bottom bar).
class NavItem {
  const NavItem({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

/// Central navigation config for the app shell.
/// Add/remove items in [navItems]; set [navigationType] to drawer or bottom.
abstract final class AppNavigationConfig {
  static const AppNavigationType navigationType = AppNavigationType.drawer;

  static const List<NavItem> navItems = [
    NavItem(path: AppRoutes.home, label: 'Home', icon: Icons.home_outlined),
    NavItem(path: AppRoutes.settings, label: 'Settings', icon: Icons.settings_outlined),
  ];
}
