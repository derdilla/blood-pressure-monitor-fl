import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/repositories/blood_pressure_repository.dart';
import 'package:health_data_store/src/repositories/blood_pressure_repository_impl.dart';
import 'package:health_data_store/src/repositories/medicine_intake_repository.dart';
import 'package:health_data_store/src/repositories/medicine_intake_repository_impl.dart';
import 'package:health_data_store/src/repositories/medicine_repository.dart';
import 'package:health_data_store/src/repositories/medicine_repository_impl.dart';
import 'package:health_data_store/src/repositories/note_repository.dart';
import 'package:health_data_store/src/repositories/note_repository_impl.dart';
import 'package:sqflite_common/sqflite.dart';

/// Factory class for objects that provide access to the health database.
///
/// Ensures that the classes are instantiated for which the table schemes in the
/// db fit and creates ensures that the db schema is created and updated where
/// necessary.
class HealthDataStore {
  HealthDataStore._create(this._dbMngr);

  DatabaseManager _dbMngr;

  /// Initializes objects from [db].
  ///
  /// [db] must be exclusive to the package and will be initialized by it. The
  /// library maintains the version and is responsible for update operations.
  static Future<HealthDataStore?> load(Database db) async {
    if (!db.isOpen) return null;
    final mngr = await DatabaseManager.load(db);
    return HealthDataStore._create(mngr);
  }

  /// Repository for blood pressure data.
  BloodPressureRepository get bpRepo =>
    BloodPressureRepositoryImpl(_dbMngr.db);

  /// Repository for notes.
  NoteRepository get noteRepo =>
    NoteRepositoryImpl(_dbMngr.db);

  /// Repository for medicines.
  MedicineRepository get medRepo =>
    MedicineRepositoryImpl(_dbMngr.db);

  /// Repository for intakes.
  MedicineIntakeRepository get intakeRepo =>
    MedicineIntakeRepositoryImpl(_dbMngr.db);

  // TODO: test
}
