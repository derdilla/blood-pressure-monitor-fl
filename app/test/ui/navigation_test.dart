import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/dialoges/enter_timeformat_dialoge.dart';
import 'package:blood_pressure_app/main.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/settings_screen.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('start page', () {
    testWidgets('should navigate to add entry page', (tester) async {
      await pumpAppRoot(tester);
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(AddEntryDialoge), findsOneWidget);
    });
    testWidgets('should navigate to settings page', (tester) async {
      await pumpAppRoot(tester);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
    testWidgets('should navigate to stats page', (tester) async {
      await pumpAppRoot(tester);
      expect(find.byIcon(Icons.insights), findsOneWidget);
      await tester.tap(find.byIcon(Icons.insights));
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsScreen), findsOneWidget);
    });
  });
  group('settings page', () {
    testWidgets('open EnterTimeFormatScreen', (tester) async {
      await pumpAppRoot(tester);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(EnterTimeFormatDialoge), findsNothing);
      expect(find.byKey(const Key('EnterTimeFormatScreen')), findsOneWidget);
      await tester.tap(find.byKey(const Key('EnterTimeFormatScreen')));
      await tester.pumpAndSettle();

      expect(find.byType(EnterTimeFormatDialoge), findsOneWidget);
    });
    // ...
  });
}

/// Creates a the same App as the main method.
@Deprecated('replaced by [newPumpAppRoot]')
Future<void> pumpAppRoot(WidgetTester tester, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
  IntakeHistory? intakeHistory,
  BloodPressureModel? model,
}) async {
  // TODO: migrate arguments
  final db = await HealthDataStore.load(await openDatabase(inMemoryDatabasePath));

  final meds = settings?.medications?.map((e) => Medicine(
      designation: e.designation,
      color: e.color.value,
      dosis: e.defaultDosis != null ? Weight.mg(e.defaultDosis!) : null));
  final medRepo = db.medRepo;
  meds?.forEach(medRepo.add);

  final intakeRepo = db.intakeRepo;
  for (final e in intakeHistory?.getIntakes(DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(999999999999))) ?? []) {
    expect(meds, isNotNull);
    expect(meds, isNotEmpty);
    final med = meds!.firstWhere((e2) => e2.designation == e.medicine.designation);
    intakeRepo.add(MedicineIntake(
      time: e.timestamp,
      dosis: Weight.mg(e.dosis),
      medicine: med,
    ));
  }

  // TODO: bpRepo

  await newPumpAppRoot(tester,
    settings: settings,
    exportSettings: exportSettings,
    csvExportSettings: csvExportSettings,
    pdfExportSettings: pdfExportSettings,
    intervallStoreManager: intervallStoreManager,
    medRepo: medRepo,
    intakeRepo: intakeRepo,
  );
}

/// Creates a the same App as the main method.
Future<void> newPumpAppRoot(WidgetTester tester, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
  BloodPressureRepository? bpRepo,
  MedicineRepository? medRepo,
  MedicineIntakeRepository? intakeRepo,
}) async {
  settings ??= Settings();
  exportSettings ??= ExportSettings();
  csvExportSettings ??= CsvExportSettings();
  pdfExportSettings ??= PdfExportSettings();
  intervallStoreManager ??= IntervallStoreManager(IntervallStorage(), IntervallStorage(), IntervallStorage());

  HealthDataStore? db;
  if  (bpRepo != null || medRepo != null || intakeRepo != null) {
    db = await HealthDataStore.load(await openDatabase(inMemoryDatabasePath));
  }

  await tester.pumpWidget(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => settings),
    ChangeNotifierProvider(create: (_) => exportSettings),
    ChangeNotifierProvider(create: (_) => csvExportSettings),
    ChangeNotifierProvider(create: (_) => pdfExportSettings),
    ChangeNotifierProvider(create: (_) => intervallStoreManager),
  ], child: MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (context) => bpRepo ?? db!.bpRepo),
      RepositoryProvider(create: (context) => medRepo ?? db!.medRepo),
      RepositoryProvider(create: (context) => intakeRepo ?? db!.intakeRepo),
    ],
    child: const AppRoot(),
  ),),);
}

class MockConfigDao implements ConfigDao {
  @override
  Future<CsvExportSettings> loadCsvExportSettings(int profileID) async => CsvExportSettings();

  @override
  Future<ExportSettings> loadExportSettings(int profileID) async => ExportSettings();

  @override
  Future<IntervallStorage> loadIntervallStorage(int profileID, int storageID) async => IntervallStorage();

  @override
  Future<PdfExportSettings> loadPdfExportSettings(int profileID) async => PdfExportSettings();

  @override
  Future<Settings> loadSettings(int profileID) async => Settings();

  void reset() {}

  @override
  Future<ExportColumnsManager> loadExportColumnsManager(int profileID) async => ExportColumnsManager();
}
