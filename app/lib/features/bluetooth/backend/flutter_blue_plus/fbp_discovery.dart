// TODO: cleanup types
// ignore_for_file: strict_raw_type

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';

/// BluetoothDeviceDiscovery implementation for the 'flutter_blue_plus' package
final class FlutterBluePlusDiscovery extends BluetoothDeviceDiscovery<FlutterBluePlusManager> {
  /// constructor
  FlutterBluePlusDiscovery(super.manager);

  @override
  Stream<List<BluetoothDevice>> get discoverStream => manager.backend.scanResults.map(
    (devices) => devices.map(manager.createDevice).toList()
  );

  @override
  Future<void> backendStart() async {
    try {
      await manager.backend.startScan();
    } catch (e) {
      onDiscoveryError(e);
    }
  }

  @override
  Future<void> backendStop() => manager.backend.stopScan();
}
