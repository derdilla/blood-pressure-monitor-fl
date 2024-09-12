part of 'bluetooth_backend.dart';

/// Wrapper class for bluetooth implementations to expose any props we need
/// in a generic way
abstract class BluetoothDevice<BM extends BluetoothManager, BS extends BluetoothService, BC extends BluetoothCharacteristic, BackendDevice> with TypeLogger {
  /// constructor
  BluetoothDevice(this._manager, this._source) {
    logger.finer('[BTBackend] Init device $this');
  }

  /// Corresponding BluetoothManager
  late final BM _manager;

  /// Corresponding BluetoothManager
  BM get manager => _manager;

  /// Original source device as returned by the backend
  late final BackendDevice _source;

  /// Original source device as returned by the backend
  BackendDevice get source => _source;

  /// (Unique?) id of the device
  String get deviceId;

  /// Name of the device
  String get name;

  /// Whether the device is connected
  bool get isConnected;

  List<BS>? _services;

  /// Take a measurement from the device
  /// Always call disconnect when ready after calling connect
  Future<bool> connect({ VoidCallback? onConnect, bool Function(bool wasConnected)? onDisconnect, ValueSetter<Object>? onError, int maxTries = 5 });

  /// Disconnect & dispose the device
  Future<bool> disconnect();

  /// Discover all available services on the device
  Future<List<BS>?> discoverServices();

  /// Return all available services for this device
  /// Difference with discoverServices is that getService memoizes the services
  Future<List<BS>?> getServices() async {
    _services ??= await discoverServices();
    if (_services == null) {
      logger.finer('[BTBackend] Failed to discoverServices on device: $name');
    }
    return _services;
  }

  /// Returns the service with requested uuid
  Future<BS?> getServiceByUuid(BluetoothUUID uuid) async {
    final services = await getServices();
    try {
      return services?.firstWhere((service) => service.uuid == uuid);
    } on StateError {
      return null;
    }
  }

  /// Retrieves the value of [characteristic] from the device, the value is added to [value]
  /// 
  /// Note that a [characteristic] could have multiple values, hency why [value] is a list of a list.
  /// Also note that [value] is a function arg as the return value is an indication if the read was
  /// succesful or not. This function could convert a listener to a Future and reading a characteristic
  /// could return muliple value items. So value could contain data even though the read gave an error
  /// indicating not all data had been read from the device.
  Future<bool> getCharacteristicValueByUuid(BC characteristic, List<Uint8List> value);

  @override
  String toString() => 'BluetoothDevice{name: $name, deviceId: $deviceId}';
}

/// Bluetooth device parser base class
/// This is a separate class as factory methods cannot be abstract
abstract class BluetoothDeviceParser<T> {
  /// Method that converts the raw bluetooth device data to our BluetoothDevice
  BluetoothDevice parse(T rawDevice, BluetoothManager manager);
}
