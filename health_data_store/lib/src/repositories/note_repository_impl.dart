import 'dart:async';

import 'package:health_data_store/src/database_helper.dart';
import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';
import 'package:health_data_store/src/repositories/note_repository.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:health_data_store/src/types/note.dart';
import 'package:sqflite_common/sqflite.dart';

/// Implementation of repository for accessing [Note]s stored in a
/// [DatabaseManager] managed db.
class NoteRepositoryImpl extends NoteRepository {
  /// Create a repository for notes.
  NoteRepositoryImpl(this._db);

  final _controller = StreamController.broadcast();

  /// The [DatabaseManager] managed database.
  final Database _db;

  @override
  Future<void> add(Note note) async {
    _controller.add(null);
    if (note.note == null && note.color == null) {
      assert(false);
      return;
    }
    await _db.transaction((txn) async {
      final id = await DBHelper.getEntryID(
        txn, note.time.secondsSinceEpoch,
        ['Notes'],
      );
      await txn.insert('Notes', {
        'entryID': id,
        if (note.note != null)
          'note': note.note,
        if (note.color != null)
          'color': note.color,
      });
    });
  }

  @override
  Future<List<Note>> get(DateRange range) async {
    final result = await _db.rawQuery(
      'SELECT t.timestampUnixS AS time, note, color '
        'FROM Timestamps AS t '
        'JOIN Notes AS n ON t.entryID = n.entryID '
      'WHERE t.timestampUnixS BETWEEN ? AND ?'
      'AND (n.note IS NOT NULL OR n.color IS NOT NULL)', [
      range.startStamp,
      range.endStamp,
    ]
    );
    final notes = <Note>[];
    for (final row in result) {
      notes.add(Note(
        time: DateTimeS.fromSecondsSinceEpoch(row['time'] as int),
        note: row['note'] as String?,
        color: row['color'] as int?,
      ));
    }
    return notes;
  }

  @override
  Future<void> remove(Note value) {
    _controller.add(null);
    return _db.rawDelete(
    'DELETE FROM Notes WHERE entryID IN ('
      'SELECT entryID FROM Timestamps '
      'WHERE timestampUnixS = ?'
    ') AND note '
    + ((value.note == null) ? 'IS NULL' : '= ?')
    + ' AND color '
    + ((value.color == null) ? 'IS NULL' : '= ?'), [
   value.time.secondsSinceEpoch,
   if (value.note != null)
     value.note,
   if (value.color != null)
     value.color,
  ]);
  }

  @override
  Stream subscribe() => _controller.stream;
}
