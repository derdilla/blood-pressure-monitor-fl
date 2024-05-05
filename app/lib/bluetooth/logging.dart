import 'package:flutter/foundation.dart';

/// Simple class for manually logging in debug builds.
class Log {
  /// Disable error logging during testing.
  static bool testExpectError = false;

  /// Log an error with stack trace in debug builds.
  static void err(String message, [List<Object>? dumps]) {
    if (kDebugMode && !testExpectError) {
      debugPrint('-----------------------------');
      debugPrint('ERROR $message:');
      debugPrintStack();
      for (final e in dumps ?? []) {
        debugPrint(e.toString());
      }
    }
  }
}