import 'dart:async';

import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database for storing settings and internal app state.
///
/// The table names ensured by this class are stored as constant public strings ending in Table.
@deprecated
class ConfigDB {
  ConfigDB._create();
  
  /// Name of the settings table.
  ///
  /// It is used to store json representations of [Settings] objects. The json representation is chosen to allow editing
  /// and editing fields without changing the database structure and because there is no use case where accessing
  /// individual fields for SQLs logic and matching is needed and the complexity of maintaining different settings
  /// formats (export) is not worth it. Disk space doesn't play a role, as in most cases there will be only one entry in
  /// the table.
  ///
  /// Format:
  /// `CREATE TABLE settings(profile_id INTEGER PRIMARY KEY, settings_json STRING)`
  static const String settingsTable = 'settings';

  /// Name of the table for storing [ExportSettings] objects.
  ///
  /// Data is saved the same way as with [settingsTable].
  ///
  /// Format:
  /// `CREATE TABLE exportSettings(profile_id INTEGER PRIMARY KEY, json STRING)`
  static const String exportSettingsTable = 'exportSettings';

  /// Name of the table for storing [CsvExportSettings] objects.
  ///
  /// Data is saved the same way as with [settingsTable].
  ///
  /// Format:
  /// `CREATE TABLE exportCsvSettings(profile_id INTEGER PRIMARY KEY, json STRING)`
  static const String exportCsvSettingsTable = 'exportCsvSettings';

  /// Name of the table for storing [PdfExportSettings] objects.
  ///
  /// Data is saved the same way as with [settingsTable].
  ///
  /// Format:
  /// `CREATE TABLE exportPdfSettings(profile_id INTEGER PRIMARY KEY, json STRING)`
  static const String exportPdfSettingsTable = 'exportPdfSettings';

  /// Name of the table for storing time intervals to display.
  ///
  /// It is used to store json representations of [IntervalStorage] objects. Data is saved as fields, to save space
  /// on the disk and because no changes in the data format are expected. The field names are made to match the variable
  /// names in the class.
  ///
  /// Note that this table has 2 keys: profile_key to support multiple profiles and storage_id to support saving
  /// multiple entries per profile (e.g. export screen and main page).
  ///
  /// Format: `CREATE TABLE selectedIntervallStorage(profile_id INTEGER, storage_id INTEGER, stepSize INTEGER,`
  /// ` start INTEGER, end INTEGER, PRIMARY KEY(profile_id, storage_id))`
  static const String selectedIntervalStorageTable = 'selectedIntervallStorage';

  /// Name of the exportStrings table. It is used to to update old columns.
  ///
  /// Format:
  /// `CREATE TABLE exportStrings(internalColumnName STRING PRIMARY KEY, columnTitle STRING, formatPattern STRING)`
  @Deprecated('removed after all usages are replaced by export_columns_store')
  static const String exportStringsTable = 'exportStrings';

  /// Name of table of storing [ExportColumnsManager] objects
  ///
  /// Format:
  /// `CREATE TABLE exportColumns(profile_id INTEGER PRIMARY KEY, json STRING)`
  static const String exportColumnsTable = 'exportColumns';
  static const String _exportColumnsTableCreationString =
      'CREATE TABLE exportColumns(profile_id INTEGER PRIMARY KEY, json STRING)';

  late final Database _database;

  /// [dbPath] is the path to the folder the database is in. When [dbPath] is left empty the default database file is
  /// used. The [isFullPath] option tells the constructor not to add the default filename at the end of [dbPath].
  Future<bool> _asyncInit(String? dbPath, bool isFullPath) async {
    dbPath ??= await getDatabasesPath();
    if (dbPath != inMemoryDatabasePath && !isFullPath) {
      dbPath = join(dbPath, 'config.db');
    }
    bool dbTooOld = false;
    _database = await openDatabase(
      dbPath,
      onCreate: (_, __) => dbTooOld = true,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        assert(newVersion == 3);
        if (oldVersion == 1) {
          dbTooOld = true;
        } else if (oldVersion == 2) {
          await db.execute(_exportColumnsTableCreationString);
        } else {
          assert(false, 'Unexpected version upgrade from $oldVersion to $newVersion.');
        }
      },
      // When increasing the version an update procedure from every other possible version is needed
      version: 3,
      // In integration tests the file may be deleted which causes deadlocks.
      singleInstance: false,
    );
    return dbTooOld;// TODO: test
  }

  /// Factory method that either opens an existing db file or creates a new one if no file is present.
  ///
  /// [dbPath] is the path to the folder the database is in. When [dbPath] is left empty the default database file is
  /// used. The [isFullPath] option tells the constructor not to add the default filename at the end of [dbPath].
  static Future<ConfigDB?> open({String? dbPath, bool isFullPath = false}) async {
    final instance = ConfigDB._create();
    if(await instance._asyncInit(dbPath, isFullPath)) {
      return instance;
    }
    return null;
  }

  /// The database created by this class for getting and setting entries.
  ///
  /// Changes to the database structure should be done by altering the [_onDBCreate] and [_onDBUpgrade] methods of this
  /// class to ensure smooth upgrades without the possibility of error.
  Database get database => _database;
}
