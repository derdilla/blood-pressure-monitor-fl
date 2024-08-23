import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ConfigDB', () {
    setUpAll(() {
      sqfliteFfiInit();
      // Avoid warning in logs by avoiding `databaseFactory` setter
      databaseFactoryOrNull = databaseFactoryFfi;
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
      expect(tableNames.contains(ConfigDB.selectedIntervalStorageTable), true);
      expect(tableNames.contains(ConfigDB.exportColumnsTable), true);
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

  group('ConfigDAO', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactoryOrNull = databaseFactoryFfi;
    });

    test('should initialize', () async {
      final rawDB = await ConfigDB.open(dbPath: inMemoryDatabasePath, isFullPath: true);
      ConfigDao(rawDB);
    });
    test('should create classes when no data is present', () async {
      final rawDB = await ConfigDB.open(dbPath: inMemoryDatabasePath, isFullPath: true);
      final dao = ConfigDao(rawDB);

      expect((await dao.loadSettings(0)).toJson(), Settings().toJson());
      expect((await dao.loadExportSettings(0)).toJson(), ExportSettings().toJson());
      expect((await dao.loadCsvExportSettings(0)).toJson(), CsvExportSettings().toJson());
      expect((await dao.loadPdfExportSettings(0)).toJson(), PdfExportSettings().toJson());
      expect((await dao.loadIntervalStorage(0,0)).stepSize, IntervalStorage().stepSize);
      expect((await dao.loadExportColumnsManager(0)).userColumns, ExportColumnsManager().userColumns);
    });
    test('should save changes', () async {
      final rawDB = await ConfigDB.open(dbPath: inMemoryDatabasePath, isFullPath: true);
      final dao = ConfigDao(rawDB);

      final settings = await dao.loadSettings(0);
      settings.dateFormatString = 'Test string';
      settings.sysColor = Colors.deepOrange;
      settings.animationSpeed = 69;

      final initialSettingsJson = settings.toJson();
      settings.dispose();

      final newSettings = await dao.loadSettings(0);
      expect(newSettings.toJson(), initialSettingsJson);
    });
  });
}
