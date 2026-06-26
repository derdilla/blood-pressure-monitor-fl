import 'package:blood_pressure_app/components/input_dialog.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/active_preset_builder.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/preset_editor.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/preset_selector.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Class orchestrates preset selector, preset editor and save/delete buttons
class ActiveColumnCustomizer extends StatelessWidget {
  const ActiveColumnCustomizer({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      PresetSelector(),
      ActivePresetBuilder(
          builder: (context, preset) {
            if (preset is! CustomPreset) return const SizedBox.shrink();
            return SizedBox(
              height: 400.0,
              child: Stack(
                children: [
                  PresetEditor(editor: preset),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _PresetEditButtons(preset: preset),
                  ),
                ],
              ),
            );
          }
      ),
    ],
  );
}

class _PresetEditButtons extends StatelessWidget {
  const _PresetEditButtons({required this.preset});

  final CustomPreset preset;

  /// Whether there is already a saved version of this
  bool get isStored => preset.baseId != null;

  Future<String?> _chooseId(BuildContext context) async {
    final blockedIds = [
      ...ExportPreset.buildInPresets,
      CustomPreset([]),
      ...context.read<ExportSettings>().presets
    ].map((p) => p.id);
    String? id;
    id = await showInputDialog(context);
    while (id != null && (blockedIds.contains(id) || id.isEmpty)) {
      if (!context.mounted) break;
      final ctrl = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.titleAlreadyExists)));
      id = await showInputDialog(context);
      ctrl.close();
    }
    return id;
  }

  /// Updates or creates preset from columns
  Future<void> _save(BuildContext context) async {

    final id = preset.baseId ?? await _chooseId(context);
    if (id == null || !context.mounted) return;

    // TODO: don't allow existing ids

    final exportSettings = context.read<ExportSettings>();
    final presets = exportSettings.presets;
    presets.removeWhere((p) => p.id == id);
    presets.add(ExportPreset(
      id,
      preset.columns,
      true,
    ));
    exportSettings.presets = presets;
    if (preset.baseId == null) {
      exportSettings.customPresetColumns = [];
      switch(exportSettings.exportFormat) {
        case ExportFormat.csv:
          context.read<CsvExportSettings>().activePreset = id;
        case ExportFormat.xls:
          context.read<PdfExportSettings>().activePreset = id;
        case ExportFormat.pdf:
          context.read<ExcelExportSettings>().activePreset = id;
        case ExportFormat.db:
          assert(false, 'used in bad context');
      }
    }
  }

  /// Removes this column from stored presets but keeps columns.
  void _unsave(BuildContext context) {
    if (!isStored) return;
    final exportSettings = context.read<ExportSettings>();

    final oldPresets = exportSettings.presets;
    oldPresets.removeWhere((p) => p.id == preset.baseId);
    if (exportSettings.customPresetColumns.isEmpty) {
      exportSettings.customPresetColumns = preset.columns;
    }
    exportSettings.presets = oldPresets;

    if (context.read<CsvExportSettings>().activePreset == preset.baseId) {
      context.read<CsvExportSettings>().activePreset = CustomPreset([]).id;
    }
    if (context.read<PdfExportSettings>().activePreset == preset.baseId) {
      context.read<PdfExportSettings>().activePreset = CustomPreset([]).id;
    }
    if (context.read<ExcelExportSettings>().activePreset == preset.baseId) {
      context.read<ExcelExportSettings>().activePreset = CustomPreset([]).id;
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isStored)
          IconButton.filledTonal(
            icon: Icon(Icons.delete_forever_outlined),
            tooltip: AppLocalizations.of(context)!.delete,
            onPressed: () => _unsave(context),
          ),
        if (isStored)
          SizedBox(width: 4.0),
        IconButton.filled(
          icon: Icon(Icons.save),
          tooltip: AppLocalizations.of(context)!.btnSave,
          onPressed: () => _save(context),
        ),
      ],
    ),
  );
}
