// TODO: cleanup types
// ignore_for_file: strict_raw_type


import 'package:blood_pressure_app/features/bluetooth/logic/ble_read_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/devices/ble_indication_read_cubit.dart';
import 'package:blood_pressure_app/logging.dart';

/// Logic for reading a from the Yonker class.
///
/// This is a low-cost device that may be sold under different brands/models:
/// - Yonker YK-IBPA1
/// - Yonker YK-BPW5
/// - Yongrow YK-IBPA1 (confirmed)
/// - METIKO MT-YK-BPA1
class YonkerReadCubit extends BleIndicationReadCubit with TypeLogger {
  /// Start reading a characteristic from a device.
  YonkerReadCubit({
    required super.device,
    super.serviceUUID = defaultServiceUUID,
    super.characteristicUUID = defaultCharacteristicUUID,
  }) : super(BleReadInProgress());

  // The yonker doesn't advertise its services

  static const defaultServiceUUID = 'cdeacd80-5235-4c07-8846-93a37ee6b86d';
  static const defaultCharacteristicUUID = 'cdeacd81-5235-4c07-8846-93a37ee6b86d';
}
