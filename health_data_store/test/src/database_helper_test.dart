
import 'package:health_data_store/src/database_helper.dart';
import 'package:health_data_store/src/database_manager.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:test/test.dart';

import 'database_manager_test.dart';

void main() {
  sqfliteTestInit();
  test('should find new entryID', () async {
    final db = await DatabaseManager.load(await openDatabase(
      inMemoryDatabasePath,
    ));
    addTearDown(db.close);
    await db.db.transaction((txn) async {
      final entry1 = await DBHelper.getEntryID(txn, 123, []);
      expect(entry1, 1);
      final entry2 = await DBHelper.getEntryID(txn, 124, []);
      expect(entry2, 2);
    });
  });
  test('should find existing entryID', () async {
    final db = await DatabaseManager.load(await openDatabase(
      inMemoryDatabasePath,
    ));
    addTearDown(db.close);
    await db.db.transaction((txn) async {
      final entry1 = await DBHelper.getEntryID(txn, 123, []);
      expect(entry1, 1);
      final entry1Again = await DBHelper.getEntryID(txn, 123, []);
      expect(entry1Again, 1);
    });
  });
  test('should find existing entryID with constraints', () async {
    final db = await DatabaseManager.load(await openDatabase(
      inMemoryDatabasePath,
    ));
    addTearDown(db.close);
    await db.db.transaction((txn) async {
      final entry1 = await DBHelper.getEntryID(txn, 123, []);
      expect(entry1, 1);
      final entry1Again = await DBHelper.getEntryID(txn, 123, ['Systolic']);
      expect(entry1Again, 1);
    });
  });
  test('should find respect constraints when finding entryID', () async {
    final db = await DatabaseManager.load(await openDatabase(
      inMemoryDatabasePath,
    ));
    addTearDown(db.close);
    await db.db.transaction((txn) async {
      final entry1 = await DBHelper.getEntryID(txn, 123, []);
      expect(entry1, 1);
      await txn.insert('Systolic', {
        'entryID': entry1,
        'value': 1,
      });
      final anotherEntry = await DBHelper.getEntryID(txn, 123, ['Systolic']);
      expect(anotherEntry, 2);
    });
  });
  test('should query entry ids in range', () async {
    final db = await DatabaseManager.load(await openDatabase(
      inMemoryDatabasePath,
    ));
    addTearDown(db.close);
    await db.db.transaction((txn) async {
      await DBHelper.getEntryID(txn, 123, []);
      await DBHelper.getEntryID(txn, 456, []);
      await DBHelper.getEntryID(txn, 789, []);
      expect(await DBHelper.queryEntryIDs(txn, 100, 800), hasLength(3));
      expect(await DBHelper.queryEntryIDs(txn, 0, 100), hasLength(0));
      expect(await DBHelper.queryEntryIDs(txn, -800, -100), hasLength(0));
      expect(await DBHelper.queryEntryIDs(txn, 400, 800), containsAll([2,3]));
    });
  });
}
