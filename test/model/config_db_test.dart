import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ConfigDB', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('should initialize database without error', () async {
      final db = await ConfigDB.open(dbPath: inMemoryDatabasePath, isFullPath: true);
      expect(db.database.isOpen, true);
    });
    test('tables should exist', () async {
      final db = await ConfigDB.open(dbPath: inMemoryDatabasePath, isFullPath: true);
      final existingTables = await db.database.query('sqlite_master');
      final tableNames = existingTables.map((e) => e['name'] as String);

      expect(tableNames.contains(ConfigDB.settingsTable), true);
      expect(tableNames.contains(ConfigDB.exportSettingsTable), true);
      expect(tableNames.contains(ConfigDB.exportCsvSettingsTable), true);
      expect(tableNames.contains(ConfigDB.exportPdfSettingsTable), true);
      expect(tableNames.contains(ConfigDB.selectedIntervallStorageTable), true);
      expect(tableNames.contains(ConfigDB.exportStringsTable), true);
    });
    test('should save and load table entries', () async {
      final db = await ConfigDB.open(dbPath: inMemoryDatabasePath, isFullPath: true);
      await db.database.insert(ConfigDB.settingsTable, {'profile_id': 0, 'settings_json': '{"test": 123}'});
      final queriedData = await db.database.query(ConfigDB.settingsTable);
      expect(queriedData.length, 1);
      expect(queriedData[0]['profile_id'], 0);
      expect(queriedData[0]['settings_json'], '{"test": 123}');
    });
  });
}