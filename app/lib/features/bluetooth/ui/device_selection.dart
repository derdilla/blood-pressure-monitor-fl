import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A pairing dialoge with a single bluetooth device.
class DeviceSelection extends StatelessWidget {
  /// Create a pairing dialoge with a single bluetooth device.
  const DeviceSelection({super.key,
    required this.scanResults,
    required this.onAccepted,
  });

  /// The name of the device trying to connect.
  final List<BluetoothDevice> scanResults;

  /// Called when the user accepts the device.
  final void Function(BluetoothDevice) onAccepted;

  Widget _buildDeviceTile(BuildContext context, BluetoothDevice dev) => ListTile(
    title: Text(dev.name),
    trailing: FilledButton(
      onPressed: () => onAccepted(dev),
      child: Text(AppLocalizations.of(context)!.connect),
    ),
    onTap: () => onAccepted(dev),
  );

  @override
  Widget build(BuildContext context) {
    assert(scanResults.isNotEmpty);
    return InputCard(
      title: Text(AppLocalizations.of(context)!.availableDevices),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final dev in scanResults)
            _buildDeviceTile(context, dev),
        ]
      ),
    );
  }

}
