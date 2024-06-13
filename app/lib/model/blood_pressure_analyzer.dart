import 'dart:math';

import 'package:collection/collection.dart';
import 'package:health_data_store/health_data_store.dart';

// TODO: ensure calculations work and return null in case of error

/// Analysis utils for a list of blood pressure records.
class BloodPressureAnalyser {
  /// Create a analyzer for a list of records.
  BloodPressureAnalyser(this._records);

  final List<BloodPressureRecord> _records;

  /// The amount of records saved.
  int get count => _records.length;

  /// The average diastolic values of all records.
  Pressure? get avgDia => _records.map((r) => r.dia?.kPa).tryAverage?.asKPa;

  /// The average pulse values of all records.
  int? get avgPul => _records.map((r) => r.pul).tryAverage?.toInt();

  /// The average systolic values of all records.
  Pressure? get avgSys => _records.map((r) => r.sys?.kPa).tryAverage?.asKPa;

  /// The maximum diastolic values of all records.
  Pressure? get maxDia => _records.map((r) => r.dia?.kPa).tryMax?.asKPa;

  /// The maximum pulse values of all records.
  int? get maxPul => _records.map((r) => r.pul).tryMax?.toInt();

  /// The maximum systolic values of all records.
  Pressure? get maxSys => _records.map((r) => r.sys?.kPa).tryMax?.asKPa;

  /// The minimal diastolic values of all records.
  Pressure? get minDia => _records.map((r) => r.dia?.kPa).tryMin?.asKPa;

  /// The minimal pulse values of all records.
  int? get minPul => _records.map((r) => r.pul).tryMin?.toInt();

  /// The minimal systolic values of all records.
  Pressure? get minSys => _records.map((r) => r.sys?.kPa).tryMax?.asKPa;

  /// The earliest timestamp of all records.
  DateTime? get firstDay {
    if (_records.isEmpty) return null;
    _records.sort((a, b) => a.time.compareTo(b.time));
    return _records.first.time;
  }

  /// The latest timestamp of all records.
  DateTime? get lastDay {
    if (_records.isEmpty) return null;
    _records.sort((a, b) => a.time.compareTo(b.time));
    return _records.last.time;
  }

  /// Average amount of measurements entered per day.
  int? get measurementsPerDay {
    final c = count;
    if (c <= 1) return null;

    final firstDay = this.firstDay;
    final lastDay = this.lastDay;
    if (firstDay == null || lastDay == null) return null;

    assert(firstDay.millisecondsSinceEpoch != -1
      && lastDay.millisecondsSinceEpoch != -1);
    if (lastDay.difference(firstDay).inDays <= 0) {
      return c;
    }

    return c ~/ lastDay.difference(firstDay).inDays;
  }

  /// Relation of average values to the time of the day.
  ///
  /// outer list is type (0 -> diastolic, 1 -> systolic, 2 -> pulse)
  /// inner list index is hour of day ([0] -> 23:30-00:29.59; [1] -> ...)
  @Deprecated("This api can't express kPa and mmHg preferences and is only a "
      'thin wrapper around the newer [groupAnalysers].')
  List<List<int>> get allAvgsRelativeToDaytime {
    final groupedAnalyzers = groupAnalysers();
    return [
      groupedAnalyzers.map((e) => e.avgDia?.mmHg ?? avgDia?.mmHg ?? 0).toList(),
      groupedAnalyzers.map((e) => e.avgSys?.mmHg ?? avgSys?.mmHg ?? 0).toList(),
      groupedAnalyzers.map((e) => e.avgPul ?? avgPul ?? 0).toList(),
    ];
  }

  /// Creates analyzers for each hour of the day (0-23).
  ///
  /// This function groups records by the hour of the day (e.g 23:30-00:29.59)
  /// and creates an [BloodPressureAnalyser] for each. The analyzers are
  /// returned ordered by the hour of the day and the index can be used as the
  /// hour.
  List<BloodPressureAnalyser> groupAnalysers() { // TODO: test
    // Group records around the full hour so that there are 24 sublists from 0
    // to 23. ([0] -> 23:30-00:29.59; [1] -> ...).
    final Map<int, List<BloodPressureRecord>> grouped = _records.groupListsBy((BloodPressureRecord record) {
      int hour = record.time.hour;
      if(record.time.minute >= 30) hour += 1;
      hour %= 24; // midnight jumps
      return hour;
    });
    final groupedAnalyzers = grouped.map((hour, subList) => MapEntry(
      hour,
      BloodPressureAnalyser(subList),
    ));
    final sortedAnalyzersList = groupedAnalyzers.entries
      .sorted((a,b) => a.key.compareTo(b.key));
    return sortedAnalyzersList
      .map((e) => e.value)
      .toList();
  }
}

extension _NullableMath on Iterable<num?> {
  /// Gets the average value or null if the iterable is empty.
  num? get tryAverage {
    final nonNull = whereNotNull();
    if(nonNull.isEmpty) return null;
    final double result = nonNull.fold(0.0, (last, next) => last + next / length);
    return result;
  }

  /// Gets the minimum value or null if the iterable is empty.
  num? get tryMin {
    final nonNull = whereNotNull();
    if(nonNull.isEmpty) return null;
    return nonNull.reduce(min);
  }

  /// Gets the maximum value or null if the iterable is empty.
  num? get tryMax {
    final nonNull = whereNotNull();
    if(nonNull.isEmpty) return null;
    return nonNull.reduce(max);
  }
}

extension _Pressure on num {
  /// Return [Pressure.kPa] of this values
  Pressure get asKPa => Pressure.kPa(toDouble());
}
