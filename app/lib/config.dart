import 'dart:io';
import 'package:blood_pressure_app/logging.dart';

/// Default name for global [log] instance (not used when printing messages atm)
const defaultLoggerName = 'BloodPressureMonitor';

/// Prefix used when printing log messages
const loggerRecordPrefix = 'BPM';

/// Whether bluetooth is supported on this platform by this app
final isPlatformSupportedBluetooth = Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux;

/// Whether we are running in a test environment
final isTestingEnvironment = Platform.environment['FLUTTER_TEST'] == 'true';

/// Whether the value graph should be shown as home screen in landscape mode
/// TODO: This functionality basically blocks the UI until the device is back into portrait mode, maybe best to implement this differently
final showValueGraphAsHomeScreenInLandscapeMode = isTestingEnvironment || !Platform.isLinux;
