// ignore_for_file: strict_raw_type

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';

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
final class MockBluetoothString extends BluetoothUuid<String> {
  /// Create a BluetoothString from a String
  MockBluetoothString(String uuid): super(uuid: uuid, source: uuid);
  /// Create a BluetoothString from a string
  MockBluetoothString.fromString(String uuid): super(uuid: uuid, source: uuid);
}

/// Wrapper class with generic interface for a [MockedService]
final class MockBluetoothService extends BluetoothService<MockedService, BluetoothCharacteristic> {
   /// Create a FlutterBlueService from a [MockedService]
  MockBluetoothService.fromSource(MockedService service): super(uuid: MockBluetoothString(service.uuid), source: service);

  @override
  List<BluetoothCharacteristic> get characteristics => source.characteristics.map(MockBluetoothCharacteristic.fromSource).toList();
}

/// Wrapper class with generic interface for a [MockedCharacteristic]
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
