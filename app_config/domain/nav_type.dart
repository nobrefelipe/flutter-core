// core/app_config/domain/nav_type.dart

enum NavType {
  /// Standard GoRouter push — route string is the path
  route,

  /// Opens a URL in an in-app WebView
  webpage,

  /// Handled by a custom injected handler — see AppNavigator.registerCustomHandler()
  custom,
}
