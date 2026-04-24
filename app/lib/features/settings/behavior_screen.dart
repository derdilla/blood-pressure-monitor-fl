import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/storage/settings.dart';
import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BehaviorScreen extends StatelessWidget {
  const BehaviorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.behavior),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(localizations.startWithAddMeasurementPage),
            subtitle: Text(localizations.startWithAddMeasurementPageDescription),
            secondary: const Icon(Icons.electric_bolt_outlined),
            value: settings.startWithAddMeasurementPage,
            onChanged: (value) {
              settings.startWithAddMeasurementPage = value;
            },
          ),
          SwitchListTile(
            value: settings.trustBLETime,
            title: Text(localizations.trustBLETime),
            secondary: const Icon(Icons.lock_clock_outlined),
            onChanged: (value) {
              settings.trustBLETime = value;
            },
          ),
          SwitchListTile(
            value: settings.allowManualTimeInput,
            onChanged: (value) {
              settings.allowManualTimeInput = value;
            },
            secondary: const Icon(Icons.details),
            title: Text(localizations.allowManualTimeInput),
          ),
          SwitchListTile(
            value: settings.validateInputs,
            title: Text(localizations.validateInputs),
            secondary: const Icon(Icons.edit),
            onChanged: settings.allowMissingValues ? null : (value) {
              assert(!settings.allowMissingValues);
              settings.validateInputs = value;
            },
          ),
          SwitchListTile(
            value: settings.allowMissingValues,
            title: Text(localizations.allowMissingValues),
            secondary: const Icon(Icons.report_off_outlined),
            onChanged: (value) {
              settings.allowMissingValues = value;
              if (value) settings.validateInputs = false;
            },
          ),
          SwitchListTile(
            value: settings.confirmDeletion,
            title: Text(localizations.confirmDeletion),
            secondary: const Icon(Icons.check),
            onChanged: (value) {
              settings.confirmDeletion = value;
            },
          ),
          DropDownListTile<PressureUnit?>(
            leading: const Icon(Icons.language),
            title: Text(localizations.preferredPressureUnit),
            value: settings.preferredPressureUnit,
            items: [
              for (final u in PressureUnit.values)
                DropdownMenuItem(
                  value: u,
                  child: Text(u.name),
                ),
            ],
            onChanged: (PressureUnit? value) {
              if (value != null) settings.preferredPressureUnit = value;
            },
          ),
          DropDownListTile<WeightUnit?>(
            leading: const Icon(Icons.language),
            title: Text(localizations.preferredWeightUnit),
            value: settings.weightUnit,
            items: [
              for (final u in WeightUnit.values)
                DropdownMenuItem(
                  value: u,
                  child: Text(u.name),
                ),
            ],
            onChanged: (WeightUnit? value) {
              if (value != null) settings.weightUnit = value;
            },
          ),
        ],
      ),
    );
  }
}
