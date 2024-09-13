import 'dart:async';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/flutter_blue_plus_mockable.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/mock/mock_manager.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/foundation.dart';

part 'bluetooth_device.dart';
part 'bluetooth_discovery.dart';
part 'bluetooth_manager.dart';
part 'bluetooth_service.dart';
part 'bluetooth_state.dart';
part 'bluetooth_utils.dart';

/// Supported bluetooth backend implementations
///
/// Enum values provide a [create] instance method to easily get a new backend instance
enum BluetoothBackend {
  /// Use the package 'bluetooth_low_energy' as backend manager
  bluetoothLowEnergy,
  /// Use the package 'flutter_blue_plus' as backend manager
  flutterBluePlus,
  /// Use a (partially) mocked backend manager.
  /// Note that for full fledged testing it might be better to use flutter_blue_plus with a
  /// custom [FlutterBluePlusMockable] instance
  mock;

  /// Create the bluetooth backend instance for the current enum value
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
}
