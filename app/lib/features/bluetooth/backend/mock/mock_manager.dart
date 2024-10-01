import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/mock/mock_service.dart';

/// Placeholder [BluetoothManager] implementation that can f.e. be used for testing
final class MockBluetoothManager extends BluetoothManager<String, String, MockedService, MockedCharacteristic> {
  @override
  BluetoothDeviceDiscovery<BluetoothManager> get discovery => throw UnimplementedError();

  @override
  Future<bool> enable() async => false;
  
  @override
  BluetoothAdapterState get lastKnownAdapterState => BluetoothAdapterState.initial;
  
  @override
  Stream<BluetoothAdapterState> get stateStream => const Stream.empty();

  @override
  BluetoothUuid createUuid(String uuid) {
    throw UnimplementedError();
  }

  @override
  BluetoothUuid createUuidFromString(String uuid) {
    throw UnimplementedError();
  }

  @override
  BluetoothDevice<BluetoothManager, BluetoothService<dynamic, BluetoothCharacteristic>, BluetoothCharacteristic, dynamic> createDevice(String device) {
    throw UnimplementedError();
  }

  @override
  BluetoothService<dynamic, BluetoothCharacteristic> createService(MockedService service) {
    throw UnimplementedError();
  }

  @override
  BluetoothCharacteristic createCharacteristic(MockedCharacteristic characteristic) {
    throw UnimplementedError();
  }
}
