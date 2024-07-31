
import 'package:sqflite_common/sqflite.dart';

/// Helper methods for database interaction to allow code reuse.
class DBHelper {
  DBHelper._();

  /// Get a entryID from the `Timestamps` table of a database.
  ///
  /// Ensures that the associated timestamp matches [timestampUnixS]. Creates a
  /// new id when necessary.
  static Future<int> getEntryID(
    Transaction txn,
    int timestampUnixS,
  ) async {
    final existing = await txn.rawQuery(
      'SELECT entryID FROM Timestamps WHERE timestampUnixS = ?',
      [timestampUnixS],
    );
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
}
