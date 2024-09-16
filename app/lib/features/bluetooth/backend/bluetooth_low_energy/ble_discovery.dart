part of 'ble_manager.dart';

/// BluetoothDeviceDiscovery implementation for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyDiscovery extends BluetoothDeviceDiscovery<BluetoothLowEnergyManager> {
  /// constructor
  BluetoothLowEnergyDiscovery(super.manager);

  @override
  Stream<List<BluetoothDevice>> get discoverStream => manager.backend.discovered.transform(
    BluetoothDiscoveryStreamTransformer(manager: manager)
  );

  @override
  Future<void> backendStart(String serviceUuid) async {
    try {
      await manager.backend.startDiscovery(
        // no timeout, the user knows best how long scanning is needed
        serviceUUIDs: [UUID.fromString(serviceUuid)],
        // Not all devices are found using this configuration (https://pub.dev/packages/flutter_blue_plus#scanning-does-not-find-my-device).
      );
    } catch (e) {
      onDiscoveryError(e);
    }
  }

  @override
  Future<void> backendStop() => manager.backend.stopDiscovery();
}
