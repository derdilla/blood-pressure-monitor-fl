import 'dart:async';

import 'package:health_data_store/src/repositories/bodyweight_repository_impl.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:test/test.dart';

import '../database_manager_test.dart';
import '../types/bodyweight_record_test.dart';

void main() {
  sqfliteTestInit();
  test('should initialize', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    BodyweightRepositoryImpl(db.db);
  });
  test('returns stored records', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BodyweightRepositoryImpl(db.db);
    final r1 = mockWeight(time: 123456000, kg: 123.456);
    final r2 = mockWeight(time: 1234567000, kg: 0.456);
    await repo.add(r1);
    await repo.add(r2);

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(123450000),
      end: DateTime.fromMillisecondsSinceEpoch(1234570000),
    ));
    expect(values, hasLength(2));
    expect(values, containsAll([r1,r2]));
  });
  test('removes records', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BodyweightRepositoryImpl(db.db);
    final r1 = mockWeight(time: 123456000, kg: 123.456);

    await repo.add(r1);
    final values1 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(123450000),
      end: DateTime.fromMillisecondsSinceEpoch(1234570000),
    ));
    expect(values1, hasLength(1));

    await repo.remove(r1);
    final values2 = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(123450000),
      end: DateTime.fromMillisecondsSinceEpoch(1234570000),
    ));
    expect(values2, isEmpty);
  });
  test('overrides when inserting multiple records are at same time', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BodyweightRepositoryImpl(db.db);
    final r1 = mockWeight(time: 123456000, kg: 1.0);
    final r2 = mockWeight(time: 123456000, kg: 2.0);
    await repo.add(r1);
    await repo.add(r2);

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(123450000),
      end: DateTime.fromMillisecondsSinceEpoch(1234570000),
    ));
    expect(values, hasLength(1));
    expect(values, containsAll([r2]));
  });
  test("doesn't throw when removing non existent record", () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BodyweightRepositoryImpl(db.db);
    final r1 = mockWeight(time: 123456000, kg: 1.0);

    await repo.remove(r1);
    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.fromMillisecondsSinceEpoch(123457000),
    ));
    expect(values, isEmpty);
  });
  test("doesn't return records out of range", () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    final repo = BodyweightRepositoryImpl(db.db);
    final r1 = mockWeight(time: 10000, kg: 1.0);
    await repo.add(r1);

    final values = await repo.get(DateRange(
      start: DateTime.fromMillisecondsSinceEpoch(20000),
      end: DateTime.fromMillisecondsSinceEpoch(80000),
    ));
    expect(values, isEmpty);
  });
  test('emits stream events on changes', () async {
    final db = await mockDBManager();
    addTearDown(db.close);
    int notifyCount = 0;

    final repo = BodyweightRepositoryImpl(db.db);
    unawaited(repo.subscribe().forEach((_) => notifyCount++));
    final r = mockWeight(time: 10000, kg: 1.0);
    expect(notifyCount, 0);

    await repo.add(r);
    expect(notifyCount, 1);

    await repo.add(mockWeight(time: 20000, kg: 2.0));
    expect(notifyCount, 2);

    await repo.remove(r);
    expect(notifyCount, 3);
  }, timeout: const Timeout(Duration(seconds: 5)));
}
