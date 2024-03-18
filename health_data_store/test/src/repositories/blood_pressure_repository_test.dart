
import 'package:health_data_store/health_data_store.dart';
import 'package:health_data_store/src/repositories/blood_pressure_repository.dart';
import 'package:test/test.dart';

import '../database_manager_test.dart';
import '../types/blood_pressure_record_test.dart';

void main() {
  sqfliteTestInit();
  test('should initialize', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    BloodPressureRepository(db.db);
  });
  test('should store records without errors', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepository(db.db);
    await repo.add(mockRecord(sys: 123, dia: 456, pul: 789));
    await repo.add(mockRecord(sys: 123, pul: 789));
    await repo.add(mockRecord(sys: 123));
    expect(() async => repo.add(mockRecord()), throwsA(isA<AssertionError>()));
  });
  test('should return stored records', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepository(db.db);
    final r1 = mockRecord(time: 50000, sys: 123);
    final r2 = mockRecord(time: 80000, sys: 456, dia: 457, pul: 458);
    final r3 = mockRecord(time: 20000, sys: 788, pul: 789);
    await repo.add(r1);
    await repo.add(r2);
    await repo.add(r3);

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(20000),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values, hasLength(3));
    expect(values, containsAll([r1,r2,r3]));
  });
}
