import 'package:flutter/material.dart';

import '../core/atomic_state/async_atom.dart';
import '../data/auth_repository.dart';
import 'app_config/app_config_controller.dart';
import 'atomic_state/auth_state.dart';
import 'global_atoms.dart';
import 'env.dart';
import 'notifications/notification_router.dart';
import 'notifications/notification_service.dart';
import 'notifications/notification_types.dart';

/// Wraps the entire app in MaterialApp.router's builder.
/// Responsible for three things only:
///   1. Triggering checkAuth() on Initial state
///   2. Setting up / tearing down notifications on auth change
///   3. Resetting all atoms on logout
///
/// Routing is handled entirely by GoRouter — never navigate from here.
class AuthBuilder extends StatefulWidget {
  final Widget child;

  const AuthBuilder({super.key, required this.child});

  @override
  State<AuthBuilder> createState() => _AuthBuilderState();
}

class _AuthBuilderState extends State<AuthBuilder> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    authState.addListener(_authListener);
    Future(() => _authListener());

    // Re-verify auth every time the app comes to foreground
    _lifecycleListener = AppLifecycleListener(onResume: () => authState.emit(Initial()));
  }

  @override
  void dispose() {
    authState.removeListener(_authListener);
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _authListener() async {
    final current = authState.value;

    // Initial = auth status unknown — check with API then return.
    // GoRouter redirect handles routing once Authenticated/Unauthenticated is emitted.
    if (current is Initial) {
      AuthRepository().checkAuth();
      return;
    }

    if (current is Authenticated) {
      await NotificationService.instance.initialize(appId: Env.oneSignalAppId, context: context);
      await appConfigController.load();

      // Wire notification routing
      NotificationRouter.configure({
        NotificationType.paymentReceived: '/home',
      });

      NotificationService.instance.onNotificationTapped = (n) => NotificationRouter.route(context, n);

      NotificationService.instance.setupUserAfterAuth();
    } else if (current is Unauthenticated) {
      NotificationService.instance.clearUserData();
      appConfigController.onLogout();
      resetAllAtoms();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
