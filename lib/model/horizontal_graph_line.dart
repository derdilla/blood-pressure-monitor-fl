import 'package:flutter/material.dart';

class HorizontalGraphLine {
  Color color;
  int height;

  HorizontalGraphLine(this.color, this.height);

  HorizontalGraphLine.fromJson(Map<String, dynamic> json)
      : color = Color(json['color']),
        height = json['height'];

  Map<String, dynamic> toJson() => {
    'color': color.value,
    'height': height,
  };
}