
import 'package:sqflite_common/sqlite_api.dart';

/// Manager for the database.
/// 
/// Responsible for setting up the database and performing schema and version 
/// updates.
class DatabaseManager {
  DatabaseManager._create(this._db);

  /// Initialize the manager from a database.
  ///
  /// If [db] doesn't contain a scheme or contains an outdated scheme, one will
  /// be created.
  static Future<DatabaseManager> load(Database db) async {
    final dbMngr = DatabaseManager._create(db);

    if (await dbMngr._db.getVersion() < 3) {
      await dbMngr._setUpTables();
      await dbMngr._db.setVersion(3);
    }
    // When updating the schema the update steps are maintained for ensured 
    // compatability.
    
    return dbMngr;
  }

  final Database _db;

  /// Get the database.
  Database get db => _db.database;
  
  Future<void> _setUpTables() async {
    await _db.execute('CREATE TABLE "Medicine" ('
      '"medID"       INTEGER NOT NULL UNIQUE,'
      '"designation" TEXT NOT NULL,'
      '"defaultDose" REAL,'
      'PRIMARY KEY("medID")'
    ');');
    await _db.execute('CREATE TABLE "Timestamps" ('
      '"entryID"	      INTEGER NOT NULL UNIQUE,'
      '"timestampUnixS"	INTEGER NOT NULL,'
      'PRIMARY KEY("entryID")'
    ');');
    await _db.execute('CREATE TABLE "Intake" ('
      '"entryID" INTEGER NOT NULL,'
      '"medID"	 INTEGER NOT NULL,'
      '"dosis"	 INTEGER NOT NULL,'
      'PRIMARY KEY("entryID"),'
      'FOREIGN KEY("entryID") REFERENCES "Timestamps"("entryID"),'
      'FOREIGN KEY("medID") REFERENCES "Medicine"("medID")'
    ');');
    for (final info in [
      ('Systolic','sys'),
      ('Diastolic', 'dia'),
      ('Pulse','pul')
    ]) {
      await _db.execute('CREATE TABLE "${info.$1}" ('
        '"entryID"	INTEGER NOT NULL,'
        '"${info.$2}"    INTEGER,'
        'FOREIGN KEY("entryID") REFERENCES "Timestamps"("entryID"),'
        'PRIMARY KEY("entryID")'
      ');');
    }
    await _db.execute('CREATE TABLE "Notes" ('
      '"entryID"	INTEGER NOT NULL,'
      '"note"     TEXT,'
      '"color"    INTEGER,'
      'FOREIGN KEY("entryID") REFERENCES "Timestamps"("entryID"),'
      'PRIMARY KEY("entryID")'
    ');');
  }

  /// Closes the database.
  Future<void> close() => _db.close();
}
