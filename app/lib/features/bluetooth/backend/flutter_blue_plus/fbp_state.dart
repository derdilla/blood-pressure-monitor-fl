import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

/// Bluetooth adapter state parser for the 'flutter_blue_plus' package
final class FlutterBluePlusStateParser extends BluetoothAdapterStateParser<fbp.BluetoothAdapterState> {
  @override
  BluetoothAdapterState parse(fbp.BluetoothAdapterState rawState) {
    switch (rawState) {
      case fbp.BluetoothAdapterState.unavailable:
        return BluetoothAdapterState.unfeasible;
      case fbp.BluetoothAdapterState.unauthorized:
        // Bluetooth permissions should always be granted on normal android
        // devices. Users on non-standard android devices will know how to
        // enable them. If this is not the case there will be bug reports.
        return BluetoothAdapterState.unauthorized;
      case fbp.BluetoothAdapterState.on:
        return BluetoothAdapterState.ready;
      case fbp.BluetoothAdapterState.off:
      case fbp.BluetoothAdapterState.turningOn:
      case fbp.BluetoothAdapterState.turningOff:
        return BluetoothAdapterState.disabled;
      case fbp.BluetoothAdapterState.unknown:
        return BluetoothAdapterState.initial;
    }
  }
}
