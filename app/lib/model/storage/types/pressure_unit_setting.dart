import 'package:settings_annotation/settings_annotation.dart';
import '../convert_util.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';

class PressureUnitSetting extends Setting<PressureUnit> {
  PressureUnitSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.serialized;

  @override
  void fromMapValue(Object? value) => super
      .fromMapValue(PressureUnit.deserialize(ConvertUtil.parseInt(value)));
}
