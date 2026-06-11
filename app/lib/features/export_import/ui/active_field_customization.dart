import 'package:blood_pressure_app/components/input_dialog.dart';
import 'package:blood_pressure_app/features/export_import/model/column.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/export_import/ui/export_column_management_screen.dart';
import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings.dart';
import 'package:blood_pressure_app/model/storage/export_settings.dart';
import 'package:blood_pressure_app/model/storage/export_xls_settings.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:blood_pressure_app/model/storage/types/export_preset.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Setting for configuring fields in the current export.
class ActiveExportFieldCustomization extends StatelessWidget {
  /// Create a widget for configuring fields in the current export.
  const ActiveExportFieldCustomization({super.key,
    required this.format,});

  final ExportFormat format;

  @override
  Widget build(BuildContext context) => switch (format) {
    ExportFormat.csv => _builder(context, context.watch<CsvExportSettings>().activePreset),
    ExportFormat.pdf => _builder(context, context.watch<PdfExportSettings>().activePreset),
    ExportFormat.xls => _builder(context, context.watch<ExcelExportSettings>().activePreset),
    ExportFormat.db => const SizedBox.shrink()
  };

  Widget _builder(BuildContext context, String activePreset) {
    final localizations = AppLocalizations.of(context)!;
    final exportSettings = context.watch<ExportSettings>();
    final unmodifiablePresets = <ExportPreset>[
      ExportPreset.appDefault,
      ExportPreset.appPdf,
      ExportPreset.myHeart,
    ];
    final dropdown = DropDownListTile<String>(
      title: Text(localizations.exportFieldsPreset),
      value: activePreset,
      items: [
        for (final preset in [
          ...unmodifiablePresets,
          CustomPreset(),
          ...exportSettings.presets
        ])
          DropdownMenuItem(
            value: preset.id,
            child: Text(preset.localize(localizations)),
          ),
      ],
      onChanged: (selectedPreset) {
        if (selectedPreset == null) return;
        final _ = switch (format) {
          ExportFormat.csv => context.read<CsvExportSettings>().activePreset = selectedPreset,
          ExportFormat.pdf => context.read<PdfExportSettings>().activePreset = selectedPreset,
          ExportFormat.xls => context.read<ExcelExportSettings>().activePreset = selectedPreset,
          ExportFormat.db => null,
        };
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dropdown,
        ListTile(
          title: Text(localizations.manageExportColumns),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (context) => const ExportColumnsManagementScreen()),);
          },
        ),
        if (unmodifiablePresets.where((p) => p.id == activePreset).isEmpty)
          SizedBox(
            height: 400,
            child: Stack(
              children: [
                _buildActiveColumnsEditor(context, localizations, activePreset),
                _PresetSaveControls(config: activePreset),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActiveColumnsEditor(BuildContext context,
    AppLocalizations localizations,
    String presetid) {
    final preset = context.read<ExportSettings>().presets.firstWhere((p) => p.id ==)
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 5, 16, 16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).textTheme.labelLarge?.color ?? Colors.teal),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Consumer<ExportColumnsManager>(
        builder: (context, availableColumns, child) {
          final activeColumns = fieldsConfig.getActiveColumns(availableColumns);
          return ReorderableListView.builder(
            itemBuilder: (context, idx) {
              if (idx >= activeColumns.length) {
                return ListTile(
                  key: const Key('add field'),
                  leading: const Icon(Icons.add),
                  title: Text(localizations.addEntry),
                  onTap: () async {
                    final column = await showDialog<ExportColumn?>(context: context, builder: (context) =>
                        SimpleDialog(
                          title: Text(localizations.addEntry),
                          insetPadding: const EdgeInsets.symmetric(
                            vertical: 64,
                          ),
                          children: availableColumns.getAllColumns().map((column) =>
                            ListTile(
                              title: Text(column.userTitle(localizations)),
                              onTap: () => Navigator.pop(context, column),
                            ),
                          ).toList(),
                        ),
                    );
                    if (column != null) fieldsConfig.addUserColumn(column);
                  },
                );
              }
              return ListTile(
                key: Key(activeColumns[idx].internalIdentifier + idx.toString()),
                title: Text(activeColumns[idx].userTitle(localizations)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: localizations.remove,
                      onPressed: () {
                        fieldsConfig.removeUserColumn(activeColumns[idx].internalIdentifier);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    ReorderableDragStartListener(
                      index: idx,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ],
                ),
              );
            },
            itemCount: activeColumns.length + 1,
            onReorderItem: fieldsConfig.reorderUserColumns,
            buildDefaultDragHandles: false,
            dragStartBehavior: DragStartBehavior.down,
          );
        },
      ),
    );
  }
}

class _PresetSaveControls extends StatefulWidget {
  const _PresetSaveControls({required this.config});

  final ActiveExportColumnConfiguration config;

  @override
  State<_PresetSaveControls> createState() => _PresetSaveControlsState();
}

class _PresetSaveControlsState extends State<_PresetSaveControls> {
  // FIXME: state is dupolicated
  String? _autosavingLabel;

  @override
  void initState() {
    super.initState();
    _autosavingLabel = widget.config.currentPresetLabel;
    widget.config.addListener(_autoSave);
  }

  @override
  void dispose() {
    widget.config.removeListener(_autoSave);
    super.dispose();
  }

  void _autoSave() {
    if (widget.config.activePreset != ExportImportPreset.none
        || _autosavingLabel == null
        || widget.config.currentPresetLabel != _autosavingLabel) {
      return;
    }
    _save();
  }

  Future<void> _save() async {
    // FIXME: properly integrate with config
    final exportSettings = context.read<ExportSettings>();

    widget.config.currentPresetLabel ??= await showInputDialog(context);
    if (widget.config.currentPresetLabel == null) return;
    setState(() {
      _autosavingLabel ??= widget.config.currentPresetLabel;
    });
    final ids = widget.config.exportCustomColumnsAsIDList();
    final preset = ExportPreset(widget.config.currentPresetLabel!, ids);

    final presets = exportSettings.presets;
    presets.removeWhere((p) => p.id == widget.config.currentPresetLabel);
    presets.add(preset);
    exportSettings.presets = presets;
    if (widget.config.currentPresetLabel == null) widget.config.loadCustomPreset(preset);
  }

  @override
  Widget build(BuildContext context) => Align(
    // TODO: if one is selected rn, change button to remove and display name. Needs autosave
    alignment: Alignment(1, 1),
    child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.config.currentPresetLabel != null)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Theme.of(context).cardColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(widget.config.currentPresetLabel!),
              ),
            ),
          SizedBox(width: 4.0),
          if (widget.config.currentPresetLabel == null)
            IconButton.filled(
              icon: Icon(Icons.save),
              onPressed: _save,
            ),
          if (widget.config.currentPresetLabel != null)
            IconButton.filled(
              icon: Icon(Icons.delete_forever_outlined),
              onPressed: () {
                final exportSettings = context.read<ExportSettings>();
                final currentColumns = widget.config.exportCustomColumnsAsIDList();
                final presets = exportSettings.presets;
                presets.removeWhere((e) => e.id != widget.config.currentPresetLabel
                      && e.columns == currentColumns);
                exportSettings.presets = presets;

                // Setting the label ensures autosave gets disabled
                setState(() {
                  _autosavingLabel = null;
                });
              },
            ),
        ],
      ),
    ),
  );
}
