part of 'bluetooth_cubit.dart';

/// State of the devices bluetooth module.
@immutable
sealed class BluetoothState {
  /// constructor
  const BluetoothState();

  /// Returns the [BluetoothState] instance for given [BluetoothAdapterState] enum state
  factory BluetoothState.fromAdapterState(BluetoothAdapterState state) {
    switch(state) {
      case BluetoothAdapterState.unauthorized:
        // Bluetooth permissions should always be granted on normal android
        // devices. Users on non-standard android devices will know how to
        // enable them. If this is not the case there will be bug reports.
        return BluetoothStateUnauthorized();
      case BluetoothAdapterState.unfeasible:
        return BluetoothStateUnfeasible();
      case BluetoothAdapterState.disabled:
        return BluetoothStateDisabled();
      case BluetoothAdapterState.initial:
        return BluetoothStateInitial();
      case BluetoothAdapterState.ready:
        return BluetoothStateReady();
    }
  }
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
