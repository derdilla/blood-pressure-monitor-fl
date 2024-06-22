import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter/material.dart';

@immutable
@Deprecated('only maintained for imports, use health_data_store')
/// Metadata and secondary information for a [BloodPressureRecord].
class MeasurementNeedlePin {
  /// Create a instance from a map created in older versions.
  MeasurementNeedlePin.fromMap(Map<String, dynamic> json)
      : color = Color(json['color']);
  // When updating this, remember to be backwards compatible.
  // (or reimplement the system)

  /// The color associated with the measurement.
  final Color color;
}
