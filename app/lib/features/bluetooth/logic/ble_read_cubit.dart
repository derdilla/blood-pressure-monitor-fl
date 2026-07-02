import 'dart:async';
import 'dart:math';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/microlife_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/microlife_protocol.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/yonker_measurement_data.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ble_read_state.dart';

/// Generic cubit a device implementation implements for reading bluetooth values.
class BleReadCubit extends Cubit<BleReadState> with TypeLogger {
  /// Start reading a characteristic from a device.
  BleReadCubit({
    required this.device,
    required this.cm,
  }): super(BleReadInProgress());

  /// Bluetooth device to connect to.
  final Peripheral device;

  final CentralManager cm;

  static const defaultServiceUUID = '1810';
  static const defaultCharacteristicUUID = '2A35';

  static const yonkerServiceUUID = 'cdeacd80-5235-4c07-8846-93a37ee6b86d';
  static const yonkerCharacteristicUUID = 'cdeacd81-5235-4c07-8846-93a37ee6b86d';

  static const microlifeServiceUUID = 'fff0';
  static const microlifeNotifyCharacteristicUUID = 'fff1';
  static const microlifeWriteCharacteristicUUID = 'fff2';

  /// Maximum number of bytes to be written to the device in a single GATT write.
  static const _microlifeWriteChunkSize = 20;

  static const _microlifeResponseTimeout = Duration(seconds: 30);
  final List<int> _microlifeResponseByteBuffer = [];
  Completer<Uint8List>? _microlifePendingResponse;

  Future<bool> _connectDevice() async {
    logger.info('Connecting to ${device.uuid}');
    final result = cm.connectionStateChanged
        .where((e) => e.peripheral == device)
        .first;
    await cm.connect(device);
    logger.finer('connect command send');
    final success = await result;
    logger.finer('Connection result: $success');
    return success.state == ConnectionState.connected;
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
            (s) => s.uuid == UUID.fromString(defaultServiceUUID));
    if (gattService != null) return _readGatt(gattService);
    logger.finest("didn't get GATT service");

    final yonkerService = services.firstWhereOrNull(
            (s) => s.uuid == UUID.fromString(yonkerServiceUUID));
    if (yonkerService != null) return _readYonker(yonkerService);
    logger.finest("didn't get yonker service");

    final microlifeService = services.firstWhereOrNull(
            (s) => s.uuid == UUID.fromString(microlifeServiceUUID));
    if (microlifeService != null) return _readMicrolife(microlifeService);
    logger.finest("didn't get microlife service");

