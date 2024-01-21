import 'dart:math';

import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:collection/collection.dart';

// TODO: consider removing avg methods

/// Analysis utils for a list of blood pressure records.
class BloodPressureAnalyser {
  /// Create a analyzer for a list of records.
  BloodPressureAnalyser(this._records);

  final List<BloodPressureRecord> _records;

  /// The amount of records saved.
  int get count => _records.length;

  /// The average diastolic values of all records.
  int get avgDia => _safeResult(() => _nonNullDia.average.toInt(), (r) => r.diastolic);

  /// The average pulse values of all records.
  int get avgPul => _safeResult(() => _nonNullPul.average.toInt(), (r) => r.pulse);

  /// The average systolic values of all records.
  int get avgSys => _safeResult(() => _nonNullSys.average.toInt(), (r) => r.systolic);

  /// The maximum diastolic values of all records.
  int get maxDia => _safeResult(() => _nonNullDia.reduce(max), (r) => r.diastolic);

  /// The maximum pulse values of all records.
  int get maxPul => _safeResult(() => _nonNullPul.reduce(max), (r) => r.pulse);

  /// The maximum systolic values of all records.
  int get maxSys => _safeResult(() => _nonNullSys.reduce(max), (r) => r.systolic);

  /// The minimal diastolic values of all records.
  int get minDia => _safeResult(() => _nonNullDia.reduce(min), (r) => r.diastolic);

  /// The minimal pulse values of all records.
  int get minPul => _safeResult(() =>  _nonNullPul.reduce(min), (r) => r.pulse);

  /// The minimal systolic values of all records.
  int get minSys => _safeResult(() => _nonNullSys.reduce(min), (r) => r.systolic);

  /// The earliest timestamp of all records.
  DateTime? get firstDay {
    if (_records.isEmpty) return null;
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.first.creationTime;
  }

  /// The latest timestamp of all records.
  DateTime? get lastDay {
    if (_records.isEmpty) return null;
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.last.creationTime;
  }

  int _safeResult(int Function() f, int? Function(BloodPressureRecord) lengthOneResult) {
    if (_records.isEmpty) return -1;
    if (_records.length == 1) return lengthOneResult(_records.first) ?? -1;
    try {
      return f();
    } on StateError {
      return -1;
    }

  }
  Iterable<int> get _nonNullDia => _records.map((e) => e.diastolic).whereNotNull();
  Iterable<int> get _nonNullSys => _records.map((e) => e.systolic).whereNotNull();
  Iterable<int> get _nonNullPul => _records.map((e) => e.pulse).whereNotNull();

  /// Average amount of measurements entered per day.
  int? get measurementsPerDay {
    final c = count;
    if (c <= 1) return null;

    final firstDay = this.firstDay;
    final lastDay = this.lastDay;
    if (firstDay == null || lastDay == null) return -1;

    if (firstDay.millisecondsSinceEpoch == -1 || lastDay.millisecondsSinceEpoch == -1) {
      return null;
    }
    if (lastDay.difference(firstDay).inDays <= 0) {
      return c;
    }

    return c ~/ lastDay.difference(firstDay).inDays;
  }

  /// Relation of average values to the time of the day.
  ///
  /// outer list is type (0 -> diastolic, 1 -> systolic, 2 -> pulse)
  /// inner list index is hour of day ([0] -> 00:00-00:59; [1] -> ...)
  List<List<int>> get allAvgsRelativeToDaytime {
    // setup vars
    final List<List<int>> allDiaValuesRelativeToTime = [];
    final List<List<int>> allSysValuesRelativeToTime = [];
    final List<List<int>> allPulValuesRelativeToTime = [];
    for (int i = 0; i < 24; i++) {
      allDiaValuesRelativeToTime.add([]);
      allSysValuesRelativeToTime.add([]);
      allPulValuesRelativeToTime.add([]);
    }

    // sort all data
    final dbRes = _records;
    for (final e in dbRes) {
      final DateTime ts = DateTime.fromMillisecondsSinceEpoch(e.creationTime.millisecondsSinceEpoch);
      if (e.diastolic != null) allDiaValuesRelativeToTime[ts.hour].add(e.diastolic!);
      if (e.systolic != null)allSysValuesRelativeToTime[ts.hour].add(e.systolic!);
      if (e.pulse != null)allPulValuesRelativeToTime[ts.hour].add(e.pulse!);
    }
    for (int i = 0; i < 24; i++) {
      if (allDiaValuesRelativeToTime[i].isEmpty) {
        allDiaValuesRelativeToTime[i].add(avgDia);
      }
      if (allSysValuesRelativeToTime[i].isEmpty) {
        allSysValuesRelativeToTime[i].add(avgSys);
      }
      if (allPulValuesRelativeToTime[i].isEmpty) {
        allPulValuesRelativeToTime[i].add(avgPul);
      }
    }

    // make avgs
    final List<List<int>> res = [[], [], []];
    for (int i = 0; i < 24; i++) {
      res[0].add(allDiaValuesRelativeToTime[i].average.toInt());
      res[1].add(allSysValuesRelativeToTime[i].average.toInt());
      res[2].add(allPulValuesRelativeToTime[i].average.toInt());
    }
    return res;
  }
}
