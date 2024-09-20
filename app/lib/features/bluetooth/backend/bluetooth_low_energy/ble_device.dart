

import 'dart:async';
import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_service.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' show CentralManager, ConnectionState, DiscoveredEventArgs, GATTCharacteristicNotifiedEventArgs, PeripheralConnectionStateChangedEventArgs;

/// BluetoothDevice implementation for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyDevice
  extends BluetoothDevice<
    BluetoothLowEnergyManager,
    BluetoothLowEnergyService,
    BluetoothLowEnergyCharacteristic,
    DiscoveredEventArgs
  > with CharacteristicValueListener<
    BluetoothLowEnergyManager,
    BluetoothLowEnergyService,
    BluetoothLowEnergyCharacteristic,
    DiscoveredEventArgs
  >
{
  /// constructor
  BluetoothLowEnergyDevice(super.manager, super.source);

  @override
  String get deviceId => source.peripheral.uuid.toString();

  @override
  String get name => source.advertisement.name ?? deviceId;

  CentralManager get _cm => manager.backend;

  @override
  Stream<BluetoothConnectionState> get connectionStream => _cm.connectionStateChanged.transform(
    BluetoothConnectionStateStreamTransformer(stateParser: BluetoothLowEnergyConnectionStateParser())
  );

  @override
  Future<void> backendConnect() => _cm.connect(source.peripheral);

  @override
  Future<void> backendDisconnect() => _cm.disconnect(source.peripheral);

  @override
  Future<void> dispose() async {
    await disposeCharacteristics();
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
      final rawServices = await _cm.discoverGATT(source.peripheral);
      logger.finer('discoverServices: $rawServices');

      return rawServices.map(BluetoothLowEnergyService.fromSource).toList();
    } catch (e) {
      logger.shout('discoverServices: error:', [source.peripheral, e]);
      return null;
    }
  }
  
  @override
  Future<bool> triggerCharacteristicValue(BluetoothLowEnergyCharacteristic characteristic, [bool state = true]) async {
    await _cm.setCharacteristicNotifyState(source.peripheral, characteristic.source, state: true);
    return true;
  }

  @override
  Future<bool> getCharacteristicValue(
    BluetoothLowEnergyCharacteristic characteristic,
    void Function(Uint8List value, [void Function(bool success)? complete]) onValue
  ) async {
    if (!isConnected) {
      assert(false, 'getCharacteristicValue: device not connected. Call device.connect() first');
      logger.finer('getCharacteristicValue: device not connected.');
      return false;
    }

    if (characteristic.canRead) { // Read characteristic value if supported
      try {
        final data = await _cm.readCharacteristic(
          source.peripheral,
          characteristic.source,
        );

        onValue(data);
        return true;
      } catch (err) {
        return false;
      }
    }

    if (characteristic.canIndicate) { // Listen for characteristic value and trigger the device to send it
      return listenCharacteristicValue(
        characteristic,
        _cm.characteristicNotified.map((eventArgs) {
          if (characteristic.source != eventArgs.characteristic) {
            /// characteristicNotified is a generic stream which ble does not
            /// pre-filter for just the current requested characteristic
            logger.finer('    data is for a different characteristic');
            logger.finest('    ${eventArgs.characteristic.uuid} == ${characteristic.source.uuid} => ${eventArgs.characteristic == characteristic.source}');
            logger.finest('    ${eventArgs.characteristic} == ${characteristic.source} => ${eventArgs.characteristic == characteristic.source}');
            return null;
          }

          return eventArgs.value;
        }),
        onValue
      );
    }

    logger.severe("Can't read or indicate characteristic: $characteristic");
    return false;
  }
}

/// Implementation to transform [PeripheralConnectionStateChangedEventArgs] to [BluetoothConnectionState]
class BluetoothLowEnergyConnectionStateParser extends BluetoothConnectionStateParser<PeripheralConnectionStateChangedEventArgs> {
  @override
  BluetoothConnectionState parse(PeripheralConnectionStateChangedEventArgs rawState) {
    switch (rawState.state) {
      case ConnectionState.connected:
        return BluetoothConnectionState.connected;
      case ConnectionState.disconnected:
        return BluetoothConnectionState.disconnected;
    }
  }
}
