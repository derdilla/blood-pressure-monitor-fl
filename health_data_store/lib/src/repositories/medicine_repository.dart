import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/medicine_intake.dart';
import 'package:sqflite_common/sqflite.dart';

/// Repository for medicines that are taken by the user.
class MedicineRepository {
  /// Create the medicine repository.
  MedicineRepository(this._db);

  /// The [DatabaseManager] managed database.
  final Database _db;

  /// Store a [Medicine] in the repository.
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

  /// Get a list of all stored Medicines that haven't been marked as removed.
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

  /// Mark a medicine as deleted.
  ///
  /// Intakes will be deleted as soon as there is no [MedicineIntake]s
  /// referencing them. They need to be stored to allow intakes of them to be
  /// still displayed correctly.
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

extension _Castable on Object {
  T? castOrNull<T>() {
    if (this is T) return this as T;
    return null;
  }
}
