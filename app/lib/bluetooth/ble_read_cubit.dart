import 'dart:async';

import 'package:blood_pressure_app/bluetooth/characteristic_decoder.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'ble_read_state.dart';

/// Logic for reading a characteristic from a device.
///
/// May only be used on devices that are fully connected.
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
  BleReadCubit(this._device)
    : super(BleReadInProgress()){
    _subscription = _device.connectionState
      .listen(_onConnectionStateChanged);
    _device.cancelWhenDisconnected(_device.mtu.listen((int mtu) => Log.trace('BleReadCubit mtu: $mtu'))); // TODO: remove
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
  
  static const String _kServiceID = '1810';
  static const String _kCharacteristicID = '2A35';

  /// Bluetooth device to connect to.
  ///
  /// Must have an active established connection and support the measurement
  /// characteristic.
  final BluetoothDevice _device;
  
  late final StreamSubscription<BluetoothConnectionState> _subscription;
  late final Timer _timeoutTimer;

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

  bool _debugEnsureConnectionInProgress = false;
  Future<void> _ensureConnection() async {
    Log.trace('BleReadCubit _ensureConnection');
    assert(!_debugEnsureConnectionInProgress);
    if (kDebugMode) _debugEnsureConnectionInProgress = true;
    
    if (_device.isAutoConnectEnabled) {
      Log.trace('BleReadCubit Waiting for auto connect...');
      if (kDebugMode) _debugEnsureConnectionInProgress = false;
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
        emit(BleReadFailure());
        if (kDebugMode) _debugEnsureConnectionInProgress = false;
        return;
      } else {
        Log.trace('BleReadCubit Connection successful');
      }
    }
    assert(_device.isConnected);
    if (kDebugMode) _debugEnsureConnectionInProgress = false;
  }

  Future<void> _onConnectionStateChanged(BluetoothConnectionState state) async {
    Log.trace('BleReadCubit _onConnectionStateChanged: $state');
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
      .firstWhereOrNull((BluetoothService s) => s.uuid.str == _kServiceID);
    if (service == null) {
      Log.err('unsupported service', [_device, allServices]);
      emit(BleReadFailure());
      return;
    }

    // https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/group___u_u_i_d___c_h_a_r_a_c_t_e_r_i_s_t_i_c_s.html#ga95fc99c7a99cf9d991c81027e4866936
    final List<BluetoothCharacteristic> allCharacteristics = service.characteristics;
    Log.trace('BleReadCubit allCharacteristics: $allCharacteristics');
    final BluetoothCharacteristic? characteristic = allCharacteristics
      .firstWhereOrNull((c) => c.uuid == Guid(_kCharacteristicID),);
    if (characteristic == null) {
      Log.err('no characteristic', [_device, allServices, allCharacteristics]);
      emit(BleReadFailure());
      return;
    }

    // This characteristic only supports indication so we need to listen to values.
    final indicationListener = characteristic
      .onValueReceived.listen((data) {
        Log.trace('BleReadCubit data indicated: $data');
        final record = CharacteristicDecoder.decodeMeasurementV2(data);
        Log.trace('BleReadCubit decoded $record');
        emit(BleReadSuccess(record!));
      });
    await characteristic.setNotifyValue(true);

    /*late final List<int> data;
    try {
      data = await characteristic.read();
    } catch (e) {
      Log.err('read error', [e, _device, allServices, allCharacteristics, characteristic,]);
      emit(BleReadFailure());
      return;
    }

    Log.trace('BleReadCubit received $data');
    final record = CharacteristicDecoder.decodeMeasurement(data);
    Log.trace('BleReadCubit decoded $record');
    emit(BleReadSuccess(record));*/
  }
}
