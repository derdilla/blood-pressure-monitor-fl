part of 'mock_manager.dart';

/// BluetoothDevice implementation for the 'bluetooth_low_energy' package
final class MockBluetoothDevice extends BluetoothDevice<BluetoothManager, BluetoothService, BluetoothCharacteristic, String> {
  /// constructor
  MockBluetoothDevice(super._manager, super._source);

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
  Future<List<BluetoothService<dynamic, BluetoothCharacteristic>>?> discoverServices() {
    final List<BluetoothService<dynamic, BluetoothCharacteristic>> services = [];
    return Future.value(services);
  }

  @override
  // ignore: prefer_expression_function_bodies
  Future<bool> getCharacteristicValueByUuid(BluetoothCharacteristic characteristic, List<Uint8List> value) {
    return Future.value(true);
  }
}
