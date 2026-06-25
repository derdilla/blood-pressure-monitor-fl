import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PresetSelector extends StatelessWidget {
  const PresetSelector({super.key});

  @override
  Widget build(BuildContext context) => DropDownListTile<String>(
    title: Text(AppLocalizations.of(context)!.exportFieldsPreset),
    value: getPreset(context),
    items: [
      for (final preset in [
        ...ExportPreset.buildInPresets,
        CustomPreset([]),
        ...context.watch<ExportSettings>().presets
      ])
        DropdownMenuItem(
          value: preset.id,
          child: Text(preset.localize(AppLocalizations.of(context)!)),
        ),
    ],
    onChanged: (selectedPreset) {
      if (selectedPreset == null) return;
      setPreset(context, selectedPreset);
    },
  );

  String? getPreset(BuildContext context) => switch(context.watch<ExportSettings>().exportFormat) {
    ExportFormat.csv => context.watch<CsvExportSettings>().activePreset,
    ExportFormat.xls => context.watch<PdfExportSettings>().activePreset,
    ExportFormat.pdf => context.watch<ExcelExportSettings>().activePreset,
    ExportFormat.db => null,
  };

  void setPreset(BuildContext context, String presetId) => switch(context.read<ExportSettings>().exportFormat) {
    ExportFormat.csv => context.read<CsvExportSettings>().activePreset = presetId,
    ExportFormat.xls => context.read<PdfExportSettings>().activePreset = presetId,
    ExportFormat.pdf => context.read<ExcelExportSettings>().activePreset = presetId,
    ExportFormat.db => null,
  };
}
