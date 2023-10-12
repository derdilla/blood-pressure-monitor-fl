import 'package:flutter/services.dart';

/// Class that hosts platform specific functions for sharing files, loading files, saving files and asking for
/// directory permissions.
///
/// Steps for expanding this class:
/// - If the purpose of the class is not related to storage create a new class with a different [_platformChannel] path.
/// - Open the android folder in Android Studio.
/// - Implement the new method in `StorageProvider.kt`.
/// - Add method name and arguments as a condition to the `onMethodCall` in the same class.
/// - Implement a helper function to this class that calls uses the platform channel (like [shareFile]).
class PlatformClient {
  /// Platform channel for sharing files, loading files, saving files and asking for directory permissions.
  static const _platformChannel = MethodChannel('bloodPressureApp.derdilla.com/storage');

  PlatformClient._create();

  /// Share a file from application storage.
  ///
  /// The file present at the [path] specified will be copied to a sharable location. The file in the sharable location
  /// will be shared with the specified [mimeType].
  ///
  /// The user will be shown the Android Sharesheet.
  /// 
  /// The returned value indicates whether a [PlatformException] was thrown.
  static Future<bool> shareFile(String path, String mimeType) async {
    try {
      await _platformChannel.invokeMethod('shareFile', {
        'path': path,
        'mimeType': mimeType
      });
      return true;
    } on PlatformException {
      return false;
    }
  }
}