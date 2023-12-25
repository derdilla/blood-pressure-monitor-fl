import 'package:flutter/material.dart';

@immutable
class MeasurementNeedlePin {
  final Color color;

  const MeasurementNeedlePin(this.color);
  // When updating this, remember to be backwards compatible
  MeasurementNeedlePin.fromJson(Map<String, dynamic> json)
      : color = Color(json['color']);
  Map<String, dynamic> toJson() => {
    'color': color.value,
  };

  @override
  String toString() {
    return 'MeasurementNeedlePin{$color}';
  }
}