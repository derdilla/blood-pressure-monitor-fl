part of 'mock_manager.dart';

/// BluetoothDevice implementation for the 'bluetooth_low_energy' package
final class MockBluetoothDevice extends BluetoothDevice<BluetoothManager, BluetoothService, BluetoothCharacteristic, String> {
  /// constructor
  MockBluetoothDevice(super._manager, super._source);
  bool _isConnected = false;

  @override
  String get deviceId => super.source;

  @override
  String get name => super.source;

  @override
  bool get isConnected => _isConnected;

  @override
  // ignore: prefer_expression_function_bodies
  Future<bool> connect({VoidCallback? onConnect, bool Function(bool wasConnected)? onDisconnect, ValueSetter<Object>? onError, int maxTries = 5}) {
    _isConnected = true;
    return Future.value(_isConnected);
  }

  @override
  Future<bool> disconnect() {
    _isConnected = false;
    return Future.value(_isConnected);
  }

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
