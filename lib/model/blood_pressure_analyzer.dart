import 'dart:math';

import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:collection/collection.dart';

class BloodPressureAnalyser {
  final List<BloodPressureRecord> _records;

  BloodPressureAnalyser(this._records);

  int get count => _records.length;

  int get avgDia => _safeResult(() => _nonNullDia.average.toInt(), (r) => r.diastolic);

  int get avgPul => _safeResult(() => _nonNullPul.average.toInt(), (r) => r.pulse);

  int get avgSys => _safeResult(() => _nonNullSys.average.toInt(), (r) => r.systolic);

  int get maxDia => _safeResult(() => _nonNullDia.reduce(max), (r) => r.diastolic);

  int get maxPul => _safeResult(() => _nonNullPul.reduce(max), (r) => r.pulse);

  int get maxSys => _safeResult(() => _nonNullSys.reduce(max), (r) => r.systolic);

  int get minDia => _safeResult(() => _nonNullDia.reduce(min), (r) => r.diastolic);

  int get minPul => _safeResult(() =>  _nonNullPul.reduce(min), (r) => r.pulse);

  int get minSys => _safeResult(() => _nonNullSys.reduce(min), (r) => r.systolic);

  DateTime? get firstDay {
    if (_records.isEmpty) return null;
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.first.creationTime;
  }

  DateTime? get lastDay {
    if (_records.isEmpty) return null;
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.last.creationTime;
  }

  int _safeResult(int Function() f, int? Function(BloodPressureRecord) lengthOneResult) {
    if (_records.isEmpty) return -1;
    if (_records.length == 1) return lengthOneResult(_records.first) ?? -1;
    return f();
  }
  Iterable<int> get _nonNullDia => _records.where((e) => e.diastolic!=null).map<int>((e) => e.diastolic!);
  Iterable<int> get _nonNullSys => _records.where((e) => e.systolic!=null).map<int>((e) => e.systolic!);
  Iterable<int> get _nonNullPul => _records.where((e) => e.pulse!=null).map<int>((e) => e.pulse!);

  int get measurementsPerDay {
    final c = count;
    if (c <= 1) return -1;

    final firstDay = this.firstDay;
    final lastDay = this.lastDay;
    if (firstDay == null || lastDay == null) return -1;

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
