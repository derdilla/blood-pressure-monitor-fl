import 'package:health_data_store/src/database_helper.dart';
import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';
import 'package:health_data_store/src/repositories/medicine_intake_repository.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/medicine_intake.dart';
import 'package:sqflite_common/sqflite.dart';

/// Implementation of a repository for [MedicineIntake]s.
///
/// Provides high level access on intakes saved in a [DatabaseManager] managed
/// database.
class MedicineIntakeRepositoryImpl extends MedicineIntakeRepository {
  /// Create a repository for medicine intakes.
  MedicineIntakeRepositoryImpl(this._db);

  /// The [DatabaseManager] managed database.
  final Database _db;

  @override
  Future<void> add(MedicineIntake intake) => _db.transaction((txn) async {
    // obtain medicine id
    final medIDRes = await txn.query('Medicine',
      columns: ['medID'],
      where: 'designation = ? '
          'AND color ' +((intake.medicine.color != null) ? '= ?' : 'IS NULL')
          + ' AND defaultDose ' +((intake.medicine.dosis != null) ? '= ?':'IS '
          'NULL'),
      whereArgs: [
        intake.medicine.designation,
        if (intake.medicine.color != null)
          intake.medicine.color,
        if (intake.medicine.dosis != null)
          intake.medicine.dosis,
      ],
    );
    assert(medIDRes.isNotEmpty);
    // Assuming intakes only contain medications that have been added
    final medID = medIDRes.first['medID'];

    // obtain free entry id
    final id = await DBHelper.getEntryID(
      txn, intake.time.secondsSinceEpoch,
      ['Intake'],
    );

    // store to db
    await txn.insert('Intake', {
      'entryID': id,
      'medID': medID,
      'dosis': intake.dosis,
    });
  });

  @override
  Future<List<MedicineIntake>> get(DateRange range) async {
    // TODO: change left join to join
    final results = await _db.rawQuery(
      'SELECT t.timestampUnixS, dosis, defaultDose, designation, color '
        'FROM Timestamps AS t '
        'LEFT JOIN Intake AS i ON t.entryID = i.entryID '
        'LEFT JOIN Medicine AS m ON m.medID = i.medID '
      'WHERE t.timestampUnixS BETWEEN ? AND ?'
      'AND i.dosis IS NOT NULL', // deleted intakes
      [range.startStamp, range.endStamp]
    );
    final intakes = <MedicineIntake>[];
    for (final r in results) {
      final timeS = r['timestampUnixS'] as int;
      intakes.add(MedicineIntake(
        time: DateTimeS.fromSecondsSinceEpoch(timeS),
        dosis: r['dosis'] as double,
        medicine: Medicine(
          designation: r['designation'] as String,
          dosis: r['defaultDose'] as double?,
          color: r['color'] as int?,
        ),
      ));
    }
    return intakes;
  }

  @override
  Future<void> remove(MedicineIntake intake) => _db.rawDelete(
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
      intake.dosis,
      intake.medicine.designation,
      if (intake.medicine.color != null)
        intake.medicine.color,
      if (intake.medicine.dosis != null)
        intake.medicine.dosis,
    ]
  );

}
