import 'package:flutter/material.dart';
import '../extensions.dart';

import '../helpers.dart';

enum NotificationType {
  paymentReceived('payment_received'),
  moneyRequest('money_request'),
  newLearningVideo('new_learning_video'),
  customCommunication('custom_communication');

  const NotificationType(this.value);
  final String value;

  static NotificationType? fromString(String? value) {
    if (value == null) return null;
    return NotificationType.values.firstWhereOrNull((t) => t.value == value);
  }

  IconData get icon => switch (this) {
    NotificationType.paymentReceived => Icons.payment,
    NotificationType.moneyRequest => Icons.request_quote,
    NotificationType.newLearningVideo => Icons.play_circle,
    NotificationType.customCommunication => Icons.message,
  };

  Color get color => switch (this) {
    NotificationType.paymentReceived => Colors.green,
    NotificationType.moneyRequest => Colors.blue,
    NotificationType.newLearningVideo => Colors.blue,
    NotificationType.customCommunication => Colors.purple,
  };
}

abstract class NotificationData {
  const NotificationData();

  factory NotificationData.fromJson(Map<String, dynamic> json, NotificationType type) {
    return switch (type) {
      NotificationType.paymentReceived => PaymentReceivedData.fromJson(json),
      NotificationType.moneyRequest => MoneyRequestData.fromJson(json),
      NotificationType.newLearningVideo => NewLearningVideoData.fromJson(json),
      NotificationType.customCommunication => CustomCommunicationData.fromJson(json),
    };
  }
}

class PaymentReceivedData extends NotificationData {
  final String transactionId;
  final double amount;
  final String currency;
  final String fromUser;
  final DateTime timestamp;

  const PaymentReceivedData({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.fromUser,
    required this.timestamp,
  });

  factory PaymentReceivedData.fromJson(Map<String, dynamic> json) => PaymentReceivedData(
    transactionId: Helper.getString(json['transaction_id']),
    amount: Helper.getDouble(json['amount']),
    currency: Helper.getString(json['currency']),
    fromUser: Helper.getString(json['from_user']),
    timestamp: DateTime.tryParse(Helper.getString(json['timestamp'])) ?? DateTime.now(),
  );

  @override
  String toString() => 'PaymentReceivedData(transactionId: $transactionId, amount: $amount, currency: $currency, fromUser: $fromUser)';
}

class MoneyRequestData extends NotificationData {
  final String requestId;
  final String reason;
  final String fromUser;
  final double amount;
  final DateTime timestamp;

  const MoneyRequestData({
    required this.requestId,
    required this.reason,
    required this.fromUser,
    required this.amount,
    required this.timestamp,
  });

  factory MoneyRequestData.fromJson(Map<String, dynamic> json) => MoneyRequestData(
    requestId: Helper.getString(json['request_id']),
    reason: Helper.getString(json['reason']),
    fromUser: Helper.getString(json['from_user']),
    amount: Helper.getDouble(json['amount']),
    timestamp: DateTime.tryParse(Helper.getString(json['timestamp'])) ?? DateTime.now(),
  );

  @override
  String toString() => 'MoneyRequestData(requestId: $requestId, reason: $reason, fromUser: $fromUser, amount: $amount)';
}

class NewLearningVideoData extends NotificationData {
  final String videoId;
  final String title;
  final String category;
  final String thumbnailUrl;
  final int durationSeconds;

  const NewLearningVideoData({
    required this.videoId,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
    required this.durationSeconds,
  });

  factory NewLearningVideoData.fromJson(Map<String, dynamic> json) => NewLearningVideoData(
    videoId: Helper.getString(json['video_id']),
    title: Helper.getString(json['title']),
    category: Helper.getString(json['category']),
    thumbnailUrl: Helper.getString(json['thumbnail_url']),
    durationSeconds: Helper.getInt(json['duration_seconds']),
  );

  @override
  String toString() => 'NewLearningVideoData(videoId: $videoId, title: $title, category: $category, durationSeconds: $durationSeconds)';
}

class CustomCommunicationData extends NotificationData {
  final String messageId;
  final String title;
  final String body;
  final String? actionUrl;
  final Map<String, dynamic> customData;

  const CustomCommunicationData({
    required this.messageId,
    required this.title,
    required this.body,
    this.actionUrl,
    required this.customData,
  });

  factory CustomCommunicationData.fromJson(Map<String, dynamic> json) => CustomCommunicationData(
    messageId: Helper.getString(json['message_id']),
    title: Helper.getString(json['title']),
    body: Helper.getString(json['body']),
    actionUrl: Helper.getStringOrNull(json['action_url']),
    customData: Helper.getMap(json['custom_data']),
  );

  @override
  String toString() => 'CustomCommunicationData(messageId: $messageId, title: $title, actionUrl: $actionUrl)';
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationData data;
  final DateTime receivedAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    NotificationData? data,
    DateTime? receivedAt,
    bool? isRead,
  }) => AppNotification(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    data: data ?? this.data,
    receivedAt: receivedAt ?? this.receivedAt,
    isRead: isRead ?? this.isRead,
  );

  @override
  String toString() => 'AppNotification(id: $id, type: $type, title: $title, isRead: $isRead, receivedAt: $receivedAt)';
}
