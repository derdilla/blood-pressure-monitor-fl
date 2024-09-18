
import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// Wrapper class for bluetooth implementations to generically expose required functionality
abstract class BluetoothDevice<BM extends BluetoothManager, BS extends BluetoothService, BC extends BluetoothCharacteristic, BackendDevice> with TypeLogger {
  /// Create a new BluetoothLowEnergyDevice
  ///
  /// [manager] Manager the device belongs to
  /// [source] Device implementation of the current backend
  BluetoothDevice(this.manager, this.source) {
    logger.finer('init device: $this');
  }

  /// BluetoothManager this device belongs to
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

  /// Array of disconnect callbacks
  ///
  /// Disconnect callbacks are processed in reverse order, i.e. the latest added callback is executed as first. Callbacks
  /// can return true to indicate they have fully handled the disconnect. This will then also stop executing any remaining
  /// callbacks.
  final List<bool Function()> disconnectCallbacks = [];

  /// Connect to the device
  ///
  /// Always call disconnect when ready after calling connect
  Future<bool> connect({ VoidCallback? onConnect, bool Function()? onDisconnect, ValueSetter<Object>? onError, int maxTries = 5 }) {
    final completer = Completer<bool>();
    logger.finer('connect: Init');

    if (onDisconnect != null) {
      disconnectCallbacks.add(onDisconnect);
    }

    _connectionListener?.cancel();
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
    return services?.firstWhereOrNull((service) => service.uuid == uuid);
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
