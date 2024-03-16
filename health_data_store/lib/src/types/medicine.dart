import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine.freezed.dart';

/// Description of a medicine.
@freezed
class Medicine with _$Medicine {
  /// Create a medicine description.
  const factory Medicine({
    /// Name of the medicine.
    required String designation,
    /// Additional data associated with this medicine.
    ///
    /// For example serialized colors or tags.
    String? data,
    /// Default dosis of medication.
    int? dosis,
  }) = _Medicine;
}
