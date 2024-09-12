part of 'ble_manager.dart';

/// BluetoothDevice implementation for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyDevice extends BluetoothDevice<BluetoothLowEnergyManager, BluetoothLowEnergyService, BluetoothLowEnergyCharacteristic, DiscoveredEventArgs> {
  /// constructor
  BluetoothLowEnergyDevice(super._manager, super._source);

  @override
  String get deviceId => source.peripheral.uuid.toString();

  @override
  String get name => source.advertisement.name ?? deviceId;

  StreamSubscription<PeripheralConnectionStateChangedEventArgs>? _connectionListener;
  bool _isConnected = false;

  @override
  bool get isConnected => _isConnected;

  CentralManager get _cm => manager.backend;

  /// Array of disconnect callbacks
  /// 
  /// Disconnect callbacks are processed in reverse order, i.e. the latest added callback is executed as first. Callbacks
  /// can return true to indicate they have fully handled the disconnect. This will then also stop executing any remaining
  /// callbacks.
  final List<bool Function(bool wasConnected)> _disconnectCallbacks = [];

  @override
  Future<bool> connect({ VoidCallback? onConnect, bool Function(bool wasConnected)? onDisconnect, ValueSetter<Object>? onError, int maxTries = 5 }) {
    final completer = Completer<bool>();
    int connectTry = 1;

    logger.finer('connect: Init');

    if (onDisconnect != null) {
      _disconnectCallbacks.add(onDisconnect);
    }

    /// Local helper util to only complete the completer when it's not completed yet
    void doComplete(bool res) => !completer.isCompleted ? completer.complete(res) : null;

    _connectionListener = _cm.connectionStateChanged.listen((PeripheralConnectionStateChangedEventArgs eventArgs) {
      logger.finer('connectionStateChanged.listen[isConnected: $_isConnected]: ${eventArgs.state}, connectTry: $connectTry');
      switch (eventArgs.state) {
        case ConnectionState.connected:
          connectTry = 0; // reset try count

          onConnect??();
          doComplete(true);
          _isConnected = true;
          return;
        case ConnectionState.disconnected:
          final wasConnected = _isConnected;
          // TODO: does this make even sense?
          if (!wasConnected && connectTry < maxTries) {
            connectTry++;
            _cm.connect(source.peripheral);
            return;
          }

          for (final fn in _disconnectCallbacks.reversed) {
            if (fn(wasConnected)) {
              // ignore other disconnect callbacks
              break;
            }
          }

          _disconnectCallbacks.clear();
          doComplete(false);
          _isConnected = false;
      }
    }, onError: onError);

    _cm.connect(source.peripheral);
    return completer.future.then((res) {
      logger.finer('connect: Completer.resolved($res)');
      return res;
    });
  }

  @override
  Future<bool> disconnect() async {
    await _connectionListener!.cancel();
    await _cm.disconnect(source.peripheral);
    return true;
  }

  @override
  Future<List<BluetoothLowEnergyService>?> discoverServices() async {
    if (!isConnected) {
      logger.finer('discoverServices: device not connect. Call device.connect() first');
      return null;
    }

    // Query actual services supported by the device. While they must be
    // rediscovered when a disconnect happens, this object is also recreated.
    try {
      final allServices = await _cm.discoverGATT(source.peripheral);
      logger.finer('discoverServices: $allServices');

      return allServices.map(BluetoothLowEnergyService.fromSource).toList();
    } catch (e) {
      logger.shout('discoverServices: error:', [source.peripheral, e]);
      return null;
    }
  }
  
  @override
  Future<bool> getCharacteristicValueByUuid(BluetoothLowEnergyCharacteristic characteristic, List<Uint8List> value) async {
    if (!_isConnected) {
      logger.finer('getCharacteristicValueByUuid: device not connect. Call device.connect() first');
      return false;
    }

    if (characteristic.canRead) { // Read characteristic value if supported
      try {
        final data = await _cm.readCharacteristic(
          source.peripheral,
          characteristic.source,
        );

        value.add(data);
        return true;
      } catch (err) {
        return false;
      }
    }

    if (characteristic.canIndicate) { // Listen for characteristic value and trigger the device to send it
      final completer = Completer<bool>();
      late StreamSubscription listener;

      bool disconnectCallback(bool wasConnected) {
        logger.finer('getCharacteristicValueByUuid(data.isEmpty: ${value.isEmpty}): onDisconnect called');
        if (value.isEmpty) {
          return false;
        }

        completer.complete(true);
        return true;
      }

      _disconnectCallbacks.add(disconnectCallback);

      listener = _cm.characteristicNotified.listen((eventArgs) {
        logger.finer('getCharacteristicValueByUuid[${eventArgs.value.length}] ${eventArgs.value}');
        if (characteristic.source != eventArgs.characteristic) {
          logger.finer('    data is for other characteristic');
          logger.finest('    ${eventArgs.characteristic.uuid} == ${characteristic.source.uuid} => ${eventArgs.characteristic == characteristic.source}');
          logger.finest('    ${eventArgs.characteristic} == ${characteristic.source} => ${eventArgs.characteristic == characteristic.source}');
          return;
        }

        value.add(eventArgs.value);
      },
        cancelOnError: true,
        onDone: () {
          // TODO: doesn't seem to be called ever, not sure why?
          logger.finer('getCharacteristicValueByUuid: onDone called');
          completer.complete(true);
        },
        onError: (Object err) {
          logger.shout('getCharacteristicValueByUuid: Error while reading characteristic', err);
          completer.complete(false);
        }
      );

      await _cm.setCharacteristicNotifyState(source.peripheral, characteristic.source, state: true);
      return completer.future.then((res) {
        // Ensure listener is always cancelled when completer resolves
        unawaited(listener.cancel());

        // Remove disconnect callback in case the connection was not automatically disconnected
        if (!_disconnectCallbacks.remove(disconnectCallback)) {
          logger.finer('getCharacteristicValueByUuid: device was not automatically disconnected after completer finished, removing disconnect callback');
        }

        return res;
      });
    }

    logger.severe("Can't read or indicate characteristic: $characteristic");
    return false;
  }
}
