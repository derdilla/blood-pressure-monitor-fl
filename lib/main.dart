import 'dart:io';

import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/model/storage/update_legacy_settings.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:blood_pressure_app/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

late final ConfigDB _database;
late final BloodPressureModel _bloodPressureModel;

void main() async {
  runApp(ConsistentFutureBuilder(
      future: _loadApp(),
      onWaiting: const LoadingScreen(),
      onData: (context, widget) => widget,
  ),);
}

/// Load the primary app data asynchronously to allow adding load animations.
Future<Widget> _loadApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 2 different db files
  _bloodPressureModel = await BloodPressureModel.create();

  _database = await ConfigDB.open();
  final configDao = ConfigDao(_database);

  final settings = await configDao.loadSettings(0);
  final exportSettings = await configDao.loadExportSettings(0);
  final csvExportSettings = await configDao.loadCsvExportSettings(0);
  final pdfExportSettings = await configDao.loadPdfExportSettings(0);
  final intervalStorageManager = await IntervallStoreManager.load(configDao, 0);
  final exportColumnsManager = await configDao.loadExportColumnsManager(0);

  // TODO: unify with blood pressure model (#257)
  late final IntakeHistory intakeHistory;
  try {
    if (settings.medications.isNotEmpty) {
      final intakeString = File(join(await getDatabasesPath(), 'medicine.intakes')).readAsStringSync();
      intakeHistory = IntakeHistory.deserialize(intakeString, settings.medications);
    } else {
      intakeHistory = IntakeHistory([]);
    }
  } catch (e, stack) {
    assert(e is PathNotFoundException, '$e\n$stack');
    intakeHistory = IntakeHistory([]);
  }
  intakeHistory.addListener(() async {
    File(join(await getDatabasesPath(), 'medicine.intakes')).writeAsStringSync(intakeHistory.serialize());
  });

  // update logic
  if (settings.lastVersion == 0) {
    await updateLegacySettings(settings, exportSettings, csvExportSettings, pdfExportSettings, intervalStorageManager);
    await updateLegacyExport(_database, exportColumnsManager);

    settings.lastVersion = 30;
    if (exportSettings.exportAfterEveryEntry) {
      await Fluttertoast.showToast(
        msg: r'Please review your export settings to ensure everything works as expected.',
      );
    }
  }
  if (settings.lastVersion == 30) {
    if (pdfExportSettings.exportFieldsConfiguration.activePreset == ExportImportPreset.bloodPressureApp) {
      pdfExportSettings.exportFieldsConfiguration.activePreset = ExportImportPreset.bloodPressureAppPdf;
    }
    settings.lastVersion = 31;
  }
  if (settings.allowMissingValues && settings.validateInputs) settings.validateInputs = false;

  settings.lastVersion = int.parse((await PackageInfo.fromPlatform()).buildNumber);

  // Reset the step size intervall to current on startup
  intervalStorageManager.mainPage.setToMostRecentIntervall();

  print(AppLocalizations.delegate);

  return MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => _bloodPressureModel),
    ChangeNotifierProvider(create: (context) => settings),
    ChangeNotifierProvider(create: (context) => exportSettings),
    ChangeNotifierProvider(create: (context) => csvExportSettings),
    ChangeNotifierProvider(create: (context) => pdfExportSettings),
    ChangeNotifierProvider(create: (context) => intervalStorageManager),
    ChangeNotifierProvider(create: (context) => exportColumnsManager),
    ChangeNotifierProvider(create: (context) => intakeHistory),
  ], child: const AppRoot(),);
}

/// Central [MaterialApp] widget of the app that sets the uniform style options.
class AppRoot extends StatelessWidget {
  /// Create the base for the entire app.
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) =>
    Consumer<Settings>(builder: (context, settings, child) => MaterialApp(
      title: 'Blood Pressure App',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
      theme: _buildTheme(ColorScheme.fromSeed(
        seedColor: settings.accentColor,
      ),),
      darkTheme: _buildTheme(ColorScheme.fromSeed(
        seedColor: settings.accentColor,
        brightness: Brightness.dark,
        background: Colors.black,
      ),),
      themeMode: settings.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.language,
      home: const AppHome(),
    ),
  );

  ThemeData _buildTheme(ColorScheme colorScheme) {
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        width: 3,
        // Through black background outlineVariant has enough contrast.
        color: (colorScheme.background == Colors.black)
            ? colorScheme.outlineVariant
            : colorScheme.outline,
      ),
      borderRadius: BorderRadius.circular(20),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        errorMaxLines: 5,
        border: inputBorder,
        enabledBorder: inputBorder,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

bool _isDatabaseClosed = false;
/// Close all connections to the databases and remove all listeners from provided objects.
///
/// The app will most likely stop working after invoking this.
///
/// Invoking the function multiple times is safe.
Future<void> closeDatabases() async {
  if (_isDatabaseClosed) return;
  _isDatabaseClosed = true;

  await _database.database.close();
  await _bloodPressureModel.close();
}
