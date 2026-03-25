import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_webview.dart' show AppWebView;
import 'app_config/app_config_controller.dart';
import 'app_config/app_shell.dart';
import 'app_config/navigation/app_navigator.dart';
import 'atomic_state/auth_state.dart';
import 'atomic_state/result.dart';
import 'global_atoms.dart';

// import additional views as features are added

// Access the router from anywhere to call router.refresh()
final router = GoRouter(
  // Re-evaluates redirect whenever authState OR appConfig changes.
  // Merging both into one Listenable means a single redirect() covers all gates.
  refreshListenable: Listenable.merge([authState, appConfig]),
  redirect: _redirect,
  routes: _routes,
);

/// Central routing guard — single place all routing decisions live.
/// Evaluated on every navigation event and on every authState / appConfig change.
String? _redirect(BuildContext context, GoRouterState state) {
  final auth = authState.value;
  final config = appConfig.value;
  final location = state.matchedLocation;
  final isOnAuth = location.startsWith('/auth');

  // ─── Auth is unknown — wait for checkAuth() ────────────────────────────────
  if (auth is Initial) return null;

  // ─── Unauthenticated ───────────────────────────────────────────────────────
  if (auth is Unauthenticated) {
    return isOnAuth ? null : '/auth/onboarding';
  }

  // ─── Authenticated ─────────────────────────────────────────────────────────
  if (auth is Authenticated) {
    // Still on an auth route — run post-auth gates then send to loader
    if (isOnAuth) {
      // if (!PostAuthGates.isPinSetupComplete(context)) return '/auth/pin-setup';
      return '/loader'; // config is fetching — wait here
    }

    // Config is loading or not yet started — stay on loader
    if (config is Loading || config is Idle) return '/loader';

    // Config fetch failed — send to error screen with retry
    if (config is Failure) return '/config-error';

    // Config ready — let the router do its thing
    // ShellRoute will render AppShell with the nav items from config
    if (config is Success) return null;
  }

  return null;
}

final _routes = <RouteBase>[
  // ─── Auth routes ────────────────────────────────────────────────────────────
  // GoRoute(path: '/auth/onboarding', builder: (_, __) => const OnboardingView()),
  // GoRoute(path: '/auth/login',      builder: (_, __) => const LoginView()),
  // GoRoute(path: '/auth/app-lock', builder: (_, __) => const AppLockPage()),
  // GoRoute(path: '/auth/pin-setup', builder: (_, __) => const PinSetupPage()),
  // GoRoute(path: '/auth/bio-setup', builder: (_, __) => const BiometricSetupPage()),

  // ─── Loading state — shown while appConfig is fetching ────────────────────
  GoRoute(path: '/loader', builder: (_, __) => const AppLoaderScreen()),

  // ─── Config error — shown if appConfig fetch fails ────────────────────────
  GoRoute(
    path: '/config-error',
    builder: (_, __) => ConfigErrorScreen(
      onRetry: appConfigController.reload,
    ),
  ),

  // ─── Shell — renders bottom nav from config ────────────────────────────────
  ShellRoute(
    builder: (context, state, child) => AppShell(child: child),
    routes: [
      // Add feature routes here as they are built.
      // Route paths must match the "route" values returned by the backend config.
      //
      // GoRoute(path: '/job-schedule', builder: (_, state) => ScheduleScreen(args: state.extra as NavArgs?)),
    ],
  ),

  // ─── WebView — used by AppNavigator for NavType.webpage ───────────────────
  GoRoute(
    path: '/webview',
    builder: (context, state) {
      final args = state.extra as NavArgs;
      final url = args.config['url'] as String;
      final title = args.config['title'] as String?;
      return AppWebView(url: url, title: title);
    },
  ),
];

/// Post-auth gate conditions.
/// Each method returns true if the condition is satisfied.
/// Resolution screens call router.refresh() when done — never navigate directly.
///
/// To add a new gate:
///   1. Add a static method here
///   2. Add the condition to _redirect() above the '/loader' fallback
///   3. Add the resolution route to _routes
///   4. In the resolution screen, call router.refresh() when done
class PostAuthGates {
  PostAuthGates._();

  // static bool isPinSetupComplete(BuildContext context) =>
  //     BiometricAuthService().isSecuritySetupComplete();

  // static bool hasAcceptedTerms(BuildContext context) =>
  //     AppCache().hasAcceptedTerms();

  // static bool isProfileComplete(BuildContext context) =>
  //     AppCache().isProfileComplete();
}
