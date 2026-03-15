import 'package:blood_pressure_app/data_util/entry_context.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';
import 'package:health/health.dart';

import '../features/measurement_list/measurement_list_entry_test.dart';
import '../model/export_import/record_formatter_test.dart';
import '../util.dart';

void main() {
  testWidgets('fully deletes entries', (tester) async {
    final entry = mockEntry(time: DateTime.now(), sys: 123, note: 'test', intake: mockIntake(mockMedicine()));

    final BloodPressureRepository bpRepo = MockBloodPressureRepository() as BloodPressureRepository;
    final NoteRepository noteRepo = MockNoteRepository() as NoteRepository;
    final MedicineIntakeRepository intakeRepo = MockMedicineIntakeRepository() as MedicineIntakeRepository;
    await bpRepo.add(entry.$1);
    await noteRepo.add(entry.$2);
    await intakeRepo.add(entry.$3.first);

    await tester.pumpWidget(materialApp(
      settings: Settings(confirmDeletion: false),
      MultiProvider(
        providers: [
          RepositoryProvider.value(value: bpRepo),
          RepositoryProvider.value(value: noteRepo),
          RepositoryProvider.value(value: intakeRepo),
        ],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => context.deleteEntry(entry),
            child: Text('X'),
          ),
        ),
      ),
    ));

    expect(await bpRepo.get(DateRange.all()), hasLength(1));
    expect(await noteRepo.get(DateRange.all()), hasLength(1));
    expect(await intakeRepo.get(DateRange.all()), hasLength(1));

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(await bpRepo.get(DateRange.all()), isEmpty);
    expect(await noteRepo.get(DateRange.all()), isEmpty);
    expect(await intakeRepo.get(DateRange.all()), isEmpty);
  });

  testWidgets('Also removes entries from health connect', (tester) async {
    final entry = mockEntry(time: DateTime.now(), sys: 123, dia: 456);

    final BloodPressureRepository bpRepo =
        MockBloodPressureRepository() as BloodPressureRepository;
    final NoteRepository noteRepo = MockNoteRepository() as NoteRepository;
    final MedicineIntakeRepository intakeRepo =
        MockMedicineIntakeRepository() as MedicineIntakeRepository;
    final fakeHealth = _FakeHealth();
    await bpRepo.add(entry.$1);

    await tester.pumpWidget(materialApp(
      settings: Settings(confirmDeletion: false),
      hcSettings: HealthConnectSettingsStore(
        useHealthConnect: true,
        syncPressureMeasurements: true,
      ),
      MultiProvider(
        providers: [
          RepositoryProvider.value(value: bpRepo),
          RepositoryProvider.value(value: noteRepo),
          RepositoryProvider.value(value: intakeRepo),
        ],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => context.deleteEntry(entry, fakeHealth),
            child: Text('X'),
          ),
        ),
      ),
    ));

    expect(fakeHealth.deletionRequests, isEmpty);

    await tester.tap(find.text('X'));
    await tester.pumpAndSettle();

    expect(fakeHealth.deletionRequests,
        contains(HealthDataType.BLOOD_PRESSURE_SYSTOLIC));
    expect(fakeHealth.deletionRequests,
        contains(HealthDataType.BLOOD_PRESSURE_DIASTOLIC));
    expect(fakeHealth.deletionRequests, hasLength(2));
  });
}

class _FakeHealth extends Fake implements Health {
  _FakeHealth();

  List<HealthDataType> deletionRequests = [];

  @override
  Future<bool> delete(
      {required HealthDataType type,
      required DateTime startTime,
      DateTime? endTime}) async {
    deletionRequests.add(type);
    return true;
  }
}
