import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:flutter/material.dart';

@immutable
/// Immutable data representation of a saved measurement.
class BloodPressureRecord {
  /// Create a measurement.
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

  /// The time the measurement was created.
  late final DateTime creationTime;

  /// The stored sys value.
  final int? systolic;

  /// The stored dia value.
  final int? diastolic;

  /// The stored pul value.
  final int? pulse;

  /// Notes stored about this measurement.
  final String notes;

  /// Secondary information about the measurement.
  final MeasurementNeedlePin? needlePin;

  @override
  String toString() => 'BloodPressureRecord($creationTime, $systolic, $diastolic, $pulse, $notes, $needlePin)';
}
