import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_manager.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' show UUID;

/// BluetoothDeviceDiscovery implementation for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyDiscovery extends BluetoothDeviceDiscovery<BluetoothLowEnergyManager> {
  /// Construct BluetoothDeviceDiscovery implementation for the 'bluetooth_low_energy' package
  BluetoothLowEnergyDiscovery(super.manager);

  @override
  Stream<List<BluetoothDevice>> get discoverStream => manager.backend.discovered.map(
    (device) => [manager.createDevice(device)]
  );

  @override
  Future<void> backendStart(String serviceUuid) async {
    try {
      await manager.backend.startDiscovery(
        // no timeout, the user knows best how long scanning is needed
        serviceUUIDs: [UUID.fromString(serviceUuid)],
        // Not all devices might be found using this configuration
      );
    } catch (e) {
      onDiscoveryError(e);
    }
  }

  @override
  Future<void> backendStop() => manager.backend.stopDiscovery();
}
