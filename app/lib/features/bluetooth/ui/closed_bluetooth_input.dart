import 'package:app_settings/app_settings.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A closed ble input that shows the adapter state and allows to start the input.
class ClosedBluetoothInput extends StatelessWidget with TypeLogger {
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
      builder: (context, BluetoothState state) {
        logger.finer('Called with state: $state');
        return switch(state) {
          BluetoothStateInitial() => const SizedBox.shrink(),
          BluetoothStateUnfeasible() => const SizedBox.shrink(),
          BluetoothStateUnauthorized() => _buildTile(
            text: localizations.errBleNoPerms,
            icon: Icons.bluetooth_disabled,
            onTap: () async {
              await AppSettings.openAppSettings();
              await bluetoothCubit.forceRefresh();
            },
          ),
          BluetoothStateDisabled() => _buildTile(
            text: localizations.bluetoothDisabled,
            icon: Icons.bluetooth_disabled,
            onTap: () async {
              final bluetoothOn = await bluetoothCubit.enableBluetooth();
              if (!bluetoothOn) await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
              await bluetoothCubit.forceRefresh();
            },
          ),
          BluetoothStateReady() => _buildTile(
            text: localizations.bluetoothInput,
            icon: Icons.bluetooth,
            onTap: onStarted,
          )
        };
      },
    );
  }
  
}
