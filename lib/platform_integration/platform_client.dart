import 'package:flutter/services.dart';

class PlatformClient {
  /// Platform channel for sharing files, loading files, saving files and asking for directory permissions.
  static const storagePlatform = MethodChannel('bloodPressureApp.derdilla.com/storage');


  static Future<bool> shareFile(String path, String mimeType) async { // TODO: arguments from platform
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