import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// The config database has the following tables:
///
/// settings
/// profile_id: INTEGER PRIMARY KEY, settings_json: STRING
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
  /// `CREATE TABLE settings(profile_id: INTEGER PRIMARY KEY, settings_json: STRING)`
  static const String settingsTable = 'settings';
  // instead of just changing this string when changing the format, _onDBUpgrade should be used.
  static const String _settingsTableCreationString =
      'CREATE TABLE settings(profile_id: INTEGER PRIMARY KEY, settings_json: STRING)';

  /// Name of the exportStrings table. It is used to store formats used in the [ExportConfigurationModel].
  ///
  /// Format:
  /// `CREATE TABLE exportStrings(internalColumnName STRING PRIMARY KEY, columnTitle STRING, formatPattern STRING)`
  static const String exportStringsTable = 'exportStrings';
  // instead of just changing this string when changing the format, _onDBUpgrade should be used.
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

  FutureOr<void> _onDBCreate(Database db, int version) {
    db.execute(_exportStringsTableCreationString);
    db.execute(_settingsTableCreationString);
  }

  FutureOr<void> _onDBUpgrade(Database db, int oldVersion, int newVersion) async {
    // When adding more versions the upgrade procedure proposed in https://stackoverflow.com/a/75153875/21489239
    // might be useful, to avoid duplicated code. Currently this would only lead to complexity, without benefits.
    if (oldVersion == 1 && newVersion == 2) {
      db.execute(_settingsTableCreationString);
      db.database.setVersion(2);
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
