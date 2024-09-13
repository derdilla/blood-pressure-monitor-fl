part of 'fbp_manager.dart';

/// BluetoothDeviceDiscovery implementation for the 'flutter_blue_plus' package
final class FlutterBluePlusDiscovery extends BluetoothDeviceDiscovery<FlutterBluePlusManager> {
  /// constructor
  FlutterBluePlusDiscovery(super._manager);

  @override
  Stream<List<BluetoothDevice>> get discoverStream => manager.backend.scanResults.transform(
    BluetoothDiscoveryStreamTransformer<List<ScanResult>>(manager: manager)
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
