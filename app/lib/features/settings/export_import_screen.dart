import 'dart:io';

import 'package:blood_pressure_app/components/disabled.dart';
import 'package:blood_pressure_app/data_util/interval_picker.dart';
import 'package:blood_pressure_app/features/export_import/active_field_customization.dart';
import 'package:blood_pressure_app/features/export_import/export_button.dart';
import 'package:blood_pressure_app/features/export_import/export_warn_banner.dart';
import 'package:blood_pressure_app/features/export_import/import_button.dart';
import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/input_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/number_input_list_tile.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:persistent_user_dir_access_android/persistent_user_dir_access_android.dart';
import 'package:provider/provider.dart';

/// Screen to configure and perform exports and imports of blood pressure values.
class ExportImportScreen extends StatelessWidget {
  /// Create a screen that shows options for ex- and importing data.
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.exportImport),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<ExportSettings>(builder: (context, settings, child) => SingleChildScrollView(
          child: Column(
            children: [
              Consumer<CsvExportSettings>(builder: (context, csvExportSettings, child) =>
                Consumer<ExportColumnsManager>(builder: (context, availableColumns, child) =>
                  ExportWarnBanner(
                    exportSettings: settings,
                    csvExportSettings: csvExportSettings,
                    availableColumns: availableColumns,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Disabled(
                disabled: settings.exportFormat == ExportFormat.db,
                child: const IntervalPicker(type: IntervalStoreManagerLocation.exportPage,),
              ),
              if (Platform.isAndroid) // only supported on android
                ListTile(
                  title: Text(localizations.exportDir),
                  subtitle: settings.defaultExportDir.isNotEmpty ? Text(settings.defaultExportDir) : null,
                  trailing: settings.defaultExportDir.isEmpty ? const Icon(Icons.folder_open) : const Icon(Icons.delete),
                  onTap: () async {
                    if (settings.defaultExportDir.isEmpty) {
                      final uri = await const PersistentUserDirAccessAndroid().requestDirectoryUri();
                      settings.defaultExportDir = uri ?? '';
                    } else {
                      settings.defaultExportDir = '';
                    }
                  },
                ),
              SwitchListTile(
                title: Text(localizations.exportAfterEveryInput),
                subtitle: Text(localizations.exportAfterEveryInputDesc),
                value: settings.exportAfterEveryEntry,
                onChanged: (value) {
                  settings.exportAfterEveryEntry = value;
                },
              ),
              DropDownListTile<ExportFormat>(
                key: const Key('exportFormat'),
                title: Text(localizations.exportFormat),
                value: settings.exportFormat,
                items: [
                  DropdownMenuItem(
                      value: ExportFormat.csv, child: Text(localizations.csv),),
                  DropdownMenuItem(
                      value: ExportFormat.pdf, child: Text(localizations.pdf),),
                  DropdownMenuItem(
                      value: ExportFormat.db, child: Text(localizations.db),),
                ],
                onChanged: (ExportFormat? value) {
                  if (value != null) {
                    settings.exportFormat = value;
                  }
                },
              ),
              if (settings.exportFormat == ExportFormat.csv)
                Consumer<CsvExportSettings>(builder: (context, csvExportSettings, child) =>
                  Column(
                    children: [
                      InputListTile(
                        label: localizations.fieldDelimiter,
                        value: csvExportSettings.fieldDelimiter,
                        onSubmit: (value) {
                          csvExportSettings.fieldDelimiter = value;
                        },
                      ),
                      InputListTile(
                        label: localizations.textDelimiter,
                        value: csvExportSettings.textDelimiter,
                        onSubmit: (value) {
                          csvExportSettings.textDelimiter = value;
                        },
                      ),
                      SwitchListTile(
                        title: Text(localizations.exportCsvHeadline),
                        subtitle: Text(localizations.exportCsvHeadlineDesc),
                        value: csvExportSettings.exportHeadline,
                        onChanged: (value) {
                          csvExportSettings.exportHeadline = value;
                        },
                      ),
                    ],
                  ),
                ),
              if (settings.exportFormat == ExportFormat.pdf)
                Consumer<PdfExportSettings>(builder: (context, pdfExportSettings, child) =>
                  Column(
                    children: [
                      SwitchListTile(
                          title: Text(localizations.exportPdfExportTitle),
                          value: pdfExportSettings.exportTitle,
                          onChanged: (value) {
                            pdfExportSettings.exportTitle = value;
                          },),
                      SwitchListTile(
                          title: Text(localizations.exportPdfExportStatistics),
                          value: pdfExportSettings.exportStatistics,
                          onChanged: (value) {
                            pdfExportSettings.exportStatistics = value;
                          },),
                      SwitchListTile(
                          title: Text(localizations.exportPdfExportData),
                          value: pdfExportSettings.exportData,
                          onChanged: (value) {
                            pdfExportSettings.exportData = value;
                          },),
                      if (pdfExportSettings.exportData)
                        Column(
                          children: [
                            NumberInputListTile(
                              value: pdfExportSettings.headerHeight,
                              label: localizations.exportPdfHeaderHeight,
                              onParsableSubmit: (value) {
                                pdfExportSettings.headerHeight = value;
                              },
                            ),
                            NumberInputListTile(
                              value: pdfExportSettings.cellHeight,
                              label: localizations.exportPdfCellHeight,
                              onParsableSubmit: (value) {
                                pdfExportSettings.cellHeight = value;
                              },
                            ),
                            NumberInputListTile(
                              value: pdfExportSettings.headerFontSize,
                              label: localizations.exportPdfHeaderFontSize,
                              onParsableSubmit: (value) {
                                pdfExportSettings.headerFontSize = value;
                              },
                            ),
                            NumberInputListTile(
                              value: pdfExportSettings.cellFontSize,
                              label: localizations.exportPdfCellFontSize,
                              onParsableSubmit: (value) {
                                pdfExportSettings.cellFontSize = value;
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ActiveExportFieldCustomization(
                format: settings.exportFormat,
              ),
            ],
          ),
        ),),
      persistentFooterButtons: const [
        ExportButton(share: true),
        ExportButton(share: false),
        ImportButton(),
      ],
    );
  }
}
