// core/app_config/navigation/app_navigator.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../domain/nav_item.dart';
import '../domain/nav_type.dart';

/// Signature for a custom navigation handler.
/// Receives the full [NavItem] so handlers have access to config, links, etc.
typedef CustomNavHandler =
    Future<void> Function(
      BuildContext context,
      NavItem item,
    );

/// Central navigation executor for [NavItem].
///
/// GoRouter is used directly for route and webpage navigation.
/// Custom handlers are injected from outside core/ — keeping the module
/// decoupled from app-specific navigation logic (e.g. opening Intercom,
/// launching a camera, triggering a native flow).
///
/// ## Setup
///
/// Register custom handlers once after login — typically in AuthBuilder
/// alongside NotificationRouter.configure():
///
/// ```dart
/// AppNavigator.registerCustomHandler(
///   'intercom',
///   (context, item) async => IntercomHandler().openMessenger(),
/// );
///
/// AppNavigator.registerCustomHandler(
///   'kiosk',
///   (context, item) async => context.push('/kiosk', extra: item.config),
/// );
/// ```
///
/// ## Navigation
///
/// Never call GoRouter directly from a [NavItem]. Always use:
///
/// ```dart
/// await item.navigate(context)
/// // or
/// await AppNavigator.navigate(context, item, forRoot: false)
/// ```
class AppNavigator {
  AppNavigator._();

  static final _customHandlers = <String, CustomNavHandler>{};

  /// Register a handler for a custom route key.
  /// Called from outside core/ — e.g. in AuthBuilder after Authenticated.
  static void registerCustomHandler(String routeKey, CustomNavHandler handler) {
    _customHandlers[routeKey] = handler;
  }

  /// Clear all registered handlers — called on logout.
  static void clearHandlers() => _customHandlers.clear();

  /// Execute navigation for [item].
  static Future<void> navigate(
    BuildContext context,
    NavItem item, {
    bool forRoot = true,
  }) => switch (item.type) {
    NavType.route => _navigateRoute(context, item, forRoot),
    NavType.webpage => _navigateWebpage(context, item),
    NavType.custom => _navigateCustom(context, item),
  };

  // ─── Route ────────────────────────────────────────────────────────────────

  static Future<void> _navigateRoute(
    BuildContext context,
    NavItem item,
    bool forRoot,
  ) async {
    final path = '/${item.route}/';
    final extra = _NavArgs(config: item.config, links: item.links);

    if (forRoot) {
      await context.push(path, extra: extra);
    } else {
      context.go(path, extra: extra);
    }
  }

  // ─── Webpage ──────────────────────────────────────────────────────────────

  /// Pushes a WebView page. The receiving route reads [_NavArgs] from
  /// GoRouter's extra and renders accordingly.
  ///
  /// Register your WebView route in your app's router:
  /// ```dart
  /// GoRoute(
  ///   path: '/webview',
  ///   builder: (_, state) {
  ///     final args = state.extra as _NavArgs;
  ///     return AppWebView(url: item.route, config: args.config);
  ///   },
  /// )
  /// ```
  static Future<void> _navigateWebpage(
    BuildContext context,
    NavItem item,
  ) async {
    await context.push(
      '/webview',
      extra: _NavArgs(
        config: {
          ...item.config,
          'url': item.route,
          'title': item.label,
        },
        links: item.links,
      ),
    );
  }

  // ─── Custom ───────────────────────────────────────────────────────────────

  static Future<void> _navigateCustom(
    BuildContext context,
    NavItem item,
  ) async {
    final handler = _customHandlers[item.route];

    assert(
      handler != null,
      'No custom handler registered for route "${item.route}". '
      'Call AppNavigator.registerCustomHandler("${item.route}", handler) '
      'in AuthBuilder after Authenticated.',
    );

    await handler?.call(context, item);
  }
}

/// Arguments passed to every GoRouter destination via [GoRouterState.extra].
class NavArgs {
  final Map<String, dynamic> config;
  final List<NavItem> links;

  const NavArgs({
    this.config = const {},
    this.links = const [],
  });
}

// Internal alias — exported as NavArgs for use in screens
typedef _NavArgs = NavArgs;
