part of 'bluetooth_backend.dart';

/// Base class for backend device discovery implementations
abstract class BluetoothDeviceDiscovery<T extends BluetoothManager> with TypeLogger {
  /// constructor
  BluetoothDeviceDiscovery(this._manager) {
    logger.finer('[BTBackend] Init discovery $this');
  }

  /// Corresponding BluetoothManager
  late final T _manager;

  /// Corresponding BluetoothManager
  T get manager => _manager;

  final List<BluetoothDevice> _devices = [];

  /// A stream that returns the discovered devices when discovering
  Stream<List<BluetoothDevice>> get discoverStream;

  StreamSubscription<List<BluetoothDevice>>? _discoverSubscription;

  /// Backend implementation to start discovering
  @protected
  Future<void> backendStart(String serviceUUID);
  /// Backend implementation to stop discovering
  @protected
  Future<void> backendStop();

  bool _discovering = false;
  /// True when already discovering devices
  bool get isDiscovering => _discovering;

  /// Start discovering for new devices
  /// 
  /// [serviceUUID] The service uuid to filter on when discovering devices
  /// [onDevices] Callback for when devices have been discovered
  Future<void> start(String serviceUUID, ValueSetter<List<BluetoothDevice>> onDevices) async {
    if (_discovering) {
      logger.finer('Not starting discovery, already discovering');
      return;
    }

    _discovering = true;
    _devices.clear();

    _discoverSubscription = discoverStream.listen((newDevices) {
      assert(_discovering);

      for (final device in newDevices) {
        final index = _devices.indexWhere((dev) => dev.deviceId == device.deviceId);
        if (index < 0) {
          _devices.add(device);
        } else {
          _devices[index] = device;
        }
      }

      onDevices(_devices);
    }, onError: onDiscoveryError);

    logger.finer('[BTBackend] Starting discovery for devices with service: $serviceUUID');
    await backendStart(serviceUUID);
  }

  /// Called when an error occurs during discovery
  @protected
  void onDiscoveryError(Object error) {
    logger.severe('Starting device scan failed', error);
    _discovering = false;
  }

  /// Stop discovering for new devices
  Future<void> stop() async {
    if (!_discovering) {
      return;
    }

    logger.finer('[BTBackend] Stopping discovery');
    await _discoverSubscription?.cancel();
    await backendStop();
    _devices.clear();
    _discovering = false;
  }
}

/// Should be extended by a backend bluetooth adapter to transform it's state stream into a normalized stream
class BluetoothDiscoveryStreamTransformer<S> extends BluetoothStreamTransformer<S, List<BluetoothDevice>> {
  ///
  BluetoothDiscoveryStreamTransformer({
    required BluetoothManager manager,
    super.sync,
    super.cancelOnError
  }) {
    _manager = manager;
  }

  late BluetoothManager _manager;

  /// Corresponding BluetoothManager
  BluetoothManager get manager => _manager;

  @override
  void onData(S data) {
    if (data is List) {
      sendData(data.map(manager.createDevice).toList());
    } else {
      final device = manager.createDevice(data);
      sendData([device]);
    }
  }
}
