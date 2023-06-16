import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:collection/collection.dart';

class BloodPressureAnalyser {
  final BloodPressureModel _model;

  BloodPressureAnalyser(this._model);

  Future<int> get measurementsPerDay async {
    final c = await _model.count;
    if (c <= 1) return -1;

    final firstDay = await _model.firstDay;
    final lastDay = await _model.lastDay;

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
  Future<List<List<int>>> get allAvgsRelativeToDaytime async {
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
    final dbRes = await _model.all;
    for (var entry in dbRes) {
      DateTime ts = DateTime.fromMillisecondsSinceEpoch(entry.creationTime.millisecondsSinceEpoch);
      allDiaValuesRelativeToTime[ts.hour].add(entry.diastolic);
      allSysValuesRelativeToTime[ts.hour].add(entry.systolic);
      allPulValuesRelativeToTime[ts.hour].add(entry.pulse);
    }
    for (int i = 0; i < 24; i++) {
      if (allDiaValuesRelativeToTime[i].isEmpty) {
        allDiaValuesRelativeToTime[i].add(await _model.avgDia);
      }
      if (allSysValuesRelativeToTime[i].isEmpty) {
        allSysValuesRelativeToTime[i].add(await _model.avgSys);
      }
      if (allPulValuesRelativeToTime[i].isEmpty) {
        allPulValuesRelativeToTime[i].add(await _model.avgPul);
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
