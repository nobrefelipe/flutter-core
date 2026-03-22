import 'package:flutter/foundation.dart';

class Errorhandler {
  static Future<void> _report(
    dynamic exception,
    StackTrace stackTrace,
    String tag,
  ) async {
    debugPrintStack(label: exception.toString(), stackTrace: stackTrace);
  }

  static void externalFailureError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reportTag,
  }) {
    if (stackTrace != null) {
      _report(exception, stackTrace, 'EXTERNAL_FAILURE: $reportTag');
    }
  }
}
