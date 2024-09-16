part of 'bluetooth_backend.dart';

/// Base class for backend device discovery implementations
abstract class BluetoothDeviceDiscovery<BM extends BluetoothManager> with TypeLogger {
  /// Initialize base class for device discovery implementations.
  BluetoothDeviceDiscovery(this.manager) {
    logger.finer('init device discovery: $this');
  }

  /// Corresponding BluetoothManager
  final BM manager;

  /// List of discovered devices
  final List<BluetoothDevice> _devices = [];

  /// A stream that returns the discovered devices when discovering
  Stream<List<BluetoothDevice>> get discoverStream;

  StreamSubscription<List<BluetoothDevice>>? _discoverSubscription;

  /// Backend implementation to start discovering
  @protected
  Future<void> backendStart(String serviceUuid);

  /// Backend implementation to stop discovering
  @protected
  Future<void> backendStop();

  /// Whether device discovery is running or not
  bool _discovering = false;

  /// True when already discovering devices
  bool get isDiscovering => _discovering;

  /// Start discovering for new devices
  ///
  /// - [serviceUuid] The service uuid to filter on when discovering devices
  /// - [onDevices] Callback for when devices have been discovered. The
  /// [onDevices] callback can be called multiple times, it is also always
  /// called with the list of all discovered devices from the start of discovering
  ///
  /// Note that there are major differences in how backends return discovered devices,
  /// f.e. FlutterBluePlus batches results itself while BluetoothLowEnergy will always
  /// return one device per listen callback
  Future<void> start(String serviceUuid, ValueSetter<List<BluetoothDevice>> onDevices) async {
    if (_discovering) {
      logger.warning('Already discovering, not starting discovery again');
      return;
    }

    _discovering = true;
    _devices.clear();

    _discoverSubscription = discoverStream.listen((newDevices) {
      logger.finest('New devices discovered: $newDevices');
      assert(_discovering);

      // See above note, some backends batch discovered devices themselves and could return
      // the same device in successive listen callbacks. So make sure we are not adding
      // duplicate devices
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

    logger.fine('Starting discovery for devices with service: $serviceUuid');
    await backendStart(serviceUuid);
  }

  /// Called when an error occurs during discovery
  void onDiscoveryError(Object error) {
    logger.severe('Starting device scan failed', error);
    _discovering = false;
  }

  /// Stop discovering for new devices
  Future<void> stop() async {
    if (!_discovering) {
      return;
    }

    logger.finer('Stopping discovery');
    await _discoverSubscription?.cancel();
    await backendStop();
    _devices.clear();
    _discovering = false;
  }
}

/// Should be extended by a backend bluetooth adapter to transform it's state stream into a normalized stream
///
/// Calls [BluetoothManager.createDevice] for each device in the stream to convert from a single [BackendDevice]
/// device to the corresponding [BluetoothDevice] for the current backend. Some backends discover devices
/// one-by-one, while others batch them into groups themselves. Therefore the [BackendDevice] type can both
/// be a device type as a list.
///
/// Backends can use this class directly, as all backend specific logic should be contained within [BluetoothManager.createDevice]
class BluetoothDiscoveryStreamTransformer<BackendDevice> extends StreamDataTransformer<BackendDevice, List<BluetoothDevice>> {
  /// Create new transformer instance
  ///
  /// [manager] The bluetooth manager the transformer is used for. Is required because the transformer 
  ///   uses [BluetoothManager.createDevice] to transform the BackendDevice into a BluetoothDevice
    BluetoothDiscoveryStreamTransformer({
    required BluetoothManager manager,
    super.sync,
    super.cancelOnError
  }) {
    _manager = manager;
  }

  late BluetoothManager _manager;

  @override
  void onData(BackendDevice streamData) {
    if (streamData is List) {
      sendData(streamData.map(_manager.createDevice).toList());
    } else {
      sendData([_manager.createDevice(streamData)]);
    }
  }
}
