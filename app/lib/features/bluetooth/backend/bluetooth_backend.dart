import 'dart:async';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/mock/mock_manager.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/foundation.dart';

part 'bluetooth_device.dart';
part 'bluetooth_discovery.dart';
part 'bluetooth_manager.dart';
part 'bluetooth_service.dart';
part 'bluetooth_state.dart';
part 'bluetooth_utils.dart';

/// List of supported bluetooth backend implementations
enum BluetoothBackend {
  /// Use the package bluetooth_low_energy as backend manager
  bluetoothLowEnergy,
  /// Use the package flutter_blue_plus as backend manager
  flutterBluePlus,
  /// Use a (partially) mocked backend manager (flutter_blue_plus can also be used for mocking)
  mock;

  /// Create a bluetooth backend instance
  BluetoothManager create() {
    switch(this) {
      case BluetoothBackend.bluetoothLowEnergy:
        return BluetoothLowEnergyManager();
      case BluetoothBackend.flutterBluePlus:
        return FlutterBluePlusManager();
      case BluetoothBackend.mock:
        return MockBluetoothManager();
    }
  }

  /// Create backend from enum value
  static BluetoothManager from(BluetoothBackend backend) => backend.create();
}
