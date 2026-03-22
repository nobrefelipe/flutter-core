// import 'package:get/route_manager.dart';

abstract class Env {
  static String get apiBaseUrl => const String.fromEnvironment("DEFINE_API_URL");
  static String get intercomID => const String.fromEnvironment("INTERCOM_ID");
  static String get intercomIosKey => const String.fromEnvironment("INTERCOM_IOS_KEY");
  static String get intercomAndroidKey => const String.fromEnvironment("INTERCOM_ANDROID_KEY");
  static String get oneSignalAppId => const String.fromEnvironment("ONESIGNAL_APP_ID");

  static bool get suppressApiLogging => const bool.fromEnvironment("DEFINE_SUPPRESS_API_LOGS");

  static bool get isInDebugMode => const bool.fromEnvironment("DEFINE_IS_DEV");
  static bool get isProd => const bool.fromEnvironment("DEFINE_IS_PROD");
  static bool get isAlpha => const bool.fromEnvironment("DEFINE_IS_ALPHA");
}
