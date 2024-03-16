import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_range.freezed.dart';

/// Encapsulates a start and end [DateTime] that represent the range of dates.
///
/// The range includes the [start] and [end] dates. The [start] and [end] dates
/// may be equal to indicate a date range of a single day. The [start] date must
/// not be after the [end] date.
@freezed
class DateRange with _$DateRange {
  // ignore: unused_element,
  const DateRange._();

  /// Creates a date range for the given start and end [DateTime].
  const factory DateRange({
    /// The start of the range of dates.
    required DateTime start,
    /// The end of the range of dates.
    required DateTime end,
  }) = _DateRange;

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [DateTime.difference] for more details.
  Duration get duration => end.difference(start);
}
