import 'dart:async';

import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/bluetooth/flutter_blue_plus_mockable.dart';
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
    assert(!_flutterBluePlus.isScanningNow, '');
    _startScanning();
  }

  /// Storage for known devices.
  final Settings settings;

  /// Service required from bluetooth devices.
  final Guid service;

  final FlutterBluePlusMockable _flutterBluePlus;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  bool _isScanning = false;

  @override
  Future<void> close() async {
    await _scanResultsSubscription.cancel();
    await _isScanningSubscription.cancel();
    await super.close();
  }

  Future<void> _startScanning() async {
    _scanResultsSubscription = _flutterBluePlus.scanResults
        .listen(_onScanResult,
      onError: _onScanError,
    );
    try {
      await _flutterBluePlus.startScan(
        withServices: [service],
        // no timeout, the user knows best how long scanning is needed
      );
    } catch (e) {
      _onScanError(e);
    }
    _isScanningSubscription = _flutterBluePlus.isScanning
        .listen(_onIsScanningChanged);
  }

  void _onScanResult(List<ScanResult> devices) {
    assert(_isScanning);
    if(state is DeviceSelected) return;
    final preferred = devices.firstWhereOrNull((dev) =>
        settings.knownBleDev.contains(dev.device.advName));
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
    // TODO
  }

  void _onIsScanningChanged(bool isScanning) {
    _isScanning = isScanning;
    // TODO: consider restarting
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
    assert(!_isScanning);
    emit(DeviceSelected(device));
    settings.knownBleDev.add(device.advName); // TODO: does this work?
  }

  /// Remove all known devices and start scanning again.
  Future<void> clearKnownDevices() async {
    settings.knownBleDev = [];
    emit(DeviceListLoading());
    if (!_isScanning) await _startScanning();
  }

}
