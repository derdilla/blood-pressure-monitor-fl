part of 'mock_manager.dart';

/// Placeholder [BluetoothDeviceDiscovery] implementation that can f.e. be used for testing
final class MockBluetoothDiscovery extends BluetoothDeviceDiscovery<MockBluetoothManager> {
  /// constructor
  MockBluetoothDiscovery(super._manager);
  
  @override
  Future<void> backendStart(String serviceUuid) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> backendStop() {
    throw UnimplementedError();
  }
  
  @override
  Stream<List<BluetoothDevice>> get discoverStream => throw UnimplementedError();

}
