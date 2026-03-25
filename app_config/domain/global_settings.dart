// core/app_config/domain/global_settings.dart

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

  @override
  String toString() =>
      'GlobalSettings(pushNotifications: $enablePushNotifications, '
      'intercom: $enableIntercom, locationTracking: $enableLocationTracking, '
      'notificationsCentre: $enableNotificationsCentre)';
}
