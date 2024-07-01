import 'dart:async';

import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
class BleReadCubit extends Cubit<BleReadState> {
  /// Start reading a characteristic from a device.
  BleReadCubit(this._device, {
    required this.serviceUUID,
    required this.characteristicUUID,
  }) : super(BleReadInProgress())
  {
    _subscription = _device.connectionState
      .listen(_onConnectionStateChanged);
    // timeout
    _timeoutTimer = Timer(const Duration(minutes: 2), () {
      if (state is BleReadInProgress) {
        Log.trace('BleReadCubit timeout reached and still running');
        emit(BleReadFailure());
      } else {
        Log.trace('BleReadCubit timeout reached with state: $state, ${state is BleReadInProgress}');
      }
    });
  }

  /// UUID of the service to read.
  final Guid serviceUUID;

  /// UUID of the characteristic to read.
  final Guid characteristicUUID;

  /// Bluetooth device to connect to.
  ///
  /// Must have an active established connection and support the measurement
  /// characteristic.
  final BluetoothDevice _device;
  
  late final StreamSubscription<BluetoothConnectionState> _subscription;
  late final Timer _timeoutTimer;
  StreamSubscription<List<int>>? _indicationListener;

  @override
  Future<void> close() async {
    Log.trace('BleReadCubit close');
    await _subscription.cancel();
    _timeoutTimer.cancel();

    if (_device.isConnected) {
      try {
        Log.trace('BleReadCubit close: Attempting disconnect from ${_device.advName}');
        await _device.disconnect();
        assert(_device.isDisconnected);
      } catch (e) {
        Log.err('unable to disconnect', [e, _device]);
      }
    }

    await super.close();
  }

  bool _ensureConnectionInProgress = false;
  Future<void> _ensureConnection([int attemptCount = 0]) async {
    Log.trace('BleReadCubit _ensureConnection');
    if (_ensureConnectionInProgress) return;
    _ensureConnectionInProgress = true;
    
    if (_device.isAutoConnectEnabled) {
      Log.trace('BleReadCubit Waiting for auto connect...');
      _ensureConnectionInProgress = false;
      return;
    }
    
    if (_device.isDisconnected) {
      Log.trace('BleReadCubit _ensureConnection: Attempting to connect with ${_device.advName}');
      try {
        await _device.connect();
      } on FlutterBluePlusException catch (e) {
        Log.err('BleReadCubit _device.connect failed:', [_device, e]);
      }
      
      if (_device.isDisconnected) {
        Log.trace('BleReadCubit _ensureConnection: Device not connected');
        _ensureConnectionInProgress = false;
        if (attemptCount >= 5) {
          emit(BleReadFailure());
          return;
        } else {
          return _ensureConnection(attemptCount + 1);
        }
      } else {
        Log.trace('BleReadCubit Connection successful');
      }
    }
    assert(_device.isConnected);
    _ensureConnectionInProgress = false;
  }

  Future<void> _onConnectionStateChanged(BluetoothConnectionState state) async {
    Log.trace('BleReadCubit _onConnectionStateChanged: $state');
    if (super.state is BleReadSuccess) return;
    if (state == BluetoothConnectionState.disconnected) {
      Log.trace('BleReadCubit _onConnectionStateChanged disconnected: '
        '${_device.disconnectReason} Attempting reconnect');
      await _ensureConnection();
      return;
    }
    assert(state == BluetoothConnectionState.connected, 'state should be '
      'connected as connecting and disconnecting are not streamed by android');
    assert(_device.isConnected);

    // Query actual services supported by the device. While they must be
    // rediscovered when a disconnect happens, this object is also recreated.
    late final List<BluetoothService> allServices;
    try {
      allServices = await _device.discoverServices();
      Log.trace('BleReadCubit allServices: $allServices');
    } catch (e) {
      Log.err('service discovery', [_device, e]);
      emit(BleReadFailure());
      return;
    }

    // [Guid.str] trims standard parts from the uuid. 0x1810 is the blood
    // pressure uuid. https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/group___u_u_i_d___s_e_r_v_i_c_e_s.html
    final BluetoothService? service = allServices
      .firstWhereOrNull((BluetoothService s) => s.uuid == serviceUUID);
    if (service == null) {
      Log.err('unsupported service', [_device, allServices]);
      emit(BleReadFailure());
      return;
    }

    // https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/group___u_u_i_d___c_h_a_r_a_c_t_e_r_i_s_t_i_c_s.html#ga95fc99c7a99cf9d991c81027e4866936
    final List<BluetoothCharacteristic> allCharacteristics = service.characteristics;
    Log.trace('BleReadCubit allCharacteristics: $allCharacteristics');
    final BluetoothCharacteristic? characteristic = allCharacteristics
      .firstWhereOrNull((c) => c.uuid == characteristicUUID,);
    if (characteristic == null) {
      Log.err('no characteristic', [_device, allServices, allCharacteristics]);
      emit(BleReadFailure());
      return;
    }

    // This characteristic only supports indication so we need to listen to values.
    await _indicationListener?.cancel();
    _indicationListener = characteristic
      .onValueReceived.listen((rawData) {
        Log.trace('BleReadCubit data received: $rawData');
        final decodedData = BleMeasurementData.decode(rawData, 0);
        if (decodedData == null) {
          Log.err('BleReadCubit decoding failed', [ rawData ]);
          emit(BleReadFailure());
        } else {
          Log.trace('BleReadCubit decoded: $decodedData');
          emit(BleReadSuccess(decodedData));
        }
        _indicationListener?.cancel();
        _indicationListener = null;
      });

    final bool indicationsSet = await characteristic.setNotifyValue(true);
    Log.trace('BleReadCubit indicationsSet: $indicationsSet');
  }
}
