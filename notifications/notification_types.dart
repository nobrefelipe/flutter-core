import 'package:flutter/material.dart';
import '../extensions.dart';

import '../helpers.dart';

enum NotificationType {
  paymentReceived('payment_received');

  const NotificationType(this.value);
  final String value;

  static NotificationType? fromString(String? value) {
    if (value == null) return null;
    return NotificationType.values.firstWhereOrNull((t) => t.value == value);
  }

  IconData get icon => switch (this) {
    NotificationType.paymentReceived => Icons.payment,
  };

  Color get color => switch (this) {
    NotificationType.paymentReceived => Colors.green,
  };
}

abstract class NotificationData {
  const NotificationData();

  factory NotificationData.fromJson(Map<String, dynamic> json, NotificationType type) {
    return switch (type) {
      NotificationType.paymentReceived => PaymentReceivedData.fromJson(json),
    };
  }
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
