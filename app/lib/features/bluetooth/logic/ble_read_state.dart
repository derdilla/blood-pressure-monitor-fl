part of 'ble_read_cubit.dart';

/// State of reading a characteristic from a BLE device.
@immutable
sealed class BleReadState {}

/// The reading has been started.
class BleReadInProgress extends BleReadState {}

/// The reading failed unrecoverable for some reason.
class BleReadFailure extends BleReadState {
  /// The reading failed unrecoverable for some reason.
  BleReadFailure(this.reason);

  /// The reason why the read failed
  final String reason;
}

/// Data has been successfully read and returned multiple measurements
class BleReadMultiple extends BleReadState {
  /// Indicate a successful reading of a ble characteristic with multiple measurements.
  BleReadMultiple(this.data);

  /// List of measurements decoded from the device.
  final List<BleMeasurementData> data;
}

/// Data has been successfully read.
class BleReadSuccess extends BleReadState {
  /// Indicate a successful reading of a ble characteristic.
  BleReadSuccess(this.data);

  /// Measurement decoded from the device.
  final BleMeasurementData data;
}
