// TODO: cleanup types
// ignore_for_file: strict_raw_type

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/mock/mock_manager.dart';
import 'package:blood_pressure_app/logging.dart';

/// Base class for a bluetooth manager
abstract class BluetoothManager<BackendDevice, BackendUuid, BackendService, BackendCharacteristic> with TypeLogger {
  /// Instantiate the correct [BluetoothManager] implementation.
  static BluetoothManager create([BluetoothBackend? backend]) {
    switch (backend) {
      case BluetoothBackend.mock:
        return MockBluetoothManager();
      case BluetoothBackend.flutterBluePlus:
        return FlutterBluePlusManager();
      case BluetoothBackend.bluetoothLowEnergy:
      default:
        return BluetoothLowEnergyManager();
    }
  }

  /// Trigger the device to request the user for bluetooth ermissions
  ///
  /// Returns null if no permissions were requested (ie because its not needed on a platform)
  /// or true/false to indicate whether requesting permissions succeeded (not if it was granted)
  Future<bool?> enable(); // TODO: use task specific plugin/native code

  /// Last known adapter state
  ///
  /// For convenience [BluetoothAdapterStateParser] instances already track the last known state,
  /// so that state only needs to be returned in a backend's manager implementation
  BluetoothAdapterState get lastKnownAdapterState;

  /// Getter for the state stream
  Stream<BluetoothAdapterState> get stateStream;

  /// Device discovery implementation
  BluetoothDeviceDiscovery get discovery;

  /// Convert a BackendDevice into a BluetoothDevice
  BluetoothDevice createDevice(BackendDevice device);

  /// Convert a BackendUuid into a BluetoothUuid
  BluetoothUuid createUuid(BackendUuid uuid);

  /// Create a BluetoothUuid from a String
  BluetoothUuid createUuidFromString(String uuid);

  /// Convert a BackendService into a BluetoothService
  BluetoothService createService(BackendService service);

  /// Convert a BackendCharacteristic into a BluetoothCharacteristic
  BluetoothCharacteristic createCharacteristic(BackendCharacteristic characteristic);
}
