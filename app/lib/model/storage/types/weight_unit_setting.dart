import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:settings_annotation/settings_annotation.dart';

class WeightUnitSetting extends Setting<WeightUnit> {
  WeightUnitSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.serialized;

  @override
  void fromMapValue(Object? value) => super
      .fromMapValue(WeightUnit.deserialize(ConvertUtil.parseInt(value)));
}
