

import 'dart:async';
import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_low_energy/ble_service.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' show
  CentralManager,
  ConnectionState,
  DiscoveredEventArgs,
  PeripheralConnectionStateChangedEventArgs;

/// BluetoothDevice implementation for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyDevice
  extends BluetoothDevice<BluetoothLowEnergyManager, BluetoothLowEnergyService, BluetoothLowEnergyCharacteristic, DiscoveredEventArgs> {
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
    if (!isConnected) {
      assert(false, 'getCharacteristicValueByUuid: device not connected. Call device.connect() first');
      logger.finer('getCharacteristicValueByUuid: device not connected.');
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

      bool disconnectCallback() {
        logger.finer('getCharacteristicValueByUuid(data.isEmpty: ${value.isEmpty}): onDisconnect called');
        if (value.isEmpty) {
          return false;
        }

        completer.complete(true);
        return true;
      }

      disconnectCallbacks.add(disconnectCallback);

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
        if (disconnectCallbacks.remove(disconnectCallback)) {
          logger.finer('getCharacteristicValueByUuid: device was not automatically disconnected after completer finished, removing disconnect callback');
        }

        return res;
      });
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
