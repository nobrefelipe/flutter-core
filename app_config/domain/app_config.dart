// core/app_config/domain/app_config.dart

import 'global_settings.dart';
import 'nav_item.dart';

/// The full configuration for this user session.
/// Drives the entire navigation structure of the app.
///
/// Fetched once on login, reset to [AsyncAtom] Idle on logout.
/// Never mutated after construction — immutable by design.
class AppConfig {
  /// Feature flags for infrastructure services.
  final GlobalSettings settings;

  /// Top-level navigation items — rendered as bottom nav tabs or a drawer.
  /// Order matches the backend response.
  final List<NavItem> navigation;

  const AppConfig({
    required this.settings,
    required this.navigation,
  });

  /// Convenience — the first navigation item.
  /// Used to redirect after login or permission check.
  NavItem get firstPage => navigation.first;

  /// Find a top-level nav item by route.
  NavItem? findByRoute(String route) {
    try {
      return navigation.firstWhere((item) => item.route == route);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'AppConfig(settings: $settings, navigation: ${navigation.length} items)';
}
