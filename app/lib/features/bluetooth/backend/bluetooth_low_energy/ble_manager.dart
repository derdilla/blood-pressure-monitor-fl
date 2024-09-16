

import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/foundation.dart';

part 'ble_device.dart';
part 'ble_discovery.dart';
part 'ble_service.dart';
part 'ble_state.dart';

/// Bluetooth manager for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyManager extends BluetoothManager<DiscoveredEventArgs, UUID, GATTService, GATTCharacteristic> {
  /// constructor
  BluetoothLowEnergyManager() {
    logger.fine('init');

    // Sync current adapter state
    _adapterStateParser.parseAndCache(BluetoothLowEnergyStateChangedEventArgs(_backend.state));
  }

  @override
  Future<bool> enable() => Future.value(false);

  final CentralManager _backend = CentralManager();

  /// The actual backend implementation
  CentralManager get backend => _backend;

  final BluetoothLowEnergyStateParser _adapterStateParser = BluetoothLowEnergyStateParser();

  @override
  BluetoothAdapterState get lastKnownAdapterState => _adapterStateParser.lastKnownState;

  @override
  Stream<BluetoothAdapterState> get stateStream => _backend.stateChanged.transform(
    BluetoothAdapterStateStreamTransformer(stateParser: _adapterStateParser)
  );

  BluetoothLowEnergyDiscovery? _discovery;

  @override
  BluetoothLowEnergyDiscovery get discovery {
    _discovery ??= BluetoothLowEnergyDiscovery(this);
    return _discovery as BluetoothLowEnergyDiscovery;
  }

  @override
  BluetoothLowEnergyDevice createDevice(DiscoveredEventArgs device) => BluetoothLowEnergyDevice(this, device);

  @override
  BluetoothLowEnergyUUID createUuid(UUID uuid) => BluetoothLowEnergyUUID(uuid);

  @override
  BluetoothLowEnergyUUID createUuidFromString(String uuid) => BluetoothLowEnergyUUID.fromString(uuid);

  @override
  BluetoothLowEnergyService createService(GATTService service) => BluetoothLowEnergyService.fromSource(service);

  @override
  BluetoothLowEnergyCharacteristic createCharacteristic(GATTCharacteristic characteristic) => BluetoothLowEnergyCharacteristic.fromSource(characteristic);
}