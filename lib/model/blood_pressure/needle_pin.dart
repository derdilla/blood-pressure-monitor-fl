import 'package:flutter/material.dart';

@immutable
class MeasurementNeedlePin {

  const MeasurementNeedlePin(this.color);
  // When updating this, remember to be backwards compatible
  MeasurementNeedlePin.fromJson(Map<String, dynamic> json)
      : color = Color(json['color']);
  final Color color;
  Map<String, dynamic> toJson() => {
    'color': color.value,
  };

  @override
  String toString() => 'MeasurementNeedlePin{$color}';
}