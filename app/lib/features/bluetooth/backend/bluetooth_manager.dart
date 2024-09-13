
part of 'bluetooth_backend.dart';

/// Base class for a bluetooth manager
abstract class BluetoothManager<BackendDevice,BackendUuid, BackendService, BackendCharacteristic> with TypeLogger {
  /// Request to enable bluetooth on the device
  Future<bool> enable();

  /// The last known adapter state
  /// For convenience BluetoothStateParser instances already track the last known state,
  /// so that state only needs to be returned in a backend's manager implementation
  BluetoothAdapterState get lastKnownAdapterState;

  /// Getter for the state stream
  Stream<BluetoothAdapterState> get stateStream;

  /// Device discovery implementation
  BluetoothDeviceDiscovery get discovery;

  /// Method to create a wrapped device
  BluetoothDevice createDevice(BackendDevice device);

  /// Method to create a wrapped uuid
  BluetoothUuid createUuid(BackendUuid uuid);

  /// Method to create a wrapped uuid
  BluetoothUuid createUuidFromString(String uuid);

  /// Method to create a wrapped device
  BluetoothService createService(BackendService service);

  /// Method to create a wrapped device
  BluetoothCharacteristic createCharacteristic(BackendCharacteristic characteristic);
}
