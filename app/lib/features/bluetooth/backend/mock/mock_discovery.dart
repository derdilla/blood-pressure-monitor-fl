part of 'mock_manager.dart';

/// BluetoothDeviceDiscovery implementation for the 'flutter_blue_plus' package
final class MockBluetoothDiscovery extends BluetoothDeviceDiscovery<MockBluetoothManager> {
  /// constructor
  MockBluetoothDiscovery(super._manager);
  
  @override
  Future<void> backendStart(String serviceUUID) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> backendStop() {
    throw UnimplementedError();
  }
  
  @override
  Stream<List<BluetoothDevice>> get discoverStream => throw UnimplementedError();

}
