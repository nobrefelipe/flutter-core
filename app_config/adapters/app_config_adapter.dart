// core/app_config/adapters/app_config_adapter.dart

import '../../helpers.dart';
import '../domain/app_config.dart';
import '../domain/global_settings.dart';
import '../domain/nav_item.dart';
import '../domain/nav_type.dart';

// ─── GlobalSettings ───────────────────────────────────────────────────────────

class GlobalSettingsAdapter {
  static GlobalSettings fromJson(dynamic json) => GlobalSettings(
    enablePushNotifications: Helper.getBool(json['enablePushNotifications']),
    enableIntercom: Helper.getBool(json['enableIntercom']),
    enableLocationTracking: Helper.getBool(json['enableLocationTracking']),
    enableNotificationsCentre: Helper.getBool(json['enable_notification_centre']),
  );
}

// ─── NavItem ──────────────────────────────────────────────────────────────────

class NavItemAdapter {
  static NavItem fromJson(dynamic json) {
    final config = Helper.getMap(json['config']);
    return NavItem(
      route: _resolveRoute(json),
      label: Helper.getString(config['title']),
      icon: Helper.getStringOrNull(config['icon']),
      description: Helper.getStringOrNull(config['description']),
      type: _resolveType(json),
      config: config,
      links: fromJsonToList(config['links']),
    );
  }

  static List<NavItem> fromJsonToList(dynamic json) {
    if (json == null || json is! List) return [];
    return json.map<NavItem>(fromJson).toList();
  }

  /// If the config has a URL, this is a webpage nav item.
  /// Otherwise use the route string directly.
  static String _resolveRoute(dynamic json) {
    final url = Helper.getStringOrNull(json['config']?['url']);
    return url ?? Helper.getString(json['route']);
  }

  /// Backend explicitly sends "type": "route" | "webpage" | "custom".
  /// No hardcoded route lists needed — the backend owns this decision.
  static NavType _resolveType(dynamic json) {
    final type = Helper.getString(json['type']);
    return switch (type) {
      'webpage' => NavType.webpage,
      'custom' => NavType.custom,
      _ => NavType.route, // "route" or missing — defaults to route
    };
  }
}

// ─── AppConfig ────────────────────────────────────────────────────────────────

class AppConfigAdapter {
  static AppConfig fromJson(dynamic json) => AppConfig(
    settings: GlobalSettingsAdapter.fromJson(json),
    navigation: NavItemAdapter.fromJsonToList(json['pages']),
  );
}
