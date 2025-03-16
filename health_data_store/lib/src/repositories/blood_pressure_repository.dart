import 'package:health_data_store/src/database_manager.dart';
import 'package:health_data_store/src/repositories/repository.dart';
import 'package:health_data_store/src/types/blood_pressure_record.dart';

/// Repository for [BloodPressureRecord]s.
///
/// Provides high level access on [BloodPressureRecord]s saved in a
/// [DatabaseManager] managed database. Allows to store and query records.
abstract class BloodPressureRepository
    extends Repository<BloodPressureRecord> {}
