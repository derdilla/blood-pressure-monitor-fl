import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:flutter/foundation.dart';

part 'mock_device.dart';
part 'mock_discovery.dart';
part 'mock_service.dart';

/// Bluetooth manager for the 'bluetooth_low_energy' package
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
  BluetoothUUID createUuid(String uuid) {
    throw UnimplementedError();
  }

  @override
  BluetoothUUID createUuidFromString(String uuid) {
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
