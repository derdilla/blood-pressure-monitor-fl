import 'dart:async';

import 'package:blood_pressure_app/components/ble_input/ble_input_events.dart';
import 'package:blood_pressure_app/components/ble_input/ble_input_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// TODO: docs
class BleInputBloc extends Bloc<BleInputEvent, BleInputState> {
  final _ble = FlutterReactiveBle();
  final Set<DiscoveredDevice> _availableDevices = {};

  final _requiredServices = [
    Uuid.parse('1810'),
  ];
  // TODO: use repo

  BleInputBloc(): super(BleInputClosed()) {
    on<BleInputOpened>((event, emit) async {
      try {
        emit(BleInputLoadInProgress());
        await _ble.initialize();
        final deviceStream = _ble.scanForDevices(withServices: _requiredServices,);
        await emit.forEach(deviceStream, onData: (DiscoveredDevice device) {
          _availableDevices.add(device);
          return BleInputLoadSuccess(_availableDevices.toList());
        },);
      } catch (e) { // TODO: ask for permission
        // TODO: check its really this type of exception
        emit(BleInputLoadFailure());
      }
    });
    on<BleInputDeviceSelected>((event, emit) async {
      emit(BleConnectInProgress());
      try {
        final connectionUpdateStream = _ble.connectToAdvertisingDevice(
          id: event.device.id,
          prescanDuration: const Duration(seconds: 5),
          withServices: _requiredServices,
          connectionTimeout: const Duration(minutes: 2),
        );
        await emit.forEach(connectionUpdateStream,
          onData: (ConnectionStateUpdate update) {
            if (update.failure != null) {
              return BleConnectFailed();
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
              _ble.subscribeToCharacteristic(characteristic).listen((event) {
                // TODO: decode byte array and create measurement
              });

              // TODO: move reading code


              return BleConnectSuccess();
            } else if (update.connectionState == DeviceConnectionState.connecting) {
              return BleConnectInProgress();
            }
            return BleConnectFailed();
          },
        );
      } on TimeoutException {
        emit(BleConnectFailed());
      }

    });
    // TODO: use _ble.statusStream

    // TODO: check if information about measurement start can be obtained
    // through bluetooth

  }

}