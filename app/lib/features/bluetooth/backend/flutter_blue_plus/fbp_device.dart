part of 'fbp_manager.dart';

/// BluetoothDevice implementation for the 'flutter_blue_plus' package
final class FlutterBluePlusDevice extends BluetoothDevice<FlutterBluePlusManager, FlutterBluePlusService, FlutterBluePlusCharacteristic, fbp.ScanResult> {
  /// constructor
  FlutterBluePlusDevice(super._manager, super._source);

  @override
  String get deviceId => source.device.remoteId.str;

  @override
  String get name => source.device.platformName;

  StreamSubscription<fbp.BluetoothConnectionState>? _connectionListener;
  bool _isConnected = false;

  @override
  bool get isConnected {
    // Ensure our isConnected state is the same as FBP's
    assert(_isConnected == source.device.isConnected);
    return _isConnected;
  }

  /// Array of disconnect callbacks
  /// 
  /// Disconnect callbacks are processed in reverse order, i.e. the latest added callback is executed as first. Callbacks
  /// can return true to indicate they have fully handled the disconnect. This will then also stop executing any remaining
  /// callbacks.
  final List<bool Function(bool wasConnected)> _disconnectCallbacks = [];

  @override
  Future<bool> connect({ VoidCallback? onConnect, bool Function(bool wasConnected)? onDisconnect, ValueSetter<Object>? onError, int maxTries = 5 }) {
    final completer = Completer<bool>();
    int connectTry = 0;

    if (onDisconnect != null) {
      _disconnectCallbacks.add(onDisconnect);
    }

    /// Local helper util to only complete the completer when it's not completed yet
    void doComplete(bool res) => !completer.isCompleted ? completer.complete(res) : null;

    _connectionListener = source.device.connectionState.listen((fbp.BluetoothConnectionState state) {
      switch (state) {
        case fbp.BluetoothConnectionState.connected:
          connectTry = 0; // reset try count

          onConnect??();
          doComplete(true);
          _isConnected = true;
          return;
        case fbp.BluetoothConnectionState.disconnected:
          final wasConnected = _isConnected;
          // TODO: does this make even sense?
          if (!wasConnected && connectTry < maxTries) {
            connectTry++;
            source.device.connect();
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
        default:
          logger.finest('connectionState.listen called with unsupported state: $state');
          // do nothing
      }
    }, onError: onError);

    source.device.connect();
    return completer.future;
  }

  @override
  Future<bool> disconnect() async {
    await _connectionListener!.cancel();
    await source.device.disconnect();
    return true;
  }

  @override
  Future<List<FlutterBluePlusService>?> discoverServices() async {
    if (!isConnected) {
      logger.finer('Device not connected, cannot discover services');
      return null;
    }

    // Query actual services supported by the device. While they must be
    // rediscovered when a disconnect happens, this object is also recreated.
    try {
      final allServices = await source.device.discoverServices();
      logger.finer('fbp.discoverServices: $allServices');

      return allServices.map(FlutterBluePlusService.fromSource).toList();
    } catch (e) {
      logger.shout('Error on service discovery', [source.device, e]);
      return null;
    }
  }
  
  @override
  Future<bool> getCharacteristicValueByUuid(FlutterBluePlusCharacteristic characteristic, List<Uint8List> value) async {
    if (!_isConnected) {
      logger.finer('getCharacteristicValueByUuid: device not connect. Call device.connect() first');
      return false;
    }

    if (characteristic.canRead) { // Read characteristic value if supported
      try {
        final data = await characteristic.source.read();
        value.add(Uint8List.fromList(data));
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

      listener = characteristic.source.onValueReceived.listen((rawData) {
        logger.finer('getCharacteristicValueByUuid[${rawData.length}] $rawData');
        value.add(Uint8List.fromList(rawData));
      },
        cancelOnError: true,
        onDone: () {
          logger.finer('getCharacteristicValueByUuid: onDone called');
          completer.complete(true);
        },
        onError: (Object err) {
          logger.shout('getCharacteristicValueByUuid: Error while reading characteristic', err);
          completer.complete(false);
        }
      );

      final bool indicationsSet = await characteristic.source.setNotifyValue(true);
      logger.finer('BleReadCubit indicationsSet: $indicationsSet');
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
