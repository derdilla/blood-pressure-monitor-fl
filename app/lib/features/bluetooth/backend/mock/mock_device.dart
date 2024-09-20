
import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';

/// Placeholder [BluetoothDevice] implementation that can f.e. be used for testing
final class MockBluetoothDevice extends BluetoothDevice<BluetoothManager, BluetoothService, BluetoothCharacteristic, String> {
  /// constructor
  MockBluetoothDevice(super.manager, super.source);

  @override
  String get deviceId => super.source;

  @override
  String get name => super.source;

  @override
  Stream<BluetoothConnectionState> get connectionStream => const Stream<BluetoothConnectionState>.empty();

  @override
  Future<void> backendConnect() async {}

  @override
  Future<void> backendDisconnect() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<List<BluetoothService<dynamic, BluetoothCharacteristic>>?> discoverServices() {
    final List<BluetoothService<dynamic, BluetoothCharacteristic>> services = [];
    return Future.value(services);
  }

  @override
  Future<bool> getCharacteristicValue(BluetoothCharacteristic characteristic, void Function(Uint8List value) onValue) async => true;
}
