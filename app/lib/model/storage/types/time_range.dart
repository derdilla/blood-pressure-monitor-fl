import 'package:flutter/material.dart';

/// Represents an inclusive time span, defined by a [start] and an [end]
/// [TimeOfDay].
///
/// **Serialization:**
/// The class serializes the [TimeOfDay] objects into simple string representations
/// of their hour and minute values (e.g., '14:30' for 2:30 PM).
class TimeRange {
  /// Creates a new [TimeRange] with a specified [start] and [end] time.
  const TimeRange({
    required this.start,
    required this.end,
  });

  /// The starting time of the range (inclusive).
  final TimeOfDay start;

  /// The ending time of the range (inclusive).
  final TimeOfDay end;

  /// Serialization to JSON-compatible map
  Map<String, dynamic> toJson() => {
    'start': _timeOfDayToString(start),
    'end': _timeOfDayToString(end),
  };

  /// Creates a [TimeRange] instance from a JSON map.
  ///
  /// Returns `null` if the input map is null or if the required keys ('start', 'end')
  /// are missing or contain invalid time strings.
  static TimeRange? fromJson(Map<String, dynamic>? json) {
    if (json == null || json['start'] is! String || json['end'] is! String) {
      return null;
    }

    try {
      final start = _timeOfDayFromString(json['start'] as String);
      final end = _timeOfDayFromString(json['end'] as String);
      return TimeRange(start: start, end: end);
    } catch (_) {
      // Return null on parsing errors (e.g., non-numeric parts)
      return null;
    }
  }

  /// Converts a TimeOfDay to 'HH:MM' string.
  static String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Converts an 'HH:MM' string back to a TimeOfDay.
  static TimeOfDay _timeOfDayFromString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
