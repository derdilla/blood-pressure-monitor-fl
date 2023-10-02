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
    db.execute(
        'CREATE TABLE exportStrings(internalColumnName STRING PRIMARY KEY, columnTitle STRING, formatPattern STRING)');
    db.execute('CREATE TABLE settings(profile_id: INTEGER PRIMARY KEY, settings_json: STRING)');
  }

  FutureOr<void> _onDBUpgrade(Database db, int oldVersion, int newVersion) async {
    // When adding more versions the upgrade procedure proposed in https://stackoverflow.com/a/75153875/21489239
    // might be useful, to avoid duplicated code. Currently this would only lead to complexity, without benefits.
    if (oldVersion == 1 && newVersion == 2) {
      db.execute('CREATE TABLE settings(profile_id: INTEGER PRIMARY KEY, settings_json: STRING)');
      db.database.setVersion(2);
    } else {
      assert(false, 'Unexpected version upgrade from $oldVersion to $newVersion.');
    }
  }

  /// Factory method that either opens an existing db file or creates a new one if no file is present.
  ///
  /// [dbPath] is the path to the folder the database is in. When [dbPath] is left empty the default database file is
  /// used. The [isFullPath] option tells the constructor not to add the default filename at the end of [dbPath].
  Future<ConfigDB> open({String? dbPath, bool isFullPath = false}) async {
    final instance = ConfigDB._create();
    await instance._asyncInit(dbPath, isFullPath);
    return instance;
  }

  Database get database => _database;
}
