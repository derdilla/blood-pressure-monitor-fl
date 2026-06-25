import 'package:blood_pressure_app/components/input_dialog.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/active_preset_builder.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/preset_editor.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/preset_selector.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/export_settings.dart';
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
            // TODO: think about showing what columns will be used
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
  const _PresetEditButtons({super.key, required this.preset});

  final CustomPreset preset;

  // FIXME: design intearction with [temporary] custom coulumns. When pressing#
  // export it must be clear which columns are used

  /// Whether there is already a saved version of this
  bool get isStored => preset.baseId != null;

  /// Updates or creates preset from columns
  Future<void> _save(BuildContext context) async {

    final id = preset.baseId ?? await showInputDialog(context);
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

    // TODO: ask parent to make this the new active?
  }

  /// Removes this column from stored presets but keeps columns.
  void _unsave(ExportSettings exportSettings) {
    if (!isStored) return;

    final oldPresets = exportSettings.presets;
    oldPresets.removeWhere((p) => p.id == preset.baseId);
    exportSettings.presets = oldPresets;

    // TODO: make sure preset is updated to one without baseId but with same columns
  }

  // TODO: think about syncing saves
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
            onPressed: () {
              final s = context.read<ExportSettings>();
              _unsave(s);
            },
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
