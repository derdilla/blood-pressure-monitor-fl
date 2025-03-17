import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';

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

  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toJson() => {
    'color': color.toARGB32(),
    'height': height,
  };
}
