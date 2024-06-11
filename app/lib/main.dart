import 'package:blood_pressure_app/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Start the app and load databases.
///
/// In debug mode `FORCE_CLEAR_ALL_APP_DATA` as the first argument deletes
/// database files before app start.
void main([List<String>? args]) async {
  if (kDebugMode && args?.firstOrNull == 'FORCE_CLEAR_ALL_APP_DATA') {
    await _forceClearAppData();
  }
  runApp(App());
}

/// Removes all files stored by the app without maintaining integrity.
Future<void> _forceClearAppData() async {
  /* TODO
  try {
    File(join(await getDatabasesPath(), 'blood_pressure.db')).deleteSync();
    File(join(await getDatabasesPath(), 'blood_pressure.db-journal')).deleteSync();
  } on FileSystemException {
    // File is likely already deleted or couldn't be created in the first place.
  }
  try {
    File(join(await getDatabasesPath(), 'config.db')).deleteSync();
    File(join(await getDatabasesPath(), 'config.db-journal')).deleteSync();
  } on FileSystemException { }
  try {
    File(join(await getDatabasesPath(), 'medicine.intakes')).deleteSync();
  } on FileSystemException { }
   */
}
