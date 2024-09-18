import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'device_scan_state.dart';

/// A component to search for bluetooth devices.
///
/// For this to work the app must have access to the bluetooth adapter
/// ([BluetoothCubit]).
/// 
/// A device counts as recognized, when the user connected with it at least 
/// once. Recognized devices connect automatically.
class DeviceScanCubit extends Cubit<DeviceScanState> with TypeLogger {
  /// Search for bluetooth devices that match the criteria or are known
  /// ([Settings.knownBleDev]).
  DeviceScanCubit({
    required BluetoothManager manager,
    required this.service,
    required this.settings,
  }): super(DeviceListLoading()) {
    _manager = manager;
    _startScanning();
  }

  /// Storage for known devices.
  late final Settings settings;

  /// Service required from bluetooth devices.
  late final String service;

  late final BluetoothManager _manager;

  @override
  Future<void> close() async {
    final stopped = await _stopScanning();
    if (stopped) {
      await super.close();
    }
  }

  Future<void> _startScanning() async {
    try {
      // no timeout, the user knows best how long scanning is needed
      // Not all devices are found using this configuration (https://pub.dev/packages/flutter_blue_plus#scanning-does-not-find-my-device).
      await _manager.discovery.start(service, _onScanResult);
    } catch (e) {
      _onScanError(e);
    }
  }

  Future<bool> _stopScanning() async {
    try {
      await _manager.discovery.stop();
    } catch (err) {
      logger.severe('Failed to stop scanning', err);
      return false;
    }

    return true;
  }

  void _onScanResult(List<BluetoothDevice> devices) {
    logger.finer('_onScanResult devices: $devices');

    // No need to check whether the devices really support the searched
    // characteristic as users have to select their device anyways.
    if(state is DeviceSelected) {
      return;
    }

    final preferred = devices.firstWhereOrNull((dev) =>
      settings.knownBleDev.contains(dev.name));

    if (preferred != null) {
      _stopScanning()
        .then((_) => emit(DeviceSelected(preferred)));
    } else if (devices.isEmpty) {
      emit(DeviceListLoading());
    } else if (devices.length == 1) {
      emit(SingleDeviceAvailable(devices.first));
    } else {
      emit(DeviceListAvailable(devices));
    }
  }

  void _onScanError(Object error) {
    logger.severe('Error during device discovery', error);
  }

  /// Mark a new device as known and switch to selected device state asap.
  Future<void> acceptDevice(BluetoothDevice device) async {
    assert(state is! DeviceSelected);
    try {
      await _stopScanning();
    } catch (e) {
      _onScanError(e);
      return;
    }

    assert(!_manager.discovery.isDiscovering);
    emit(DeviceSelected(device));
    final List<String> list = settings.knownBleDev.toList();
    list.add(device.name);
    settings.knownBleDev = list;
  }
}
