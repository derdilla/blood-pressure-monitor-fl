import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:flutter/material.dart';

/// Immutable data representation of a saved measurement.
@immutable
@Deprecated('use health data store')
class OldBloodPressureRecord {
  /// Create a measurement.
  OldBloodPressureRecord(DateTime creationTime, this.systolic, this.diastolic, this.pulse, this.notes, {
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

  /// Creates a new record from this one by updating individual properties.
  OldBloodPressureRecord copyWith({
    DateTime? creationTime,
    int? systolic,
    int? diastolic,
    int? pulse,
    String? notes,
    MeasurementNeedlePin? needlePin,
  }) => OldBloodPressureRecord(
    creationTime ?? this.creationTime,
    systolic ?? this.systolic,
    diastolic ?? this.diastolic,
    pulse ?? this.pulse,
    notes ?? this.notes,
    needlePin: needlePin ?? this.needlePin,
  );

  @override
  String toString() => 'BloodPressureRecord($creationTime, $systolic, $diastolic, $pulse, $notes, $needlePin)';
}
