

import 'dart:io';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_discovery.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_service.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_state.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/flutter_blue_plus_mockable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show Guid, ScanResult;

/// Bluetooth manager for the 'flutter_blue_plus' package
class FlutterBluePlusManager extends BluetoothManager<ScanResult, Guid, fbp.BluetoothService, fbp.BluetoothCharacteristic> {
  /// constructor
  FlutterBluePlusManager([FlutterBluePlusMockable? backend]): backend = (backend ?? FlutterBluePlusMockable()) {
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

  @override
  BluetoothAdapterState get lastKnownAdapterState {
    // Check whether our lastKnownState is the same as FlutterBluePlus's
    assert(_adapterStateParser.parse(backend.adapterStateNow) == _adapterStateParser.lastKnownState);
    return _adapterStateParser.lastKnownState;
  }

  final FlutterBluePlusStateParser _adapterStateParser = FlutterBluePlusStateParser();

  @override
  Stream<BluetoothAdapterState> get stateStream => backend.adapterState.map(_adapterStateParser.parse);

  FlutterBluePlusDiscovery? _discovery;

  @override
  FlutterBluePlusDiscovery get discovery {
    _discovery ??= FlutterBluePlusDiscovery(this);
    return _discovery!;
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
