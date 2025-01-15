import 'package:blood_pressure_app/features/old_bluetooth/ui/input_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A pairing dialoge with a single bluetooth device.
class DeviceSelection extends StatelessWidget {
  /// Create a pairing dialoge with a single bluetooth device.
  const DeviceSelection({super.key,
    required this.scanResults,
    required this.onAccepted,
  });

  /// The name of the device trying to connect.
  final List<ScanResult> scanResults;

  /// Called when the user accepts the device.
  final void Function(BluetoothDevice) onAccepted;

  Widget _buildDeviceTile(BuildContext context, ScanResult dev) => ListTile(
    title: Text(dev.device.platformName),
    trailing: FilledButton(
      onPressed: () => onAccepted(dev.device),
      child: Text(AppLocalizations.of(context)!.connect),
    ),
    onTap: () => onAccepted(dev.device),
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
