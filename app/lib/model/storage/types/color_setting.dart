import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';

class ColorSetting extends Setting<Color> {
  ColorSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.toARGB32();

  @override
  void fromMapValue(Object? value) => super
      .fromMapValue(ConvertUtil.parseColor(value));
}
