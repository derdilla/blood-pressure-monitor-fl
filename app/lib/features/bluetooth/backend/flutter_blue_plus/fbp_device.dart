import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_connection.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

/// BluetoothDevice implementation for the 'flutter_blue_plus' package
final class FlutterBluePlusDevice extends BluetoothDevice<FlutterBluePlusManager, FlutterBluePlusService, FlutterBluePlusCharacteristic, fbp.ScanResult> {
  /// constructor
  FlutterBluePlusDevice(super.manager, super.source);

  @override
  String get deviceId => source.device.remoteId.str;

  @override
  String get name => source.device.platformName;

  @override
  Stream<BluetoothConnectionState> get connectionStream => source.device.connectionState.transform(
    BluetoothConnectionStateStreamTransformer(stateParser: FlutterBluePlusConnectionStateParser())
  );

  @override
  Future<void> backendConnect() => source.device.connect();

  @override
  Future<void> backendDisconnect() => source.device.disconnect();

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
  Future<bool> getCharacteristicValueByUuid(FlutterBluePlusCharacteristic characteristic, List<Uint8List> value) async {
    if (!isConnected) {
      logger.finer('getCharacteristicValueByUuid: device not connect. Call device.connect() first');
      return false;
    }

    if (characteristic.canRead) { // Read characteristic value if supported
      try {
        final data = await characteristic.source.read();
        value.add(Uint8List.fromList(data));
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

      listener = characteristic.source.onValueReceived.listen((rawData) {
        logger.finer('getCharacteristicValueByUuid[${rawData.length}] $rawData');
        value.add(Uint8List.fromList(rawData));
      },
        cancelOnError: true,
        onDone: () {
          logger.finer('getCharacteristicValueByUuid: onDone called');
          completer.complete(true);
        },
        onError: (Object err) {
          logger.shout('getCharacteristicValueByUuid: Error while reading characteristic', err);
          completer.complete(false);
        }
      );

      final bool indicationsSet = await characteristic.source.setNotifyValue(true);
      logger.finer('BleReadCubit indicationsSet: $indicationsSet');
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

/// Implementation to transform [fbp.BluetoothConnectionState] to [BluetoothConnectionState]
class FlutterBluePlusConnectionStateParser extends BluetoothConnectionStateParser<fbp.BluetoothConnectionState> {
  @override
  BluetoothConnectionState parse(fbp.BluetoothConnectionState rawState) {
    switch (rawState) {
      case fbp.BluetoothConnectionState.connected:
        return BluetoothConnectionState.connected;
      case fbp.BluetoothConnectionState.disconnected:
        return BluetoothConnectionState.disconnected;
      case fbp.BluetoothConnectionState.connecting:
      case fbp.BluetoothConnectionState.disconnecting:
        // code should never reach here
        throw ErrorDescription('Unsupported connection state: $rawState');
    }
  }
}
