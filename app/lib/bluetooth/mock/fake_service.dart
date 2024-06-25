import 'package:blood_pressure_app/bluetooth/mock/fake_characteristic.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FakeBleBPService implements BluetoothService {
  @override
  List<BluetoothCharacteristic> get characteristics => [FakeBleBpCharacteristic()];

  @override
  // TODO: implement deviceId
  DeviceIdentifier get deviceId => throw UnimplementedError();

  @override
  List<BluetoothService> get includedServices => [];

  @override
  // TODO: implement isPrimary
  bool get isPrimary => throw UnimplementedError();

  @override
  // TODO: implement remoteId
  DeviceIdentifier get remoteId => throw UnimplementedError();

  @override
  Guid get serviceUuid => Guid('1810');

  @override
  Guid get uuid => Guid('1810');

}
