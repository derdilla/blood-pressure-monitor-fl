import 'dart:async';

import 'package:blood_pressure_app/bluetooth/ble_read_cubit.dart';
import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/bluetooth/device_scan_cubit.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show Guid;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class for inputting measurement through bluetooth.
class BluetoothInput extends StatefulWidget {
  /// Create a measurement input through bluetooth.
  const BluetoothInput({super.key, required this.settings});

  final Settings settings;

  @override
  State<BluetoothInput> createState() => _BluetoothInputState();
}

class _BluetoothInputState extends State<BluetoothInput> {
  /// Whether the user expanded bluetooth input
  bool _isActive = false;

  final BluetoothCubit _bluetoothCubit =  BluetoothCubit();
  StreamSubscription<BluetoothState>? _bluetoothSubscription;

  void _returnToIdle() {
    _bluetoothSubscription?.cancel();
    _bluetoothSubscription = null;
    if (_isActive) {
      setState(() {
        _isActive = false;
      });
    }
  }

  Widget _buildIdle(BuildContext context) => BlocBuilder<BluetoothCubit, BluetoothState>(
    bloc: _bluetoothCubit,
    builder: (context, BluetoothState state) => switch(state) {
      BluetoothInitial() => const Align(
        alignment: Alignment.topRight,
        child: CircularProgressIndicator(),
      ),
      BluetoothUnfeasible() => const SizedBox.shrink(),
      BluetoothUnauthorized() => Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.errBleNoPerms),
            const Icon(Icons.bluetooth_disabled),
            // TODO: tapable
          ],
        ),
      ),
      BluetoothDisabled() => Align(
        alignment: Alignment.topRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.bluetoothDisabled),
            const Icon(Icons.bluetooth_disabled),
            // TODO: tapable
          ],
        ),
      ),
      BluetoothReady() => IconButton(
        icon: const Icon(Icons.bluetooth),
        onPressed: () => setState(() => _isActive = true),
      ),
    },
  );

  Widget _buildActive(BuildContext context) {
    _bluetoothSubscription = _bluetoothCubit.stream.listen((state) {
      if (state is! BluetoothReady) _returnToIdle();
    });
    final deviceScanBloc = DeviceScanCubit(
      service: Guid('1810'),
      settings: widget.settings,
    );
    return BlocBuilder<DeviceScanCubit, DeviceScanState>(
      bloc: deviceScanBloc,
      builder: (context, DeviceScanState state) => switch(state) {
        DeviceListLoading() => _buildMainCard(context,
          child: const CircularProgressIndicator()),
        DeviceListAvailable() => _buildMainCard(context,
          title: Text(AppLocalizations.of(context)!.selectDevice),
          child: ListView(
            children: [
              for (final d in state.devices)
                ListTile(
                  // TODO: consider only passing the string
                  title: Text(d.device.platformName),
                  onTap: () => deviceScanBloc.acceptDevice(d.device),
                ),
            ],
          ),
        ),
        SingleDeviceAvailable() => _buildMainCard(context,
          title: Text(AppLocalizations.of(context)!
              .connectTo(state.device.device.platformName)),
          child: FilledButton(
            child: Text(AppLocalizations.of(context)!.connect),
            onPressed: () => deviceScanBloc.acceptDevice(state.device.device),
          ),
        ),
        DeviceSelected() => BlocBuilder<BleReadCubit, BleReadState>(
          bloc: BleReadCubit(state.device),
          builder: (BuildContext context, BleReadState state) => switch (state) {
            BleReadInProgress() => _buildMainCard(context, child: CircularProgressIndicator()),
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
    return _buildIdle(context);
  }


  Widget _buildMainCard(BuildContext context, {
    required Widget child,
    Widget? title,
  }) => Card.outlined(
    color: Theme.of(context).cardColor,
    // borderRadius: BorderRadius.circular(24),
    // width: MediaQuery.of(context).size.width,
    // height: MediaQuery.of(context).size.width,
    // padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.all(8),
    child: Stack(
      children: [
        Padding( // content
          padding: const EdgeInsets.all(24),
          child: child,
        ),
        if (title != null)
          Align(
            alignment: Alignment.topLeft,
            child: title,
          ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => null, // TODO
          ),
        ),
      ],
    ),
  );
}

enum _State {
  /// Default state of the widget shown when no interaction happened.
  idle,
  /// Scanning and selecting devices.
  deviceScan,
  measurementRead,
}
