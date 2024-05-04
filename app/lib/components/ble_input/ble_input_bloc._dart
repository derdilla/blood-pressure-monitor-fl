import 'dart:async';

import 'package:blood_pressure_app/components/ble_input/ble_input_events.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_state.dart';
import 'package:blood_pressure_app/components/ble_input/measurement_characteristic.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';

/// Logic for bluetooth measurement input.
class BleInputBloc extends Bloc<BleInputEvent, BleInputState> {
  /// Create logic component for bluetooth measurement input.
  BleInputBloc(): super(BleInputClosed()) {
    on<OpenBleInput>(_onOpenBleInput);
    on<CloseBleInput>(_onCloseBleInput);
    on<BleInputDeviceSelected>(_onBleInputDeviceSelected);
    // TODO: figure out exhaustive approach

    // TODO: show capabilities during testing:
    // _ble.getDiscoveredServices()

    // Interesting available characteristics:
    // - Battery Health Information 0x2BEB (and other battery ...)
    // - Blood Pressure Feature 0x2A49
    // - Device Name 0x2A00
    // - Enhanced Blood Pressure Measurement 0x2B34
    // - Live Health Observations 0x2B8B

  }

  final _ble = FlutterReactiveBle();

  final Set<DiscoveredDevice> _availableDevices = {};

  StreamSubscription<DiscoveredDevice>? _deviceStreamSubscribtion;
  StreamSubscription<ConnectionStateUpdate>? _connectionUpdateStreamSubscribtion;

  final _requiredServices = [
    Uuid.parse('1810'),
  ];
  
  
  Future<void> _onOpenBleInput(OpenBleInput event, Emitter<BleInputState> emit) async {
    emit(BleInputLoadInProgress());
    if (await Permission.bluetoothConnect.isDenied) {
      emit(BleInputPermissionFailure());
      await Permission.bluetoothConnect.request();
      return;
    }
    emit(BleInputLoadInProgress());
    if (await Permission.bluetoothScan.isDenied) {
      emit(BleInputPermissionFailure());
      await Permission.bluetoothScan.request();
      return;
    }
    emit(BleInputLoadInProgress());

    try {
      await _ble.initialize();
      final deviceStream = _ble.scanForDevices(withServices: _requiredServices,);
      await _deviceStreamSubscribtion?.cancel();
      _deviceStreamSubscribtion = deviceStream.listen((device) {
        if (!_availableDevices.any((e) => e.name == device.name)) {
          _availableDevices.add(device);
          emit(BleInputLoadSuccess(_availableDevices.toList()));
        }
      });
      await _deviceStreamSubscribtion!.asFuture();
    } catch (e) {
      emit(BleInputLoadFailure());
    }
  }

  Future<void> _onCloseBleInput(CloseBleInput event, Emitter<BleInputState> emit) async {
    await _deviceStreamSubscribtion?.cancel();
    await _connectionUpdateStreamSubscribtion?.cancel();
    await _ble.deinitialize();
    emit(BleInputClosed());
    // TODO: cleanup
  }

  Future<void> _onBleInputDeviceSelected(BleInputDeviceSelected event, Emitter<BleInputState> emit) async {
    await _deviceStreamSubscribtion?.cancel();
    emit(BleConnectInProgress());
    try {
      await _connectionUpdateStreamSubscribtion?.cancel();
      _connectionUpdateStreamSubscribtion = _ble.connectToAdvertisingDevice(
        id: event.device.id,
        prescanDuration: const Duration(seconds: 5),
        withServices: _requiredServices,
        connectionTimeout: const Duration(minutes: 2),
      ).listen((update) {
        if (update.failure != null) {
          emit(BleConnectFailed());
        } else if (update.connectionState == DeviceConnectionState.connected) {
          // characteristics IDs (https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/Assigned_Numbers/out/en/Assigned_Numbers.pdf?v=1711151578821):
          // - Blood Pressure Measurement: 0x2A35 (https://bitbucket.org/bluetooth-SIG/public/src/main/gss/org.bluetooth.characteristic.blood_pressure_measurement.yaml)
          // - Blood Pressure Records: 0x2A36 (https://bitbucket.org/bluetooth-SIG/public/src/main/gss/org.bluetooth.characteristic.blood_pressure_record.yaml)
          //
          // A record represents a stored measurement, so in theory we should
          // search for a measurement.
          // Definition: https://www.bluetooth.com/specifications/bls-1-1-1/
          final characteristic = QualifiedCharacteristic(
            characteristicId: Uuid.parse('2A35'),
            serviceId: Uuid.parse('1810'),
            deviceId: event.device.id,
          );
          // TODO: extract subscription
          _ble.subscribeToCharacteristic(characteristic).listen((List<int> data) async {
            await _deviceStreamSubscribtion?.cancel();
            await _connectionUpdateStreamSubscribtion?.cancel();
            emit(BleMeasurementInProgress());
            debugLog.add('BLE MESSAGE: $data');
            final decoded = BPMeasurementCharacteristic.parse(data);
            final record = BloodPressureRecord(
              decoded.time ?? DateTime.now(),
              // TODO: unit conversions
              decoded.sys.toInt(),
              decoded.dia.toInt(),
              decoded.pul?.toInt(),
              '',
            );
            emit(BleMeasurementSuccess(record,
              bodyMoved: decoded.bodyMoved,
              cuffLoose: decoded.cuffLoose,
              irregularPulse: decoded.irregularPulse,
              improperMeasurementPosition: decoded.improperMeasurementPosition,
              measurementStatus: decoded.measurementStatus,
            ),);
          });
          emit(BleConnectSuccess());
        } else if (update.connectionState == DeviceConnectionState.connecting) {
          emit(BleConnectInProgress());
        } else {
          emit(BleConnectFailed());
        }
      });
      await _connectionUpdateStreamSubscribtion!.asFuture();
    } on TimeoutException {
      emit(BleConnectFailed());
    }
  }
}
