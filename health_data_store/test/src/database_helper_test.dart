
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
      final entry1 = await DBHelper.getEntryID(txn, 123);
      expect(entry1, 1);
      final entry2 = await DBHelper.getEntryID(txn, 124);
      expect(entry2, 2);
    });
  });
  test('should find existing entryID', () async {
    final db = await DatabaseManager.load(await openDatabase(
      inMemoryDatabasePath,
    ));
    addTearDown(db.close);
    await db.db.transaction((txn) async {
      final entry1 = await DBHelper.getEntryID(txn, 123);
      expect(entry1, 1);
      final entry1Again = await DBHelper.getEntryID(txn, 123);
      expect(entry1Again, 1);
    });
  });
}
