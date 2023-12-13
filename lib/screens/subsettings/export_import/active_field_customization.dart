import 'package:blood_pressure_app/components/settings/dropdown_list_tile.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/common_settings_interfaces.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Setting for configuring fields in the current export.
class ActiveExportFieldCustomization extends StatelessWidget {
  /// Create a widget for configuring fields in the current export.
  const ActiveExportFieldCustomization({super.key,
    required this.format,});

  final ExportFormat format;

  @override
  Widget build(BuildContext context) => switch (format) {
    ExportFormat.csv => Consumer<CsvExportSettings>(builder: _builder),
    ExportFormat.pdf => Consumer<PdfExportSettings>(builder: _builder),
    ExportFormat.db => const SizedBox.shrink()
  };

  Widget _builder(BuildContext context, CustomFieldsSettings settings, Widget? child) {
    final localizations = AppLocalizations.of(context)!;
    final fieldsConfig = settings.exportFieldsConfiguration;
    final dropdown = DropDownListTile(
      title: Text(localizations.exportFieldsPreset),
      value: fieldsConfig.activePreset,
      items: ExportImportPreset.values.map(
              (e) => DropdownMenuItem(
            value: e,
            child: Text(e.localize(localizations)),
          )
      ).toList(),
      onChanged: (selectedPreset) {
        if (selectedPreset != null) {
          fieldsConfig.activePreset = selectedPreset;
        }
      },
    );

    if (fieldsConfig.activePreset != ExportImportPreset.none) {
      return dropdown;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dropdown,
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 5
          ),
          height: 400,
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
                                        onTap: () => Navigator.of(context).pop(column),
                                      )
                                  ).toList(),
                                )
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
                                icon: const Icon(Icons.remove_circle_outline)
                            ),
                            const Icon(Icons.drag_handle),
                          ],
                        ),
                      );
                    },
                    itemCount: activeColumns.length + 1,
                    onReorder: fieldsConfig.reorderUserColumns
                );
              }
          ),
        ),
        ListTile(
          title: Text(localizations.manageExportColumns),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // TODO implement adding / editing columns => separate ColumnsManagerScreen ?
          },
        ),
      ],
    );
  }
}