part of 'bluetooth_cubit.dart';

/// State of the devices bluetooth module.
@immutable
sealed class BluetoothState {}

/// No information on whether bluetooth is available.
///
/// Users may show a loading indication but can not assume bluetooth is
/// available.
class BluetoothInitial extends BluetoothState {}

/// There is no way bluetooth will work (e.g. no sensor).
///
/// Options relating to bluetooth should not be shown.
class BluetoothUnfeasible extends BluetoothState {}

/// There is a bluetooth sensor but the app has no permission.
class BluetoothUnauthorized extends BluetoothState {}

/// The device has Bluetooth and the app has permissions, but it is disabled in
/// the device settings.
class BluetoothDisabled extends BluetoothState {}

/// Bluetooth is ready for use by the app.
class BluetoothReady extends BluetoothState {}
