import 'dart:async';

import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

/// Create a root material widget with localizations.
Widget materialApp(Widget child, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervalStoreManager? intervallStoreManager,
}) {
  settings ??= Settings();
  exportSettings ??= ExportSettings();
  csvExportSettings ??= CsvExportSettings();
  pdfExportSettings ??= PdfExportSettings();
  intervallStoreManager ??= IntervalStoreManager(IntervalStorage(), IntervalStorage(), IntervalStorage());
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
Widget appBase(Widget child,  {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervalStoreManager? intervallStoreManager,
  BloodPressureRepository? bpRepo,
  MedicineRepository? medRepo,
  NoteRepository? noteRepo,
  MedicineIntakeRepository? intakeRepo,
  BodyweightRepository? weightRepo,
}) {
  HealthDataStore? db;
  if (bpRepo == null
    || medRepo == null
    || intakeRepo == null
    || noteRepo == null
    || weightRepo == null
  ) {
    db = MockHealthDataSore();
  }

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (context) => bpRepo ?? db!.bpRepo),
      RepositoryProvider(create: (context) => medRepo ?? db!.medRepo),
      RepositoryProvider(create: (context) => intakeRepo ?? db!.intakeRepo),
      RepositoryProvider(create: (context) => noteRepo ?? db!.noteRepo),
      RepositoryProvider(create: (context) => weightRepo ?? db!.weightRepo),
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
  IntervalStoreManager? intervallStoreManager,
  List<BloodPressureRecord>? records,
  List<Medicine>? meds,
  List<Note>? notes,
  List<MedicineIntake>? intakes,
  List<BodyweightRecord>? weights,
}) async {
  final db = MockHealthDataSore();
  final bpRepo = db.bpRepo;
  for (final r in records ?? []) {
    await bpRepo.add(r);
  }
  final medRepo = db.medRepo;
  for (final m in meds ?? []) {
    await medRepo.add(m);
  }
  final intakeRepo = db.intakeRepo;
  for (final i in intakes ?? []) {
    await intakeRepo.add(i);
  }
  final noteRepo = db.noteRepo;
  for (final n in notes ?? []) {
    await noteRepo.add(n);
  }
  final weightRepo = db.weightRepo;
  for (final w in weights ?? []) {
    await weightRepo.add(w);
  }

  return appBase(
    child,
    settings: settings,
    exportSettings: exportSettings,
    csvExportSettings: csvExportSettings,
    pdfExportSettings: pdfExportSettings,
    intervallStoreManager: intervallStoreManager,
    bpRepo: bpRepo,
    medRepo: medRepo,
    noteRepo: noteRepo,
    intakeRepo: intakeRepo,
    weightRepo: weightRepo,
  );
}

/// [materialApp] variant that doesn't assume scaffold.
Widget materialForScreens(Widget child, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervalStoreManager? intervallStoreManager,
}) {
  settings ??= Settings();
  exportSettings ??= ExportSettings();
  csvExportSettings ??= CsvExportSettings();
  pdfExportSettings ??= PdfExportSettings();
  intervallStoreManager ??= IntervalStoreManager(IntervalStorage(), IntervalStorage(), IntervalStorage());
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
      home: child,
    ),
  );
}

Widget appBaseForScreen(Widget child,  {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervalStoreManager? intervallStoreManager,
  BloodPressureRepository? bpRepo,
  MedicineRepository? medRepo,
  NoteRepository? noteRepo,
  MedicineIntakeRepository? intakeRepo,
  BodyweightRepository? weightRepo,
}) {
  HealthDataStore? db;
  if (bpRepo == null
      || medRepo == null
      || intakeRepo == null
      || noteRepo == null
      || weightRepo == null
  ) {
    db = MockHealthDataSore();
  }

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider(create: (context) => bpRepo ?? db!.bpRepo),
      RepositoryProvider(create: (context) => medRepo ?? db!.medRepo),
      RepositoryProvider(create: (context) => intakeRepo ?? db!.intakeRepo),
      RepositoryProvider(create: (context) => noteRepo ?? db!.noteRepo),
      RepositoryProvider(create: (context) => weightRepo ?? db!.weightRepo),
    ],
    child: materialForScreens(child,
      settings: settings,
      exportSettings: exportSettings,
      csvExportSettings: csvExportSettings,
      pdfExportSettings: pdfExportSettings,
      intervallStoreManager: intervallStoreManager,
    ),
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

class MockHealthDataSore implements HealthDataStore {
  @override
  BloodPressureRepository bpRepo = MockBloodPressureRepository();

  @override
  MedicineIntakeRepository intakeRepo = MockMedicineIntakeRepository();

  @override
  MedicineRepository medRepo = MockMedicineRepository();

  @override
  NoteRepository noteRepo = MockNoteRepository();

  @override
  BodyweightRepository weightRepo = MockBodyweightRepository();
}

class _MockRepo<T> extends Repository<T> {
  List<T> data = [];
  final contr = StreamController.broadcast();

  @override
  Future<void> add(T value) async {
    data.add(value);
    contr.sink.add(null);
  }

  @override
  Future<List<T>> get(DateRange range) async => data;

  @override
  Future<void> remove(T value) async {
    data.remove(value);
    contr.sink.add(null);
  }

  @override
  Stream subscribe() => contr.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw Exception('unexpected call: $invocation');
}

class MockBloodPressureRepository extends _MockRepo<BloodPressureRecord> implements BloodPressureRepository {}
class MockMedicineIntakeRepository extends _MockRepo<MedicineIntake> implements MedicineIntakeRepository {}
class MockMedicineRepository extends _MockRepo<Medicine> implements MedicineRepository {}
class MockNoteRepository extends _MockRepo<Note> implements NoteRepository {}
class MockBodyweightRepository extends _MockRepo<BodyweightRecord> implements BodyweightRepository {}

/// [matchesGoldenFile] wrapper that includes a dir for image names.
dynamic myMatchesGoldenFile(String key) => matchesGoldenFile(join('golden', key));
