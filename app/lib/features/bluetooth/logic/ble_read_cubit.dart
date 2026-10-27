import 'dart:async';
import 'dart:math';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/microlife_3g_measurement_data.dart';
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
    this.deviceName,
    this.connectionTimeout = const Duration(seconds: 30),
    this.serviceDiscoveryTimeout = const Duration(seconds: 20),
    this.disconnectTimeout = const Duration(seconds: 5),
  }) : super(BleReadInProgress());

  /// Bluetooth device to connect to.
  final Peripheral device;

  final CentralManager cm;

  final Duration connectionTimeout;

  final Duration serviceDiscoveryTimeout;

  final Duration disconnectTimeout;

  final Completer<void> _readCancelled = Completer<void>();
  Future<void>? _disconnectFuture;
  bool _closing = false;

  /// Advertised name of [device], used to detect devices that deviate from the
  /// GATT spec (currently some Beurer devices, see [isKnownBigEndianDevice]).
  final String? deviceName;

  static const defaultServiceUUID = '1810';
  static const defaultCharacteristicUUID = '2A35';

  static const yonkerServiceUUID = 'cdeacd80-5235-4c07-8846-93a37ee6b86d';
  static const yonkerCharacteristicUUID =
      'cdeacd81-5235-4c07-8846-93a37ee6b86d';

  static const microlifeServiceUUID = 'fff0';
  static const microlifeNotifyCharacteristicUUID = 'fff1';
  static const microlifeWriteCharacteristicUUID = 'fff2';

  /// How long to let a freshly connected device settle before subscribing.
  static const _settleDelay = Duration(milliseconds: 100);

  /// Maximum number of bytes to be written to the device in a single GATT write.
  static const _microlifeWriteChunkSize = 20;

  static const _microlifeResponseTimeout = Duration(seconds: 30);
  final _microlifeFrameDecoder = MicrolifeFrameDecoder();
  Completer<MicrolifeResponseFrame>? _microlifePendingResponse;
  bool Function(MicrolifeResponseFrame)? _microlifeAcceptsResponse;
  bool _microlifeWriteInFlight = false;

  /// Whether [advertisedName] belongs to a model known to send multi byte
  /// fields big endian instead of the little endian the spec requires.
  ///
  /// Currently supports some Beurer devices. The official Beurer app keeps a
  /// similar list of models and uses it to pick between the byte orders.
  @visibleForTesting
  static bool isKnownBigEndianDevice(String? advertisedName) {
    if (advertisedName == null) return false;
    final normalized = advertisedName.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return const ['BM85'].any(normalized.contains);
  }

  Future<void> _connectDevice() async {
    logger.info('Connecting to ${device.uuid}');
    final result = Completer<void>();
    final subscription = cm.connectionStateChanged
        .where((event) => event.peripheral == device)
        .listen(
          (event) {
            if (result.isCompleted) return;
            switch (event.state) {
              case ConnectionState.connected:
                result.complete();
              case ConnectionState.disconnected:
                break;
            }
          },
          onError: (Object error, StackTrace stack) {
            if (!result.isCompleted) result.completeError(error, stack);
          },
          onDone: () {
            if (!result.isCompleted) {
              result.completeError(
                StateError('Connection state stream closed'),
              );
            }
          },
        );

    try {
      await _runBluetoothPhase('Bluetooth connection', () async {
        await Future.wait<void>([
          cm.connect(device),
          result.future,
        ], eagerError: true);
      }, timeout: connectionTimeout);
    } finally {
      await subscription.cancel();
      if (!result.isCompleted) result.complete();
    }
  }

  Future<T> _runBluetoothPhase<T>(
    String phase,
    Future<T> Function() action, {
    required Duration timeout,
    bool failOnDisconnect = false,
  }) async {
    if (_closing) throw const _BleReadCancelled();
    final disconnected = Completer<T>();
    final disconnectSubscription = failOnDisconnect
        ? cm.connectionStateChanged
              .where(
                (event) =>
                    event.peripheral == device &&
                    event.state == ConnectionState.disconnected,
              )
              .listen((_) {
                if (!disconnected.isCompleted) {
                  disconnected.completeError(
                    StateError('Device disconnected during $phase'),
                  );
                }
              })
        : null;
    try {
      final value = await Future.any<T>([
        Future<T>.sync(action),
        _readCancelled.future.then<T>((_) => throw const _BleReadCancelled()),
        if (failOnDisconnect) disconnected.future,
      ]).timeout(timeout);
      return value;
    } on _BleReadCancelled {
      rethrow;
    } on TimeoutException catch (error) {
      throw _BluetoothPhaseFailure(
        phase,
        'Timed out after ${timeout.inSeconds} seconds. $error',
      );
    } catch (error) {
      throw _BluetoothPhaseFailure(phase, error);
    } finally {
      await disconnectSubscription?.cancel();
    }
  }

  Future<void> _disconnectDevice() =>
      _disconnectFuture ??= _performDisconnect();

  Future<void> _performDisconnect() async {
    try {
      await cm.disconnect(device).timeout(disconnectTimeout);
    } catch (error) {
      logger.warning('Failed to cancel connection to ${device.uuid}: $error');
    }
  }

  /// Take a 'measurement', i.e. read the blood pressure values from the given characteristicUUID
  /// and catch all exceptions to not stall the UI if something goes wrong.
  Future<void> takeMeasurement() async {
    try {
      await _takeMeasurement();
      if (state is BleReadFailure) await _disconnectDevice();
    } on _BleReadCancelled {
      logger.finer('Read cancelled for ${device.uuid}');
    } catch (e, stack) {
      logger.severe('takeMeasurement failed', e, stack);
      if (!_closing && !isClosed && state is BleReadInProgress) {
        emit(BleReadFailure('Could not read from device: $e'));
      }
      await _disconnectDevice();
    }
  }

  Future<void> _takeMeasurement() async {
    logger.finest('takeMeasurement();');
    await _connectDevice();

    logger.finest('starting service discovery...');
    final services = await _runBluetoothPhase(
      'Bluetooth service discovery',
      () => cm.discoverGATT(device),
      timeout: serviceDiscoveryTimeout,
      failOnDisconnect: true,
    );
    if (_closing) throw const _BleReadCancelled();
    if (services.isEmpty) {
      logger.warning(
        'Device ${device.uuid} advertised no services after connecting',
      );
    }

    final gattService = services.firstWhereOrNull(
      (s) => s.uuid == UUID.fromString(defaultServiceUUID),
    );
    if (gattService != null) return _readGatt(gattService);
    logger.finest("didn't get GATT service");

    final yonkerService = services.firstWhereOrNull(
      (s) => s.uuid == UUID.fromString(yonkerServiceUUID),
    );
    if (yonkerService != null) return _readYonker(yonkerService);
    logger.finest("didn't get yonker service");

    final microlifeService = services.firstWhereOrNull(
      (s) => s.uuid == UUID.fromString(microlifeServiceUUID),
    );
    if (microlifeService != null) return _readMicrolife(microlifeService);
    logger.finest("didn't get microlife service");

    emit(
      BleReadFailure(
        'Device ${device.uuid} does not advertise a supported service',
      ),
    );
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

    // The known big endian models also always send the user id without setting
    // its flag, so one device check drives both quirks.
    final bigEndian = isKnownBigEndianDevice(deviceName);
    logger.finer('reading GATT data from $deviceName (bigEndian: $bigEndian)');

    // Read or indicate data;
    final canRead = characteristic.properties.contains(GATTCharacteristicProperty.read);
    final canIndicate = characteristic.properties.contains(GATTCharacteristicProperty.indicate);
    if (canRead) {
      final data = await cm.readCharacteristic(device, characteristic);
      final decodedData = BleMeasurementData.decode(data,
          bigEndian: bigEndian, alwaysSendsUserId: bigEndian);
      if (decodedData == null) {
        logger.warning('Failed to decode GATT measurement $data for $device');
        emit(BleReadFailure('Could not decode data'));
        return;
      }
      emit(BleReadSuccess(decodedData));

    } else if (canIndicate) {
      // Beurer BM85 seems to need some rest between service discovery and subscribing or it will stay silent.
      await Future<void>.delayed(_settleDelay);

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
          .map((e) => BleMeasurementData.decode(e.value,
              bigEndian: bigEndian, alwaysSendsUserId: bigEndian))
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
      // if a device disconnects immediately after a data transfer, disabling notifications throws.
      try {
        await cm.setCharacteristicNotifyState(device, characteristic, state: false);
      } catch (e) {
        logger.finer('Failed to disable GATT notifications: $e');
      }

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
    try {
      await cm.setCharacteristicNotifyState(device, characteristic, state: false);
    } catch (e) {
      logger.finer('Failed to disable yonker notifications: $e');
    }

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
      (c) => c.uuid == UUID.fromString(microlifeNotifyCharacteristicUUID),
    );
    final writeCharacteristic = service.characteristics.firstWhereOrNull(
      (c) => c.uuid == UUID.fromString(microlifeWriteCharacteristicUUID),
    );

    if (notifyCharacteristic == null || writeCharacteristic == null) {
      emit(
        BleReadFailure(
          'Device ${device.uuid} does not provide the expected microlife characteristics',
        ),
      );
      return;
    }

    _microlifeFrameDecoder.clear();
    _microlifePendingResponse = null;
    final subscription = cm.characteristicNotified
        .where(
          (e) =>
              e.characteristic == notifyCharacteristic &&
              e.peripheral == device,
        )
        .listen(
          (e) => _onMicrolifeNotified(e.value),
          onError: (Object error, StackTrace stack) {
            final pending = _microlifePendingResponse;
            if (pending != null && !pending.isCompleted) {
              pending.completeError(error, stack);
            }
          },
        );

    try {
      await _runBluetoothPhase(
        'Microlife notification setup',
        () => cm.setCharacteristicNotifyState(
          device,
          notifyCharacteristic,
          state: true,
        ),
        timeout: serviceDiscoveryTimeout,
        failOnDisconnect: true,
      );

      var use3g = MicrolifeProtocol.isKnown3gDevice(deviceName);
      if (use3g) {
        final version = await _sendMicrolifeCommand(
          writeCharacteristic,
          MicrolifeProtocol.readUserVersionCommand,
          phase: 'Microlife device identification',
          preferWithoutResponse: true,
          accepts: (frame) => frame.payload.length > 1 && frame.payload[0] == 5,
        );
        use3g = version!.marker == 0x31;
      }

      if (!use3g) {
        try {
          await _sendMicrolifeCommand(
            writeCharacteristic,
            MicrolifeProtocol.buildSetTimeCommand(DateTime.now()),
            phase: 'Microlife clock synchronization',
            accepts: (frame) =>
                frame.marker == 0x3A &&
                frame.payload.length == 1 &&
                frame.payload[0] == 0x81,
            timeout: const Duration(seconds: 10),
          );
        } on _BleReadCancelled {
          rethrow;
        } catch (error) {
          logger.warning(
            'Microlife clock synchronization failed, continuing: $error',
          );
        }
      }

      final response = await _sendMicrolifeCommand(
        writeCharacteristic,
        use3g
            ? MicrolifeProtocol.buildRead3gMeasurementsCommand(DateTime.now())
            : MicrolifeProtocol.getMeasurementsCommand,
        phase: 'Microlife stored readings',
        preferWithoutResponse: use3g,
        responseCompletesWrite: true,
        accepts: (frame) =>
            frame.marker == (use3g ? 0x31 : 0x3A) &&
            frame.payload.isNotEmpty &&
            frame.payload[0] == 0 &&
            frame.payload.length >= (use3g ? 29 : 38),
      );
      late final List<BleMeasurementData> measurements;
      String? reviewNotice;
      if (use3g) {
        final history = Microlife3gMeasurementData.decodeHistory(
          response!.payload,
        );
        measurements = history.measurements;
        if (history.rejectedRecords.isNotEmpty) {
          reviewNotice =
              '${history.rejectedRecords.length} of '
              '${response.payload[3]} stored readings were left out because '
              'their date or measurement fields are invalid. '
              '${measurements.isEmpty ? "No valid stored readings are available to import." : "Review the ${measurements.length} remaining readings before importing."}';
        }
      } else {
        measurements = MicrolifeMeasurementData.decodeMeasurements(
          response!.payload,
        ).map((measurement) => measurement.asBleData).toList();
      }

      // Politely tell the device to disconnect (no response is sent).
      if (!_microlifeWriteInFlight) {
        try {
          await _sendMicrolifeCommand(
            writeCharacteristic,
            MicrolifeProtocol.disconnectCommand,
            phase: 'Microlife transfer completion',
            preferWithoutResponse: use3g,
            waitForResponse: false,
            timeout: disconnectTimeout,
          );
        } catch (e) {
          logger.finer('Microlife disconnect command failed: $e');
        }
      }

      if (_closing || isClosed) return;
      if (measurements.isEmpty) {
        emit(
          BleReadFailure(
            reviewNotice ??
                'The monitor returned no stored readings for its selected user. '
                    'Select the user bank on the monitor and try again.',
          ),
        );
      } else if (reviewNotice != null) {
        emit(BleReadMultiple(measurements, reviewNotice: reviewNotice));
      } else if (measurements.length == 1) {
        emit(BleReadSuccess(measurements.first));
      } else {
        emit(BleReadMultiple(measurements));
      }
    } finally {
      await subscription.cancel();
      try {
        if (!_microlifeWriteInFlight) {
          await cm
              .setCharacteristicNotifyState(
                device,
                notifyCharacteristic,
                state: false,
              )
              .timeout(disconnectTimeout);
        }
      } catch (e) {
        logger.finer('Failed to disable microlife notifications: $e');
      }
      await _disconnectDevice();
      _microlifePendingResponse = null;
      _microlifeAcceptsResponse = null;
      _microlifeFrameDecoder.clear();
    }
  }

  /// Reassembles Microlife response frames from one or more notifications and
  /// completes the [_microlifePendingResponse] once a full frame is received.
  void _onMicrolifeNotified(Uint8List value) {
    for (final frame in _microlifeFrameDecoder.add(value)) {
      final pending = _microlifePendingResponse;
      if (pending != null && !pending.isCompleted
          && (_microlifeAcceptsResponse?.call(frame) ?? false)) {
        pending.complete(frame);
      }
    }
  }

  /// Writes [command] to the Microlife write characteristic (in chunks) and,
  /// when [waitForResponse] is true, waits for the decoded response payload.
  Future<MicrolifeResponseFrame?> _sendMicrolifeCommand(
    GATTCharacteristic writeChar,
    List<int> command, {
    required String phase,
    bool Function(MicrolifeResponseFrame)? accepts,
    bool preferWithoutResponse = false,
    bool responseCompletesWrite = false,
    bool waitForResponse = true,
    Duration timeout = _microlifeResponseTimeout,
  }) async {
    Completer<MicrolifeResponseFrame>? completer;
    if (waitForResponse) {
      assert(accepts != null);
      completer = Completer<MicrolifeResponseFrame>();
      _microlifePendingResponse = completer;
      _microlifeAcceptsResponse = accepts;
    }
    final connectionSubscription = completer == null
        ? null
        : cm.connectionStateChanged
              .where((event) => event.peripheral == device)
              .listen(
                (event) {
                  if (event.state == ConnectionState.disconnected &&
                      !completer!.isCompleted) {
                    completer.completeError(
                      StateError('Device disconnected before $phase completed'),
                    );
                  }
                },
                onError: (Object error, StackTrace stack) {
                  if (!completer!.isCompleted) {
                    completer.completeError(error, stack);
                  }
                },
              );

    final withoutResponse = writeChar.properties.contains(
      GATTCharacteristicProperty.writeWithoutResponse,
    );
    final withResponse = writeChar.properties.contains(
      GATTCharacteristicProperty.write,
    );
    final writeType =
        withoutResponse && (preferWithoutResponse || !withResponse)
        ? GATTCharacteristicWriteType.withoutResponse
        : GATTCharacteristicWriteType.withResponse;
    try {
      return await _runBluetoothPhase<MicrolifeResponseFrame?>(
        phase,
        () async {
          Future<void> writeChunks() async {
            if (!withoutResponse && !withResponse) {
              throw StateError(
                'Microlife command characteristic is not writable',
              );
            }
            for (
              var offset = 0;
              offset < command.length;
              offset += _microlifeWriteChunkSize
            ) {
              if (_closing) throw const _BleReadCancelled();
              final end = min(
                offset + _microlifeWriteChunkSize,
                command.length,
              );
              if (_microlifeWriteInFlight) {
                throw StateError('A Microlife write is still pending');
              }
              _microlifeWriteInFlight = true;
              try {
                await cm.writeCharacteristic(
                  device,
                  writeChar,
                  value: Uint8List.fromList(command.sublist(offset, end)),
                  type: writeType,
                );
              } finally {
                _microlifeWriteInFlight = false;
              }
            }
          }

          if (completer == null) {
            await writeChunks();
            return null;
          }
          if (!responseCompletesWrite) {
            final results = await Future.wait<Object?>([
              writeChunks(),
              completer.future,
            ], eagerError: true);
            return results.last as MicrolifeResponseFrame;
          }
          return Future.any<MicrolifeResponseFrame>([
            completer.future,
            writeChunks().then((_) => completer!.future),
          ]);
        },
        timeout: timeout,
        failOnDisconnect: waitForResponse && !responseCompletesWrite,
      );
    } finally {
      await connectionSubscription?.cancel();
      if (completer != null && !completer.isCompleted) {
        completer.completeError(const _BleReadCancelled());
      }
      if (identical(_microlifePendingResponse, completer)) {
        _microlifePendingResponse = null;
        _microlifeAcceptsResponse = null;
      }
    }
  }

  @mustCallSuper
  @override
  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    _readCancelled.complete();
    await _disconnectDevice();
    await super.close();
  }

  /// Called after reading from a device returned multiple measurements and the
  /// user chose which measurement they wanted to add.
  Future<void> useMeasurement(BleMeasurementData data) async {
    assert(state is! BleReadSuccess);
    emit(BleReadSuccess(data));
  }
}

class _BleReadCancelled implements Exception {
  const _BleReadCancelled();
}

class _BluetoothPhaseFailure implements Exception {
  const _BluetoothPhaseFailure(this.phase, this.cause);

  final String phase;
  final Object cause;

  @override
  String toString() => '$phase failed: $cause';
}
