// TODO document
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

sealed class BleInputEvent {}

/// Request expanding the input field.
class OpenBleInput extends BleInputEvent {}

/// Request closing the input field.
class CloseBleInput extends BleInputEvent {}

class BleInputDeviceSelected extends BleInputEvent {
  BleInputDeviceSelected(this.device);

  final DiscoveredDevice device;
}

/// A measurement was started over bluetooth.
class BleBluetoothMeasurementRecieved extends BleInputEvent {
  BleBluetoothMeasurementRecieved(this.data);

  /// The binary data received.
  final List<int> data;
}
