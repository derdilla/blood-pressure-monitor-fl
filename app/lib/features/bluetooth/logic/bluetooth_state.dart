part of 'bluetooth_cubit.dart';

/// State of the devices bluetooth module.
@immutable
sealed class BluetoothState {
  /// Initialize state of the devices bluetooth module.
  const BluetoothState();

  /// Returns the [BluetoothState] instance for given [BluetoothAdapterState] enum state
  factory BluetoothState.fromAdapterState(BluetoothAdapterState state) => switch(state) {
    // Bluetooth permissions should always be granted on normal android
    // devices. Users on non-standard android devices will know how to
    // enable them. If this is not the case there will be bug reports.
    BluetoothAdapterState.unauthorized => BluetoothStateUnauthorized(),
    BluetoothAdapterState.unfeasible => BluetoothStateUnfeasible(),
    BluetoothAdapterState.disabled => BluetoothStateDisabled(),
    BluetoothAdapterState.initial => BluetoothStateInitial(),
    BluetoothAdapterState.ready => BluetoothStateReady(),
  };
}

/// No information on whether bluetooth is available.
///
/// Users may show a loading indication but can not assume bluetooth is
/// available.
class BluetoothStateInitial extends BluetoothState {}

/// There is no way bluetooth will work (e.g. no sensor).
///
/// Options relating to bluetooth should not be shown.
class BluetoothStateUnfeasible extends BluetoothState {}

/// There is a bluetooth sensor but the app has no permission.
class BluetoothStateUnauthorized extends BluetoothState {}

/// The device has Bluetooth and the app has permissions, but it is disabled in
/// the device settings.
class BluetoothStateDisabled extends BluetoothState {}

/// Bluetooth is ready for use by the app.
class BluetoothStateReady extends BluetoothState {}
