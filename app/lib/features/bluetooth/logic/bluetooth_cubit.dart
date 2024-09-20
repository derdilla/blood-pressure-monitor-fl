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
  BluetoothCubit({ required BluetoothManager manager }):
        super(BluetoothState.fromAdapterState(manager.lastKnownAdapterState)) {
    _manager = manager;
    _adapterStateSubscription = _manager.stateStream.listen(_onAdapterStateChanged);

    _lastKnownState = _manager.lastKnownAdapterState;
    logger.finer('lastKnownState: $_lastKnownState');
  }

  late final BluetoothManager _manager;
  late BluetoothAdapterState _lastKnownState;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  Future<void> close() async {
    await _adapterStateSubscription.cancel();
    await super.close();
  }

  void _onAdapterStateChanged(BluetoothAdapterState state) {
    _lastKnownState = state;
    logger.finer('_onAdapterStateChanged(state: $state)');
    emit(BluetoothState.fromAdapterState(state));
  }

  /// Request to enable bluetooth on the device
  Future<bool> enableBluetooth() async {
    assert(state is BluetoothStateDisabled, 'No need to enable bluetooth when '
        'already enabled or not known to be disabled.');
    try {
      return _manager.enable();
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
