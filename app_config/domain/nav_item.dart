import 'package:flutter/material.dart';

import '../../helpers.dart';
import '../navigation/app_navigator.dart';
import 'nav_type.dart';

/// A single navigation destination derived from the backend config.
///
/// Can represent a bottom nav tab, a menu link, or a nested sub-link.
/// Knows how to navigate itself via [navigate()] — callers never
/// need to switch on [type] manually.
class NavItem {
  /// The raw route string or URL depending on [type].
  final String route;

  /// Display label shown in nav bars and menus.
  final String label;

  /// Icon identifier string — resolved to an [IconData] by the UI layer.
  final String? icon;

  /// Optional description shown in menu items.
  final String? description;

  /// How this item navigates.
  final NavType type;

  /// Raw config map — passed through to the destination screen as arguments.
  final Map<String, dynamic> config;

  /// Nested links — used for menu sections and link groups.
  final List<NavItem> links;

  const NavItem({
    required this.route,
    required this.label,
    required this.type,
    required this.config,
    this.icon,
    this.description,
    this.links = const [],
  });

  /// Navigate to this item.
  ///
  /// [forRoot] controls whether the push sits above or inside the
  /// bottom navigation shell — pass false when navigating between tabs.
  Future<void> navigate(BuildContext context, {bool forRoot = true}) => AppNavigator.navigate(context, this, forRoot: forRoot);

  factory NavItem.fromJson(dynamic json) {
    final config = Helper.getMap(json['config']);
    final url = Helper.getStringOrNull(config['url']);
    final route = url ?? Helper.getString(json['route']);
    final typeStr = Helper.getString(json['type']);

    final type = switch (typeStr) {
      'webpage' => NavType.webpage,
      _ => NavType.route,
    };

    return NavItem(
      route: route,
      label: Helper.getString(config['title']),
      icon: Helper.getStringOrNull(config['icon']),
      description: Helper.getStringOrNull(config['description']),
      type: type,
      config: config,
      links: fromJsonList(config['links']),
    );
  }

  static List<NavItem> fromJsonList(dynamic json) {
    if (json == null || json is! List) return [];
    return json.map<NavItem>((item) => NavItem.fromJson(item)).toList();
  }

  @override
  String toString() => 'NavItem(route: $route, type: $type, label: $label, links: ${links.length})';
}
