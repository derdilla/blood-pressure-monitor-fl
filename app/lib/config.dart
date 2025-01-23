import 'dart:io';

/// Whether bluetooth is supported on this platform by this app
final isPlatformSupportedBluetooth = Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux;

/// Whether we are running in a test environment
final isTestingEnvironment = Platform.environment['FLUTTER_TEST'] == 'true';

/// Whether the value graph should be shown as home screen in landscape mode
final showValueGraphAsHomeScreenInLandscapeMode = isTestingEnvironment || !Platform.isLinux;
