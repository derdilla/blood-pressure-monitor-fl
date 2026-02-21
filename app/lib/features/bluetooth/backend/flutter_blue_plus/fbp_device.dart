import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

/// BluetoothDevice implementation for the 'flutter_blue_plus' package
final class FlutterBluePlusDevice
  extends BluetoothDevice<
    FlutterBluePlusManager,
    FlutterBluePlusService,
    FlutterBluePlusCharacteristic,
    fbp.ScanResult
  >
  with CharacteristicValueListener<
    FlutterBluePlusManager,
    FlutterBluePlusService,
    FlutterBluePlusCharacteristic,
    fbp.ScanResult
  >
{
  /// Initialize BluetoothDevice implementation for the 'flutter_blue_plus' package
  FlutterBluePlusDevice(super.manager, super.source);

  @override
  String get deviceId => source.device.remoteId.str;

  @override
  String get name => source.device.platformName;

  @override
  Stream<BluetoothConnectionState> get connectionStream => source.device.connectionState
    .map((fbp.BluetoothConnectionState rawState) => switch (rawState) {
      fbp.BluetoothConnectionState.connected => BluetoothConnectionState.connected,
      fbp.BluetoothConnectionState.disconnected => BluetoothConnectionState.disconnected,
      // ignore: deprecated_member_use, code should never reach here
      fbp.BluetoothConnectionState.connecting || fbp.BluetoothConnectionState.disconnecting
        => throw ErrorDescription('Unsupported connection state: $rawState'),
    });

  @override
  Future<void> backendConnect() => source.device.connect();

  @override
  Future<void> backendDisconnect() => source.device.disconnect();

  @override
  Future<void> dispose() => disposeCharacteristics();

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
  Future<bool> triggerCharacteristicValue(FlutterBluePlusCharacteristic characteristic, [bool state = true]) => characteristic.source.setNotifyValue(state);

  @override
  Future<bool> getCharacteristicValue(
    FlutterBluePlusCharacteristic characteristic,
    void Function(Uint8List value, [void Function(bool success)? complete]) onValue
  ) async {
    if (!isConnected) {
      assert(false, 'getCharacteristicValue: device not connected. Call device.connect() first');
      logger.finer('getCharacteristicValue: device not connected.');
      return false;
    }

    if (characteristic.canRead) { // Read characteristic value if supported
      try {
        final data = await characteristic.source.read();
        onValue(Uint8List.fromList(data));
        return true;
      } catch (err) {
        logger.severe('getCharacteristicValue(read error)', err);
        return false;
      }
    }

    if (characteristic.canIndicate) { // Listen for characteristic value and trigger the device to send it
      return listenCharacteristicValue(
        characteristic,
        characteristic.source.onValueReceived.map(Uint8List.fromList),
        onValue
      );
    }

    logger.severe("Can't read or indicate characteristic: $characteristic");
    return false;
  }
}
