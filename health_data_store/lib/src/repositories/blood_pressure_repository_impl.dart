import 'dart:async';

import 'package:health_data_store/src/database_helper.dart';
import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';
import 'package:health_data_store/src/repositories/blood_pressure_repository.dart';
import 'package:health_data_store/src/types/blood_pressure_record.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:health_data_store/src/types/units/pressure.dart';
import 'package:sqflite_common/sqflite.dart';

/// Implementation of repository for [BloodPressureRecord]s.
///
/// Provides high level access on [BloodPressureRecord]s saved in a
/// [DatabaseManager] managed database. Allows to store and query records.
class BloodPressureRepositoryImpl extends BloodPressureRepository {
  /// Create [BloodPressureRecord] repository.
  BloodPressureRepositoryImpl(this._db);

  final _controller = StreamController.broadcast();

  /// The [DatabaseManager] managed database
  final Database _db;

  @override
  Future<void> add(BloodPressureRecord record) async {
    _controller.add(null);
    assert(
        record.sys != null || record.dia != null || record.pul != null,
        "Adding records that don't contain values(sys,dia,pul) can't be accessed"
        'and should therefore not be added to the repository.');
    final timeSec = record.time.secondsSinceEpoch;
    await _db.transaction((txn) async {
      final entryID = await DBHelper.getEntryID(
        txn,
        timeSec,
      );
      if (record.sys != null) {
        await txn.delete(
          'Systolic',
          where: 'entryID = ?',
          whereArgs: [entryID],
        );
        await txn.insert('Systolic', {
          'entryID': entryID,
          'sys': record.sys!.kPa,
        });
      }
      if (record.dia != null) {
        await txn.delete(
          'Diastolic',
          where: 'entryID = ?',
          whereArgs: [entryID],
        );
        await txn.insert('Diastolic', {
          'entryID': entryID,
          'dia': record.dia!.kPa,
        });
      }
      if (record.pul != null) {
        await txn.delete(
          'Pulse',
          where: 'entryID = ?',
          whereArgs: [entryID],
        );
        await txn.insert('Pulse', {
          'entryID': entryID,
          'pul': record.pul,
        });
      }
    });
  }

  @override
  Future<List<BloodPressureRecord>> get(DateRange range) async {
    final results = await _db.rawQuery(
        'SELECT timestampUnixS, sys, dia, pul '
        'FROM Timestamps AS t '
        'LEFT JOIN Systolic AS s ON t.entryID = s.entryID '
        'LEFT JOIN Diastolic AS d ON t.entryID = d.entryID '
        'LEFT JOIN Pulse AS p ON t.entryID = p.entryID '
        'WHERE timestampUnixS BETWEEN ? AND ?',
        [range.startStamp, range.endStamp]);
    final records = <BloodPressureRecord>[];
    for (final r in results) {
      final timeS = r['timestampUnixS'] as int;
      final newRec = BloodPressureRecord(
        time: DateTimeS.fromSecondsSinceEpoch(timeS),
        sys: _decodePressure(r['sys']),
        dia: _decodePressure(r['dia']),
        pul: _decodeInt(r['pul']),
      );
      if (newRec.sys != null || newRec.dia != null || newRec.pul != null) {
        records.add(newRec);
      }
    }

    return records;
  }

  @override
  Future<void> remove(BloodPressureRecord value) =>
      _db.transaction((txn) async {
        _controller.add(null);
        String query = 'SELECT t.entryID FROM Timestamps AS t ';
        if (value.sys != null)
          query += 'LEFT JOIN Systolic AS s ON t.entryID = s.entryID ';
        if (value.dia != null)
          query += 'LEFT JOIN Diastolic AS d ON t.entryID = d.entryID ';
        if (value.pul != null)
          query += 'LEFT JOIN Pulse AS p ON t.entryID = p.entryID ';
        query += 'WHERE timestampUnixS = ? ';
        if (value.sys != null) query += 'AND sys = ? ';
        if (value.dia != null) query += 'AND dia = ? ';
        if (value.pul != null) query += 'AND pul = ? ';

        final entryResult = await txn.rawQuery(query, [
          value.time.secondsSinceEpoch,
          if (value.sys != null) value.sys!.kPa,
          if (value.dia != null) value.dia!.kPa,
          if (value.pul != null) value.pul,
        ]);
        if (entryResult.isEmpty) return;
        final entryID = entryResult.first['entryID'];
        if (value.sys != null)
          await txn
              .delete('Systolic', where: 'entryID = ?', whereArgs: [entryID]);
        if (value.dia != null)
          await txn
              .delete('Diastolic', where: 'entryID = ?', whereArgs: [entryID]);
        if (value.pul != null)
          await txn.delete('Pulse', where: 'entryID = ?', whereArgs: [entryID]);
      });

  Pressure? _decodePressure(Object? value) {
    if (value is! double) return null;
    return Pressure.kPa(value);
  }

  int? _decodeInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return null;
  }

  @override
  Stream subscribe() => _controller.stream;
}
