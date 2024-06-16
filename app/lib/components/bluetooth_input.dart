import 'dart:async';

import 'package:blood_pressure_app/bluetooth/ble_read_cubit.dart';
import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/bluetooth/device_scan_cubit.dart';
import 'package:blood_pressure_app/components/bluetooth_input/closed_bluetooth_input.dart';
import 'package:blood_pressure_app/components/bluetooth_input/device_selection.dart';
import 'package:blood_pressure_app/components/bluetooth_input/input_card.dart';
import 'package:blood_pressure_app/components/bluetooth_input/measurement_failure.dart';
import 'package:blood_pressure_app/components/bluetooth_input/measurement_success.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show Guid;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class for inputting measurement through bluetooth.
class BluetoothInput extends StatefulWidget {
  /// Create a measurement input through bluetooth.
  const BluetoothInput({super.key,
    required this.settings,
    required this.onMeasurement,
  });

  /// Settings to store known devices.
  final Settings settings;

  /// Called when a measurement was received through bluetooth.
  final void Function(BloodPressureRecord data) onMeasurement;

  @override
  State<BluetoothInput> createState() => _BluetoothInputState();
}

class _BluetoothInputState extends State<BluetoothInput> {
  /// Whether the user expanded bluetooth input
  bool _isActive = false;

  final BluetoothCubit _bluetoothCubit =  BluetoothCubit();
  StreamSubscription<BluetoothState>? _bluetoothSubscription;
  DeviceScanCubit? _deviceScanCubit;
  BleReadCubit? _deviceReadCubit;

  @override
  void dispose() {
    unawaited(_bluetoothSubscription?.cancel());
    unawaited(_bluetoothCubit.close());
    unawaited(_deviceScanCubit?.close());
    unawaited(_deviceReadCubit?.close());
    super.dispose();
  }

  void _returnToIdle() async {
    await _bluetoothSubscription?.cancel();
    _bluetoothSubscription = null;
    await _deviceScanCubit?.close();
    _deviceScanCubit = null;
    await _deviceReadCubit?.close();
    _deviceReadCubit = null;
    if (_isActive) {
      setState(() {
        _isActive = false;
      });
    }
  }

  Widget _buildActive(BuildContext context) {
    final Guid serviceUUID = Guid('1810');
    final Guid characteristicUUID = Guid('1810');
    _bluetoothSubscription = _bluetoothCubit.stream.listen((state) {
      if (state is! BluetoothReady) {
        Log.trace('_BluetoothInputState: _bluetoothSubscription state=$state, calling _returnToIdle');
        _returnToIdle();
      }
    });
    _deviceScanCubit ??= DeviceScanCubit(
      service: serviceUUID,
      settings: widget.settings,
    );
    return BlocBuilder<DeviceScanCubit, DeviceScanState>(
      bloc: _deviceScanCubit,
      builder: (context, DeviceScanState state) {
        Log.trace('_BluetoothInputState _deviceScanCubit: $state');
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
            // distinction
          DeviceSelected() => BlocConsumer<BleReadCubit, BleReadState>(
            bloc: (){
              _deviceReadCubit = BleReadCubit(state.device,
                characteristicUUID: characteristicUUID,
                serviceUUID: serviceUUID,
              );
              return _deviceReadCubit;
            }(),
            listener: (BuildContext context, BleReadState state) {
              if (state is BleReadSuccess) {
                final BloodPressureRecord record = BloodPressureRecord(
                  state.data.timestamp ?? DateTime.now(),
                  state.data.systolic.toInt(), // TODO: use pressure info in data
                  state.data.diastolic.toInt(),
                  state.data.pulse?.toInt(),
                  'notes',
                );
                widget.onMeasurement(record);
              }
            },
            builder: (BuildContext context, BleReadState state) {
              Log.trace('_BluetoothInputState BleReadCubit: $state');
              return switch (state) {
                BleReadInProgress() => _buildMainCard(context,
                  child: const CircularProgressIndicator(),
                ),
                BleReadFailure() => MeasurementFailure(
                  onTap: _returnToIdle,
                ),
                BleReadSuccess() => MeasurementSuccess(
                  onTap: _returnToIdle,
                  data: state.data,
                ),
              };
            },
          ),
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive) return _buildActive(context);
    return ClosedBluetoothInput(
      bluetoothCubit: _bluetoothCubit,
      onStarted: () => setState(() =>_isActive = true),
      inputInfo: () async {
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

  Widget _buildMainCard(BuildContext context, {
    required Widget child,
    Widget? title,
  }) => InputCard(
    onClosed: _returnToIdle,
    title: title,
    child: child,
  );
}
