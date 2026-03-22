import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'notification_types.dart';

/// Routes notification taps to app screens.
/// injected via configure() from main.dart or AuthBuilder.
///
/// Setup (call once after app initialises):
///   NotificationRouter.configure({
///     NotificationType.paymentReceived: '/home',
///     NotificationType.moneyRequest: '/home',
///     NotificationType.newLearningVideo: '/learning',
///     NotificationType.customCommunication: '/home',
///   });
///
/// The destination screen receives the full NotificationData object via
/// state.extra and extracts what it needs:
///   final data = state.extra as PaymentReceivedData;
class NotificationRouter {
  NotificationRouter._();

  static Map<NotificationType, String> _routes = {};

  /// Register routes from outside core/ — call once from main.dart or AuthBuilder.
  static void configure(Map<NotificationType, String> routes) {
    _routes = routes;
  }

  /// Routes the notification tap to the registered path.
  /// Falls back to '/home' for unregistered types.
  /// Full NotificationData is passed as extra — screens extract what they need.
  static void route(BuildContext context, AppNotification notification) {
    final path = _routes[notification.type] ?? '/home';
    context.go(path, extra: notification.data);
  }
}
