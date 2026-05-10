import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:settings_annotation/settings_annotation.dart';

class PressureUnitSetting extends Setting<PressureUnit> {
  PressureUnitSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.serialized;

  @override
  void fromMapValue(Object? value) => super
      .fromMapValue(PressureUnit.deserialize(ConvertUtil.parseInt(value)));
}
