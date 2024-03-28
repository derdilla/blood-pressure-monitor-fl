
import 'package:health_data_store/health_data_store.dart';
import 'package:test/test.dart';

import '../database_manager_test.dart';
import '../types/medicine_intake_test.dart';
import '../types/medicine_test.dart';

void main() {
  sqfliteTestInit();
  test('should initialize', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    MedicineIntakeRepository(db.db);
  });
  test('should store intakes without errors', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final med1 = mockMedicine(designation: 'med1', dosis: 2.4);
    final med2 = mockMedicine(designation: 'med2',);
    final medRepo = MedicineRepository(db.db);
    await medRepo.add(med1);
    await medRepo.add(med2);

    final repo = MedicineIntakeRepository(db.db);
    await repo.add(mockIntake(med1));
    await repo.add(mockIntake(med2));
    await repo.add(mockIntake(med1, dosis: 123));
    // This medicine is not added to med repo
    expect(() async => repo.add(mockIntake(mockMedicine())),
        throwsA(isA<AssertionError>()));
  });
  test('should return stored intakes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final med1 = mockMedicine(dosis: 2.4);
    final med2 = mockMedicine();
    final medRepo = MedicineRepository(db.db);
    await medRepo.add(med1);
    await medRepo.add(med2);

    final repo = MedicineIntakeRepository(db.db);
    final t1 = mockIntake(med1, time: 20000);
    final t2 = mockIntake(med2, time: 76000);
    final t3 = mockIntake(med1, dosis: 123, time: 50000,);
    await repo.add(t1);
    await repo.add(t2);
    await repo.add(t3);
    await repo.add(mockIntake(med1));

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(20000),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values, hasLength(3));
    expect(values, containsAll([t1, t2, t3,]));
  });
  test('should remove intakes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final medRepo = MedicineRepository(db.db);
    final med = mockMedicine();
    await medRepo.add(med);
    final repo = MedicineIntakeRepository(db.db);
    final i1 = mockIntake(med, time: 5000);
    await repo.add(i1);

    final values1 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(10000),
    ));
    expect(values1, hasLength(1));
    expect(values1, contains(i1));

    await repo.remove(i1);
    final values2 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(10000),
    ));
    expect(values2, isEmpty);
  });
  test('should remove correct intake when multiple are at same time', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = MedicineIntakeRepository(db.db);
    final medRepo = MedicineRepository(db.db);
    final med = mockMedicine();
    await medRepo.add(med);
    final i1 = mockIntake(med, time: 10000);
    final i2 = mockIntake(med, time: 10000, dosis: 458);
    await repo.add(i1);
    await repo.add(i2);

    await repo.remove(i1);
    final values2 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values2, hasLength(1));
    expect(values2, contains(i2));
  });
  test('should not throw when removing non existent record', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final medRepo = MedicineRepository(db.db);
    final med = mockMedicine();
    await medRepo.add(med);
    final repo = MedicineIntakeRepository(db.db);
    final i1 = mockIntake(med);

    await repo.remove(i1);
    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values, isEmpty);
  });
}
