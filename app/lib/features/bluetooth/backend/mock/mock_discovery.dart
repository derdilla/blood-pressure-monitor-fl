import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/mock/mock_manager.dart';

/// Placeholder [BluetoothDeviceDiscovery] implementation that can f.e. be used for testing
final class MockBluetoothDiscovery extends BluetoothDeviceDiscovery<MockBluetoothManager> {
  /// constructor
  MockBluetoothDiscovery(super.manager);
  
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
