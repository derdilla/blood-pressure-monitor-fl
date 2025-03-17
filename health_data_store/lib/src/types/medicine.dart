import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_data_store/src/types/units/weight.dart';

part 'medicine.freezed.dart';

/// Description of a medicine.
@freezed
class Medicine with _$Medicine {
  /// Create a medicine description.
  const factory Medicine({
    /// Name of the medicine.
    required String designation,

    /// ARGB color in number format.
    ///
    /// Can also be obtained through the `Colors.toARGB32()` method in `dart:ui`.
    /// Sample value: `0xFF42A5F5`
    int? color,

    /// Default dosis of medication.
    Weight? dosis,
  }) = _Medicine;
}
