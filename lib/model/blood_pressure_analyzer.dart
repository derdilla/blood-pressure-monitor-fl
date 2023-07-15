import 'dart:math';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:collection/collection.dart';

class BloodPressureAnalyser {
  final List<BloodPressureRecord> _records;

  BloodPressureAnalyser(this._records);

  int get count => _records.length;

  int get avgDia => _nonNullDia.reduce((a, b) => a + b) ~/ _nonNullDia.length;

  int get avgPul => _nonNullPul.reduce((a, b) => a + b) ~/ _nonNullPul.length;

  int get avgSys => _nonNullSys.reduce((a, b) => a + b) ~/ _nonNullSys.length;

  int get maxDia => _nonNullDia.reduce(max);

  int get maxPul => _nonNullPul.reduce(max);

  int get maxSys => _nonNullSys.reduce(max);

  int get minDia => _nonNullDia.reduce(min);

  int get minPul => _nonNullPul.reduce(min);

  int get minSys => _nonNullSys.reduce(min);

  DateTime get firstDay {
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.first.creationTime;
  }

  DateTime get lastDay {
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.last.creationTime;
  }

  Iterable<int> get _nonNullDia => _records.where((e) => e.diastolic!=null).map<int>((e) => e.diastolic!);
  Iterable<int> get _nonNullSys => _records.where((e) => e.systolic!=null).map<int>((e) => e.systolic!);
  Iterable<int> get _nonNullPul => _records.where((e) => e.pulse!=null).map<int>((e) => e.pulse!);

  int get measurementsPerDay {
    final c = count;
    if (c <= 1) return -1;

    final firstDay = this.firstDay;
    final lastDay = this.lastDay;

    if (firstDay.millisecondsSinceEpoch == -1 || lastDay.millisecondsSinceEpoch == -1) {
      return -1;
    }
    if (lastDay.difference(firstDay).inDays <= 0) {
      return c;
    }

    return c ~/ lastDay.difference(firstDay).inDays;
  }

  /// outer list is type (0 -> diastolic, 1 -> systolic, 2 -> pulse)
  /// inner list index is hour of day ([0] -> 00:00-00:59; [1] -> ...)
  List<List<int>> get allAvgsRelativeToDaytime {
    // setup vars
    List<List<int>> allDiaValuesRelativeToTime = [];
    List<List<int>> allSysValuesRelativeToTime = [];
    List<List<int>> allPulValuesRelativeToTime = [];
    for (int i = 0; i < 24; i++) {
      allDiaValuesRelativeToTime.add([]);
      allSysValuesRelativeToTime.add([]);
      allPulValuesRelativeToTime.add([]);
    }

    // sort all data
    final dbRes = _records;
    for (var e in dbRes) {
      DateTime ts = DateTime.fromMillisecondsSinceEpoch(e.creationTime.millisecondsSinceEpoch);
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
    List<List<int>> res = [[], [], []];
    for (int i = 0; i < 24; i++) {
      res[0].add(allDiaValuesRelativeToTime[i].average.toInt());
      res[1].add(allSysValuesRelativeToTime[i].average.toInt());
      res[2].add(allPulValuesRelativeToTime[i].average.toInt());
    }
    return res;
  }
}
