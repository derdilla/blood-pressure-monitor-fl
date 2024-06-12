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

/// Base class for the entire app.
///
/// Sets up databases, performs update logic and provides styles and ancestors
/// that should be available everywhere in the app.
class App extends StatefulWidget {
  /// Create the base for the entire app.
  const App({this.forceClearAppDataOnLaunch = false});

  /// Permanently deletes all files the app uses during state initialization.
  final bool forceClearAppDataOnLaunch;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// Database object for app settings.
  ConfigDB? _configDB;
  BloodPressureModel? _bloodPressureModel;

  /// The result of the first [_loadApp] call.
  ///
  /// Storing this is necessary to ensure the app is not loaded multiple times.
  Widget? _loadedChild;

  @override
  void dispose() {
    _configDB?.database.close();
    _configDB = null;
    _bloodPressureModel?.close();
    _bloodPressureModel = null;
    super.dispose();
  }

  /// Load the primary app data asynchronously to allow load animations.
  Future<Widget> _loadApp() async {
    if (_loadedChild != null) return _loadedChild!;

    WidgetsFlutterBinding.ensureInitialized();

    if (widget.forceClearAppDataOnLaunch) {
      try {
        final dbPath = await getDatabasesPath();
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
    }

    // 2 different db files
    _bloodPressureModel = await BloodPressureModel.create();
    _configDB = await ConfigDB.open();

    final configDao = ConfigDao(_configDB!);

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
      await updateLegacyExport(_configDB!, exportColumnsManager);

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

    _loadedChild = MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => _bloodPressureModel!),
      ChangeNotifierProvider(create: (context) => settings),
      ChangeNotifierProvider(create: (context) => exportSettings),
      ChangeNotifierProvider(create: (context) => csvExportSettings),
      ChangeNotifierProvider(create: (context) => pdfExportSettings),
      ChangeNotifierProvider(create: (context) => intervalStorageManager),
      ChangeNotifierProvider(create: (context) => exportColumnsManager),
      ChangeNotifierProvider(create: (context) => intakeHistory),
    ], child: _buildAppRoot(),);

    return _loadedChild!;
  }

  @override
  Widget build(BuildContext context) => ConsistentFutureBuilder(
    future: _loadApp(),
    onWaiting: const LoadingScreen(),
    onData: (context, widget) => widget,
  );

  /// Central [MaterialApp] widget of the app that sets the uniform style options.
  Widget _buildAppRoot() => Consumer<Settings>(
    builder: (context, settings, child) => MaterialApp(
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
