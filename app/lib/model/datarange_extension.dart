import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';

/// Allow converting to custom [DateRange] implementation.
extension DateRangeCompat on DateTimeRange {
  /// Convert to [DateRange].
  DateRange get dateRange => DateRange(start: start, end: end);
}
