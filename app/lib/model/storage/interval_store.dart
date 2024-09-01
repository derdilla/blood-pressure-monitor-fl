import 'dart:convert';

import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Class for storing the current interval, as it is needed in start page, statistics and export.
class IntervalStorage extends ChangeNotifier {
  /// Create a instance from a map created by [toMap].
  factory IntervalStorage.fromMap(Map<String, dynamic> map) => IntervalStorage(
    stepSize: TimeStep.deserialize(map['stepSize']),
    range: ConvertUtil.parseRange(map['start'], map['end']),
  );

  /// Create a instance from a [String] created by [toJson].
  factory IntervalStorage.fromJson(String json) {
    try {
      return IntervalStorage.fromMap(jsonDecode(json));
    } catch (exception) {
      return IntervalStorage();
    }
  }

  /// Create a storage to interact with a display intervall.
  IntervalStorage({TimeStep? stepSize, DateRange? range}) :
    _stepSize = stepSize ?? TimeStep.last7Days {
    _currentRange = range ?? _getMostRecentDisplayIntervall();
  }

  TimeStep _stepSize;

  late DateRange _currentRange;

  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'stepSize': stepSize.serialize(),
    'start': currentRange.start.millisecondsSinceEpoch,
    'end': currentRange.end.millisecondsSinceEpoch,
  };

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode(toMap());

  /// The stepSize gets set through the changeStepSize method.
  TimeStep get stepSize => _stepSize;

  /// sets the stepSize to the new value and resets the currentRange to the most recent one. 
  void changeStepSize(TimeStep value) {
    _stepSize = value;
    setToMostRecentInterval();
  }

  DateRange get currentRange => _currentRange;

  set currentRange(DateRange value) {
    _currentRange = value;
    notifyListeners();
  }

  /// Sets internal _currentRange to the most recent intervall and notifies listeners.
  void setToMostRecentInterval() {
    _currentRange = _getMostRecentDisplayIntervall();
    notifyListeners();
  }

  void moveDataRangeByStep(int directionalStep) {
    final oldStart = currentRange.start;
    final oldEnd = currentRange.end;
    currentRange = switch (stepSize) {
      TimeStep.day => DateRange(
        start: oldStart.add(Duration(days: directionalStep)),
        end: oldEnd.add(Duration(days: directionalStep)),
      ),
      TimeStep.week || TimeStep.last7Days => DateRange(
        start: oldStart.add(Duration(days: directionalStep * 7)),
        end: oldEnd.add(Duration(days: directionalStep * 7)),
      ),
      TimeStep.month => DateRange(
        // No fitting Duration: wraps correctly according to doc
        start: oldStart.copyWith(month: oldStart.month + directionalStep),
        end: oldEnd.copyWith(month: oldEnd.month + directionalStep),
      ),
      TimeStep.year => DateRange(
        // No fitting Duration: wraps correctly according to doc
        start: oldStart.copyWith(year: oldStart.year + directionalStep),
        end: oldEnd.copyWith(year: oldEnd.year + directionalStep),
      ),
      TimeStep.lifetime => DateRange(
        start: DateTime.fromMillisecondsSinceEpoch(1),
        end: DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
      ),
      TimeStep.last30Days => DateRange(
        start: oldStart.add(Duration(days: directionalStep * 30)),
        end: oldEnd.add(Duration(days:  directionalStep * 30)),
      ),
      TimeStep.custom => DateRange(
        start: oldStart.add(oldEnd.difference(oldStart) * directionalStep),
        end: oldEnd.add(oldEnd.difference(oldStart) * directionalStep),
      ),
    };
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
        return DateRange(
          start: now.subtract(currentRange.duration),
          end: now,
        );
    }
  }
}

/// Different range types supported by the interval switcher.
enum TimeStep {
  day,
  month,
  year,
  lifetime,
  week,
  last7Days,
  last30Days,
  custom;

  /// Recreate a TimeStep from a number created with [TimeStep.serialize].
  factory TimeStep.deserialize(value) {
    final int? intValue = ConvertUtil.parseInt(value);
    assert(intValue == null || intValue >= 0 && intValue <= 7);
    return switch (intValue) {
      null => TimeStep.last7Days,
      0 => TimeStep.day,
      1 => TimeStep.month,
      2 => TimeStep.year,
      3 => TimeStep.lifetime,
      4 => TimeStep.week,
      5 => TimeStep.last7Days,
      6 => TimeStep.last30Days,
      7 => TimeStep.custom,
      _ => TimeStep.last7Days,
    };
  }

  /// Select a displayable string from [localizations].
  String localize(AppLocalizations localizations) => switch (this) {
    TimeStep.day => localizations.day,
    TimeStep.month => localizations.month,
    TimeStep.year => localizations.year,
    TimeStep.lifetime => localizations.lifetime,
    TimeStep.week => localizations.week,
    TimeStep.last7Days => localizations.last7Days,
    TimeStep.last30Days => localizations.last30Days,
    TimeStep.custom =>  localizations.custom,
  };

  int serialize() =>switch (this) {
    TimeStep.day => 0,
    TimeStep.month => 1,
    TimeStep.year => 2,
    TimeStep.lifetime => 3,
    TimeStep.week => 4,
    TimeStep.last7Days => 5,
    TimeStep.last30Days => 6,
    TimeStep.custom => 7,
  };
}

/// Class that stores the interval objects that are needed in the app and provides named access to them. 
class IntervalStoreManager extends ChangeNotifier {
  /// Constructor for creating [IntervalStoreManager] from items.
  ///
  /// You should use [SettingsLoader.loadExportColumnsManager] for most cases.
  IntervalStoreManager(this.mainPage, this.exportPage, this.statsPage) {
    mainPage.addListener(notifyListeners);
    exportPage.addListener(notifyListeners);
    statsPage.addListener(notifyListeners);
  }

  IntervalStorage get(IntervalStoreManagerLocation type) => switch (type) {
    IntervalStoreManagerLocation.mainPage => mainPage,
    IntervalStoreManagerLocation.exportPage => exportPage,
    IntervalStoreManagerLocation.statsPage => statsPage,
  };

  /// Reset all fields to their default values.
  void reset() {
    mainPage = IntervalStorage();
    exportPage = IntervalStorage();
    statsPage = IntervalStorage();
    notifyListeners();
  }

  // Copy all values from another instance.
  void copyFrom(IntervalStoreManager other) {
    mainPage = other.mainPage;
    exportPage = other.exportPage;
    statsPage = other.statsPage;
    notifyListeners();
  }

  /// Intervall for the page with graph and list.
  IntervalStorage mainPage;

  /// Intervall for all exports.
  IntervalStorage exportPage;

  /// Intervall to display statistics in.
  IntervalStorage statsPage;

  @override
  void dispose() {
    super.dispose();
    mainPage.dispose();
    exportPage.dispose();
    statsPage.dispose();
  }
}

/// Locations supported by [IntervalStoreManager].
enum IntervalStoreManagerLocation {
  mainPage,
  exportPage,
  statsPage,
}