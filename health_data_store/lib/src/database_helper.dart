
import 'package:sqflite_common/sqflite.dart';

/// Helper methods for database interaction to allow code reuse.
class DBHelper {
  DBHelper._();

  /// Get a entryID from the `Timestamps` table of a database.
  ///
  /// Ensures that the associated timestamp matches [timestampUnixS] and that
  /// it is used in no table with a name in [blockedTables]. Creates a entry
  /// when necessary
  static Future<int> getEntryID(
    Transaction txn,
    int timestampUnixS,
    List<String> blockedTables,
  ) async {
    var query = 'SELECT entryID FROM Timestamps WHERE timestampUnixS = ?';
    for (final t in blockedTables) {
      query += 'AND entryID NOT IN (SELECT entryID FROM $t)';
    }
    final existing = await txn.rawQuery(query, [timestampUnixS]);
    int entryID;
    if (existing.isEmpty) {
      final result = await txn.query('Timestamps',
        columns: ['MAX(entryID)']
      );
      final highestID = result.first['MAX(entryID)'] as int?;
      entryID = (highestID ?? 0) + 1;
      await txn.insert('Timestamps', {
        'entryID': entryID,
        'timestampUnixS': timestampUnixS,
      });
    } else {
      entryID = existing.first['entryID'] as int;
    }
    return entryID;
  }

  /// Querries all entryIDs between [startUnixS] and [endUnixS] (inclusive).
  static Future<List<int>> queryEntryIDs(
    Transaction txn,
    int startUnixS,
    int endUnixS,
  ) async { // TODO: consider removing, once unused
    final result = await txn.query('Timestamps',
      columns: ['entryID'],
      where: 'timestampUnixS BETWEEN ? AND ?',
      whereArgs: [startUnixS, endUnixS]
    );
    return result
      .map((e) => e['entryID'])
      .toList()
      .cast();
  }
}
