
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' hide BluetoothLowEnergyManager;

/// Base class for a bluetooth manager
abstract class BluetoothManager<BackendDevice> with TypeLogger {
  /// Instantiate the correct [BluetoothManager] implementation.
  static BluetoothManager<DiscoveredEventArgs> create() => BluetoothLowEnergyManager();

  /// Trigger the device to request the user for bluetooth permissions

  ///
  /// Returns null if no permissions were requested (ie because its not needed on a platform)
  /// or true/false to indicate whether requesting permissions succeeded (not if it was granted)
  Future<bool?> requestPermission();

  /// Ask the system to turn on the bluetooth adapter.
  ///
  /// Returns null if turning on is not supported on the platform,
  /// or true/false to indicate whether the adapter was turned on.
  Future<bool?> turnOn();

  /// Last known adapter state
  ///
  /// For convenience [BluetoothAdapterStateParser] instances already track the last known state,
  /// so that state only needs to be returned in a backend's manager implementation
  BluetoothAdapterState get lastKnownAdapterState;

  /// Getter for the state stream
  Stream<BluetoothAdapterState> get stateStream;

  /// Device discovery implementation
  BluetoothDeviceDiscovery<DiscoveredEventArgs> get discovery;

  CentralManager get backend;

  /// Convert a BackendDevice into a BluetoothDevice
  BluetoothDevice createDevice(BackendDevice device);
}
