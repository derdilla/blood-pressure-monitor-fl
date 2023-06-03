import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';

class RamBloodPressureModel extends ChangeNotifier implements BloodPressureModel {
  final List<BloodPressureRecord> _records = [];

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
    for(final e in _records) {
      if (e.creationTime.isAfter(from) && e.creationTime.isBefore(to)) {
        recordsInTime.add(e);
      }
    }
    return UnmodifiableListView(recordsInTime);
  }

  @override
  Future<UnmodifiableListView<BloodPressureRecord>> get all async => UnmodifiableListView(_records);

  @override
  Future<int> get count async => _records.length;

  @override
  Future<int> get avgDia async => _records.map((e) => e.diastolic).reduce((a, b) => a+b) ~/ _records.length;

  @override
  Future<int> get avgPul async => _records.map((e) => e.pulse).reduce((a, b) => a+b) ~/ _records.length;

  @override
  Future<int> get avgSys async => _records.map((e) => e.systolic).reduce((a, b) => a+b) ~/ _records.length;

  @override
  Future<int> get maxDia async => _records.reduce((a,b) => (a.diastolic>=b.diastolic) ? a : b).diastolic;

  @override
  Future<int> get maxPul async => _records.reduce((a,b) => (a.pulse>=b.pulse) ? a : b).pulse;

  @override
  Future<int> get maxSys async => _records.reduce((a,b) => (a.systolic>=b.systolic) ? a : b).systolic;

  @override
  Future<int> get minDia async => _records.reduce((a,b) => (a.diastolic<=b.diastolic) ? a : b).diastolic;

  @override
  Future<int> get minPul async => _records.reduce((a,b) => (a.pulse<=b.pulse) ? a : b).pulse;

  @override
  Future<int> get minSys async => _records.reduce((a,b) => (a.systolic<=b.systolic) ? a : b).systolic;

  @override
  Future<DateTime> get firstDay async {
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.first.creationTime;
  }

  @override
  Future<DateTime> get lastDay async {
    _records.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    return _records.last.creationTime;
  }

  @override
  void close() {}

  @override
  Future<void> import(void Function(bool p1, String? p2) callback) {
    // TODO: implement import
    throw UnimplementedError();
  }

  @override
  Future<void> save(void Function(bool success, String? msg) callback, {bool exportAsText = false}) {
    // TODO: implement save
    throw UnimplementedError();
  }
}