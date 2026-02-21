// TODO: cleanup types
// ignore_for_file: strict_raw_type

import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bluetooth_state.dart';

/// Availability of the devices bluetooth adapter.
///
/// The only state that allows using the adapter is [BluetoothStateReady].
class BluetoothCubit extends Cubit<BluetoothState> with TypeLogger {
  /// Create a cubit connecting to the bluetooth module for availability.
  ///
  /// [manager] manager to check availabilty of.
  BluetoothCubit({ required this.manager }):
        super(BluetoothState.fromAdapterState(manager.lastKnownAdapterState)) {
    _adapterStateSubscription = manager.stateStream.listen(_onAdapterStateChanged);

    _lastKnownState = manager.lastKnownAdapterState;
    logger.finer('lastKnownState: $_lastKnownState');
  }

  /// Bluetooth manager
  late final BluetoothManager manager;
  late BluetoothAdapterState _lastKnownState;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  Future<void> close() async {
    await _adapterStateSubscription.cancel();
    await super.close();
  }

  void _onAdapterStateChanged(BluetoothAdapterState state) async {
    if (state == BluetoothAdapterState.unauthorized) {
      final success = await manager.enable();
      if (success != true) {
        logger.warning('Enabling bluetooth failed or not needed on this platform');
      }
    }

    _lastKnownState = state;
    logger.finer('_onAdapterStateChanged(state: $state)');
    emit(BluetoothState.fromAdapterState(state));
  }

  /// Request to enable bluetooth on the device
  Future<bool?> enableBluetooth() async {
    assert(state is BluetoothStateDisabled, 'No need to enable bluetooth when '
        'already enabled or not known to be disabled.');
    try {
      return manager.enable();
    } on Exception {
      return false;
    }
  }

  /// Reevaluate the current state.
  ///
  /// When the user is in another app like the device settings, sometimes
  /// the app won't get notified about permission changes and such. In those
  /// instances the user should have the option to manually recheck the state to
  /// avoid getting stuck on a unauthorized state.
  void forceRefresh() => _onAdapterStateChanged(_lastKnownState);
}
