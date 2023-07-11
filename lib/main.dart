import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 2 different db files
  final dataModel = await BloodPressureModel.create();
  final settingsModel = await Settings.create();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => dataModel),
    ChangeNotifierProvider(create: (context) => settingsModel),
  ], child: const AppRoot()));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      late final ThemeMode mode;
      if (settings.followSystemDarkMode) {
        mode = ThemeMode.system;
      } else if (settings.darkMode) {
        mode = ThemeMode.dark;
      } else {
        mode = ThemeMode.light;
      }

      return MaterialApp(
        title: 'Blood Pressure App',
        onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
        theme: ThemeData(primaryColor: settings.accentColor),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          canvasColor: Colors.black,
          primaryColor: settings.accentColor.shade400,
        ),
        themeMode: mode,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('de'), // German
          Locale('zh'), // generic Chinese; The file present is actually zh_Hans
        ],
        home: const AppHome(),
      );
    });
  }
}
