import 'package:flutter/services.dart';

class PlatformClient {
  /// Platform channel for sharing files, loading files, saving files and asking for directory permissions.
  static const storagePlatform = MethodChannel('bloodPressureApp.derdilla.com/storage');

  /// Share a file from application storage.
  ///
  /// The file present at the [path] specified will be copied to a sharable location. The file in the sharable location
  /// will be shared with the specified [mimeType].
  ///
  /// The user will be shown the Android Sharesheet.
  static Future<bool> shareFile(String path, String mimeType) async {
    try {
      await storagePlatform.invokeMethod('shareFile', {
        'path': path,
        'mimeType': mimeType
      });
      return true;
    } on PlatformException {
      return false;
    }
  }
}