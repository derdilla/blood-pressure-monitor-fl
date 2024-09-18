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
    final loggerName = record.loggerName == defaultLoggerName ? null : record.loggerName;
    return '${record.level.name}: ${record.time}: ${loggerName != null ? '$loggerName: ' : ''}${record.message}';
  }

  /// Strip types from definition, i.e. MyClass<SomeType> -> MyClass
  static String withoutTypes(String type) => type.replaceAll(RegExp(r'<[^>]+>'), '');
}
