import 'package:blood_pressure_app/model/bluetooth_measurement_import_mode.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:settings_annotation/settings_annotation.dart';

class BluetoothMeasurementImportModeSetting
    extends Setting<BluetoothMeasurementImportMode> {
  BluetoothMeasurementImportModeSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.serialized;

  @override
  void fromMapValue(Object? value) => super.fromMapValue(
      BluetoothMeasurementImportMode.deserialize(ConvertUtil.parseInt(value)));
}
