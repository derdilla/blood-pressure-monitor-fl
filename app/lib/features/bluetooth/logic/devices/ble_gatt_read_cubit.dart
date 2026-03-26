// TODO: cleanup types
// ignore_for_file: strict_raw_type


import 'package:blood_pressure_app/features/bluetooth/logic/ble_read_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/devices/ble_indication_read_cubit.dart';
import 'package:blood_pressure_app/logging.dart';

/// Logic for reading a characteristic from a device supporting the BLE GATT protocol.
class BleGattReadCubit extends BleIndicationReadCubit with TypeLogger {

  /// Start reading a characteristic from a device.
  BleGattReadCubit({
    required super.device,
    super.serviceUUID = defaultServiceUUID,
    super.characteristicUUID = defaultCharacteristicUUID,
  }) : super(BleReadInProgress());

  // See assigned numbers:
  // https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/Assigned_Numbers/out/en/Assigned_Numbers.pdf?v=1706215305114

  static const defaultServiceUUID = '1810';
  static const defaultCharacteristicUUID = '2A35';
}
