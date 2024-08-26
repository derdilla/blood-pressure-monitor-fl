import 'dart:io';

import 'package:blood_pressure_app/data_util/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/blood_pressure/update_legacy_entries.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/db/file_settings_loader.dart';
import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/error_reporting_screen.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:blood_pressure_app/screens/loading_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Base class for the entire app.
///
/// Sets up databases, performs update logic and provides styles and ancestors
/// that should be available everywhere in the app.
class App extends StatefulWidget {
  /// Create the base for the entire app.
  const App();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Database? _entryDB;

  /// The result of the first [_loadApp] call.
  ///
  /// Storing this is necessary to ensure the app is not loaded multiple times.
  Widget? _loadedChild;
  Settings? _settings;
  ExportSettings? _exportSettings;
  CsvExportSettings? _csvExportSettings;
  PdfExportSettings? _pdfExportSettings;
  IntervalStoreManager? _intervalStorageManager;
  ExportColumnsManager? _exportColumnsManager;

  @override
  void dispose() {
    _entryDB?.close();
    _entryDB = null;
    _settings?.dispose();
    _exportSettings?.dispose();
    _csvExportSettings?.dispose();
    _pdfExportSettings?.dispose();
    _intervalStorageManager?.dispose();
    _exportColumnsManager?.dispose();
    super.dispose();
  }

  /// Load the primary app data asynchronously to allow load animations.
  Future<Widget> _loadApp() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      databaseFactory = databaseFactoryFfi;
    }

    if (kDebugMode && (const bool.fromEnvironment('testing_mode'))) {
      final dbPath = await getDatabasesPath();
      try {
        File(join(dbPath, 'bp.db')).deleteSync();
        File(join(dbPath, 'bp.db-journal')).deleteSync();
      } on FileSystemException {
        // File is likely already deleted or couldn't be created in the first place.
      }
      try {
        File(join(dbPath, 'config.db')).deleteSync();
        File(join(dbPath, 'config.db-journal')).deleteSync();
      } on FileSystemException { }
      try {
        File(join(dbPath, 'medicine.intakes')).deleteSync();
      } on FileSystemException { }
    }

    try {
      final SettingsLoader settingsLoader = await FileSettingsLoader.load();
      _settings ??= await settingsLoader.loadSettings();
      _exportSettings ??= await settingsLoader.loadExportSettings();
      _csvExportSettings ??= await settingsLoader.loadCsvExportSettings();
      _pdfExportSettings ??= await settingsLoader.loadPdfExportSettings();
      _intervalStorageManager ??= await settingsLoader.loadIntervalStorageManager();
      _exportColumnsManager ??= await settingsLoader.loadExportColumnsManager();
    } catch (e, stack) {
      await ErrorReporting.reportCriticalError('Error loading settings from files', '$e\n$stack',);
    }

    // TODO: update old settings
    if (false) {
      try {
        final _configDB = await ConfigDB.open();
        final configDao = ConfigDao(_configDB!);

        _settings ??= await configDao.loadSettings();
        _exportSettings ??= await configDao.loadExportSettings();
        _csvExportSettings ??= await configDao.loadCsvExportSettings();
        _pdfExportSettings ??= await configDao.loadPdfExportSettings();
        _intervalStorageManager ??= await configDao.loadIntervalStorageManager();
        _exportColumnsManager ??= await configDao.loadExportColumnsManager();
      } catch (e, stack) {
        await ErrorReporting.reportCriticalError('Error loading config db', '$e\n$stack',);
      }
    }


    late BloodPressureRepository bpRepo;
    late NoteRepository noteRepo;
    late MedicineRepository medRepo;
    late MedicineIntakeRepository intakeRepo;

    try {
      _entryDB = await openDatabase(
        join(await getDatabasesPath(), 'bp.db'),
      );
      final db = await HealthDataStore.load(_entryDB!);
      bpRepo = db.bpRepo;
      noteRepo = db.noteRepo;
      medRepo = db.medRepo;
      intakeRepo = db.intakeRepo;
    } catch (e, stack) {
      await ErrorReporting.reportCriticalError('Error loading entry db', '$e\n$stack',);
    }

    try {
      await updateLegacyEntries(
        _settings!,
        bpRepo,
        noteRepo,
        medRepo,
        intakeRepo,
      );

      // update logic
      if (_settings!.lastVersion == 0) {
        await updateLegacySettings(_settings!, _exportSettings!, _csvExportSettings!, _pdfExportSettings!, _intervalStorageManager!);
        // await updateLegacyExport(_configDB!, _exportColumnsManager!); // TODO

        _settings!.lastVersion = 30;
        if (_exportSettings!.exportAfterEveryEntry) {
          await Fluttertoast.showToast(
            msg: r'Please review your export settings to ensure everything works as expected.',
          );
        }
      }
      if (_settings!.lastVersion == 30) {
        if (_pdfExportSettings!.exportFieldsConfiguration.activePreset == ExportImportPreset.bloodPressureApp) {
          _pdfExportSettings!.exportFieldsConfiguration.activePreset = ExportImportPreset.bloodPressureAppPdf;
        }
        _settings!.lastVersion = 31;
      }
      if (_settings!.allowMissingValues && _settings!.validateInputs){
        _settings!.validateInputs = false;
      }

      _settings!.lastVersion = int.parse((await PackageInfo.fromPlatform()).buildNumber);

      // Reset the step size interval to current on startup
      _intervalStorageManager!.mainPage.setToMostRecentInterval();
    } catch (e, stack) {
      await ErrorReporting.reportCriticalError('Error performing upgrades:', '$e\n$stack',);
    }

    _loadedChild = MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: bpRepo),
        RepositoryProvider.value(value: noteRepo),
        RepositoryProvider.value(value: medRepo),
        RepositoryProvider.value(value: intakeRepo),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _settings!),
          ChangeNotifierProvider.value(value: _exportSettings!),
          ChangeNotifierProvider.value(value: _csvExportSettings!),
          ChangeNotifierProvider.value(value: _pdfExportSettings!),
          ChangeNotifierProvider.value(value: _intervalStorageManager!),
          ChangeNotifierProvider.value(value: _exportColumnsManager!),
        ],
        child: _buildAppRoot(),
      ),
    );

    return _loadedChild!;
  }

  @override
  Widget build(BuildContext context) {
    if (!(kDebugMode && (const bool.fromEnvironment('testing_mode')))
        && _loadedChild != null && _settings != null && _entryDB != null) {
      return _loadedChild!;
    }
    return ConsistentFutureBuilder(
      future: _loadApp(),
      onWaiting: const LoadingScreen(),
      onData: (context, widget) => widget,
    );
  }

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
      ),),
      themeMode: settings.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.language,
      debugShowCheckedModeBanner: false,
      home: const AppHome(),
    ),
  );

  ThemeData _buildTheme(ColorScheme colorScheme) {
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        width: 3,
        // Through black background outlineVariant has enough contrast.
        color: (colorScheme.brightness == Brightness.dark)
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
      scaffoldBackgroundColor: colorScheme.brightness == Brightness.dark
        ? Colors.black
        : Colors.white,
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
