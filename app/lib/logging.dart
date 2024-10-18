import 'package:blood_pressure_app/config.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Logger instance
final log = Logger('BloodPressureMonitor');

/// Mixin to provide logging instances within classes
///
/// Usage: extend your class with this mixin by adding 'with TypeLogger'
/// to be able to call the logger property anywhere in your class.
mixin TypeLogger {
  /// log interface, returns a [Logger] instance from https://pub.dev/packages/logging
  Logger get logger => Logger('BPM[${Log.withoutTypes('$runtimeType')}]');
}

/// Simple class for manually logging in debug builds.
///
/// Also contains some logging configuration logic
class Log {
  /// Whether logging is enabled
  static final enabled = kDebugMode && !isTestingEnvironment;

  /// Format a log record
  static String format(LogRecord record) {
    final loggerName = record.loggerName == 'BloodPressureMonitor' ? null : record.loggerName;
    return '${record.level.name}: ${record.time}: ${loggerName != null ? '$loggerName: ' : ''}${record.message}';
  }

  /// Strip types from definition, i.e. MyClass<SomeType> -> MyClass
  static String withoutTypes(String type) => type.replaceAll(RegExp(r'<[^>]+>'), '');

  /// Register the apps logging config with [Logger].
  static void setup() {
    if (Log.enabled) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) => debugPrint(Log.format(record)));
    }
  }
}
