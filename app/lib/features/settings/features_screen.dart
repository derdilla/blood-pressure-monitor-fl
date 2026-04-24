import 'package:blood_pressure_app/features/settings/medicine_manager_screen.dart';
import 'package:blood_pressure_app/features/settings/tiles/ble_input_options_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.featuresSetting)),
      body: ListView(
        children: [
          SwitchListTile(
            value: settings.weightInput,
            title: Text(localizations.activateWeightFeatures),
            secondary: const Icon(Icons.scale),
            onChanged: (value) {
              settings.weightInput = value;
            },
          ),
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute<void>(builder:
                  (context) => const MedicineManagerScreen()));
            },
            leading: const Icon(Icons.medication),
            title: Text(localizations.medications),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          BleInputOptionsTile(
            value: settings.bleInput,
            onChanged: (value) => settings.bleInput = value ?? settings.bleInput,
          ),
        ],
      ),
    );
  }
}
