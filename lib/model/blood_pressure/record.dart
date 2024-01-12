import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:flutter/material.dart';

@immutable
class BloodPressureRecord {

  BloodPressureRecord(DateTime creationTime, this.systolic, this.diastolic, this.pulse, this.notes, {
    this.needlePin,
  }) {
    if (creationTime.millisecondsSinceEpoch > 0) {
      this.creationTime = creationTime;
    } else {
      assert(false, 'Tried to create BloodPressureRecord at or before epoch');
      this.creationTime = DateTime.fromMillisecondsSinceEpoch(1);
    }
  }
  late final DateTime creationTime;
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final String notes;
  final MeasurementNeedlePin? needlePin;

  @override
  String toString() => 'BloodPressureRecord($creationTime, $systolic, $diastolic, $pulse, $notes, $needlePin)';
}