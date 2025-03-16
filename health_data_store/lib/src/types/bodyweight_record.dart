import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_data_store/src/types/units/weight.dart';

part 'bodyweight_record.freezed.dart';

/// Body weight at a specific time.
@freezed
class BodyweightRecord with _$BodyweightRecord {
  /// Create a body weight measurement.
  const factory BodyweightRecord({
    /// Timestamp when the weight was measured.
    required DateTime time,

    /// Weight at [time].
    required Weight weight,
  }) = _BodyweightRecord;
}
