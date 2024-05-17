import 'dart:async';

import 'package:blood_pressure_app/bluetooth/ble_read_cubit.dart';
import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/bluetooth/device_scan_cubit.dart';
import 'package:blood_pressure_app/components/bluetooth_input/closed_bluetooth_input.dart';
import 'package:blood_pressure_app/components/bluetooth_input/device_selection.dart';
import 'package:blood_pressure_app/components/bluetooth_input/input_card.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show Guid;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class for inputting measurement through bluetooth.
class BluetoothInput extends StatefulWidget {
  /// Create a measurement input through bluetooth.
  const BluetoothInput({super.key, required this.settings});

  /// Settings to store known devices.
  final Settings settings;

  @override
  State<BluetoothInput> createState() => _BluetoothInputState();
}
// TODO: more info
// TODO: make toggleable in settings

class _BluetoothInputState extends State<BluetoothInput> {
  /// Whether the user expanded bluetooth input
  bool _isActive = false;

  // TODO: return values

  final BluetoothCubit _bluetoothCubit =  BluetoothCubit();
  StreamSubscription<BluetoothState>? _bluetoothSubscription;
  DeviceScanCubit? _deviceScanCubit;

  void _returnToIdle() {
    _bluetoothSubscription?.cancel();
    _bluetoothSubscription = null;
    _deviceScanCubit?.close().then((_) => _deviceScanCubit = null);
    if (_isActive) {
      setState(() {
        _isActive = false;
      });
    }
  }

  // TODO: bloc dispose

  Widget _buildActive(BuildContext context) {
    _bluetoothSubscription = _bluetoothCubit.stream.listen((state) {
      if (state is! BluetoothReady) _returnToIdle();
    });
    _deviceScanCubit = DeviceScanCubit(
      service: Guid('1810'),
      settings: widget.settings,
    );
    return BlocBuilder<DeviceScanCubit, DeviceScanState>(
      bloc: _deviceScanCubit,
      builder: (context, DeviceScanState state) => switch(state) {
        DeviceListLoading() => _buildMainCard(context,
          title: Text(AppLocalizations.of(context)!.scanningForDevices),
          child: const CircularProgressIndicator()),
        DeviceListAvailable() => DeviceSelection(
          scanResults: state.devices,
          onAccepted: (dev) => _deviceScanCubit!.acceptDevice(dev),
        ),
        SingleDeviceAvailable() => DeviceSelection(
          scanResults: [ state.device ],
          onAccepted: (dev) => _deviceScanCubit!.acceptDevice(dev),
        ),
          // distinction
        DeviceSelected() => BlocBuilder<BleReadCubit, BleReadState>(
          bloc: BleReadCubit(state.device),
          builder: (BuildContext context, BleReadState state) => switch (state) {
            BleReadInProgress() => _buildMainCard(context,
              child: const CircularProgressIndicator()),
            BleReadFailure() => _buildMainCard(context,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8,),
                    Text(AppLocalizations.of(context)!.errMeasurementRead),
                  ],
                ),
              ),
            ),
            BleReadSuccess() => _buildMainCard(context,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.done, color: Colors.green),
                    const SizedBox(height: 8,),
                    Text(AppLocalizations.of(context)!.measurementSuccess),
                  ],
                ),
              ),
            ),
          },
        ),
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
  // TODO: scanning devices info


  Widget _buildMainCard(BuildContext context, {
    required Widget child,
    Widget? title,
  }) => InputCard(
    onClosed: _returnToIdle,
    title: title,
    child: child,
  );
}
