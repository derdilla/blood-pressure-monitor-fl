import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';

class RamBloodPressureModel extends ChangeNotifier implements BloodPressureModel {
  final List<BloodPressureRecord> _records = [];
  
  static RamBloodPressureModel fromEntries(List<BloodPressureRecord> records) {
    final m = RamBloodPressureModel();
    for (var e in records) {
      m.add(e);
    }
    return m;
  }

  @override
  Future<void> add(BloodPressureRecord measurement) async {
    _records.add(measurement);
    notifyListeners();
  }

  @override
  Future<void> delete(DateTime timestamp) async {
    _records.removeWhere((element) => element.creationTime.isAtSameMomentAs(timestamp));
  }

  @override
  Future<UnmodifiableListView<BloodPressureRecord>> getInTimeRange(DateTime from, DateTime to) async {
    List<BloodPressureRecord> recordsInTime = [];
    for (final e in _records) {
      if (e.creationTime.isAfter(from) && e.creationTime.isBefore(to)) {
        recordsInTime.add(e);
      }
    }
    return UnmodifiableListView(recordsInTime);
  }

  @override
  Future<UnmodifiableListView<BloodPressureRecord>> get all async => UnmodifiableListView(_records);

  @override
  Future<void> close() async {}
}