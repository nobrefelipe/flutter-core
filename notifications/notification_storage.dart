import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../atomic_state/result.dart';
import '../helpers.dart';
import 'notification_types.dart';

class NotificationStorage {
  static const String _notificationsKey = 'app_notifications';
  static const String _lastNotificationIdKey = 'last_notification_id';
  static const int _maxStoredNotifications = 100;

  static Future<Result<void>> saveNotification(AppNotification notification) async {
    try {
      final result = await getStoredNotifications();
      if (result is! Success<List<AppNotification>>) return Failure('Failed to retrieve existing notifications');
      final trimmed = [notification, ...result.value].take(_maxStoredNotifications).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, jsonEncode(trimmed.map(_toJson).toList()));
      return Success(null);
    } catch (e) {
      return Failure('Failed to save notification: $e');
    }
  }

  static Future<Result<List<AppNotification>>> getStoredNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);
      if (jsonString == null) return Success([]);
      final notifications = (jsonDecode(jsonString) as List)
          .map((json) => _fromJson(json))
          .whereType<AppNotification>()
          .toList();
      return Success(notifications);
    } catch (e) {
      return Failure('Failed to retrieve notifications: $e');
    }
  }

  static Future<Result<void>> markAsRead(String notificationId) async {
    try {
      final result = await getStoredNotifications();
      if (result is! Success<List<AppNotification>>) return Failure(result.errorMessage);
      final updated = result.value
          .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
          .toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, jsonEncode(updated.map(_toJson).toList()));
      return Success(null);
    } catch (e) {
      return Failure('Failed to mark notification as read: $e');
    }
  }

  static Future<Result<void>> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      return Success(null);
    } catch (e) {
      return Failure('Failed to clear notifications: $e');
    }
  }

  static Future<Result<int>> getUnreadCount() async {
    try {
      final result = await getStoredNotifications();
      if (result is! Success<List<AppNotification>>) return Failure(result.errorMessage);
      return Success(result.value.where((n) => !n.isRead).length);
    } catch (e) {
      return Failure('Failed to get unread count: $e');
    }
  }

  static Future<Result<void>> saveLastNotificationId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastNotificationIdKey, id);
      return Success(null);
    } catch (e) {
      return Failure('Failed to save last notification ID: $e');
    }
  }

  static Future<Result<String?>> getLastNotificationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Success(prefs.getString(_lastNotificationIdKey));
    } catch (e) {
      return Failure('Failed to get last notification ID: $e');
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  static Map<String, dynamic> _toJson(AppNotification n) => {
        'id': n.id,
        'type': n.type.value,
        'title': n.title,
        'body': n.body,
        'data': _dataToJson(n.data),
        'received_at': n.receivedAt.toIso8601String(),
        'is_read': n.isRead,
      };

  static AppNotification? _fromJson(dynamic json) {
    try {
      final type = NotificationType.fromString(Helper.getString(json['type']));
      if (type == null) return null;
      return AppNotification(
        id: Helper.getString(json['id']),
        type: type,
        title: Helper.getString(json['title']),
        body: Helper.getString(json['body']),
        data: NotificationData.fromJson(Helper.getMap(json['data']), type),
        receivedAt: DateTime.tryParse(Helper.getString(json['received_at'])) ?? DateTime.now(),
        isRead: Helper.getBool(json['is_read']),
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _dataToJson(NotificationData data) => switch (data) {
        PaymentReceivedData d => {
            'transaction_id': d.transactionId,
            'amount': d.amount.toString(),
            'currency': d.currency,
            'from_user': d.fromUser,
            'timestamp': d.timestamp.toIso8601String(),
          },
        MoneyRequestData d => {
            'request_id': d.requestId,
            'reason': d.reason,
            'from_user': d.fromUser,
            'amount': d.amount.toString(),
            'timestamp': d.timestamp.toIso8601String(),
          },
        NewLearningVideoData d => {
            'video_id': d.videoId,
            'title': d.title,
            'category': d.category,
            'thumbnail_url': d.thumbnailUrl,
            'duration_seconds': d.durationSeconds.toString(),
          },
        CustomCommunicationData d => {
            'message_id': d.messageId,
            'title': d.title,
            'body': d.body,
            'action_url': d.actionUrl,
            'custom_data': d.customData,
          },
        _ => {},
      };
}
