// TODO: cleanup types
// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:math';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// Current state of the bluetooth device
enum BluetoothDeviceState {
  /// Started connecting to the device
  connecting,
  /// Started disconnecting the device
  disconnecting,
  /// Device is connected (f.e. it send a connected event)
  connected,
  /// Device is disconnected (f.e. it send a disconnected event)
  disconnected;
}

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

  BluetoothDeviceState _state = BluetoothDeviceState.disconnected;

  /// (Unique?) id of the device
  String get deviceId;

  /// Name of the device
  String get name;

  /// Memoized service list for the device
  List<BS>? _services;

  StreamSubscription<BluetoothConnectionState>? _connectionListener;

  /// Whether the device is connected
  bool get isConnected => _state == BluetoothDeviceState.connected;

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

  /// Wait for the device state to change to a different value then disconnecting
  ///
  /// [timeout] - How long to wait before timeout occurs. A value of -1 disables waiting, a value of 0 waits indefinitely
  Future<void> _waitForDisconnectingStateChange({ int timeout = 300000 }) async {
    if (timeout < 0) {
      return;
    }

    // Futures within an any still always resolve, it's just that the results
    // are disregard for futures that do not finish first. Use this bool to
    // keep track whether the futures are already completed or not
    bool futuresCompleted = false;

    /// Waits and calls itself recursively as long as the current device [_state] equals [BluetoothDeviceState.disconnecting]
    Future<void> checkDeviceState() async {
      while (!futuresCompleted && _state == BluetoothDeviceState.disconnecting) {
        logger.finest('Waiting because device is still disconnecting');
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    final futures = [checkDeviceState()];
    if (timeout > 0) {
      futures.add(
        Future<void>.delayed(Duration(milliseconds: min(timeout, 300000))).then((_) {
          if (!futuresCompleted) {
            logger.finest('connect: Wait for state change timed out after $timeout ms');
          }
        })
      );
    }

    await Future.any(futures);
    futuresCompleted = true;
  }

  /// Connect to the device
  ///
  /// Always call [disconnect] when ready after calling connect
  /// [onConnect] Called after device is connected
  /// [onDisconnect] Called after device is disconnected, see [disconnectCallbacks]
  /// [onError] Called when an error occurs
  /// [waitForDisconnectingStateChangeTimeout] If connect is called while the device is still disconnecting, wait
  ///   for the device to change it's state. A value of -1 means don't ever wait, a value of 0 means wait indefinitely
  ///   Setting this timeout ensures correct state management of the device so users only have to call disconnect()/connect() 
  Future<bool> connect({
    VoidCallback? onConnect,
    bool Function()? onDisconnect,
    ValueSetter<Object>? onError,
    int waitForDisconnectingStateChangeTimeout = 3000
  }) async {
    if (_state == BluetoothDeviceState.disconnecting) {
      await _waitForDisconnectingStateChange(timeout: waitForDisconnectingStateChangeTimeout);
    }

    if (_state != BluetoothDeviceState.disconnected) {
      return false;
    }

    _state = BluetoothDeviceState.connecting;

    final completer = Completer<bool>();
    logger.finer('connect: start connecting');

    if (onDisconnect != null) {
      disconnectCallbacks.add(onDisconnect);
    }

    await _connectionListener?.cancel();
    _connectionListener = connectionStream.listen((BluetoothConnectionState state) {
      logger.finest('connectionStream.listen[_state: $_state]: $state');

      // Note: in this abstraction we want the device state to be singular. Unfortunately
      // not all libraries on all platforms send only a single connection state event. F.e.
      // flutter_blue_plus can send 3 disconnect events the very first time you try to connect
      // with a device. These multiple similar events for the same device will break our logic
      // so we need to filter the states.
      switch (state) {
        case BluetoothConnectionState.connected:
          if (_state != BluetoothDeviceState.connecting) {
            // Ignore status update if the current device state was not connecting. Cause then
            // the library probably send multiple state update events.
            logger.finest('Ignoring state update because device was not connecting: $_state');
            return;
          }

          onConnect?.call();
          if (!completer.isCompleted) completer.complete(true);
          _state = BluetoothDeviceState.connected;
          return;
        case BluetoothConnectionState.disconnected:
          if ([BluetoothDeviceState.connecting, BluetoothDeviceState.disconnected].any((s) => s == _state)) {
            // Ignore status update if the state was connecting or already disconnected
            logger.finest('Ignoring state update because device was already disconnected: $_state');
            return;
          }

          for (final fn in disconnectCallbacks.reversed) {
            if (fn()) {
              // ignore other disconnect callbacks
              break;
            }
          }

          disconnectCallbacks.clear();
          if (!completer.isCompleted) completer.complete(false);
          _state = BluetoothDeviceState.disconnected;
      }
    }, onError: onError);

    try {
      await backendConnect();
    } catch (e) {
      logger.severe('Failed to connect to device', e);
      if (!completer.isCompleted) completer.complete(false);
      _state = BluetoothDeviceState.disconnected;
    }

    return completer.future.then((res) {
      logger.finer('connect: completer.resolved($res)');
      return res;
    });
  }

  /// Disconnect & dispose the device
  ///
  /// Always call [disconnect] after calling [connect] to ensure all resources are disposed
  /// Optionally specify [waitForStateChangeTimeout] in milliseconds to indicate how long we
  /// should wait for the device to send a disconnect event. Specifying a value of -1 disables
  /// waiting for the state change, a value of 0 means wait indefinitely.
  Future<bool> disconnect({ int waitForStateChangeTimeout = 3000 }) async {
    _state = BluetoothDeviceState.disconnecting;
    await backendDisconnect();

    if (waitForStateChangeTimeout > -1) {
      await _waitForDisconnectingStateChange(timeout: waitForStateChangeTimeout);

      assert(
        _state == BluetoothDeviceState.disconnecting || _state == BluetoothDeviceState.disconnected,
        'Expected state either to be disconnecting (due to timeout) or disconnected. Got $_state instead'
      );
    }

    await _connectionListener?.cancel();
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
  /// Compare devices, only checking hashCode is not sufficient during tests as hashCode
  /// of mocked classes seems to be always 0 hence why also comparing by deviceId
  /// TODO: Understand why the mocked devices in the device_scan_cubit_test have the same hashCode=0 and are therefore not all added to the set
  bool operator == (Object other) => other is BluetoothDevice && hashCode == other.hashCode && deviceId == other.deviceId;

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

    final listener = characteristicValueStream.listen(
      (value) {
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

    try {
      logger.finest('listenCharacteristicValue: triggering characteristic value');
      final bool triggerSuccess = await triggerCharacteristicValue(characteristic);
      if (!triggerSuccess) {
        logger.warning('listenCharacteristicValue: triggerCharacteristicValue returned $triggerSuccess');
      }
    } catch (e) {
      logger.severe('Error occured while triggering characteristic', e);
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
