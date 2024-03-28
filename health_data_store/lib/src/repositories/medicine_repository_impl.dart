import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/castable.dart';
import 'package:health_data_store/src/repositories/medicine_repository.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:sqflite_common/sqflite.dart';

/// Implementation of repository for medicines that are taken by the user.
class MedicineRepositoryImpl extends MedicineRepository {
  /// Create the medicine repository.
  MedicineRepositoryImpl(this._db);

  /// The [DatabaseManager] managed database.
  final Database _db;

  @override
  Future<void> add(Medicine medicine) => _db.transaction((txn) async {
    final idRes = await txn.query('Medicine', columns: ['MAX(medID)']);
    final id = (idRes.firstOrNull?['MAX(medID)']?.castOrNull<int>() ?? 0) + 1;
    await txn.insert('Medicine', {
      'medID': id,
      'designation': medicine.designation,
      'defaultDose': medicine.dosis,
      'color': medicine.color,
      'removed': 0,
    });
  });

  @override
  Future<List<Medicine>> getAll() async {
    final medData = await _db.query('Medicine',
      columns: ['designation', 'defaultDose', 'color'],
      where: 'removed = false'
    );
    final meds = <Medicine>[];
    for (final m in medData) {
      meds.add(Medicine(
        designation: m['designation'].toString(),
        dosis: m['defaultDose'] as double?,
        color: m['color'] as int?,
      ));
    }

    return meds;
  }

  @override
  Future<void> remove(Medicine value) => _db.update('Medicine', {
      'removed': 1,
    },
    where: 'designation = ? AND color = ? AND defaultDose = ?',
    whereArgs: [
      value.designation,
      value.color,
      value.dosis,
    ], // TODO: test for null values
  );

}
