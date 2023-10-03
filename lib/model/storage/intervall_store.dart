import 'dart:convert';

import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class for storing the current interval, as it is needed in start page, statistics and export.
class IntervallStorage extends ChangeNotifier {
  IntervallStorage({TimeStep? stepSize, DateTimeRange? range}) {
    _stepSize = stepSize ?? TimeStep.last7Days;
    _currentRange = range ?? _getMostRecentDisplayIntervall();
  }
   //TODO: add to database
  late TimeStep _stepSize;
  late DateTimeRange _currentRange;

  factory IntervallStorage.fromMap(Map<String, dynamic> map) => IntervallStorage(
    stepSize: TimeStep.deserialize(map['stepSize']),
    range: ConvertUtil.parseRange(map['start'], map['end']),
  );

  factory IntervallStorage.fromJson(String json) {
    try {
      return IntervallStorage.fromMap(jsonDecode(json));
    } catch (exception) {
      return IntervallStorage();
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'stepSize': stepSize.serialize(),
    'start': currentRange.start.millisecondsSinceEpoch,
    'end': currentRange.end.millisecondsSinceEpoch,
  };

  String toJson() => jsonEncode(toMap());

  /// The stepSize gets set through the changeStepSize method.
  TimeStep get stepSize => _stepSize;

  /// sets the stepSize to the new value and resets the currentRange to the most recent one. 
  void changeStepSize(TimeStep value) {
    _stepSize = value;
    setToMostRecentIntervall();
    notifyListeners();
  }

  DateTimeRange get currentRange {
    return _currentRange;
  }

  set currentRange(DateTimeRange value) {
    _currentRange = value;
    notifyListeners();
  }

  /// Sets internal _currentRange to the most recent intervall and notifies listeners.
  void setToMostRecentIntervall() {
    _currentRange = _getMostRecentDisplayIntervall();
    notifyListeners();
  }

  void moveDataRangeByStep(int directionalStep) {
    final oldStart = currentRange.start;
    final oldEnd = currentRange.end;
    switch (stepSize) {
      case TimeStep.day:
        currentRange = DateTimeRange(
          start: oldStart.copyWith(day: oldStart.day + directionalStep),
          end: oldEnd.copyWith(day: oldEnd.day + directionalStep)
        );
        break;
      case TimeStep.week:
      case TimeStep.last7Days:
        currentRange = DateTimeRange(
          start: oldStart.copyWith(day: oldStart.day + directionalStep * 7),
          end: oldEnd.copyWith(day: oldEnd.day + directionalStep * 7)
        );
        break;
      case TimeStep.month:
        currentRange = DateTimeRange(
          start: oldStart.copyWith(month: oldStart.month + directionalStep),
          end: oldEnd.copyWith(month: oldEnd.month + directionalStep)
        );
        break;
      case TimeStep.year:
        currentRange = DateTimeRange(
          start: oldStart.copyWith(year: oldStart.year + directionalStep),
          end: oldEnd.copyWith(year: oldEnd.year + directionalStep)
        );
        break;
      case TimeStep.lifetime:
        currentRange = DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(1),
            end: DateTime.now().copyWith(hour: 23, minute: 59, second: 59)
        );
        break;
      case TimeStep.last30Days:
        currentRange = DateTimeRange(
            start: oldStart.copyWith(day: oldStart.day + directionalStep * 30),
            end: oldEnd.copyWith(day: oldEnd.day + directionalStep * 30)
        );
        break;
      case TimeStep.custom:
        final step = oldEnd.difference(oldStart) * directionalStep;
        currentRange = DateTimeRange(
            start: oldStart.add(step),
            end: oldEnd.add(step)
        );
        break;
    }
  }

  DateTimeRange _getMostRecentDisplayIntervall() {
    final now = DateTime.now();
    switch (stepSize) {
      case TimeStep.day:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: start, end: start.copyWith(day: now.day + 1));
      case TimeStep.week:
        final start = DateTime(now.year, now.month, now.day - (now.weekday - 1)); // monday
        return DateTimeRange(start: start, end: start.copyWith(day: start.day + DateTime.sunday)); // end of sunday
      case TimeStep.month:
        final start = DateTime(now.year, now.month);
        return DateTimeRange(start: start, end: start.copyWith(month: now.month + 1));
      case TimeStep.year:
        final start = DateTime(now.year);
        return DateTimeRange(start: start, end: start.copyWith(year: now.year + 1));
      case TimeStep.lifetime:
        final start = DateTime.fromMillisecondsSinceEpoch(1);
        final endOfToday = now.copyWith(hour: 23, minute: 59, second: 59);
        return DateTimeRange(start: start, end: endOfToday);
      case TimeStep.last7Days:
        final start = now.copyWith(day: now.day - 7);
        final endOfToday = now.copyWith(hour: 23, minute: 59, second: 59);
        return DateTimeRange(start: start, end: endOfToday);
      case TimeStep.last30Days:
        final start = now.copyWith(day: now.day - 30);
        final endOfToday = now.copyWith(hour: 23, minute: 59, second: 59);
        return DateTimeRange(start: start, end: endOfToday);
      case TimeStep.custom:
        // fallback, TimeStep will be reset by getter
        // TODO: evaluate above comment for the new class
        return DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(-1), 
          end: DateTime.fromMillisecondsSinceEpoch(-1));
    }
  }
}

enum TimeStep {
  day,
  month,
  year,
  lifetime,
  week,
  last7Days,
  last30Days,
  custom;

  static const options = [TimeStep.day, TimeStep.week, TimeStep.month, TimeStep.year, TimeStep.lifetime, TimeStep.last7Days, TimeStep.last30Days, TimeStep.custom];

  static String getName(TimeStep opt, BuildContext context) {
    switch (opt) {
      case TimeStep.day:
        return AppLocalizations.of(context)!.day;
      case TimeStep.month:
        return AppLocalizations.of(context)!.month;
      case TimeStep.year:
        return AppLocalizations.of(context)!.year;
      case TimeStep.lifetime:
        return AppLocalizations.of(context)!.lifetime;
      case TimeStep.week:
        return AppLocalizations.of(context)!.week;
      case TimeStep.last7Days:
        return AppLocalizations.of(context)!.last7Days;
      case TimeStep.last30Days:
        return AppLocalizations.of(context)!.last30Days;
      case TimeStep.custom:
        return AppLocalizations.of(context)!.custom;
    }
  }

  int serialize() {
    switch (this) {
      case TimeStep.day:
        return 0;
      case TimeStep.month:
        return 1;
      case TimeStep.year:
        return 2;
      case TimeStep.lifetime:
        return 3;
      case TimeStep.week:
        return 4;
      case TimeStep.last7Days:
        return 5;
      case TimeStep.last30Days:
        return 6;
      case TimeStep.custom:
        return 7;
    }
  }

  factory TimeStep.deserialize(dynamic value) {
    int? intValue = ConvertUtil.parseInt(value);
    if (value == null || intValue == null) return TimeStep.last7Days;

    switch (intValue) {
      case 0:
        return TimeStep.day;
      case 1:
        return TimeStep.month;
      case 2:
        return TimeStep.year;
      case 3:
        return TimeStep.lifetime;
      case 4:
        return TimeStep.week;
      case 5:
        return TimeStep.last7Days;
      case 6:
        return TimeStep.last30Days;
      case 7:
        return TimeStep.custom;
      default:
        assert(false);
        return TimeStep.last7Days;
    }
  }
}