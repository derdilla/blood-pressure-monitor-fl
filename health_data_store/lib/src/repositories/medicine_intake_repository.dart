import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/repositories/repository.dart';
import 'package:health_data_store/src/types/medicine_intake.dart';

/// Repository for [MedicineIntake]s.
///
/// Provides high level access on intakes saved in a [DatabaseManager] managed
/// database.
abstract class MedicineIntakeRepository extends Repository<MedicineIntake> {}
