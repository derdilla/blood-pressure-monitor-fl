
import 'package:sqflite_common/sqlite_api.dart';

/// Manager for the database.
/// 
/// Responsible for setting up the database and performing schema and version 
/// updates.
///
/// ## DB scheme
///
/// ![Diagram](https://github.com/NobodyForNothing/blood-pressure-monitor-fl/blob/main/docs/resources/db-scheme.png?raw=true)
///
/// ## Types
/// Data in the database tries to always use the most common SI-units.
/// Exceptions must be documented here.
/// - Timestamps are in seconds since unix epoch
/// - Color are integers in format 0xRRGGBB
/// - Pressure is in *kPa*
/// - Pulse is in bpm
/// - Weight is in kg
/// - Length is in meter
/// - Temperature is in kelvin
class DatabaseManager {
  DatabaseManager._create(this._db);

  /// Initialize the manager from a database.
  ///
  /// If [db] doesn't contain a scheme or contains an outdated scheme, one will
  /// be created.
  static Future<DatabaseManager> load(Database db, [bool isReadOnly = false]) async {
    final dbMngr = DatabaseManager._create(db);

    final tables = await dbMngr._db.query('"main".sqlite_master');
    if (tables.length <= 3 && !isReadOnly) {
      // DB has just been created, no version yet.
      await dbMngr._db.setVersion(2);
    }

    if (!isReadOnly && await dbMngr._db.getVersion() < 3) {
      await dbMngr._setUpTables();
      await dbMngr._db.setVersion(4);
    } else {
      await dbMngr._setupWeightTable(dbMngr._db);
      await dbMngr._db.setVersion(4);
    }
    // When updating the schema the update steps are maintained for ensured 
    // compatability.
    // TODO: develop strategy for loading older db versions as read only.
    return dbMngr;
  }

  final Database _db;

  /// Get the database.
  Database get db => _db.database;
  
  Future<void> _setUpTables() => _db.transaction((txn) async {
    await txn.execute('CREATE TABLE "Medicine" ('
      '"medID"       INTEGER NOT NULL UNIQUE,'
      '"designation" TEXT NOT NULL,'
      '"defaultDose" REAL,'
      '"color" INTEGER,'
      '"removed" BOOLEAN,'
      'PRIMARY KEY("medID")'
    ');');
    await txn.execute('CREATE TABLE "Timestamps" ('
      '"entryID"	      INTEGER NOT NULL UNIQUE,'
      '"timestampUnixS"	INTEGER NOT NULL,'
      'PRIMARY KEY("entryID")'
    ');');
    await txn.execute('CREATE TABLE "Intake" ('
      '"entryID" INTEGER NOT NULL,'
      '"medID"	 INTEGER NOT NULL,'
      '"dosis"	 REAL NOT NULL,'
      'PRIMARY KEY("entryID"),'
      'FOREIGN KEY("entryID") REFERENCES "Timestamps"("entryID"),'
      'FOREIGN KEY("medID") REFERENCES "Medicine"("medID")'
    ');');
    for (final info in [
      ('Systolic','sys'),
      ('Diastolic', 'dia'),
      // Pulse is stored as a double because bpm could be measured over
      // non one-minute intervalls which might be necessary to support in the
      // future.
      ('Pulse','pul'),
    ]) {
      await txn.execute('CREATE TABLE "${info.$1}" ('
        '"entryID"	    INTEGER NOT NULL,'
        '"${info.$2}"   REAL,'
        'FOREIGN KEY("entryID") REFERENCES "Timestamps"("entryID"),'
        'PRIMARY KEY("entryID")'
      ');');
    }
    await txn.execute('CREATE TABLE "Notes" ('
      '"entryID"	INTEGER NOT NULL,'
      '"note"     TEXT,'
      // When implementing attachments instead of updating this scheme note text
      // can be interpreted as markdown and support formatting as well as files.
      '"color"    INTEGER,'
      'FOREIGN KEY("entryID") REFERENCES "Timestamps"("entryID"),'
      'PRIMARY KEY("entryID")'
    ');');
    await _setupWeightTable(txn);
  });

  Future<void> _setupWeightTable(DatabaseExecutor executor) async {
    await executor.execute('CREATE TABLE "Weight" ('
      '"entryID"	    INTEGER NOT NULL,'
      '"weightMg"     REAL NOT NULL,'
      'FOREIGN KEY("entryID") REFERENCES "Timestamps"("entryID"),'
      'PRIMARY KEY("entryID")'
    ');');
  }

  /// Removes unused and deleted entries rows.
  ///
  /// Specifically:
  /// - medicines that are marked as deleted and have no referencing intakes
  /// - timestamp entries that have no
  Future<void> performCleanup() => _db.transaction((txn) async {
    // Remove medicines marked deleted with no remaining entries
    await txn.rawDelete('DELETE FROM Medicine '
      'WHERE removed = 1 '
      'AND medID NOT IN (SELECT medID FROM Intake);',
    );
    // Remove unused entry ids
    await txn.rawDelete('DELETE FROM Timestamps '
      'WHERE entryID NOT IN (SELECT entryID FROM Intake)'
      'AND entryID NOT IN (SELECT entryID FROM Systolic) '
      'AND entryID NOT IN (SELECT entryID FROM Diastolic) '
      'AND entryID NOT IN (SELECT entryID FROM Pulse) '
      'AND entryID NOT IN (SELECT entryID FROM Notes);',
    );
  });

  /// Closes the database.
  Future<void> close() => _db.close();
}
