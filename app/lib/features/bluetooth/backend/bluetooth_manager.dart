

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:blood_pressure_app/logging.dart';

/// Base class for a bluetooth manager
abstract class BluetoothManager<BackendDevice, BackendUuid, BackendService, BackendCharacteristic> with TypeLogger {
  /// Request to enable bluetooth on the device
  Future<bool> enable();

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
