import 'dart:async';

import 'package:blood_pressure_app/bluetooth/logging.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
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
class BleReadCubit extends Cubit<BleRead> {
  /// Start reading a characteristic from a device.
  BleReadCubit(this._device)
    : super(BleReadInProgress()) {
   unawaited(_startRead());
  }

  /// Bluetooth device to connect to.
  ///
  /// Must have an active established connection and support the measurement
  /// characteristic.
  final BluetoothDevice _device;

  Future<void> _startRead() async {
    // Query actual services supported by the device. While they must be
    // rediscovered when a disconnect happens, this object is also recreated.
    late final List<BluetoothService> allServices;
    try {
      allServices = await _device.discoverServices();
    } catch (e) {
      Log.err('service discovery', [_device, e]);
      emit(BleReadFailure());
      return;
    }


    // [Guid.str] trims standard parts from the uuid. 0x1810 is the blood
    // pressure uuid. https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/group___u_u_i_d___s_e_r_v_i_c_e_s.html
    final service = allServices.firstWhereOrNull((s) => s.uuid.str == '1810');
    if (service == null) {
      Log.err('unsupported service', [_device, allServices]);
      emit(BleReadFailure());
      return;
    }

    // https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/group___u_u_i_d___c_h_a_r_a_c_t_e_r_i_s_t_i_c_s.html#ga95fc99c7a99cf9d991c81027e4866936
    final allCharacteristics = service.characteristics;
    final characteristic = allCharacteristics.firstWhereOrNull(
            (c) => c.uuid.str == '2a35');
    if (characteristic == null) {
      Log.err('no characteristic', [_device, allServices, allCharacteristics]);
      emit(BleReadFailure());
      return;
    }

    late final List<int> data;
    try {
      data = await characteristic.read();
    } catch (e) {
      Log.err('read error', [_device, allServices, characteristic, e]);
      emit(BleReadFailure());
      return;
    }

    // TODO: decode data before emitting success.
    emit(BleReadSuccess(data));
  }
}
