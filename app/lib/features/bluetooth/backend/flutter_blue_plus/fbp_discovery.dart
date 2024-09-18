import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show Guid, ScanResult;

/// BluetoothDeviceDiscovery implementation for the 'flutter_blue_plus' package
final class FlutterBluePlusDiscovery extends BluetoothDeviceDiscovery<FlutterBluePlusManager> {
  /// constructor
  FlutterBluePlusDiscovery(super.manager);

  @override
  Stream<List<BluetoothDevice>> get discoverStream => manager.backend.scanResults.map(
    (devices) => devices.map(manager.createDevice).toList()
  );

  @override
  Future<void> backendStart(String serviceUuid) async {
    try {
      await manager.backend.startScan(
        // no timeout, the user knows best how long scanning is needed
        withServices: [ Guid(serviceUuid) ],
        // Not all devices are found using this configuration (https://pub.dev/packages/flutter_blue_plus#scanning-does-not-find-my-device).
      );
    } catch (e) {
      onDiscoveryError(e);
    }
  }

  @override
  Future<void> backendStop() => manager.backend.stopScan();
}
