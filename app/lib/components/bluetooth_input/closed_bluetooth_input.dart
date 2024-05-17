import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A closed ble input that shows the adapter state and allows to start the input.
class ClosedBluetoothInput extends StatelessWidget {
  /// Show adapter state and allow starting inputs
  const ClosedBluetoothInput({super.key,
    required this.bluetoothCubit,
    required this.onStarted,
    this.inputInfo,
  });

  /// State update provider and interaction with the device.
  final BluetoothCubit bluetoothCubit;

  /// Called when the user taps on an active start button.
  final void Function() onStarted;

  /// Callback called when the user wants to know more about this input.
  ///
  /// The info icon is not shown when this is null.
  final void Function()? inputInfo;

  Widget _buildTile({
    required String text,
    required IconData icon,
    required void Function() onTap,
  }) => ListTile(
    title: Text(text),
    leading: Icon(icon),
    onTap: onTap,
    trailing: inputInfo == null ? null : IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: inputInfo!,
    ),
  );
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<BluetoothCubit, BluetoothState>(
      bloc: bluetoothCubit,
      builder: (context, BluetoothState state) => switch(state) {
        BluetoothInitial() => const SizedBox.shrink(),
        BluetoothUnfeasible() => const SizedBox.shrink(),
        BluetoothUnauthorized() => _buildTile(
          text: localizations.errBleNoPerms,
          icon: Icons.bluetooth_disabled,
          onTap: () async {
            await bluetoothCubit.requestPermission();
            await bluetoothCubit.forceRefresh();
          },
        ),
        BluetoothDisabled() => _buildTile(
          text: localizations.bluetoothDisabled,
          icon: Icons.bluetooth_disabled,
          onTap: () async {
            await bluetoothCubit.enableBluetooth();
            await bluetoothCubit.forceRefresh();
          },
        ),
        BluetoothReady() => _buildTile(
          text: localizations.bluetoothInput,
          icon: Icons.bluetooth,
          onTap: onStarted,
        ),
      },
    );
  }
  
}
