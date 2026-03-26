// core/app_config/navigation/app_navigator.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/nav_item.dart';
import '../domain/nav_type.dart';

/// Central navigation executor for [NavItem].
///
/// GoRouter is used directly for route and webpage navigation.
/// Config and links are passed via GoRouter's extra parameter.
///
/// ## Navigation
///
/// Never call GoRouter directly from a [NavItem]. Always use:
///
/// ```dart
/// await item.navigate(context)
/// await AppNavigator.navigate(context, item, forRoot: false)
/// ```
class AppNavigator {
  AppNavigator._();

  /// Execute navigation for [item].
  static Future<void> navigate(
    BuildContext context,
    NavItem item, {
    bool forRoot = true,
  }) => switch (item.type) {
    NavType.route => _navigateRoute(context, item, forRoot),
    NavType.webpage => _navigateWebpage(context, item),
  };

  // ─── Route ────────────────────────────────────────────────────────────────

  static Future<void> _navigateRoute(
    BuildContext context,
    NavItem item,
    bool forRoot,
  ) async {
    final path = '/${item.route}/';
    final extra = {'config': item.config, 'links': item.links};

    if (forRoot) {
      await context.push(path, extra: extra);
    } else {
      context.go(path, extra: extra);
    }
  }

  // ─── Webpage ──────────────────────────────────────────────────────────────

  /// Pushes a WebView page. The receiving route reads config and links from
  /// GoRouter's extra map.
  ///
  /// Register your WebView route in your app's router:
  /// ```dart
  /// GoRoute(
  ///   path: '/webview',
  ///   builder: (_, state) {
  ///     final extra = state.extra as Map<String, dynamic>;
  ///     final config = extra['config'] as Map<String, dynamic>;
  ///     return AppWebView(url: config['url'], title: config['title']);
  ///   },
  /// )
  /// ```
  static Future<void> _navigateWebpage(
    BuildContext context,
    NavItem item,
  ) async {
    await context.push(
      '/webview',
      extra: {
        'config': {
          ...item.config,
          'url': item.route,
          'title': item.label,
        },
        'links': item.links,
      },
    );
  }
}
