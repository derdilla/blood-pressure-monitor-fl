// TODO: cleanup types
// ignore_for_file: strict_raw_type

import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/devices/ble_gatt_read_cubit.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

part 'ble_read_state.dart';

/// Generic cubit a device implementation implements for reading bluetooth values.
///
/// To add support for more devices, implement a class like [BleGattReadCubit]
/// in the `devices/` directory. Add references to relevant service UUIDs to the
/// [supportedServices] list and cubit construction to the [build] method.
abstract class BleReadCubit extends Cubit<BleReadState> with TypeLogger {
  /// Start reading a characteristic from a device.
  BleReadCubit(super.initialState, {
    required this.device,
  });

  static const supportedServices = [
    BleGattReadCubit.defaultServiceUUID,
  ];

  /// Create instance that understands the device.
  static Future<BleReadCubit?> build(BluetoothDevice device) async {
    final log = Logger('BleReadCubit.build');

    // Get supported services
    final supported = await device.getServices();
    if (supported == null) {
      log.info('Unable to retrieve services for $device');
      return null;
    }

    // Check for BLE GATT service
    final bleGattServiceUUID = device.manager
        .createUuid(BleGattReadCubit.defaultServiceUUID);
    final gattService = supported.firstWhereOrNull(
            (e) => e.uuid.uuid == bleGattServiceUUID.uuid);
    if (gattService != null) {
      log.info('Found GATT service');
      return BleGattReadCubit(device: device);
    }

    // ...

    log.info('No supported service found in $device');
    return null;
  }

  /// Bluetooth device to connect to.
  ///
  /// Must have an active established connection and support the measurement characteristic.
  final BluetoothDevice device;

  /// Take a 'measurement', i.e. read the blood pressure values from the given characteristicUUID
  Future<void> takeMeasurement();

  @mustCallSuper
  @override
  Future<void> close() async {
    if (device.isConnected) {
      await device.disconnect();
    }

    await super.close();
  }

  /// Called after reading from a device returned multiple measurements and the
  /// user chose which measurement they wanted to add.
  Future<void> useMeasurement(BleMeasurementData data) async {
    assert(state is! BleReadSuccess);
    emit(BleReadSuccess(data));
  }
}
