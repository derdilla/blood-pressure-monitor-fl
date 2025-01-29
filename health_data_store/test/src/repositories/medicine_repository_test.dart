import 'package:health_data_store/src/repositories/medicine_repository_impl.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../database_manager_test.dart';
import '../types/medicine_test.dart';

void main() {
  sqfliteTestInit();
  test('should initialize', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    MedicineRepositoryImpl(db.db);
  });
  test('should return no medicines when no are added', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = MedicineRepositoryImpl(db.db);
    final all = await repo.getAll();
    expect(all, isEmpty);
  });
  test('should store all complete medicines', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = MedicineRepositoryImpl(db.db);
    await repo
        .add(mockMedicine(designation: 'med1', color: 0xFF226A, dosis: 42));
    await repo
        .add(mockMedicine(designation: 'med2', color: 0xAF226B, dosis: 43));
    final all = await repo.getAll();
    expect(all, hasLength(2));
    expect(
        all,
        containsAll([
          isA<Medicine>()
              .having((p0) => p0.designation, 'designation', 'med1')
              .having((p0) => p0.color, 'color', 0xFF226A)
              .having((p0) => p0.dosis?.mg, 'dosis', 42),
          isA<Medicine>()
              .having((p0) => p0.designation, 'designation', 'med2')
              .having((p0) => p0.color, 'color', 0xAF226B)
              .having((p0) => p0.dosis?.mg, 'dosis', 43),
        ]));
  });
  test('should store all incomplete medicines', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = MedicineRepositoryImpl(db.db);
    await repo.add(Medicine(
      designation: 'med1',
      color: 0xFF226A,
    ));
    await repo.add(mockMedicine(designation: 'med2', dosis: 43));
    await repo.add(Medicine(
      designation: 'med3',
    ));
    final all = await repo.getAll();
    expect(all, hasLength(3));
    expect(
        all,
        containsAll([
          isA<Medicine>()
              .having((p0) => p0.designation, 'designation', 'med1')
              .having((p0) => p0.color, 'color', 0xFF226A)
              .having((p0) => p0.dosis?.mg, 'dosis', null),
          isA<Medicine>()
              .having((p0) => p0.designation, 'designation', 'med2')
              .having((p0) => p0.color, 'color', null)
              .having((p0) => p0.dosis?.mg, 'dosis', 43),
          isA<Medicine>()
              .having((p0) => p0.designation, 'designation', 'med3')
              .having((p0) => p0.color, 'color', null)
              .having((p0) => p0.dosis?.mg, 'dosis', null),
        ]));
  });
  test('should mark medicines as deleted', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = MedicineRepositoryImpl(db.db);
    final med1 = mockMedicine(designation: 'med1', color: 0xFF226A, dosis: 42);
    await repo.add(med1);
    await repo
        .add(mockMedicine(designation: 'med2', color: 0xAF226B, dosis: 43));
    expect(await repo.getAll(), hasLength(2));
    await repo.remove(med1);
    expect(await repo.getAll(), hasLength(1));
  });
  test('should mark partial medicines as deleted', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = MedicineRepositoryImpl(db.db);
    final med1 = Medicine(
      designation: 'med1',
      color: 0xFF226A,
    );
    await repo.add(med1);
    final med2 = mockMedicine(designation: 'med2', dosis: 43);
    await repo.add(med2);
    final med3 = Medicine(
      designation: 'med3',
    );
    await repo.add(med3);
    expect(await repo.getAll(), hasLength(3));
    await repo.remove(med1);
    await repo.remove(med2);
    await repo.remove(med3);
    expect(await repo.getAll(), isEmpty);
  });
  test('notifies on changes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = MedicineRepositoryImpl(db.db);
    int calls = 0;
    repo.subscribe().listen((_) => calls++);
    final med1 = Medicine(
      designation: 'med1',
      color: 0xFF226A,
    );
    await repo.add(med1);
    expect(calls, 1);
    await repo.add(mockMedicine(designation: 'med2', dosis: 43));
    await repo.add(Medicine(designation: 'med3'));
    expect(calls, 3);
    await repo.remove(med1);
    expect(calls, 4);
  });
}
