part of 'ble_read_cubit.dart';

/// State of reading a characteristic from a BLE device.
@immutable
abstract class BleRead {}

/// The reading has been started.
class BleReadInProgress extends BleRead {}

/// The reading failed unrecoverable for some reason.
class BleReadFailure extends BleRead {}

/// Data has been successfully read.
class BleReadSuccess extends BleRead {
  /// Indicate a successful reading of a ble characteristic.
  BleReadSuccess(this.data);

  /// Raw binary data received from the device.
  final List<int> data;
}
