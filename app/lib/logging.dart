import 'dart:io';

import 'package:flutter/foundation.dart';

/// Simple class for manually logging in debug builds.
class Log {
  /// Log an error with stack trace in debug builds.
  static void err(String message, [List<Object>? dumps]) {
    if (kDebugMode && !(Platform.environment['FLUTTER_TEST'] == 'true')) {
      debugPrint('-----------------------------');
      debugPrint('ERROR $message:');
      debugPrintStack();
      for (final e in dumps ?? []) {
        debugPrint(e.toString());
      }
    }
  }

  /// Log a message in debug more
  static void trace(String message) {
    if (kDebugMode && !(Platform.environment['FLUTTER_TEST'] == 'true')) {
      debugPrint('TRACE: $message');
    }
  }
}
