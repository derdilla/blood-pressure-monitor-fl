import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/bluetooth_input_mode.dart';
import 'package:flutter/material.dart';

class BleInputOptionsTile extends StatelessWidget {
  const BleInputOptionsTile({super.key,
    required this.value,
    required this.onChanged,
  });

  final BluetoothInputMode value;

  final void Function(BluetoothInputMode?) onChanged;

  @override
  Widget build(BuildContext context) => RadioGroup<BluetoothInputMode>(
    groupValue: value,
    onChanged: onChanged,
    // TODO: Write shorter texts per tile
    child: ExpansionTile(
      title: Text(AppLocalizations.of(context)!.bluetoothInput),
      leading: const Icon(Icons.bluetooth),
      children: [
        Padding(
          padding: EdgeInsetsGeometry.all(6.0),
          child: Text(AppLocalizations.of(context)!.bluetoothInputDesc),
        ),
        for (final mode in BluetoothInputMode.values)
          RadioListTile(
            value: mode,
            title: Text(mode.localize(AppLocalizations.of(context)!)),
          ),
      ],
    ),
  );
}
