
import 'package:freezed_annotation/freezed_annotation.dart';

part 'blood_pressure_record.freezed.dart';

/// Immutable representation of a blood pressure measurement.
@freezed
class BloodPressureRecord with _$BloodPressureRecord {
  /// Create a immutable representation of a blood pressure measurement.
  const factory BloodPressureRecord({
    /// Timestamp when the measurement was taken.
    required DateTime time,
    /// Systolic value of the measurement.
    int? sys,
    /// Diastolic value of the measurement.
    int? dia,
    /// Pulse value of the measurement.
    int? pul,
  }) = _BloodPressureRecord;
}
// TODO: create class for note and color/pin
