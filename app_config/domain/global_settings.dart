// core/app_config/domain/global_settings.dart

import '../../helpers.dart';

/// Feature flags returned by the backend config.
/// Controls which infrastructure services are active for this user/tenant.
class GlobalSettings {
  final bool enablePushNotifications;
  final bool enableIntercom;
  final bool enableLocationTracking;
  final bool enableNotificationsCentre;

  const GlobalSettings({
    required this.enablePushNotifications,
    required this.enableIntercom,
    required this.enableLocationTracking,
    required this.enableNotificationsCentre,
  });

  const GlobalSettings.empty()
    : enablePushNotifications = false,
      enableIntercom = false,
      enableLocationTracking = false,
      enableNotificationsCentre = false;

  factory GlobalSettings.fromJson(dynamic json) => GlobalSettings(
    enablePushNotifications: Helper.getBool(json['enablePushNotifications']),
    enableIntercom: Helper.getBool(json['enableIntercom']),
    enableLocationTracking: Helper.getBool(json['enableLocationTracking']),
    enableNotificationsCentre: Helper.getBool(json['enable_notification_centre']),
  );

  @override
  String toString() =>
      'GlobalSettings(pushNotifications: $enablePushNotifications, '
      'intercom: $enableIntercom, locationTracking: $enableLocationTracking, '
      'notificationsCentre: $enableNotificationsCentre)';
}
