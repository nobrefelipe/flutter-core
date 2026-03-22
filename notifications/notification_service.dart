import 'dart:convert';

import 'package:flutter/material.dart' show BuildContext;
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../data/auth_repository.dart';
import '../atomic_state/auth_state.dart';
import '../atomic_state/result.dart';
import '../cache/local_cache.dart';
import '../global_atoms.dart';
import '../helpers.dart';
import 'foreground_notification_banner.dart';
import 'notification_storage.dart';
import 'notification_types.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();

  bool _isInitialized = false;
  BuildContext? _context;
  final _cache = AppCache();

  Future<Result<void>> initialize({required String appId, required BuildContext context}) async {
    if (_isInitialized) return Success(null);
    OneSignal.initialize(appId);
    await OneSignal.Notifications.requestPermission(true);
    _context = context;
    _setupHandlers();
    _isInitialized = true;
    debugLog('NotificationService initialized', 'NotificationService');
    return Success(null);
  }

  void _setupHandlers() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugLog('Foreground notification: ${event.notification.title}', 'NotificationService');
      _handleReceived(event.notification, isBackground: false);
      event.preventDefault();
    });

    OneSignal.Notifications.addClickListener((event) {
      debugLog('Notification clicked: ${event.notification.title}', 'NotificationService');
      _handleClicked(event.notification);
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      debugLog('Permission changed: $state', 'NotificationService');
    });
  }

  Future<void> _handleReceived(OSNotification notification, {bool isBackground = true}) async {
    final appNotification = _parse(notification);
    if (appNotification == null) return;
    if (!_isAuthenticated()) return;

    await NotificationStorage.saveNotification(appNotification);
    await NotificationStorage.saveLastNotificationId(appNotification.id);

    if (!isBackground && _context != null && _context!.mounted) {
      ForegroundNotificationBanner.show(_context!, appNotification);
    }
  }

  Future<void> _handleClicked(OSNotification notification) async {
    final appNotification = _parse(notification);
    if (appNotification == null) return;
    if (!_isAuthenticated()) return;

    await NotificationStorage.markAsRead(appNotification.id);

    // NotificationRouter lives outside core/ — injected via callback to avoid core/ importing app routes
    _onNotificationTapped?.call(appNotification);
  }

  // Set this from AuthBuilder or main.dart after initialization
  // e.g. NotificationService.instance.onNotificationTapped = (n) => NotificationRouter.route(context, n);
  void Function(AppNotification)? _onNotificationTapped;
  set onNotificationTapped(void Function(AppNotification) handler) => _onNotificationTapped = handler;

  bool _isAuthenticated() => authState.value is Authenticated;

  AppNotification? _parse(OSNotification notification) {
    try {
      final additionalData = notification.additionalData ?? {};
      final type = NotificationType.fromString(additionalData['type'] as String?);
      if (type == null) return null;

      final rawData = additionalData['data'];
      final Map<String, dynamic> dataMap = switch (rawData) {
        String s => Map<String, dynamic>.from(jsonDecode(s) as Map? ?? {}),
        Map m => Map<String, dynamic>.from(m),
        _ => {},
      };

      return AppNotification(
        id: notification.notificationId,
        type: type,
        title: Helper.getString(notification.title),
        body: Helper.getString(notification.body),
        data: NotificationData.fromJson(dataMap, type),
        receivedAt: DateTime.now(),
        isRead: false,
      );
    } catch (e) {
      debugLog('Error parsing notification: $e', 'NotificationService');
      return null;
    }
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<Result<void>> setupUserAfterAuth() async {
    if (!_isInitialized) return Failure('NotificationService not initialized');
    if (!_isAuthenticated()) return Failure('User not authenticated');

    try {
      // ! MODIFY BASED ON PROJECT
      final user = await _cache.getUser();
      if (user.id.isEmpty) return Failure('Student ID is empty');

      await OneSignal.login(user.id);
      OneSignal.User.addTags({'user_type': 'student', 'student_id': user.id, 'school_id': student.schoolName});
      await AuthRepository().updateOneSignalPlayerId();

      debugLog('OneSignal user setup complete: ${user.id}', 'NotificationService');
      return Success(null);
    } catch (e) {
      return Failure('Failed to setup user after auth: $e');
    }
  }

  Future<Result<void>> clearUserData() async {
    try {
      OneSignal.logout();
      debugLog('OneSignal user data cleared', 'NotificationService');
      return Success(null);
    } catch (e) {
      return Failure('Failed to clear OneSignal user data: $e');
    }
  }

  Future<Result<List<AppNotification>>> getNotifications() => NotificationStorage.getStoredNotifications();

  Future<Result<int>> getUnreadCount() => NotificationStorage.getUnreadCount();

  Future<Result<void>> markNotificationAsRead(String id) => NotificationStorage.markAsRead(id);

  Future<Result<void>> clearAllNotifications() => NotificationStorage.clearAllNotifications();

  Future<Result<String?>> getPlayerId() async {
    try {
      return Success(OneSignal.User.pushSubscription.id);
    } catch (e) {
      return Failure('Failed to get player ID: $e');
    }
  }

  Future<Result<bool>> areNotificationsEnabled() async {
    try {
      return Success(OneSignal.Notifications.permission);
    } catch (e) {
      return Failure('Failed to check notification permission: $e');
    }
  }

  Future<Result<bool>> requestPermission() async {
    try {
      return Success(await OneSignal.Notifications.requestPermission(true));
    } catch (e) {
      return Failure('Failed to request permission: $e');
    }
  }

  void updateContext(BuildContext context) => _context = context;

  void dispose() {
    _context = null;
    _isInitialized = false;
  }
}
