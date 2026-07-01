import 'dart:math';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/input_card.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A pairing dialog with a single bluetooth device.
class DeviceSelection extends StatelessWidget {
  /// Create a pairing dialog with a single bluetooth device.
  const DeviceSelection({super.key,
    required this.scanResults,
    required this.onAccepted,
  });

  /// The name of the device trying to connect.
  final List<BluetoothDevice> scanResults;

  /// Called when the user accepts the device.
  final void Function(BluetoothDevice) onAccepted;

  @override
  Widget build(BuildContext context) {
    assert(scanResults.isNotEmpty);
    return InputCard(
      title: Text(AppLocalizations.of(context)!.availableDevices),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: min(400.0, MediaQuery.of(context).size.height)
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final dev in scanResults)
              _DeviceTile(dev, onAccepted),
          ]
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile(this.dev, this.onAccepted);

  final BluetoothDevice dev;

  final void Function(BluetoothDevice) onAccepted;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(dev.name),
    trailing: FilledButton(
      onPressed: () => onAccepted(dev),
      child: Text(AppLocalizations.of(context)!.connect),
    ),
    onTap: () => onAccepted(dev),
  );
}
