import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// Wrapper class for bluetooth implementations to generically expose required functionality
abstract class BluetoothDevice<
  BM extends BluetoothManager,
  BS extends BluetoothService,
  BC extends BluetoothCharacteristic,
  BackendDevice
> with TypeLogger {
  /// Create a new BluetoothDevice.
  ///
  /// * [manager] Manager the device belongs to
  /// * [source] Device implementation of the current backend
  BluetoothDevice(this.manager, this.source) {
    logger.finer('init device: $this');
  }

  /// [BluetoothManager] this device belongs to
  final BM manager;

  /// Original source device as returned by the backend
  final BackendDevice source;

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

  /// Require backends to implement a dispose method to cleanup any resources
  Future<void> dispose();

  /// Array of disconnect callbacks
  ///
  /// Disconnect callbacks are processed in reverse order, i.e. the latest added callback is executed as first. Callbacks
  /// can return true to indicate they have fully handled the disconnect. This will then also stop executing any remaining
  /// callbacks.
  final List<bool Function()> disconnectCallbacks = [];

  /// Connect to the device
  ///
  /// Always call disconnect when ready after calling connect
  Future<bool> connect({ VoidCallback? onConnect, bool Function()? onDisconnect, ValueSetter<Object>? onError }) async {
    final completer = Completer<bool>();
    logger.finer('connect: Init');

    if (onDisconnect != null) {
      disconnectCallbacks.add(onDisconnect);
    }

    await _connectionListener?.cancel();
    _connectionListener = connectionStream.listen((BluetoothConnectionState state) {
      logger.finest('connectionStream.listen[isConnected: $_isConnected]: $state');

      switch (state) {
        case BluetoothConnectionState.connected:
          onConnect?.call();
          if (!completer.isCompleted) completer.complete(true);
          _isConnected = true;
          return;
        case BluetoothConnectionState.disconnected:
          for (final fn in disconnectCallbacks.reversed) {
            if (fn()) {
              // ignore other disconnect callbacks
              break;
            }
          }

          disconnectCallbacks.clear();
          if (!completer.isCompleted) completer.complete(false);
          _isConnected = false;
      }
    }, onError: onError);

    await backendConnect();
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
    await dispose();
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
    final logServices = _services == null; // only log services on the first call
    _services ??= await discoverServices();
    if (_services == null) {
      logger.finer('Failed to discoverServices on: $this');
    }

    if (logServices) {
      logger.finest(_services
        ?.map((s) => 'Found services\n$s:\n  - ${s.characteristics.join('\n  - ')}]')
        .join('\n'));
    }

    return _services;
  }

  /// Returns the service with requested [uuid] or null if requested service is not available
  Future<BS?> getServiceByUuid(BluetoothUuid uuid) async {
    final services = await getServices();
    return services?.firstWhereOrNull((service) => service.uuid == uuid);
  }

  /// Retrieves the value of [characteristic] from the device and calls [onValue] for all received values
  /// 
  /// This method provides a generic implementation for async reading of data, regardless whether the
  /// characteristic can be read directly or through a notification or indication. In case the value
  /// is being read using an indication, then the [onValue] callback receives a second argument [complete] with
  /// which you can stop reading the data.
  ///
  /// Note that a [characteristic] could have multiple values, so [onValue] can be called more then once.
  /// TODO: implement reading values for characteristics with [canNotify]
  Future<bool> getCharacteristicValue(BC characteristic, void Function(Uint8List value, [void Function(bool success)? complete]) onValue);

  @override
  String toString() => 'BluetoothDevice{name: $name, deviceId: $deviceId}';

  @override
  bool operator == (Object other) => other is BluetoothDevice
    && hashCode == other.hashCode;

  @override
  int get hashCode => deviceId.hashCode ^ name.hashCode;
}

/// Generic logic to implement an indication stream to read characteristic values
mixin CharacteristicValueListener<
  BM extends BluetoothManager,
  BS extends BluetoothService,
  BC extends BluetoothCharacteristic,
  BackendDevice
> on BluetoothDevice<BM, BS, BC, BackendDevice> {
  /// List of read characteristic completers, used for cleanup on device disconnect
  final List<Completer<bool>> _readCharacteristicCompleters = [];
  /// List of read characteristic subscriptions, used for cleanup on device disconnect
  final List<StreamSubscription<Uint8List?>> _readCharacteristicListeners = [];

  /// Dispose of all resources used to read characteristics
  ///
  /// Internal method, should not be used by users
  @protected
  Future<void> disposeCharacteristics() async {
    for (final completer in _readCharacteristicCompleters) {
      // completing the completer also cancels the listener
      completer.complete(false);
    }

    _readCharacteristicCompleters.clear();
    _readCharacteristicListeners.clear();
  }

  /// Trigger notifications or indications for the [characteristic]
  @protected
  Future<bool> triggerCharacteristicValue(BC characteristic, [bool state = true]);

  /// Read characteristic values from a stream
  ///
  /// It's not recommended to use this method directly, use [BluetoothDevice.getCharacteristicValue] instead
  @protected
  Future<bool> listenCharacteristicValue(
    BC characteristic,
    Stream<Uint8List?> characteristicValueStream,
    void Function(Uint8List value, [void Function(bool success)? complete]) onValue
  ) async {
    if (!characteristic.canIndicate) {
      return false;
    }

    final completer = Completer<bool>();
    bool receivedSomeData = false;

    bool disconnectCallback() {
      logger.finer('listenCharacteristicValue(receivedSomeData: $receivedSomeData): onDisconnect called');
      if (!receivedSomeData) {
        return false;
      }

      completer.complete(true);
      return true;
    }

    disconnectCallbacks.add(disconnectCallback);

    final listener = characteristicValueStream.listen((value) {
      if (value == null) {
        // ignore null values
        return;
      }

      logger.finer('listenCharacteristicValue[${value.length}] $value');

      receivedSomeData = true;
      onValue(value, completer.complete);
    },
      cancelOnError: true,
      onDone: () {
        logger.finer('listenCharacteristicValue: onDone called');
        completer.complete(receivedSomeData);
      },
      onError: (Object err) {
        logger.shout('listenCharacteristicValue: Error while reading characteristic', err);
        completer.complete(false);
      }
    );

    // track completer & listener so we can clean them up
    // when the device unexpectedly disconnects (ie before
    // any data has been received yet)
    _readCharacteristicCompleters.add(completer);
    _readCharacteristicListeners.add(listener);

    final bool triggerSuccess = await triggerCharacteristicValue(characteristic);
    if (!triggerSuccess) {
      logger.warning('listenCharacteristicValue: triggerCharacteristicValue returned $triggerSuccess');
    }

    return completer.future.then((res) {
      // Ensure listener is always cancelled when completer resolves
      listener.cancel().then((_) => _readCharacteristicListeners.remove(listener));

      // Remove stored completer reference
      _readCharacteristicCompleters.remove(completer);

      // Remove disconnect callback in case the connection was not automatically disconnected
      if (disconnectCallbacks.remove(disconnectCallback)) {
        logger.finer('listenCharacteristicValue: device was not automatically disconnected after completer finished, removing disconnect callback');
      }

      return res;
    });
  }
}
