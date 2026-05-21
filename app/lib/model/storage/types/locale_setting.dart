import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:flutter/material.dart';
import 'package:settings_annotation/settings_annotation.dart';

class LocaleSetting extends Setting<Locale?> {
  LocaleSetting({required super.initialValue});

  @override
  Object? toMapValue() => ConvertUtil.serializeLocale(value);

  @override
  void fromMapValue(Object? value) => this.value = ConvertUtil.parseLocale(value);
}
