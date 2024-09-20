import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/ble_read_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/device_scan_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/closed_bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/device_selection.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/input_card.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/measurement_failure.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/measurement_multiple.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/measurement_success.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// Class for inputting measurement through bluetooth.
class BluetoothInput extends StatefulWidget {
  /// Create a measurement input through bluetooth.
  const BluetoothInput({super.key,
    required this.onMeasurement,
    required this.manager,
    this.bluetoothCubit,
    this.deviceScanCubit,
    this.bleReadCubit,
  });

  /// Bluetooth Backend manager
  final BluetoothManager manager;

  /// Called when a measurement was received through bluetooth.
  final void Function(BloodPressureRecord data) onMeasurement;

  /// Function to customize [BluetoothCubit] creation.
  final BluetoothCubit Function()? bluetoothCubit;

  /// Function to customize [DeviceScanCubit] creation.
  final DeviceScanCubit Function()? deviceScanCubit;

  /// Function to customize [BleReadCubit] creation.
  final BleReadCubit Function(BluetoothDevice dev)? bleReadCubit;

  @override
  State<BluetoothInput> createState() => _BluetoothInputState();
}

/// Read bluetooth input happy workflow:
/// - build is called and renders ClosedBluetoothInput with read bluetooth input button
/// - User clicks button, toggles _isActive
/// - _buildActive is called, waits for device_scan_state.DeviceSelected
/// - _buildReadDevice is called, waits for ble_read_state.BleReadSuccess
/// - onMeasurement callback triggered
class _BluetoothInputState extends State<BluetoothInput> with TypeLogger {
  /// Whether the user initiated reading bluetooth input
  bool _isActive = false;

  late final BluetoothCubit _bluetoothCubit;
  DeviceScanCubit? _deviceScanCubit;
  BleReadCubit? _deviceReadCubit;

  StreamSubscription<BluetoothState>? _bluetoothSubscription;

  /// Data received from reading bluetooth values.
  ///
  /// Its presence indicates that this input is done.
  BleMeasurementData? _finishedData;

  @override
  void initState() {
    super.initState();
    _bluetoothCubit = widget.bluetoothCubit?.call() ?? BluetoothCubit(manager: widget.manager);
  }

  @override
  void dispose() {
    unawaited(_bluetoothSubscription?.cancel());
    unawaited(_bluetoothCubit.close());
    unawaited(_deviceScanCubit?.close());
    unawaited(_deviceReadCubit?.close());
    super.dispose();
  }

  void _returnToIdle() async {
    // No need to show wait in the UI.
    if (_isActive) {
      setState(() {
        _isActive = false;
        _finishedData = null;
      });
    }

    await _deviceReadCubit?.close();
    await _deviceScanCubit?.close();
    await _bluetoothSubscription?.cancel();
    _deviceReadCubit = null;
    _deviceScanCubit = null;
    _bluetoothSubscription = null;
  }

