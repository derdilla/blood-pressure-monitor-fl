
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:file_saver/file_saver.dart' show MimeType;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exportImport),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Settings>(builder: (context, settings, child) {
        List<Widget> modeSpecificSettings = [];
        if (settings.exportFormat == ExportFormat.csv) {
          modeSpecificSettings = [
            InputSettingsTile(
              title: Text(AppLocalizations.of(context)!.fieldDelimiter),
              inputWidth: 40,
              initialValue: settings.csvFieldDelimiter,
              onEditingComplete: (value) {
                if (value != null) {
                  settings.csvFieldDelimiter = value;
                }
              },
            ),
            InputSettingsTile(
              title: Text(AppLocalizations.of(context)!.textDelimiter),
              inputWidth: 40,
              initialValue: settings.csvTextDelimiter,
              onEditingComplete: (value) {
                if (value != null) {
                  settings.csvTextDelimiter = value;
                }
              },
            )
          ];
        }

        List<Widget> options = [
          DropDownSettingsTile<MimeType>(
            key: const Key('exportMimeType'),
            title: Text(AppLocalizations.of(context)!.exportMimeType),
            value: settings.exportMimeType,
            items: [
              DropdownMenuItem(value: MimeType.csv, child: Text(AppLocalizations.of(context)!.csv)),
              DropdownMenuItem(value: MimeType.text, child: Text(AppLocalizations.of(context)!.text)),
              DropdownMenuItem(value: MimeType.pdf, child: Text(AppLocalizations.of(context)!.pdf)),
              DropdownMenuItem(value: MimeType.other, child: Text(AppLocalizations.of(context)!.other)),
            ],
            onChanged: (MimeType? value) {
              if (value != null) {
                settings.exportMimeType = value;
              }
            },
          ),
          DropDownSettingsTile<ExportFormat>(
            key: const Key('exportFormat'),
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
