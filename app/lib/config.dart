import 'dart:io';

/// Default name for global logger instance (not used when printing messages atm)
const defaultLoggerName = 'BloodPressureMonitor';

/// Prefix used when printing log messages
const loggerRecordPrefix = 'BPM';

/// Whether bluetooth is supported on this platform by this app
final isPlatformSupportedBluetooth = Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux;

/// Whether we are running in a test environment
final isTestingEnvironment = Platform.environment['FLUTTER_TEST'] == 'true';