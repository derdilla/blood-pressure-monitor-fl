import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_data_store/src/types/medicine.dart';
import 'package:health_data_store/src/types/units/weight.dart';

part 'medicine_intake.freezed.dart';

/// Instance of a [Medicine] intake.
@freezed
class MedicineIntake with _$MedicineIntake {
  /// Create a instance of a medicine intake.
  const factory MedicineIntake({
    /// Timestamp when the medicine was taken.
    required DateTime time,
    /// Description of the taken medicine.
    required Medicine medicine,
    /// Amount of medicine taken.
    ///
    /// When the medication has a default value, this must be set to that value,
    /// as it may change.
    required Weight dosis,
  }) = _MedicineIntake;
}
