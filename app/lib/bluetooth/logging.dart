import 'package:flutter/foundation.dart';

/// Simple class for manually logging in debug builds.
class Log {
  /// Log an error with stack trace in debug builds.
  static void err(String message, [List<Object>? dumps]) {
    if (kDebugMode) {
      debugPrint('-----------------------------');
      debugPrintStack();
      debugPrint('ERROR $message:');
      for (final e in dumps ?? []) {
        debugPrint(e);
      }
    }
  }
}