import 'package:health_data_store/health_data_store.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'database_manager_test.dart';
import 'types/blood_pressure_record_test.dart';

void main() {
 sqfliteTestInit();
 test('should initialize with new db', () async {
  final store = await HealthDataStore.load(
    await openDatabase(inMemoryDatabasePath));
  expect(store, isNotNull);
 });
 test('should construct repositories', () async {
  final store = await HealthDataStore.load(
      await openDatabase(inMemoryDatabasePath));
  expect(store, isNotNull);
  expect(() => store.medRepo, returnsNormally);
  expect(() => store.intakeRepo, returnsNormally);
  expect(() => store.bpRepo, returnsNormally);
  expect(() => store.noteRepo, returnsNormally);
 });
 test('constructed repos should work', () async {
  final store = await HealthDataStore.load(
      await openDatabase(inMemoryDatabasePath));
  expect(store, isNotNull);
  final bpRepo = store.bpRepo;
  final r = mockRecord(time: 10000, sys: 123, dia: 45, pul: 67);
  await bpRepo.add(r);
  final data = await bpRepo.get(DateRange(
    start: DateTime.fromMillisecondsSinceEpoch(5000),
    end: DateTime.fromMillisecondsSinceEpoch(20000),
  ));
  expect(data.length, 1);
  expect(data, contains(r));
 });
}
