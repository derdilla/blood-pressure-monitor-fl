import 'dart:async';

import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/extensions/castable.dart';
import 'package:health_data_store/src/repositories/medicine_repository.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/units/weight.dart';
import 'package:sqflite_common/sqflite.dart';

/// Implementation of repository for medicines that are taken by the user.
class MedicineRepositoryImpl extends MedicineRepository {
  /// Create the medicine repository.
  MedicineRepositoryImpl(this._db);

  /// The [DatabaseManager] managed database.
  final Database _db;

  final _controller = StreamController.broadcast();

  @override
  Future<void> add(Medicine medicine) => _db.transaction((txn) async {
        final idRes = await txn.query('Medicine', columns: ['MAX(medID)']);
        final id =
            (idRes.firstOrNull?['MAX(medID)']?.castOrNull<int>() ?? 0) + 1;
        _controller.add(null);
        await txn.insert('Medicine', {
          'medID': id,
          'designation': medicine.designation,
          'defaultDose': medicine.dosis?.mg,
          'color': medicine.color,
          'removed': 0,
        });
      });

  @override
  Future<List<Medicine>> getAll() async {
    final medData = await _db.query('Medicine',
        columns: ['designation', 'defaultDose', 'color'], where: 'removed = 0');
    final meds = <Medicine>[];
    for (final m in medData) {
      meds.add(Medicine(
        designation: m['designation'].toString(),
        dosis: _decode(m['defaultDose']),
        color: m['color'] as int?,
      ));
    }

    return meds;
  }

  @override
  Future<void> remove(Medicine value) async {
    _controller.add(null);
    await _db.update(
      'Medicine',
      {
        'removed': 1,
      },
      where: 'designation = ? AND color ' +
          (value.color == null ? 'IS NULL' : '= ?') +
          ' AND defaultDose ' +
          (value.dosis == null ? 'IS NULL' : '= ?'),
      whereArgs: [
        value.designation,
        if (value.color != null) value.color,
        if (value.dosis != null) value.dosis!.mg,
      ],
    );
  }

  Weight? _decode(Object? value) {
    if (value is! double) return null;
    return Weight.mg(value);
  }

  @override
  @Deprecated('Medicines have no date. Use getAll directly')
  Future<List<Medicine>> get(DateRange _) => getAll();

  @override
  Stream subscribe() => _controller.stream;
}