    emit(BleReadFailure('Device ${device.uuid} does not advertise a supported service'));
  }

  Future<void> _readGatt(GATTService service) async {
    // See assigned numbers:
    // https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/Assigned_Numbers/out/en/Assigned_Numbers.pdf?v=1706215305114

    final characteristic = service.characteristics
        .firstWhereOrNull((c) => c.uuid == UUID.fromString(defaultCharacteristicUUID));

    if (characteristic == null) {
      emit(BleReadFailure('Device ${device.uuid} does not provide the expected GATT characteristic'));
      return;
    }

    // Read or indicate data;
    final canRead = characteristic.properties.contains(GATTCharacteristicProperty.read);
    final canIndicate = characteristic.properties.contains(GATTCharacteristicProperty.indicate);
    if (canRead) {
      final data = await cm.readCharacteristic(device, characteristic);
      final decodedData = BleMeasurementData.decode(data);
      if (decodedData == null) {
        logger.warning('Failed to decode GATT measurement $data for $device');
        emit(BleReadFailure('Could not decode data'));
        return;
      }
      emit(BleReadSuccess(decodedData));

    } else if (canIndicate) {
      final completer = Completer<void>();
      final data = <BleMeasurementData>[];
      final connectionSubscription = cm.connectionStateChanged.listen((e) {
        if (e.peripheral == device && e.state == ConnectionState.disconnected && !completer.isCompleted) {
          completer.complete();
        }
      });
      final dataSubscription = cm.characteristicNotified
          .where((e) => e.characteristic == characteristic
                  && e.peripheral == device)
          .map((e) => BleMeasurementData.decode(e.value))
          .listen((e) { if (e != null) data.add(e); },
              onDone: () {
                if (!completer.isCompleted) completer.complete();
              },
              onError: ([Object? e]) {
                logger.warning(e);
                if (!completer.isCompleted) completer.complete();
              });
      await cm.setCharacteristicNotifyState(device, characteristic, state: true);
      await completer.future;
      await cm.setCharacteristicNotifyState(device, characteristic, state: false);

      await connectionSubscription.cancel();
      await dataSubscription.cancel();

      if (data.isEmpty) {
        emit(BleReadFailure('No data received'));
      } else if (data.length == 1) {
        emit(BleReadSuccess(data.first));
      } else {
        emit(BleReadMultiple(data));
      }

    } else {
      emit(BleReadFailure('Unable to get data from characteristic of GATT device ${device.uuid}'));
    }
  }

  /// This reads from a low-cost device that may be sold under different brands:
  /// - Yonker YK-IBPA1
  /// - Yonker YK-BPW5
  /// - Yongrow YK-IBPA1
  /// - METIKO MT-YK-BPA1
  Future<void> _readYonker(GATTService service) async {
    // The process is as follows:
    // 1. take an actual measurement
    // 2. Connect to the device AFTER measurement
    // 4. subscribe to the service/characteristic
    // 5. the device sends us a notification (wrong timestamp)

    logger.finest('_readYonker()');
    final characteristic = service.characteristics
        .firstWhereOrNull((c) => c.uuid == UUID.fromString(yonkerCharacteristicUUID));

    if (characteristic == null) {
      emit(BleReadFailure('Device ${device.uuid} does not provide the expected yonker characteristic'));
      return;
    }

    final future = cm.characteristicNotified
        .where((e) {
          logger.fine('Received notification: ${e.value} satisfying ${e.peripheral == device}, ${e.characteristic == characteristic}');
          return e.characteristic == characteristic && e.peripheral == device;
        })
        .map((e) => YonkerMeasurementData.decode(e.value)?.asBleData)
        .first;
    await cm.setCharacteristicNotifyState(device, characteristic, state: true);
    final data = await future;
    await cm.setCharacteristicNotifyState(device, characteristic, state: false);

    if (data == null) {
      logger.warning('Failed to decode yonker measurement $data for $device');
      emit(BleReadFailure('Could not decode data'));
      return;
    }
    emit(BleReadSuccess(data));
  }

  /// This reads stored measurements from a Microlife blood pressure monitor
  /// (e.g. BP3GY1-2N), which uses a vendor specific protocol on the `fff0`
  /// service instead of the standard GATT blood pressure service.
  ///
  /// The process is as follows:
  /// 1. subscribe to notifications on `fff1` (responses can possibly be split across multiple packets)
  /// 2. set the device clock by writing to `fff2`
  /// 3. request all stored measurements
  /// 4. ask the device to disconnect
  Future<void> _readMicrolife(GATTService service) async {
    logger.finest('_readMicrolife()');
    final notifyCharacteristic = service.characteristics.firstWhereOrNull(
            (c) => c.uuid == UUID.fromString(microlifeNotifyCharacteristicUUID));
    final writeCharacteristic = service.characteristics.firstWhereOrNull(
            (c) => c.uuid == UUID.fromString(microlifeWriteCharacteristicUUID));

    if (notifyCharacteristic == null || writeCharacteristic == null) {
      emit(BleReadFailure('Device ${device.uuid} does not provide the expected microlife characteristics'));
      return;
    }

    _microlifeResponseByteBuffer.clear();
    _microlifePendingResponse = null;
    final subscription = cm.characteristicNotified
        .where((e) => e.characteristic == notifyCharacteristic && e.peripheral == device)
        .listen((e) => _onMicrolifeNotified(e.value));

    try {
      await cm.setCharacteristicNotifyState(device, notifyCharacteristic, state: true);

      // Keep the device clock accurate for future measurements.
      try {
        await _sendMicrolifeCommand(writeCharacteristic,
            MicrolifeProtocol.buildSetTimeCommand(DateTime.now()),
            timeout: const Duration(seconds: 10));
      } catch (e) {
        logger.warning('Microlife set time failed, continuing: $e');
      }

      final payload = await _sendMicrolifeCommand(
          writeCharacteristic, MicrolifeProtocol.getMeasurementsCommand);
      final measurements = MicrolifeMeasurementData.decodeMeasurements(payload)
          .map((m) => m.asBleData)
          .toList();

      // Politely tell the device to disconnect (no response is sent).
      try {
        await _sendMicrolifeCommand(
            writeCharacteristic, MicrolifeProtocol.disconnectCommand,
            waitForResponse: false);
      } catch (e) {
        logger.finer('Microlife disconnect command failed: $e');
      }

      if (measurements.isEmpty) {
        emit(BleReadFailure('No data received'));
      } else if (measurements.length == 1) {
        emit(BleReadSuccess(measurements.first));
      } else {
        emit(BleReadMultiple(measurements));
      }
    } on TimeoutException {
      logger.warning('Microlife communication timed out for ${device.uuid}');
      emit(BleReadFailure('No data received'));
    } catch (e) {
      logger.warning('Microlife communication failed: $e');
      emit(BleReadFailure('Could not decode data'));
    } finally {
      await subscription.cancel();
      try {
        await cm.setCharacteristicNotifyState(device, notifyCharacteristic, state: false);
      } catch (e) {
        logger.finer('Failed to disable microlife notifications: $e');
      }
      _microlifePendingResponse = null;
      _microlifeResponseByteBuffer.clear();
    }
  }

  /// Reassembles Microlife response frames from one or more notifications and
  /// completes the [_microlifePendingResponse] once a full frame is received.
  void _onMicrolifeNotified(Uint8List value) {
    logger.fine('Microlife notification: $value');
    _microlifeResponseByteBuffer.addAll(value);

    final expectedLength = MicrolifeProtocol.expectedFrameLength(_microlifeResponseByteBuffer);
    if (expectedLength == null || _microlifeResponseByteBuffer.length < expectedLength) {
      return; // wait for the remaining packets
    }

    final frame = _microlifeResponseByteBuffer.sublist(0, expectedLength);
    _microlifeResponseByteBuffer.clear();

    final pending = _microlifePendingResponse;
    if (pending == null || pending.isCompleted) return;

    final payload = MicrolifeProtocol.parseResponsePayload(frame);
    if (payload == null) {
      pending.completeError(StateError('Invalid microlife frame: $frame'));
    } else {
      pending.complete(payload);
    }
  }

  /// Writes [command] to the Microlife write characteristic (in chunks) and,
  /// when [waitForResponse] is true, waits for the decoded response payload.
  Future<Uint8List> _sendMicrolifeCommand(
    GATTCharacteristic writeChar,
    List<int> command, {
    bool waitForResponse = true,
    Duration timeout = _microlifeResponseTimeout,
  }) async {
    _microlifeResponseByteBuffer.clear();
    Completer<Uint8List>? completer;
    if (waitForResponse) {
      completer = Completer<Uint8List>();
      _microlifePendingResponse = completer;
    }

    final writeType = writeChar.properties.contains(GATTCharacteristicProperty.write)
        ? GATTCharacteristicWriteType.withResponse
        : GATTCharacteristicWriteType.withoutResponse;

    for (var offset = 0; offset < command.length; offset += _microlifeWriteChunkSize) {
      final end = min(offset + _microlifeWriteChunkSize, command.length);
      await cm.writeCharacteristic(
        device,
        writeChar,
        value: Uint8List.fromList(command.sublist(offset, end)),
        type: writeType,
      );
    }

    if (completer == null) return Uint8List(0);
    try {
      return await completer.future.timeout(timeout);
    } finally {
      if (identical(_microlifePendingResponse, completer)) {
        _microlifePendingResponse = null;
      }
    }
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
