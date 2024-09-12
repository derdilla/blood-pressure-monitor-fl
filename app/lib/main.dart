import 'package:blood_pressure_app/app.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// Run the [App].
void main() {
  if (Log.enabled) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) => debugPrint(Log.format(record)));
  }

  runApp(const App());
}
