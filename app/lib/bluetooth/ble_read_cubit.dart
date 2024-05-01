import 'dart:async';

import 'package:blood_pressure_app/bluetooth/flutter_blue_plus_mockable.dart';
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
class BleReadCubit extends Cubit<BleRead> {
  /// Start reading a characteristic from a device.
  BleReadCubit(this._flutterBluePlus, this._device)
    : super(BleReadInProgress()) {
   unawaited(_startRead());
  }

  final FlutterBluePlusMockable _flutterBluePlus;

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
      emit(BleReadFailure());
      Log.err('service discovery', [_device, e]);
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
            (c) => c.uuid.str == '2A35');
    if (characteristic == null) {
      emit(BleReadFailure());
      Log.err('no characteristic', [_device, allServices, allCharacteristics]);
      return;
    }

    late final List<int> data;
    try {
      data = await characteristic.read();
    } catch (e) {
      emit(BleReadFailure());
      Log.err('read error', [_device, allServices, characteristic, e]);
    }

    // TODO: decode data before emitting success.
    emit(BleReadSuccess(data));
  }
}
