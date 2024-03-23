// TODO document
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

sealed class BleInputEvent {}
class BleInputOpened extends BleInputEvent {}
class BleInputDeviceSelected extends BleInputEvent {
  BleInputDeviceSelected(this.device);

  final DiscoveredDevice device;
}
