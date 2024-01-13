import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter/material.dart';

/// Information about a straight horizontal line through the graph.
///
/// Can be used to indicate value ranges and provide a frame of reference to the
/// user.
class HorizontalGraphLine {
  /// Create a instance from a [String] created by [toJson].
  HorizontalGraphLine.fromJson(Map<String, dynamic> json)
      : color = Color(json['color']),
        height = json['height'];

  /// Create information about a new horizontal line through the graph.
  HorizontalGraphLine(this.color, this.height);

  /// Color of the line.
  Color color;

  /// Height to display the line in.
  ///
  /// Usually on the same scale as [BloodPressureRecord]
  int height;

  /// Serialize the object to a restoreable string.
  Map<String, dynamic> toJson() => {
    'color': color.value,
    'height': height,
  };
}
