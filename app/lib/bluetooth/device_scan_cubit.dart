import 'dart:async';

import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/bluetooth/flutter_blue_plus_mockable.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'device_scan_state.dart';

/// A component to search for bluetooth devices.
///
/// For this to work the app must have access to the bluetooth adapter
/// ([BluetoothCubit]).
/// 
/// A device counts as recognized, when the user connected with it at least 
/// once. Recognized devices connect automatically.
class DeviceScanCubit extends Cubit<DeviceScanState> {
  /// Search for bluetooth devices that match the criteria or are known
  /// ([Settings.knownBleDev]).
  DeviceScanCubit({
    FlutterBluePlusMockable? flutterBluePlus,
    required this.service,
    required this.settings,
  }) : _flutterBluePlus = flutterBluePlus ?? FlutterBluePlusMockable(),
        super(DeviceListLoading()) {
    assert(!_flutterBluePlus.isScanningNow);
    _startScanning();
  }

  /// Storage for known devices.
  final Settings settings;

  /// Service required from bluetooth devices.
  final Guid service;

  final FlutterBluePlusMockable _flutterBluePlus;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  @override
  Future<void> close() async {
    await _scanResultsSubscription.cancel();
    try {
      await _flutterBluePlus.stopScan();
    } catch (e) {
      Log.err('Failed to stop scanning', [e]);
      return;
    }
    await super.close();
  }

  Future<void> _startScanning() async {
    _scanResultsSubscription = _flutterBluePlus.scanResults
      .listen(_onScanResult,
        onError: _onScanError,
    );
    try {
      await _flutterBluePlus.startScan(
        // no timeout, the user knows best how long scanning is needed
        withServices: [service],
        // Not all devices are found using this configuration (https://pub.dev/packages/flutter_blue_plus#scanning-does-not-find-my-device).
      );
    } catch (e) {
      _onScanError(e);
    }
  }

  void _onScanResult(List<ScanResult> devices) {
    Log.trace('_onScanResult devices: $devices');

    assert(_flutterBluePlus.isScanningNow);
    // No need to check whether the devices really support the searched
    // characteristic as users have to select their device anyways.
    if(state is DeviceSelected) return;
    final preferred = devices.firstWhereOrNull((dev) =>
        settings.knownBleDev.contains(dev.device.platformName));
    if (preferred != null) {
      emit(DeviceSelected(preferred.device));
    } else if (devices.isEmpty) {
      emit(DeviceListLoading());
    } else if (devices.length == 1) {
      emit(SingleDeviceAvailable(devices.first));
    } else {
      emit(DeviceListAvailable(devices));
    }
  }

  void _onScanError(Object error) {
    Log.err('Starting device scan failed', [ error ]);
  }

  /// Mark a new device as known and switch to selected device state asap.
  Future<void> acceptDevice(BluetoothDevice device) async {
    assert(state is! DeviceSelected);
    try {
      await _flutterBluePlus.stopScan();
    } catch (e) {
      _onScanError(e);
      return;
    }
    assert(!_flutterBluePlus.isScanningNow);
    emit(DeviceSelected(device));
    final List<String> list = settings.knownBleDev.toList();
    list.add(device.platformName);
    settings.knownBleDev = list;
  }

  /// Remove all known devices and start scanning again.
  Future<void> clearKnownDevices() async {
    settings.knownBleDev = [];
    emit(DeviceListLoading());
    if (!_flutterBluePlus.isScanningNow) await _startScanning();
  }

}
