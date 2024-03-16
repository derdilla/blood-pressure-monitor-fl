
import 'package:sqflite_common/sqflite.dart';

// TODO: document once finished
abstract class HealthDataStore {

  const HealthDataStore._create();

  /// Initializes objects from [db].
  ///
  /// [db] must be exclusive to the package and will be initialized by it.
  static Future<HealthDataStore?> load(Database db) async {
    if (!db.isOpen) return null;
    // TODO
    throw UnimplementedError();
  }

  // TODO: Future<BloodPressureRepository> getBloodPressureRepository();
  // ...

}
