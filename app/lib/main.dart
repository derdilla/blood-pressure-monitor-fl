import 'package:blood_pressure_app/app.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/material.dart';

/// Run the [App].
void main() {
  Log.setup();
  runApp(const App());
}
