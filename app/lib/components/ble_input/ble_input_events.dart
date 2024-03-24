// TODO document
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

sealed class BleInputEvent {}

class BleInputOpened extends BleInputEvent {}

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
