import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter/material.dart';

@immutable
/// Metadata and secondary information for a [BloodPressureRecord].
class MeasurementNeedlePin {
  /// Create metadata for a [BloodPressureRecord].
  const MeasurementNeedlePin(this.color);

  /// Create a instance from a map created by [toMap].
  MeasurementNeedlePin.fromJson(Map<String, dynamic> json)
      : color = Color(json['color']);
  // When updating this, remember to be backwards compatible.
  // (or reimplement the system)

  /// The color associated with the measurement.
  final Color color;

  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toMap() => {
    'color': color.value,
  };

  @override
  String toString() => 'MeasurementNeedlePin{$color}';
}
