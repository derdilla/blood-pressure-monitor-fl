import 'dart:async';

import 'package:health_data_store/src/repositories/blood_pressure_repository_impl.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:test/test.dart';

import '../database_manager_test.dart';
import '../types/blood_pressure_record_test.dart';

void main() {
  sqfliteTestInit();
  test('should initialize', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    BloodPressureRepositoryImpl(db.db);
  });
  test('should store records without errors', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepositoryImpl(db.db);
    await repo.add(mockRecord(sys: 123, dia: 456, pul: 789));
    await repo.add(mockRecord(sys: 123, pul: 789));
    await repo.add(mockRecord(sys: 123));
    expect(() async => repo.add(mockRecord()), throwsA(isA<AssertionError>()));
  });
  test('should return stored records', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepositoryImpl(db.db);
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
    expect(values, containsAll([r1, r2, r3]));
  });
  test('should remove records', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepositoryImpl(db.db);
    final r1 = mockRecord(time: 10000, sys: 456, dia: 457, pul: 458);
    await repo.add(r1);

    final values1 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values1, hasLength(1));
    expect(values1, contains(r1));

    await repo.remove(r1);
    final values2 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values2, isEmpty);
  });
  test('should remove partial records', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepositoryImpl(db.db);
    final r1 = mockRecord(time: 10000, sys: 456, dia: 457, pul: 458);
    final r2 = mockRecord(time: 20000, sys: 123);
    final r3 = mockRecord(time: 30000, sys: 788, pul: 789);
    await repo.add(r1);
    await repo.add(r2);
    await repo.add(r3);

    final values0 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values0, hasLength(3));
    expect(values0, containsAll([r1, r2, r3]));

    await repo.remove(r1);
    final values1 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values1, hasLength(2));
    expect(values1, containsAll([r2, r3]));

    await repo.remove(r2);
    final values2 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values2, hasLength(1));
    expect(values2, containsAll([r3]));

    await repo.remove(r3);
    final values3 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values3, isEmpty);
  });
  test('overrides when inserting multiple records are at same time', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepositoryImpl(db.db);
    final r1 = mockRecord(time: 10000, sys: 456, dia: 457, pul: 458);
    final r2 = mockRecord(time: 10000, sys: 678, dia: 457, pul: 458);
    await repo.add(r1);
    await repo.add(r2);
    final values2 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values2, hasLength(1));
    expect(values2, contains(r2));
  });
  test('should not throw when removing non existent record', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepositoryImpl(db.db);
    final r1 = mockRecord(time: 10000, sys: 456, dia: 457, pul: 458);

    await repo.remove(r1);
    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values, isEmpty);
  });
  test('should not return records out of range', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BloodPressureRepositoryImpl(db.db);
    final r1 = mockRecord(time: 10000, sys: 456, dia: 457, pul: 458);
    await repo.add(r1);

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(20000),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values, isEmpty);
  });
  test('should emit stream events on changes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);

    int notifyCount = 0;

    final repo = BloodPressureRepositoryImpl(db.db);
    unawaited(repo.subscribe().forEach((_) => notifyCount++));
    final r = mockRecord(time: 10000, sys: 456, dia: 457, pul: 458);
    expect(notifyCount, 0);
    await repo.add(r);
    expect(notifyCount, 1);
    await repo.add(mockRecord(time: 20000, sys: 123));
    expect(notifyCount, 2);
    await repo.add(mockRecord(time: 30000, sys: 788, pul: 789));
    expect(notifyCount, 3);
    await repo.remove(r);
    expect(notifyCount, 4);
  });
}
