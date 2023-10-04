import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// The config database has the following tables:
///
/// settings
/// profile_id INTEGER PRIMARY KEY, settings_json STRING
///
/// exportStrings
/// internalColumnName STRING PRIMARY KEY, columnTitle STRING, formatPattern STRING
class ConfigDB {
  ConfigDB._create();
  
  /// Name of the settings table.
  ///
  /// It is used to store json representations of [Settings] objects. Settings are saved as json, as there is no use
  /// case where accessing individual fields for SQLs logic and matching is needed and the complexity of maintaining
  /// different settings formats (export) is not worth it. Disk space doesn't play a role, as in most cases there will
  /// be only one entry in the table.
  ///
  /// Format:
  /// `CREATE TABLE settings(profile_id INTEGER PRIMARY KEY, settings_json STRING)`
  static const String settingsTable = 'settings';
  // instead of just changing this string when changing the format, _onDBUpgrade should be used.
  static const String _settingsTableCreationString =
      'CREATE TABLE settings(profile_id INTEGER PRIMARY KEY, settings_json STRING)';

  /// Name of the export settings table.
  ///
  /// It is used to store json representations of [ExportSettings] objects. Data is saved the same way as with
  /// [settingsTable]
  ///
  /// Format:
  /// `CREATE TABLE exportSettings(profile_id INTEGER PRIMARY KEY, json STRING)`
  static const String exportSettingsTable = 'exportSettings';
  static const String _exportSettingsTableCreationString =
      'CREATE TABLE exportSettings(profile_id INTEGER PRIMARY KEY, json STRING)';

  /// Name of the table for csv export settings.
  ///
  /// It is used to store json representations of [CsvExportSettings] objects. Data is saved the same way as with
  /// [settingsTable]
  ///
  /// Format:
  /// `CREATE TABLE exportCsvSettings(profile_id INTEGER PRIMARY KEY, json STRING)`
  static const String exportCsvSettingsTable = 'exportCsvSettings';
  static const String _exportCsvSettingsTableCreationString =
      'CREATE TABLE exportCsvSettings(profile_id INTEGER PRIMARY KEY, json STRING)';

  /// Name of the table for pdf export settings.
  ///
  /// It is used to store json representations of [PdfExportSettings] objects. Data is saved the same way as with
  /// [settingsTable]
  ///
  /// Format:
  /// `CREATE TABLE exportPdfSettings(profile_id INTEGER PRIMARY KEY, json STRING)`
  static const String exportPdfSettingsTable = 'exportPdfSettings';
  static const String _exportPdfSettingsTableCreationString =
      'CREATE TABLE exportPdfSettings(profile_id INTEGER PRIMARY KEY, json STRING)';

  /// Name of the table for storing time intervals to display.
  ///
  /// It is used to store json representations of [IntervallStorage] objects. Data is saved in as fields, to save space
  /// on the disk and because no changes in the data format are expected. The field names are made to match the variable
  /// names in the class.
  ///
  /// Note that this table has 2 keys: profile_key to support multiple profiles and storage_id to support saving
  /// multiple entries per profile (e.g. export screen and main page).
  ///
  /// Format: `CREATE TABLE selectedIntervallStorage(profile_id INTEGER, storage_id INTEGER, stepSize INTEGER,`
  /// ` start INTEGER, end INTEGER, PRIMARY KEY(profile_id, storage_id))`
  static const String selectedIntervallStorageTable = 'selectedIntervallStorage';
  static const String _selectedIntervallStorageCreationString = 'CREATE TABLE selectedIntervallStorage(profile_id '
      'INTEGER, storage_id INTEGER, stepSize INTEGER, start INTEGER, end INTEGER, '
      'PRIMARY KEY(profile_id, storage_id))';

  /// Name of the exportStrings table. It is used to store formats used in the [ExportConfigurationModel].
  ///
  /// Format:
  /// `CREATE TABLE exportStrings(internalColumnName STRING PRIMARY KEY, columnTitle STRING, formatPattern STRING)`
  static const String exportStringsTable = 'exportStrings';
  static const String _exportStringsTableCreationString =
      'CREATE TABLE exportStrings(internalColumnName STRING PRIMARY KEY, columnTitle STRING, formatPattern STRING)';

  late final Database _database;

  /// The meaning of the arguments is the same as in the create constructor.
  Future<void> _asyncInit(String? dbPath, bool isFullPath) async {
    dbPath ??= await getDatabasesPath();
    if (dbPath != inMemoryDatabasePath && !isFullPath) {
      dbPath = join(dbPath, 'config.db');
    }

    _database = await openDatabase(
      dbPath,
      onCreate: _onDBCreate,
      onUpgrade: _onDBUpgrade,
      // When increasing the version an update procedure from every other possible version is needed
      version: 2,
    );
  }

  FutureOr<void> _onDBCreate(Database db, int version) async {
    await db.execute(_exportStringsTableCreationString);
    await db.execute(_settingsTableCreationString);
    await db.execute(_exportSettingsTableCreationString);
    await db.execute(_exportCsvSettingsTableCreationString);
    await db.execute(_exportPdfSettingsTableCreationString);
    await db.execute(_selectedIntervallStorageCreationString);
  }

  FutureOr<void> _onDBUpgrade(Database db, int oldVersion, int newVersion) async {
    // When adding more versions the upgrade procedure proposed in https://stackoverflow.com/a/75153875/21489239
    // might be useful, to avoid duplicated code. Currently this would only lead to complexity, without benefits.
    if (oldVersion == 1 && newVersion == 2) {
      await db.execute(_settingsTableCreationString);
      await db.execute(_exportSettingsTableCreationString);
      await db.execute(_exportCsvSettingsTableCreationString);
      await db.execute(_exportPdfSettingsTableCreationString);
      await db.execute(_selectedIntervallStorageCreationString);
      await db.database.setVersion(2);
    } else {
      assert(false, 'Unexpected version upgrade from $oldVersion to $newVersion.');
    }
  }

  /// Factory method that either opens an existing db file or creates a new one if no file is present.
  ///
  /// [dbPath] is the path to the folder the database is in. When [dbPath] is left empty the default database file is
  /// used. The [isFullPath] option tells the constructor not to add the default filename at the end of [dbPath].
  static Future<ConfigDB> open({String? dbPath, bool isFullPath = false}) async {
    final instance = ConfigDB._create();
    await instance._asyncInit(dbPath, isFullPath);
    return instance;
  }

  Database get database => _database;
}
