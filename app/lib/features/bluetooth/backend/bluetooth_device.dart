part of 'bluetooth_backend.dart';

/// Wrapper class for bluetooth implementations to generically expose required functionality
abstract class BluetoothDevice<BM extends BluetoothManager, BS extends BluetoothService, BC extends BluetoothCharacteristic, BackendDevice> with TypeLogger {
  /// Create a new BluetoothLowEnergyDevice
  ///
  /// [_manager] Manager the device belongs to
  /// [_source] Device implementation of the current backend
  BluetoothDevice(this._manager, this._source) {
    logger.finer('init device: $this');
  }

  /// BluetoothManager this device belongs to
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

  /// Memoized service list for the device
  List<BS>? _services;

  bool _isConnected = false;
  StreamSubscription<BluetoothConnectionState>? _connectionListener;

  /// Whether the device is connected
  bool get isConnected => _isConnected;

  /// Stream to listen to for connection state changes after connecting to a device
  Stream<BluetoothConnectionState> get connectionStream;

  /// Backend implementation to connect to the device
  Future<void> backendConnect();
  /// Backend implementation to disconnect to the device
  Future<void> backendDisconnect();

  /// Array of disconnect callbacks
  ///
  /// Disconnect callbacks are processed in reverse order, i.e. the latest added callback is executed as first. Callbacks
  /// can return true to indicate they have fully handled the disconnect. This will then also stop executing any remaining
  /// callbacks.
  @protected
  final List<bool Function(bool wasConnected)> disconnectCallbacks = [];

  /// Connect to the device
  ///
  /// Always call disconnect when ready after calling connect
  Future<bool> connect({ VoidCallback? onConnect, bool Function(bool wasConnected)? onDisconnect, ValueSetter<Object>? onError, int maxTries = 5 }) {
    final completer = Completer<bool>();
    int connectTry = 1;

    logger.finer('connect: Init');

    if (onDisconnect != null) {
      disconnectCallbacks.add(onDisconnect);
    }

    /// Local helper util to only complete the completer when it's not completed yet
    void doComplete(bool res) => !completer.isCompleted ? completer.complete(res) : null;

    _connectionListener = connectionStream.listen((BluetoothConnectionState state) {
      logger.finest('connectionStream.listen[isConnected: $_isConnected]: $state, connectTry: $connectTry');

      switch (state) {
        case BluetoothConnectionState.connected:
          connectTry = 0; // reset try count

          onConnect?.call();
          doComplete(true);
          _isConnected = true;
          return;
        case BluetoothConnectionState.disconnected:
          final wasConnected = _isConnected;
          // TODO: does this make even sense? I.e. can this listener be called with successive disconnected states?
          if (!wasConnected && connectTry < maxTries) {
            connectTry++;
            backendConnect();
            return;
          }

          for (final fn in disconnectCallbacks.reversed) {
            if (fn(wasConnected)) {
              // ignore other disconnect callbacks
              break;
            }
          }

          disconnectCallbacks.clear();
          doComplete(false);
          _isConnected = false;
      }
    }, onError: onError);

    backendConnect();
    return completer.future.then((res) {
      logger.finer('connect: completer.resolved($res)');
      return res;
    });
  }

  /// Disconnect & dispose the device
  ///
  /// Always call [disconnect] after calling [connect] to ensure all resources are disposed
  Future<bool> disconnect() async {
    await _connectionListener?.cancel();
    await backendDisconnect();
    return true;
  }

  /// Discover all available services on the device
  ///
  /// It's recommended to use [getServices] instead
  Future<List<BS>?> discoverServices();

  /// Return all available services for this device
  ///
  /// Difference with [discoverServices] is that [getServices] memoizes the results
  Future<List<BS>?> getServices() async {
    _services ??= await discoverServices();
    if (_services == null) {
      logger.finer('Failed to discoverServices on: $this');
    }
    return _services;
  }

  /// Returns the service with requested [uuid] or null if requested service is not available
  Future<BS?> getServiceByUuid(BluetoothUuid uuid) async {
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
///
/// This is a separate helper class as factory or static methods cannot be abstract,
/// so even though this class only has one method it's useful to enforce the types
abstract class BluetoothDeviceParser<T> {
  /// Method that converts the raw bluetooth device data to a [BluetoothDevice] instance
  BluetoothDevice parse(T rawDevice, BluetoothManager manager);
}
