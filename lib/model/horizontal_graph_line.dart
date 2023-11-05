import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';

class HorizontalGraphLine {
  HorizontalGraphLine(this.color, this.height);

  /// Color of the line.
  Color color;

  /// Height to display the line in.
  ///
  /// Usually on the same scale as [BloodPressureRecord]
  int height;

  HorizontalGraphLine.fromJson(Map<String, dynamic> json)
      : color = Color(json['color']),
        height = json['height'];

  Map<String, dynamic> toJson() => {
    'color': color.value,
    'height': height,
  };
}