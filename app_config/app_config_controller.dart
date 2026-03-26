// core/app_config/app_config_controller.dart

import '../atomic_state/async_atom.dart';
import '../atomic_state/result.dart';
import 'app_config_service.dart';
import 'domain/app_config.dart';

/// Global atom — self-registers for resetAllAtoms() on logout.
/// Holds the full navigation and settings config for the current session.
///
/// Idle     → not yet fetched (before login)
/// Loading  → fetch in progress
/// Success  → config ready, app navigation is active
/// Failure  → fetch failed — app should show an error and offer retry
final appConfig = AsyncAtom<AppConfig>();

class AppConfigController {
  final _service = AppConfigService();

  /// Fetch config and emit the result.
  /// Call once after login — typically from AuthBuilder after Authenticated.
  ///
  /// On success the atom moves to Success(config) and the router
  /// can redirect to config.firstPage.route.
  ///
  /// On failure the atom moves to Failure(message) — the router
  /// should redirect to an error screen with a retry option.
  Future<void> load() async {
    appConfig.emit(const Loading());
    appConfig.emit(await _service.fetchConfig());
  }

  /// Convenience getter — null-safe access to the current config.
  /// Returns null if atom is not in Success state.
  AppConfig get current => switch (appConfig.value) {
    Success(:final value) => value,
    _ => AppConfig.empty(),
  };
}

final appConfigController = AppConfigController();
