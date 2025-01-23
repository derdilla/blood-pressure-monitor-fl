import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/foundation.dart';

/// Base class for backend device discovery implementations
abstract class BluetoothDeviceDiscovery<BM extends BluetoothManager> with TypeLogger {
  /// Initialize base class for device discovery implementations.
  BluetoothDeviceDiscovery(this.manager) {
    logger.finer('init device discovery: $this');
  }

  /// Corresponding BluetoothManager
  final BM manager;

  /// List of discovered devices
  final Set<BluetoothDevice> _devices = {};

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
  ///   [onDevices] callback can be called multiple times, it is also always
  ///   called with the list of all discovered devices from the start of discovering
  Future<void> start(String serviceUuid, ValueSetter<List<BluetoothDevice>> onDevices) async {
    if (_discovering) {
      logger.warning('Already discovering, not starting discovery again');
      return;
    }

    // Do not remove this if, otherwise the device_scan_cubit_test will 'hang'
    // Not sure why, it seems during testing this would close the mocked stream
    // immediately so when adding devices through mock.sink.add they never reach
    // the device_scan_cubit component
    // TODO: figure out why test fails without this if
    if (_discoverSubscription != null) {
      await _discoverSubscription?.cancel();
    }

    _discovering = true;
    _devices.clear();

    _discoverSubscription = discoverStream.listen((newDevices) {
      logger.finest('New devices discovered: $newDevices');
      assert(_discovering);

      // Note that there are major differences in how backends return discovered devices,
      // f.e. FlutterBluePlus batches results itself while BluetoothLowEnergy will always
      // return one device per listen callback.
      // The _devices type [Set] makes sure sure we are not adding duplicate devices.
      _devices.addAll(newDevices);

      onDevices(_devices.toList());
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
