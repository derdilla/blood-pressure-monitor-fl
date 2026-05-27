// TODO: cleanup types
// ignore_for_file: strict_raw_type

import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/yonker_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/devices/ble_gatt_read_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/devices/yonker_read_cubit.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ble_read_state.dart';

/// Generic cubit a device implementation implements for reading bluetooth values.
///
/// To add support for more devices, implement a class like [BleGattReadCubit]
/// in the `devices/` directory. Add references to relevant service UUIDs to the
/// [supportedServices] list and cubit construction to the [build] method.
class BleReadCubit extends Cubit<BleReadState> with TypeLogger {
  /// Start reading a characteristic from a device.
  BleReadCubit({
    required this.device,
    required this.cm,
  }): super(BleReadInProgress());

  /// Bluetooth device to connect to.
  final Peripheral device;

  final CentralManager cm;

  Future<bool> _connectDevice({int retries = 3}) async {
    logger.info('Connecting to ${device.uuid}');
    final result = cm.connectionStateChanged
        .where((e) => e.peripheral == device)
        .first;
    await cm.connect(device);
    logger.finer('connect command send');
    final success = await result;
    logger.finer('Connection result: $success');
    if (success.state == ConnectionState.disconnected) {
      logger.info('Device disconnected');
      if (retries > 0) return _connectDevice(retries: retries - 1);
      logger.finest('No retries left');
      return false;
    }
    logger.finer('Successfully connected to ${device.uuid}');
    return true;
  }

  /// Take a 'measurement', i.e. read the blood pressure values from the given characteristicUUID
  Future<void> takeMeasurement() async {
    logger.finest('takeMeasurement();');
    if (!await _connectDevice()) {
      emit(BleReadFailure('Unable to connect to device: ${device.uuid}'));
      return;
    }

    logger.finest('starting service discovery...');
    final services = await cm.discoverGATT(device);
    if (services.isEmpty) {
      logger.warning('Device ${device.uuid} advertised no services after connecting');
    }

    final gattService = services.firstWhereOrNull(
            (s) => s.uuid == UUID.fromString(BleGattReadCubit.defaultServiceUUID));
    if (gattService != null) return _readGatt(gattService);
    logger.finest("didn't get GATT service");

    final yonkerService = services.firstWhereOrNull(
            (s) => s.uuid == UUID.fromString(YonkerReadCubit.defaultServiceUUID));
    if (yonkerService != null) return _readYonker(yonkerService);
    logger.finest("didn't get yonker service");

    emit(BleReadFailure('Device ${device.uuid} does not advertise a supported service'));
  }

  Future<void> _readGatt(GATTService service) async {
    // See assigned numbers:
    // https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/Assigned_Numbers/out/en/Assigned_Numbers.pdf?v=1706215305114

    final characteristic = service.characteristics
        .firstWhereOrNull((c) => c.uuid == UUID.fromString(BleGattReadCubit.defaultCharacteristicUUID));

    if (characteristic == null) {
      emit(BleReadFailure('Device ${device.uuid} does not provide the expected GATT characteristic'));
      return;
    }

    // Read or indicate data;
    Uint8List? data;
    final canRead = characteristic.properties.contains(GATTCharacteristicProperty.read);
    final canIndicate = characteristic.properties.contains(GATTCharacteristicProperty.indicate);
    if (canRead) {
      data = await cm.readCharacteristic(device, characteristic);
    } else if (canIndicate) {
      final future = cm.characteristicNotified
          .where((e) => e.characteristic == characteristic
                  && e.peripheral == device)
          .map((e) => e.value)
          .first;
      await cm.setCharacteristicNotifyState(device, characteristic, state: true);
      data = await future;
      // FIXME: from bug reports we know that more data may follow for some devices
      // We should handle that and return: BleReadMultiple;
      // For that we need to wait until the device disconnects naturally
      await cm.setCharacteristicNotifyState(device, characteristic, state: false);
    }

    if (data == null) {
      emit(BleReadFailure('Unable to get data from characteristic of GATT device ${device.uuid}'));
      return;
    }

    final decodedData = BleMeasurementData.decode(data);
    if (decodedData == null) {
      logger.warning('Failed to decode GATT measurement $data for $device');
      emit(BleReadFailure('Could not decode data'));
      return;
    }

    emit(BleReadSuccess(decodedData));
  }

  Future<void> _readYonker(GATTService service) async {
    /// This is a low-cost device that may be sold under different brands/models:
    /// - Yonker YK-IBPA1
    /// - Yonker YK-BPW5
    /// - Yongrow YK-IBPA1 (confirmed)
    /// - METIKO MT-YK-BPA1

    // The process is as follows:
    // 1. take an actual measurement
    // 2. Connect to the device AFTER measurement
    // 4. subscribe to the service/characteristic
    // 5. the device sends us a notification (wrong timestamp)
    logger.finest('_readYonker()');
    final characteristic = service.characteristics
        .firstWhereOrNull((c) => c.uuid == UUID.fromString(YonkerReadCubit.defaultCharacteristicUUID));

    if (characteristic == null) {
      emit(BleReadFailure('Device ${device.uuid} does not provide the expected yonker characteristic'));
      return;
    }

    final future = cm.characteristicNotified
        .where((e) => e.characteristic == characteristic
        && e.peripheral == device)
        .map((e) => e.value)
        .first;
    await cm.setCharacteristicNotifyState(device, characteristic, state: true);
    // FIXME: the device sends all values / the earliest value?
    final data = await future;
    await cm.setCharacteristicNotifyState(device, characteristic, state: false);

    final decodedData = YonkerMeasurementData.decode(data);
    if (decodedData == null) {
      logger.warning('Failed to decode yonker measurement $data for $device');
      emit(BleReadFailure('Could not decode data'));
      return;
    }

    emit(BleReadSuccess(decodedData.asBleData));
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    try {
      await cm.disconnect(device).timeout(Duration(seconds: 10));
    } catch (e) {
      logger.warning('Failed to disconnect from ${device.uuid}: $e');
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
