import 'dart:async';
import 'dart:io';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_state.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// Bluetooth manager for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyManager extends BluetoothManager<DiscoveredEventArgs> {
  /// constructor
  BluetoothLowEnergyManager() {
    logger.fine('BluetoothLowEnergyManager()');

    // Sync current adapter state
    _adapterStateParser.parseAndCache(BluetoothLowEnergyStateChangedEventArgs(backend.state));
  }

  @override
  Future<bool?> enable() async {
    if (!Platform.isAndroid) {
      return null;
    }

    return backend.authorize();
  }

  /// The actual backend implementation
  @override
  final CentralManager backend = CentralManager();

  final BluetoothLowEnergyStateParser _adapterStateParser = BluetoothLowEnergyStateParser();

  @override
  BluetoothAdapterState get lastKnownAdapterState => _adapterStateParser.lastKnownState;

  @override
  Stream<BluetoothAdapterState> get stateStream => backend.stateChanged.map(_adapterStateParser.parse);

  BluetoothLowEnergyDiscovery? _discovery;

  @override
  BluetoothLowEnergyDiscovery get discovery {
    _discovery ??= BluetoothLowEnergyDiscovery(this);
    return _discovery!;
  }

  @override
  BluetoothLowEnergyDevice createDevice(DiscoveredEventArgs device) => BluetoothLowEnergyDevice(backend, device);

}
