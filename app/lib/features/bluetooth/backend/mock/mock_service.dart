// ignore_for_file: public_member_api_docs

part of 'mock_manager.dart';

/// Backend implementation for MockBluetoothService
final class MockedService {
  /// constructor
  MockedService({ required this.uuid, required this.characteristics });

  String uuid;
  List<MockedCharacteristic> characteristics;
}

/// Backend implementation for MockBluetoothCharacteristic
final class MockedCharacteristic {
  /// constructor
  MockedCharacteristic({
    required this.uuid,
    this.canRead = false,
    this.canWrite = false,
    this.canWriteWithoutResponse = false,
    this.canNotify = false,
    this.canIndicate = false,
  });

  String uuid;
  bool canRead;
  bool canWrite;
  bool canWriteWithoutResponse;
  bool canNotify;
  bool canIndicate;
}

/// String wrapper for Bluetooth
final class MockBluetoothString extends BluetoothUUID<String> {
  /// Create a BluetoothString from a String
  MockBluetoothString(String uuid): super(uuid: uuid);
  /// Create a BluetoothString from a string
  MockBluetoothString.fromString(String uuid): super(uuid: uuid);
}

/// Wrapper class with generic interface for a GATTService
final class MockBluetoothService extends BluetoothService<MockedService, BluetoothCharacteristic> {
   /// Create a FlutterBlueService from a GATTService
  MockBluetoothService.fromSource(MockedService service): super(uuid: MockBluetoothString(service.uuid), source: service);

  @override
  List<BluetoothCharacteristic> get characteristics => source.characteristics.map(MockBluetoothCharacteristic.fromSource).toList();
}

/// Wrapper class with generic interface for a GATTCharacteristic
final class MockBluetoothCharacteristic extends BluetoothCharacteristic<MockedCharacteristic> {
  /// Create a BluetoothCharacteristic from the backend specific source
  MockBluetoothCharacteristic.fromSource(MockedCharacteristic source): super(uuid: MockBluetoothString(source.uuid), source: source);

  @override
  bool get canRead => source.canRead;

  @override
  bool get canWrite => source.canWrite;

  @override
  bool get canWriteWithoutResponse => source.canWriteWithoutResponse;

  @override
  bool get canNotify => source.canNotify;

  @override
  bool get canIndicate => source.canIndicate;
}
