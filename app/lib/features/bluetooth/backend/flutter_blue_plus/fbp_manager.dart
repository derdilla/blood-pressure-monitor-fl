import 'dart:async';
import 'dart:io';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/flutter_blue_plus_mockable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show Guid, ScanResult;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

part 'fbp_device.dart';
part 'fbp_discovery.dart';
part 'fbp_service.dart';
part 'fbp_state.dart';

/// Bluetooth manager for the 'flutter_blue_plus' package
class FlutterBluePlusManager extends BluetoothManager<ScanResult, Guid, fbp.BluetoothService, fbp.BluetoothCharacteristic> {
  /// constructor
  FlutterBluePlusManager([FlutterBluePlusMockable? backend]): backend = backend ?? FlutterBluePlusMockable() {
    logger.finer('init');
  }

  /// backend implementation
  final FlutterBluePlusMockable backend;

  @override
  Future<bool> enable() async {
    if (Platform.isAndroid) {
      await backend.turnOn();
      return true;
    }

    return false;
  }

  final FlutterBluePlusStateParser _adapterStateParser = FlutterBluePlusStateParser();

  @override
  BluetoothAdapterState get lastKnownAdapterState {
    // Check whether our lastKnownState is the same as FlutterBluePlus's
    assert(_adapterStateParser.parse(backend.adapterStateNow) ==_adapterStateParser.lastKnownState);
    return _adapterStateParser.lastKnownState;
  }

  @override
  Stream<BluetoothAdapterState> get stateStream => backend.adapterState.transform(
    BluetoothAdapterStateStreamTransformer(stateParser: _adapterStateParser)
  );

  FlutterBluePlusDiscovery? _discovery;

  @override
  FlutterBluePlusDiscovery get discovery {
    _discovery ??= FlutterBluePlusDiscovery(this);
    return _discovery as FlutterBluePlusDiscovery; // cast to prevent null lint error
  }

  @override
  FlutterBluePlusDevice createDevice(ScanResult device) => FlutterBluePlusDevice(this, device);

  @override
  FlutterBluePlusUUID createUuid(Guid uuid) => FlutterBluePlusUUID(uuid);

  @override
  FlutterBluePlusUUID createUuidFromString(String uuid) => FlutterBluePlusUUID.fromString(uuid);

  @override
  FlutterBluePlusService createService(fbp.BluetoothService service) => FlutterBluePlusService.fromSource(service);

  @override
  FlutterBluePlusCharacteristic createCharacteristic(fbp.BluetoothCharacteristic characteristic) => FlutterBluePlusCharacteristic.fromSource(characteristic);
}
