import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:health_data_store/src/extensions/datetime_seconds.dart';

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
  @Assert('end.isAfter(start)')
  factory DateRange({
    /// The start of the range of dates.
    required DateTime start,

    /// The end of the range of dates.
    required DateTime end,
  }) = _DateRange;

  /// Creates a date range from unix epoch to now.
  factory DateRange.all() => DateRange(
        start: DateTime.fromMillisecondsSinceEpoch(0),
        end: DateTime.now(),
      );

  /// Returns a [Duration] of the time between [start] and [end].
  ///
  /// See [DateTime.difference] for more details.
  Duration get duration => end.difference(start);

  /// Gets the [start] timestamp in seconds since epoch.
  int get startStamp => start.secondsSinceEpoch;

  /// Gets the [end] timestamp in seconds since epoch.
  int get endStamp => end.secondsSinceEpoch;
}
