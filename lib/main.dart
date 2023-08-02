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

// TODO: centralize disabling
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
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: settings.accentColor,
                brightness: Brightness.light,
            ),
            useMaterial3: true
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: settings.accentColor,
            brightness: Brightness.dark,
            background: Colors.black
          ),
          useMaterial3: true
        ),
        themeMode: mode,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: settings.language,
        home: const AppHome(),
      );
    });
  }
}
