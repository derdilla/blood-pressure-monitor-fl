import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_data_store/src/types/units/weight.dart';

part 'body_weight_record.freezed.dart';

/// Instance of entered body weight.
@freezed
class BodyWeightRecord with _$BodyWeightRecord {
  /// Create a instance of a body weight record.
  const factory BodyWeightRecord({
    /// Timestamp when the weight was measured.
    required DateTime time,
    /// Current weight.
    required Weight weight,
  }) = _BodyWeightRecord;
}
