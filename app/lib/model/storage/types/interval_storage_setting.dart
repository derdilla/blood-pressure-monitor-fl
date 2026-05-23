import 'dart:convert';

import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/types/time_range.dart';
import 'package:blood_pressure_app/model/storage/types/time_step.dart';
import 'package:flutter/foundation.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:settings_annotation/settings_annotation.dart';

class IntervalStorageSetting extends DeepSetting<IntervalStorage> {
  IntervalStorageSetting(): super(initialValue: IntervalStorage());

  @override
  Object? toMapValue() => value.toJson();

  @override
  void fromMapValue(Object? value) => super.fromMapValue(IntervalStorage.fromJson(value as String));
}

/// Class for storing the current interval, as it is needed in start page, statistics and export.
class IntervalStorage extends ChangeNotifier {
  /// Create a storage to interact with a display intervall.
  IntervalStorage({
    TimeStep stepSize = TimeStep.last7Days,
    int directionalStep = 0,
    DateRange? customRange,
    TimeRange? timeRange,
  }) : _stepSize = stepSize,
        _directionalStep = directionalStep,
        _customRange = customRange,
        _timeRange = timeRange;

  /// Create a instance from a map created by [toMap].
  factory IntervalStorage.fromMap(Map<String, dynamic> map) => IntervalStorage(
      stepSize: TimeStep.deserialize(map['stepSize']),
      directionalStep: ConvertUtil.parseInt(map['directionalStep']) ?? 0,
      customRange: ConvertUtil.parseRange(map['customRangeStart'], map['customRangeEnd']),
      timeRange: TimeRange.fromJson(map['timeRange'] as Map<String, dynamic>?)
  );

  /// Create a instance from a [String] created by [toJson].
  factory IntervalStorage.fromJson(String json) {
    try {
      return IntervalStorage.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (exception) {
      return IntervalStorage();
    }
  }

  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'stepSize': stepSize.serialize(),
    'directionalStep': _directionalStep,
    'customRangeStart': _customRange?.start.millisecondsSinceEpoch,
    'customRangeEnd': _customRange?.end.millisecondsSinceEpoch,
    'timeRange': _timeRange?.toJson(),
  };

  String toJson() => jsonEncode(toMap());

  TimeStep _stepSize;

  DateRange? _customRange;

  int _directionalStep = 0;

  TimeRange? _timeRange;

  /// The range to use if [stepSize] is [TimeStep.custom]
  set customRange(DateRange newRange) {
    _customRange = newRange;
    notifyListeners();
  }

  /// The stepSize gets set through the changeStepSize method.
  TimeStep get stepSize => _stepSize;

  /// The [TimeRange] used to limit data selection if non-null.
  ///
  /// Data points must fall on or between the start and end times to be selected.
  TimeRange? get timeLimitRange => _timeRange;

  set timeLimitRange(TimeRange? value) {
    _timeRange = value;
    notifyListeners();
  }

  /// sets the stepSize to the new value and resets the currentRange to the most recent one.
  void changeStepSize(TimeStep value) {
    _directionalStep = 0;
    if (value == TimeStep.custom) _customRange ??= currentRange;
    _stepSize = value;
    notifyListeners();
  }

  DateRange get currentRange {
    final range = _getMostRecentDisplayIntervall();
    final oldStart = range.start;
    final oldEnd = range.end;
    return switch (stepSize) {
      TimeStep.day => DateRange(
        start: oldStart.copyWith(day: oldStart.day + _directionalStep),
        end: oldEnd.copyWith(day: oldEnd.day + _directionalStep),
      ),
      TimeStep.week || TimeStep.last7Days => DateRange(
        start: oldStart.copyWith(day: oldStart.day + 7 * _directionalStep),
        end: oldEnd.copyWith(day: oldEnd.day + 7 * _directionalStep),
      ),
      TimeStep.month => DateRange(
        // No fitting Duration: wraps correctly according to doc
        start: oldStart.copyWith(month: oldStart.month + _directionalStep),
        end: oldEnd.copyWith(month: oldEnd.month + _directionalStep),
      ),
      TimeStep.year => DateRange(
        // No fitting Duration: wraps correctly according to doc
        start: oldStart.copyWith(year: oldStart.year + _directionalStep),
        end: oldEnd.copyWith(year: oldEnd.year + _directionalStep),
      ),
      TimeStep.lifetime => DateRange.all(),
      TimeStep.last30Days => DateRange(
        start: oldStart.copyWith(day: oldStart.day + 30 * _directionalStep),
        end: oldEnd.copyWith(day: oldEnd.day + 30 * _directionalStep),
      ),
      TimeStep.custom => DateRange(
        start: oldStart.add(oldEnd.difference(oldStart) * _directionalStep),
        end: oldEnd.add(oldEnd.difference(oldStart) * _directionalStep),
      ),
    };
  }

  /// Resets any steps the user might have made.
  void setToMostRecentInterval() {
    _directionalStep = 0;
    notifyListeners();
  }

  void moveDataRangeByStep(int delta) {
    _directionalStep += delta;
    notifyListeners();
  }

  DateRange _getMostRecentDisplayIntervall() {
    final now = DateTime.now();
    switch (stepSize) {
      case TimeStep.day:
        final start = DateTime(now.year, now.month, now.day);
        return DateRange(start: start, end: start.copyWith(day: now.day + 1));
      case TimeStep.week:
        final start = DateTime(now.year, now.month, now.day - (now.weekday - 1)); // monday
        return DateRange(start: start, end: start.copyWith(day: start.day + DateTime.sunday)); // end of sunday
      case TimeStep.month:
        final start = DateTime(now.year, now.month);
        return DateRange(start: start, end: start.copyWith(month: now.month + 1));
      case TimeStep.year:
        final start = DateTime(now.year);
        return DateRange(start: start, end: start.copyWith(year: now.year + 1));
      case TimeStep.lifetime:
        final start = DateTime.fromMillisecondsSinceEpoch(1);
        final endOfToday = now.copyWith(hour: 23, minute: 59, second: 59);
        return DateRange(start: start, end: endOfToday);
      case TimeStep.last7Days:
        final start = now.subtract(const Duration(days: 7));
        final endOfToday = now.copyWith(hour: 23, minute: 59, second: 59);
        return DateRange(start: start, end: endOfToday);
      case TimeStep.last30Days:
        final start = now.subtract(const Duration(days: 30));
        final endOfToday = now.copyWith(hour: 23, minute: 59, second: 59);
        return DateRange(start: start, end: endOfToday);
      case TimeStep.custom:
      // Do nothing
        assert(_customRange != null);
        return _customRange ?? DateRange.all();
    }
  }
}
