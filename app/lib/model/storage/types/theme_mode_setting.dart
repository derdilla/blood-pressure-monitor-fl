import 'package:settings_annotation/settings_annotation.dart';
import '../convert_util.dart';
import 'package:flutter/material.dart';

class ThemeModeSetting extends Setting<ThemeMode> {
  ThemeModeSetting({required super.initialValue});

  @override
  Object? toMapValue() => switch(value) {
    ThemeMode.system => 0,
    ThemeMode.dark => 1,
    ThemeMode.light => 2,
  };

  @override
  void fromMapValue(Object? value) {
    final mode = switch(ConvertUtil.parseInt(value)) {
      0 => ThemeMode.system,
      1 => ThemeMode.dark,
      2 => ThemeMode.light,
      _ => ThemeMode.system,
    };
    super.fromMapValue(mode);
  }
}
