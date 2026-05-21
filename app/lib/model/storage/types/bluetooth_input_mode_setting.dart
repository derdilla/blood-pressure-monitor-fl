import 'package:blood_pressure_app/model/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:settings_annotation/settings_annotation.dart';

class BluetoothInputModeSetting extends Setting<BluetoothInputMode> {
  BluetoothInputModeSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.serialized;

  @override
  void fromMapValue(Object? value) => super.fromMapValue(
      BluetoothInputMode.deserialize(ConvertUtil.parseInt(value)));
}
