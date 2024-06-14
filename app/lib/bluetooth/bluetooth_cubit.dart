import 'dart:async';
import 'dart:io';

import 'package:blood_pressure_app/bluetooth/flutter_blue_plus_mockable.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

part 'bluetooth_state.dart';

/// Availability of the devices bluetooth adapter.
///
/// The only state that allows using the adapter is [BluetoothReady].
class BluetoothCubit extends Cubit<BluetoothState> {
  /// Create a cubit connecting to the bluetooth module for availability.
  ///
  /// [flutterBluePlus] may be provided for testing purposes.
  BluetoothCubit({
    FlutterBluePlusMockable? flutterBluePlus
  }): _flutterBluePlus = flutterBluePlus ?? FlutterBluePlusMockable(),
        super(BluetoothInitial()) {
    _adapterStateStateSubscription = _flutterBluePlus.adapterState.listen(_onAdapterStateChanged);
  }

  final FlutterBluePlusMockable _flutterBluePlus;

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  Future<void> close() async {
    await _adapterStateStateSubscription.cancel();
    await super.close();
  }

  void _onAdapterStateChanged(BluetoothAdapterState state) async {
    _adapterState = state;
    switch (_adapterState) {
      case BluetoothAdapterState.unavailable:
        emit(BluetoothUnfeasible());
      case BluetoothAdapterState.unauthorized:
        emit(BluetoothUnauthorized());
        await requestPermission();
      case BluetoothAdapterState.on:
        if (await Permission.bluetoothConnect.isGranted) {
          emit(BluetoothReady());
          Permission.bluetoothConnect
            .onGrantedCallback(() => _onAdapterStateChanged(state));
        } else {
          emit(BluetoothUnauthorized());
        }

      case BluetoothAdapterState.off:
      case BluetoothAdapterState.turningOff:
      case BluetoothAdapterState.turningOn:
        emit(BluetoothDisabled());
        await enableBluetooth();
      case BluetoothAdapterState.unknown:
        emit(BluetoothInitial());
    }
  }

  /// Request the permission to connect to bluetooth devices.
  Future<bool> requestPermission() async { // TODO: can this be removed entirely ?
    assert(_adapterState == BluetoothAdapterState.unauthorized, 'No need to '
        'request permission when device unavailable or already authorized.');
    try {
      assert(!await Permission.bluetoothConnect.isGranted, 'Permissions handler'
          'should report the same as blue_plus');
      final permission = await Permission.bluetoothConnect.request();
      return permission.isGranted;
    } catch (error) {
      Log.err('Failed to request bluetooth permissions', [error]);
      return false;
    }
  }

  /// Request to enable bluetooth on the device
  Future<bool> enableBluetooth() async {
    assert(state is BluetoothDisabled, 'No need to enable bluetooth when '
        'already enabled or not known to be disabled.');
    try {
      if (!Platform.isAndroid) return false;
      await _flutterBluePlus.turnOn();
      return true;
    } on FlutterBluePlusException {
      return false;
    }
  }

  /// Reevaluate the current state.
  ///
  /// When the user is in another app like the device settings, sometimes
  /// the app won't get notified about permission changes and such. In those
  /// instances the user should have the option to manually recheck the state to
  /// avoid getting stuck on a unauthorized state.
  Future<void> forceRefresh() async {
    _onAdapterStateChanged(_flutterBluePlus.adapterStateNow);
  }
}
