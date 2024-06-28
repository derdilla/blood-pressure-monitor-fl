import 'dart:async';

import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Create a root material widget with localizations.
Widget materialApp(Widget child, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
}) {
  settings ??= Settings();
  exportSettings ??= ExportSettings();
  csvExportSettings ??= CsvExportSettings();
  pdfExportSettings ??= PdfExportSettings();
  intervallStoreManager ??= IntervallStoreManager(IntervallStorage(), IntervallStorage(), IntervallStorage());
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider.value(value: exportSettings),
      ChangeNotifierProvider.value(value: csvExportSettings),
      ChangeNotifierProvider.value(value: pdfExportSettings),
      ChangeNotifierProvider.value(value: intervallStoreManager),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: Scaffold(body:child),
    ),
  );
}

/// Creates a the same App as the main method.
Future<Widget> appBase(Widget child,  {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
  BloodPressureRepository? bpRepo,
  MedicineRepository? medRepo,
  MedicineIntakeRepository? intakeRepo,
}) async {
  HealthDataStore? db;
  if (bpRepo == null || medRepo == null || intakeRepo == null) {
    db = await _getHealthDateStore();
  }

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (context) => bpRepo ?? db!.bpRepo),
      RepositoryProvider(create: (context) => medRepo ?? db!.medRepo),
      RepositoryProvider(create: (context) => intakeRepo ?? db!.intakeRepo),
    ],
    child: materialApp(child,
      settings: settings,
      exportSettings: exportSettings,
      csvExportSettings: csvExportSettings,
      pdfExportSettings: pdfExportSettings,
      intervallStoreManager: intervallStoreManager,
    ),
  );
}

/// Creates a the same App as the main method.
Future<Widget> appBaseWithData(Widget child,  {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
  List<BloodPressureRecord>? records,
  List<Medicine>? meds,
  List<MedicineIntake>? intakes,
}) async {
  final db = await _getHealthDateStore();
  final bpRepo = db.bpRepo;
  await Future.forEach<BloodPressureRecord>(records ?? [], bpRepo.add);
  final medRepo = db.medRepo;
  final intakeRepo = db.intakeRepo;

  return appBase(
    child,
    settings: settings,
    exportSettings: exportSettings,
    csvExportSettings: csvExportSettings,
    pdfExportSettings: pdfExportSettings,
    intervallStoreManager: intervallStoreManager,
    bpRepo: bpRepo,
    medRepo: medRepo,
    intakeRepo: intakeRepo,
  );
}


/// Open a dialoge through a button press.
///
/// Example usage:
/// ```dart
/// dynamic returnedValue = false;
/// await loadDialoge(tester, (context) async => returnedValue =
///    await showAddExportColumnDialoge(context, Settings(),
///      UserColumn('initialInternalIdentifier', 'csvTitle', 'formatPattern')
/// ));
/// ```
Future<void> loadDialoge(WidgetTester tester, void Function(BuildContext context) dialogeStarter, {
  String dialogeStarterText = 'X',
  Settings? settings,
}) async {
  await tester.pumpWidget(materialApp(
    Builder(builder: (context) => TextButton(onPressed: () => dialogeStarter(context), child: Text(dialogeStarterText)),),
    settings: settings,
  ),);
  await tester.tap(find.text(dialogeStarterText));
  await tester.pumpAndSettle();
}

/// Get empty mock med repo.
// Using a instance of the real repository somehow causes a deadlock in tests.
MedicineRepository medRepo([List<Medicine>? meds]) => MockMedRepo(meds);

class MockMedRepo implements MedicineRepository {
  MockMedRepo(List<Medicine>? meds) {
    if (meds != null) _meds.addAll(meds);
  }

  final List<Medicine> _meds = [];

  final _controller = StreamController.broadcast();

  @override
  Future<void> add(Medicine medicine) async {
    _meds.add(medicine);
    _controller.add(null);
  }

  @override
  Future<List<Medicine>> getAll() async=> _meds;

  @override
  Future<void> remove(Medicine value) async {
    _meds.remove(value);
    _controller.add(null);
  }

  @override
  @Deprecated('Medicines have no date. Use getAll directly')
  Future<List<Medicine>> get(DateRange range) => getAll();

  @override
  Stream subscribe() => _controller.stream;
}

final List<Medicine> _meds = [];

/// Creates mock Medicine.
///
/// Medicines with the same properties will keep the correct id.
Medicine mockMedicine({
  Color color = Colors.black,
  String designation = '',
  double? defaultDosis,
}) {
  final matchingMeds = _meds.where((med) => med.dosis?.mg == defaultDosis
    && med.color == color.value
    && med.designation == designation,
  );
  if (matchingMeds.isNotEmpty) return matchingMeds.first;
  final med = Medicine(
    designation: designation,
    color: color.value,
    dosis: defaultDosis == null ? null : Weight.mg(defaultDosis),
  );
  _meds.add(med);
  return med;
}

/// Don't use this, use [_getHealthDateStore] to obtain.
HealthDataStore? _db;
Future<HealthDataStore> _getHealthDateStore() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  _db ??= await HealthDataStore.load(db);
  return _db!;
}
