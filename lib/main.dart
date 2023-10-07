import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/model/storage/update_legacy_settings.dart';
import 'package:blood_pressure_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

@Deprecated('see #182')
late AppLocalizations gLocalizations;
@Deprecated('This should not be used for new code, but rather for migrating existing code.')
late final ConfigDao globalConfigDao;

late final ConfigDB _database;
late final BloodPressureModel _bloodPressureModel;

void main() async {
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

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => _bloodPressureModel),
    ChangeNotifierProvider(create: (context) => settings),
    ChangeNotifierProvider(create: (context) => exportSettings),
    ChangeNotifierProvider(create: (context) => csvExportSettings),
    ChangeNotifierProvider(create: (context) => pdfExportSettings),
    ChangeNotifierProvider(create: (context) => intervalStorageManager),
  ], child: const AppRoot()));
}

// TODO: centralize disabling
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      final mode = getMode(settings);

      return MaterialApp(
        title: 'Blood Pressure App',
        onGenerateTitle: (context) {
          gLocalizations = AppLocalizations.of(context)!;
          return gLocalizations.title;
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

  ThemeMode getMode(Settings settings) {
    if (settings.followSystemDarkMode) {
      return ThemeMode.system;
    } else if (settings.darkMode) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }
}

bool _areAllProvidersUnregistered = false;
/// Close all connections to the databases and remove all listeners from provided objects.
///
/// The app will most likely stop working after invoking this.
///
/// Invoking the function multiple times is safe.
Future<void> closeDatabases() async {
  if (_areAllProvidersUnregistered) return;
  _areAllProvidersUnregistered = true;

  await _database.database.close();
  await _bloodPressureModel.close();
}
