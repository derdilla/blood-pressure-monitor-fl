import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_data_store/src/types/units/weight.dart';

part 'bodyweight_record.freezed.dart';

/// Instance of entered body weight.
@freezed
class BodyweightRecord with _$BodyweightRecord {
  /// Create a instance of a body weight record.
  const factory BodyweightRecord({
    /// Timestamp when the weight was measured.
    required DateTime time,
    /// Current weight.
    required Weight weight,
  }) = _BodyweightRecord;
}
