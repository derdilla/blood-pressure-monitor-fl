import 'dart:io';

import 'package:blood_pressure_app/config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Logger instance
final log = Logger(defaultLoggerName);

/// Mixin to provide logging instances within classes
///
/// Usage: extend your class with this mixin by adding 'with TypeLogger'
/// to be able to call the logger property anywhere in your class. Log
/// statements will be printed with the given class name, ie given a
/// loggerRecordPrefix of 'PREF' and class name MyClass then
/// calling MyClass.logger will include the text 'PREF[MyClass]:'
mixin TypeLogger {
  /// log interface, returns a [Logger] instance from https://pub.dev/packages/logging
  Logger get logger => Logger('$loggerRecordPrefix[${Log.withoutTypes('$runtimeType')}]');
}

/// Simple class for manually logging in debug builds.
///
/// Also contains some logging configuration logic
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

  /// Find callee of log call from [stacktrace], uses [StackTrace.current] if none provided
  /// 
  /// [skipCount] defines which line from the stracktrace should be used. With the default value of 2,
  /// then the 3rd line will be used. Lines in the stracktrace refer to each step in the call tree,
  /// the default value of 2 is to skip the calls to the [findRuntimeType] method itself and to skip
  /// the calls to f.e. the [err] or [trace] methods.
  /// Note: references to anonymous closures (ie '.<anonymous closure>') are always stripped
  static String findRuntimeType([StackTrace? stacktrace, int skipCount = 2]) {
    // logSource parse examples:
    // #1      new BluetoothCubit (package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart:18:9)
    // #1      ClosedBluetoothInput.build.<anonymous closure> (package:blood_pressure_app/features/bluetooth/ui/closed_bluetooth_input.dart:49:13)
    final logSource = (stacktrace ?? StackTrace.current)
      .toString()
      .split('\n')
      .skip(skipCount) // skip 2 by default, one for call to this method and one for call to Log.(err|trace)
      .first;
    final words = logSource
      .replaceAll('.<anonymous closure>', '') // Remove info about anonymous closures
      .split(RegExp(r'\s+')); // split into words

    for (final word in words) {
      if (word != 'new' && !word.startsWith('#')) {
        return Log.withoutTypes(word);
      }
    }

    return '';
  }

  /// Log an error with stack trace in debug builds.
  @Deprecated('Use log.(severe|shout) or the TypeLogger mixin instead')
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
  @Deprecated('Use log.fine(r|st)? or the TypeLogger mixin instead')
  static void trace(String message) {
    if (Log.enabled) {
      final runtimeType = Log.findRuntimeType();
      log.finer('$loggerRecordPrefix{$runtimeType}: $message');
    }
  }
}
