import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' show CentralManager, ConnectionState, PeripheralConnectionStateChangedEventArgs;

/// BluetoothDevice implementation for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyDevice extends BluetoothDevice {
  /// Init BluetoothDevice implementation for the 'bluetooth_low_energy' package
  BluetoothLowEnergyDevice(super.manager, super.source);

  @override
  String get deviceId => source.peripheral.uuid.toString();

  @override
  String get name => source.advertisement.name ?? deviceId;

  CentralManager get _cm => manager;

  @override
  Stream<BluetoothConnectionState> get connectionStream => _cm.connectionStateChanged
    .map((PeripheralConnectionStateChangedEventArgs rawState) => switch (rawState.state) {
      ConnectionState.connected => BluetoothConnectionState.connected,
      ConnectionState.disconnected => BluetoothConnectionState.disconnected,
    });

  @override
  Future<void> backendConnect() => _cm.connect(source.peripheral);

  @override
  Future<void> backendDisconnect() => _cm.disconnect(source.peripheral);

  @override
  Future<void> dispose() async {}

}
