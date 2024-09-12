import 'dart:async';

import 'package:health_data_store/health_data_store.dart';
import 'package:health_data_store/src/database_helper.dart';
import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';
import 'package:sqflite_common/sqflite.dart';

/// Implementation of repository for [BodyweightRecord]s.
class BodyweightRepositoryImpl extends BodyweightRepository {
  /// Create [BodyweightRecord] repository.
  BodyweightRepositoryImpl(this._db);

  final _controller = StreamController.broadcast();

  /// The [DatabaseManager] managed database.
  final Database _db;
  
  @override
  Future<void> add(BodyweightRecord record) async {
    _controller.add(null);
    await _db.transaction((txn) async {
      final entryID = await DBHelper.getEntryID(
        txn,
        record.time.secondsSinceEpoch,
      );
      await txn.delete('Weight', where: 'entryID = ?',
        whereArgs: [entryID],
      );
      await txn.insert('Weight', {
        'entryID': entryID,
        'weightKg': record.weight.kg,
      });
    });
  }

  @override
  Future<List<BodyweightRecord>> get(DateRange range) async {
    final results = await _db.rawQuery(
      'SELECT timestampUnixS, weightKg '
        'FROM Timestamps AS t '
        'INNER JOIN Weight AS w ON t.entryID = w.entryID '
      'WHERE timestampUnixS BETWEEN ? AND ?',
      [range.startStamp, range.endStamp]
    );
    return <BodyweightRecord>[
      for (final r in results)
        BodyweightRecord(
          time: DateTimeS.fromSecondsSinceEpoch(r['timestampUnixS'] as int),
          weight: Weight.kg(r['weightKg'] as double)
        ),
    ];
  }

  @override
  Future<void> remove(BodyweightRecord record) async {
    _controller.add(null);
    await _db.rawDelete(
      'DELETE FROM Weight WHERE entryID IN ('
        'SELECT entryID FROM Timestamps '
        'WHERE timestampUnixS = ?'
      ') AND weightKg = ?',
      [
        record.time.secondsSinceEpoch,
        record.weight.kg,
      ],
    );
  }

  @override
  Stream subscribe() => _controller.stream;

}
