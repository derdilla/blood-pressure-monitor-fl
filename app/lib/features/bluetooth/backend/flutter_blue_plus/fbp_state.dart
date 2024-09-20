import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

/// Bluetooth adapter state parser for the 'flutter_blue_plus' package
final class FlutterBluePlusStateParser extends BluetoothAdapterStateParser<fbp.BluetoothAdapterState> {
  @override
  BluetoothAdapterState parse(fbp.BluetoothAdapterState rawState) => switch (rawState) {
    fbp.BluetoothAdapterState.unavailable => BluetoothAdapterState.unfeasible,
    // Bluetooth permissions should always be granted on normal android
    // devices. Users on non-standard android devices will know how to
    // enable them. If this is not the case there will be bug reports.
    fbp.BluetoothAdapterState.unauthorized => BluetoothAdapterState.unauthorized,
    fbp.BluetoothAdapterState.on => BluetoothAdapterState.ready,
    fbp.BluetoothAdapterState.off
      || fbp.BluetoothAdapterState.turningOn
      || fbp.BluetoothAdapterState.turningOff => BluetoothAdapterState.disabled,
    fbp.BluetoothAdapterState.unknown => BluetoothAdapterState.initial,
  };
}
