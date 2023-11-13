import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/central_callback.dart';
import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/model/storage/update_legacy_settings.dart';
import 'package:blood_pressure_app/screens/home.dart';
import 'package:blood_pressure_app/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

@Deprecated('This should not be used for new code, but rather for migrating existing code.')
late final ConfigDao globalConfigDao;

late final ConfigDB _database;
late final BloodPressureModel _bloodPressureModel;

void main() async {
  runApp(ConsistentFutureBuilder(
      future: _loadApp(),
      onWaiting: const LoadingScreen(),
      onData: (context, widget) => widget
  ));
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

  await updateLegacySettings(settings, exportSettings, csvExportSettings, pdfExportSettings, intervalStorageManager);

  globalConfigDao = configDao;

  // Reset the step size intervall to current on startup
  intervalStorageManager.mainPage.setToMostRecentIntervall();

  return MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => _bloodPressureModel),
    ChangeNotifierProvider(create: (context) => settings),
    ChangeNotifierProvider(create: (context) => exportSettings),
    ChangeNotifierProvider(create: (context) => csvExportSettings),
    ChangeNotifierProvider(create: (context) => pdfExportSettings),
    ChangeNotifierProvider(create: (context) => intervalStorageManager),
  ], child: AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return MaterialApp(
        title: 'Blood Pressure App',
        onGenerateTitle: (context) {
          return AppLocalizations.of(context)!.title;
        },
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
        themeMode: settings.themeMode,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: settings.language,
        home: const CentralCallbackInitializer(child: AppHome()),
      );
    });
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
