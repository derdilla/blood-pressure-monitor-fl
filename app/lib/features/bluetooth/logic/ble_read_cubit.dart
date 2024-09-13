import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ble_read_state.dart';

/// Logic for reading a characteristic from a device through a "indication".
///
/// For using this Cubit the flow is as follows:
/// 1. Create a instance with the initial [BleReadInProgress] state
/// 2. Wait for either a [BleReadFailure] or a [BleReadSuccess].
///
/// When a read failure is emitted, the only way to try again is to create a new
/// cubit. This should be accompanied with reconnecting to the [_device].
///
/// Internally the class performs multiple steps to successfully read data, if
/// one of them fails the entire cubit fails:
/// 1. Discover services
/// 2. If the searched service is found read characteristics
/// 3. If the searched characteristic is found read its value
/// 4. If binary data is read decode it to object
/// 5. Emit decoded object
class BleReadCubit extends Cubit<BleReadState> with TypeLogger {
  /// Start reading a characteristic from a device.
  BleReadCubit(this._device, {
    required this.serviceUUID,
    required this.characteristicUUID,
  }) : super(BleReadInProgress())
  {
    takeMeasurement();

    // start read timeout
    _timeoutTimer = Timer(const Duration(minutes: 2), () {
      if (state is BleReadInProgress) {
        logger.finer('BleReadCubit timeout reached and still running');
        emit(BleReadFailure('Timed out after 2 minutes'));
      } else {
        logger.finer('BleReadCubit timeout reached with state: $state, ${state is BleReadInProgress}');
      }
    });
  }

  /// Bluetooth device to connect to.
  ///
  /// Must have an active established connection and support the measurement characteristic.
  final BluetoothDevice _device;

  /// UUID of the service to read.
  final String serviceUUID;

  /// UUID of the characteristic to read.
  final String characteristicUUID;
  
  late final Timer _timeoutTimer;

  /// Take a 'measurement', i.e. read the blood pressure values from the given characteristicUUID
  /// TODO: make this generic by accepting a data decoder argument?
  Future<void> takeMeasurement() async {
    final success = await _device.connect(
      onDisconnect: (wasConnected) {
        logger.finer('BleReadCubit: device.onDisconnect called: wasConnected: $wasConnected');
        if (wasConnected) {
          emit(BleReadFailure('Device unexpectedly disconnected'));
        }
        return true;
      },
      onError: (Object err) => emit(BleReadFailure(err.toString()))
    );
    if (success) {
      final uuidService = _device.manager.createUuidFromString(serviceUUID);
      final service = await _device.getServiceByUuid(uuidService);
      logger.finer('BleReadCubit: Found service: $service');
      if (service == null) {
        emit(BleReadFailure('Device does not provide the expected service with uuid $serviceUUID'));
        return;
      }

      final uuidCharacteristic = _device.manager.createUuidFromString(characteristicUUID);
      final characteristic = await service.getCharacteristicByUuid(uuidCharacteristic);
      logger.finer('BleReadCubit: Found characteristic: $characteristic');
      if (characteristic == null) {
        emit(BleReadFailure('Device does not provide the expected characteristic with uuid $characteristicUUID'));
        return;
      }

      final List<Uint8List> data = [];
      final success = await _device.getCharacteristicValueByUuid(characteristic, data);
      logger.finer('BleReadCubit(success: $success): Got data: $data');
      if (!success) {
        emit(BleReadFailure('Could not retrieve characteristic value'));
        return;
      }

      final List<BleMeasurementData> measurements = [];

      for (final item in data) {
        final decodedData = BleMeasurementData.decode(item, 0);
        if (decodedData == null) {
          logger.severe('BleReadCubit decoding failed', item);
          emit(BleReadFailure('Could not decode data'));
          return;
        }

        measurements.add(decodedData);
      }

      if (measurements.length > 1) {
        logger.finer('BleReadMultiple decoded ${measurements.length} measurements');
        emit(BleReadMultiple(measurements));
      } else {
        logger.finer('BleReadCubit decoded: ${measurements.first}');
        emit(BleReadSuccess(measurements.first));
      }
    }
  }

  @override
  Future<void> close() async {
    logger.finer('BleReadCubit close');
    _timeoutTimer.cancel();

    if (_device.isConnected) {
      await _device.disconnect();
    }

    await super.close();
  }

  /// Called after reading from a device returned multiple measurements and the user chose which measurement they wanted to add.
  Future<void> useMeasurement(BleMeasurementData data) async {
    assert(state is! BleReadSuccess);
    emit(BleReadSuccess(data));
  }
}
