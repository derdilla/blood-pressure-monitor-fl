/// Utility import that only exposes the bluetooth backend services that should be used.
library;

export 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart' show BluetoothDevice;
export 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart' show BluetoothManager;
export 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart' show BluetoothAdapterState;

/// All available bluetooth backends
enum BluetoothBackend {
  /// Bluetooth Low Energy backend
  bluetoothLowEnergy,
  /// Flutter Blue Plus backend
  flutterBluePlus,
  /// Mock backend
  mock;
}
