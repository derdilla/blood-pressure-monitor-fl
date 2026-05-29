import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// BluetoothDeviceDiscovery implementation for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyDiscovery extends BluetoothDeviceDiscovery<DiscoveredEventArgs> {
  /// Construct BluetoothDeviceDiscovery implementation for the 'bluetooth_low_energy' package
  BluetoothLowEnergyDiscovery(super.manager);

  CentralManager get _cm => manager.backend;

  @override
  Stream<List<BluetoothDevice>> get discoverStream => _cm.discovered.map(
    (device) => [manager.createDevice(device)]
  );

  @override
  Future<void> backendStart() async {
    try {
      await _cm.startDiscovery();
    } catch (e) {
      onDiscoveryError(e);
    }
  }

  @override
  Future<void> backendStop() => _cm.stopDiscovery();
}
