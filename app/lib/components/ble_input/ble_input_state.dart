// TODO: doc
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

sealed class BleInputState {}

/// The ble input field is inactive.
class BleInputClosed extends BleInputState {}

/// Scanning for devices.
class BleInputLoadInProgress extends BleInputState {}
/// No device available.
class BleInputLoadFailure extends BleInputState {}
/// Found devices.
class BleInputLoadSuccess extends BleInputState {
  BleInputLoadSuccess(this.availableDevices);

  final List<DiscoveredDevice> availableDevices;
}

/// Connecting to device.
class BleConnectInProgress extends BleInputState {}
/// Couldn't connect to device or closed connection.
class BleConnectFailed extends BleInputState {}
/// Is connected with device.
class BleConnectSuccess extends BleInputState {}

/// A measurement was taken through the bluetooth device.
class BleMeasureSuccess extends BleInputState {
  BleMeasureSuccess(this.record);

  final BloodPressureRecord record;
}
