import 'package:blood_pressure_app/model/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/screens/home.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 2 different db files
  final dataModel = await BloodPressureModel.create();
  final settingsModel = await Settings.create();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => dataModel),
          ChangeNotifierProvider(create: (context) => settingsModel),
        ],
        child: const AppRoot()
      )
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
        builder: (context, settings, child) {
          late var mode;
          if (settings.followSystemDarkMode) {
            mode = ThemeMode.system;
          } else if (settings.darkMode) {
            mode = ThemeMode.dark;
          } else {
            mode = ThemeMode.light;
          }

          return MaterialApp(
            title: 'Blood Pressure App',
            theme: ThemeData(
                primaryColor: settings.accentColor
            ),
            darkTheme: ThemeData(
                brightness: Brightness.dark,
                canvasColor: Colors.black,
                primaryColor: settings.accentColor.shade400,
                iconTheme: const IconThemeData(color: Colors.black)
            ),
            themeMode:  mode,
            home: const AppHome(),
          );
        });
  }
}