  // TODO(derdilla): extract logic from UI
  @override
  Widget build(BuildContext context) {
    const SizeChangedLayoutNotification().dispatch(context);
    logger.finer('build[_isActive: $_isActive, _finishedData: $_finishedData]');

    if (_finishedData != null) {
      return MeasurementSuccess(
        onTap: _returnToIdle,
        data: _finishedData!,
      );
    }

    if (_isActive) {
      return _buildActive(context);
    }

    return ClosedBluetoothInput(
      bluetoothCubit: _bluetoothCubit,
      onStarted: () async {
        setState(() => _isActive = true);
      },
      inputInfo: () async {
        logger.finer('build.inputInfo[mounted: ${context.mounted}]');
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.bluetoothInput),
              content: Text(AppLocalizations.of(context)!.aboutBleInput),
              actions: <Widget>[
                ElevatedButton(
                  child: Text((AppLocalizations.of(context)!.btnConfirm)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /// Build widget for 'adapter ready & discovering devices from bluetooth' state
  Widget _buildActive(BuildContext context) {
    /// blood pressure service, see https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/group___u_u_i_d___s_e_r_v_i_c_e_s.html
    const String serviceUUID = '1810';
    /// blood pressure characterisic, see https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/group___u_u_i_d___c_h_a_r_a_c_t_e_r_i_s_t_i_c_s.html#ga95fc99c7a99cf9d991c81027e4866936
    const String characteristicUUID = '2A35';

    _bluetoothSubscription = _bluetoothCubit.stream.listen((state) {
      if (state is BluetoothStateReady) {
        logger.finest('_bluetoothSubscription.listen: state=$state');
      } else {
        logger.finer('_bluetoothSubscription.listen: state=$state, calling _returnToIdle');
        _returnToIdle();
      }
    });

    final settings = context.watch<Settings>();
    _deviceScanCubit ??= widget.deviceScanCubit?.call() ?? DeviceScanCubit(
      manager: widget.manager,
      service: serviceUUID,
      settings: settings,
    );

    return BlocBuilder<DeviceScanCubit, DeviceScanState>(
      bloc: _deviceScanCubit,
      builder: (context, DeviceScanState state) {
        logger.finer('DeviceScanCubit.builder deviceScanState: $state');
        const SizeChangedLayoutNotification().dispatch(context);
        return switch(state) {
          DeviceListLoading() => _buildMainCard(context,
            title: Text(AppLocalizations.of(context)!.scanningForDevices),
            child: const CircularProgressIndicator(),
          ),
          DeviceListAvailable() => DeviceSelection(
            scanResults: state.devices,
            onAccepted: (dev) => _deviceScanCubit!.acceptDevice(dev),
          ),
          SingleDeviceAvailable() => DeviceSelection(
            scanResults: [ state.device ],
            onAccepted: (dev) => _deviceScanCubit!.acceptDevice(dev),
          ),
          DeviceSelected() => _buildReadDevice(state, serviceUUID: serviceUUID, characteristicUUID: characteristicUUID)
        };
      },
    );
  }

  /// Build widget for 'reading characteristic value from bluetooth' state
  Widget _buildReadDevice(DeviceSelected state, { required String serviceUUID, required String characteristicUUID }) {
    logger.finer('_buildReadDevice: state: $state');
    return BlocConsumer<BleReadCubit, BleReadState>(
      bloc: () {
        _deviceReadCubit = widget.bleReadCubit?.call(state.device) ?? BleReadCubit(
          state.device,
          characteristicUUID: characteristicUUID,
          serviceUUID: serviceUUID,
        );
        return _deviceReadCubit;
      }(),
      listener: (BuildContext context, BleReadState state) {
        if (state is BleReadSuccess) {
          final BloodPressureRecord record = state.data.asBloodPressureRecord();
          widget.onMeasurement(record);
          setState(() => _finishedData = state.data);
        }
      },
      builder: (BuildContext context, BleReadState state) {
        logger.finer('BleReadCubit.builder: $state');
        const SizeChangedLayoutNotification().dispatch(context);

        return switch (state) {
          BleReadInProgress() => _buildMainCard(context,
            child: const CircularProgressIndicator(),
          ),
          BleReadFailure() => MeasurementFailure(
            onTap: _returnToIdle,
            reason: state.reason,
          ),
          BleReadMultiple() => MeasurementMultiple(
            onTap: _returnToIdle,
            onSelect: (data) => _deviceReadCubit!.useMeasurement(data),
            measurements: state.data,
          ),
          BleReadSuccess() => MeasurementSuccess(
            onTap: _returnToIdle,
            data: state.data,
          ),
        };
      },
    );
  }

  Widget _buildMainCard(BuildContext context, {
    required Widget child,
    Widget? title,
  }) => InputCard(
    onClosed: _returnToIdle,
    title: title,
    child: child,
  );
}
