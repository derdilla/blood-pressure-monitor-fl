import 'package:health_data_store/health_data_store.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'database_manager_test.dart';

void main() {
 sqfliteTestInit();
 test('should initialize with new db', () async {
  final store = await HealthDataStore.load(
    await openDatabase(inMemoryDatabasePath));
  expect(store, isNotNull);
 });
 // TODO: implement more tests
}
