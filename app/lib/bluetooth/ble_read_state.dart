part of 'ble_read_cubit.dart';

/// State of reading a characteristic from a BLE device.
@immutable
sealed class BleReadState {}

/// The reading has been started.
class BleReadInProgress extends BleReadState {}

/// The reading failed unrecoverable for some reason.
class BleReadFailure extends BleReadState {}

/// Data has been successfully read.
class BleReadSuccess extends BleReadState {
  /// Indicate a successful reading of a ble characteristic.
  BleReadSuccess(this.data);

  /// Measurement decoded from the device.
  final BleMeasurementData data;
}
