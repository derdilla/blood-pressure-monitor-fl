
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.exportImport),),
      body: Consumer<Settings>(builder: (context, settings, child) {
        List<Widget> modeSpecificSettings = [];
        if (settings.exportFormat == ExportFormat.csv) {
          modeSpecificSettings = [];
        }

        List<Widget> options = [
          DropDownSettingsTile<ExportFormat>(
            key: const Key('exportFormat'),
            leading: const Icon(Icons.error),
            title: Text(AppLocalizations.of(context)!.exportFormat),
            value: settings.exportFormat,
            items: [
              DropdownMenuItem(value: ExportFormat.csv, child: Text(AppLocalizations.of(context)!.csv)),
              DropdownMenuItem(value: ExportFormat.pdf, child: Text(AppLocalizations.of(context)!.pdf)),
            ],
            onChanged: (ExportFormat? value) {
              if (value != null) {
                settings.exportFormat = value;
              }
            },
          )
        ];
        options.addAll(modeSpecificSettings);

        return ListView(
          children: options,
        );
      }),
    );
  }
}
