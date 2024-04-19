import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Bluetooth measurement event.
sealed class BleInputEvent {}

/// Request expanding the input field.
class OpenBleInput extends BleInputEvent {}

/// Request closing the input field.
class CloseBleInput extends BleInputEvent {}

/// Connection with a device has been requested.
class BleInputDeviceSelected extends BleInputEvent {
  /// Request connection with a device.
  BleInputDeviceSelected(this.device);

  /// The device to connect with.
  final DiscoveredDevice device;
}
