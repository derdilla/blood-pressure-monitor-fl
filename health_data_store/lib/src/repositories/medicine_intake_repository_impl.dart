import 'dart:async';

import 'package:health_data_store/src/database_helper.dart';
import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';
import 'package:health_data_store/src/repositories/medicine_intake_repository.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/medicine_intake.dart';
import 'package:health_data_store/src/types/units/weight.dart';
import 'package:sqflite_common/sqflite.dart';

/// Implementation of a repository for [MedicineIntake]s.
///
/// Provides high level access on intakes saved in a [DatabaseManager] managed
/// database.
class MedicineIntakeRepositoryImpl extends MedicineIntakeRepository {
  /// Create a repository for medicine intakes.
  MedicineIntakeRepositoryImpl(this._db);

  final _controller = StreamController.broadcast();

  /// The [DatabaseManager] managed database.
  final Database _db;

  @override
  Future<void> add(MedicineIntake intake) => _db.transaction((txn) async {
    _controller.add(null);
    // obtain medicine id
    final medIDRes = await txn.query('Medicine',
      columns: ['medID'],
      where: 'designation = ? '
          'AND color ' + ((intake.medicine.color != null) ? '= ?' : 'IS NULL')
          + ' AND defaultDose ' + ((intake.medicine.dosis != null) ? '= ?':'IS '
          'NULL'),
      whereArgs: [
        intake.medicine.designation,
        if (intake.medicine.color != null)
          intake.medicine.color,
        if (intake.medicine.dosis != null)
          intake.medicine.dosis!.mg,
      ],
    );
    assert(medIDRes.isNotEmpty);
    // Assuming intakes only contain medications that have been added
    final medID = medIDRes.first['medID'];

    // obtain free entry id
    final id = await DBHelper.getEntryID(txn, intake.time.secondsSinceEpoch);
    await txn.delete('Intake', where: 'entryID = ?', whereArgs: [id]);

    // store to db
    await txn.insert('Intake', {
      'entryID': id,
      'medID': medID,
      'dosis': intake.dosis.mg,
    });
  });

  @override
  Future<List<MedicineIntake>> get(DateRange range) async {
    final results = await _db.rawQuery(
      'SELECT t.timestampUnixS, dosis, defaultDose, designation, color '
        'FROM Timestamps AS t '
        'JOIN Intake AS i ON t.entryID = i.entryID '
        'JOIN Medicine AS m ON m.medID = i.medID '
      'WHERE t.timestampUnixS BETWEEN ? AND ?'
      'AND i.dosis IS NOT NULL', // deleted intakes
      [range.startStamp, range.endStamp]
    );
    final intakes = <MedicineIntake>[];
    for (final r in results) {
      final timeS = r['timestampUnixS'] as int;
      intakes.add(MedicineIntake(
        time: DateTimeS.fromSecondsSinceEpoch(timeS),
        dosis: _decode(r['dosis'])!,
        medicine: Medicine(
          designation: r['designation'] as String,
          dosis: _decode(r['defaultDose']),
          color: r['color'] as int?,
        ),
      ));
    }
    return intakes;
  }

  @override
  Future<void> remove(MedicineIntake intake) {
    _controller.add(null);
    return _db.rawDelete(
      'DELETE FROM Intake WHERE entryID IN ('
        'SELECT entryID FROM Timestamps '
        'WHERE timestampUnixS = ?'
      ') AND dosis = ? '
      'AND medID IN ('
        'SELECT medID FROM Medicine '
        'WHERE designation = ?'
        'AND color '
          + ((intake.medicine.color != null) ? '= ?' : 'IS NULL') +
        ' AND defaultDose '
          + ((intake.medicine.dosis != null) ? '= ?' : 'IS NULL') +
      ')',
      [
        intake.time.secondsSinceEpoch,
        intake.dosis.mg,
        intake.medicine.designation,
        if (intake.medicine.color != null)
          intake.medicine.color,
        if (intake.medicine.dosis != null)
          intake.medicine.dosis?.mg,
      ]
    );
  }

  Weight? _decode(Object? value) {
    if (value is! double) return null;
    return Weight.mg(value);
  }

  @override
  Stream subscribe() => _controller.stream;

}
