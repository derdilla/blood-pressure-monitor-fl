import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/medicine_intake.dart';

/// Repository for medicines that are taken by the user.
abstract class MedicineRepository {

  /// Store a [Medicine] in the repository.
  Future<void> add(Medicine medicine);

  /// Get a list of all stored Medicines that haven't been marked as removed.
  Future<List<Medicine>> getAll();

  /// Mark a medicine as deleted.
  ///
  /// Intakes will be deleted as soon as there is no [MedicineIntake]s
  /// referencing them. They need to be stored to allow intakes of them to be
  /// still displayed correctly.
  Future<void> remove(Medicine value);

}
