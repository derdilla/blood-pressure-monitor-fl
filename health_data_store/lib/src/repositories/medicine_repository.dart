import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/repositories/repository.dart';
import 'package:health_data_store/src/types/date_range.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:sqflite_common/sqflite.dart';

/// Repository for medicines that are taken by the user.
class MedicineRepository extends Repository<Medicine> {
  /// Create the medicine repository.
  MedicineRepository(this._db);

  /// The [DatabaseManager] managed database.
  final Database _db;

  @override
  Future<void> add(Medicine value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<List<Medicine>> get(DateRange range) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<void> remove(Medicine value) {
    // TODO: implement remove
    throw UnimplementedError();
  }

}
