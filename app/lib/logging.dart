import 'dart:io';

import 'package:blood_pressure_app/config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Logger instance
final log = Logger(defaultLoggerName);

/// Mixin to provide logging instances within classes
mixin TypeLogger {
  /// log interface
  Logger get logger => Logger('$loggerRecordPrefix[${Log.withoutTypes('$runtimeType')}]');
}

/// Simple class for manually logging in debug builds.
class Log {
  /// Whether logging is enabled
  static final enabled = kDebugMode && !(Platform.environment['FLUTTER_TEST'] == 'true');

  /// Format a log record
  static String format(LogRecord record) {
    String? loggerName = record.loggerName == defaultLoggerName ? null : record.loggerName;
    if (loggerName == '') {
      loggerName = Log.findRuntimeType();
    }

    return '${record.level.name}: ${record.time}: ${loggerName != null ? '$loggerName: ' : ''}${record.message}';
  }

  /// Strip types from definition, i.e. MyClass<SomeType> -> MyClass
  static String withoutTypes(String type) => type.replaceAll(RegExp(r'<[^>]+>'), '');

  /// Find callee of log call from [stacktrace]
  static String findRuntimeType([StackTrace? stacktrace, int skipCount = 2]) {
    // logSource examples:
    // #1      new BluetoothCubit (package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart:18:9)
    // #1      ClosedBluetoothInput.build.<anonymous closure> (package:blood_pressure_app/features/bluetooth/ui/closed_bluetooth_input.dart:49:13)
    final logSource = (stacktrace ?? StackTrace.current)
      .toString()
      .split('\n')
      .skip(skipCount) // skip 2 by default, one for call to this method and one for call to Log.(err|trace)
      .first;
    final words = logSource.split(RegExp(r'\s+'));

    for (final word in words) {
      if (word != 'new' && !word.startsWith('#')) {
        // Remove info about closures
        return Log.withoutTypes(word.replaceAll('.<anonymous', ''));
      }
    }

    return '';
  }

  /// Log an error with stack trace in debug builds.
  @Deprecated('Use logger.(severe|shout) instead')
  static void err(String message, [List<Object>? dumps]) {
    if (!Log.enabled) {
      return;
    }

    final runtimeType = Log.findRuntimeType();
    log.severe('$loggerRecordPrefix{$runtimeType}: $message', dumps?.first, StackTrace.current);

    if (dumps != null && dumps.length > 1) {
      for (final e in dumps.skip(1)) {
        debugPrint(e.toString());
      }
    }
  }

  /// Log a message in debug more
  @Deprecated('Use logger.fine(r|st)? instead')
  static void trace(String message) {
    if (Log.enabled) {
      final runtimeType = Log.findRuntimeType();
      log.finer('$loggerRecordPrefix{$runtimeType}: $message');
    }
  }
}
