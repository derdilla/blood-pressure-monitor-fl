
import 'package:blood_pressure_app/components/diabled.dart';
import 'package:blood_pressure_app/components/export_warn_banner.dart';
import 'package:blood_pressure_app/components/settings/settings_widgets.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/display_interval_picker.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import/active_field_customization.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import/export_button_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jsaver/jSaver.dart';
import 'package:provider/provider.dart';

/// Screen to configure and perform exports and imports of blood pressure values.
class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.exportImport),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<ExportSettings>(builder: (context, settings, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Consumer<CsvExportSettings>(builder: (context, csvExportSettings, child) =>
                Consumer<ExportColumnsManager>(builder: (context, availableColumns, child) =>
                  ExportWarnBanner(
                    exportSettings: settings,
                    csvExportSettings: csvExportSettings,
                    availableColumns: availableColumns
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Disabled(
                disabled: settings.exportFormat == ExportFormat.db,
                child: const IntervalPicker(type: IntervallStoreManagerLocation.exportPage,),
              ),
              ListTile(
                title: Text(localizations.exportDir),
                subtitle: settings.defaultExportDir.isNotEmpty ? Text(settings.defaultExportDir) : null,
                trailing: settings.defaultExportDir.isEmpty ? const Icon(Icons.folder_open) : const Icon(Icons.delete),
                onTap: () async {
                  if (settings.defaultExportDir.isEmpty) {
                    final appDir = await JSaver.instance.setDefaultSavingDirectory();
                    settings.defaultExportDir = appDir.value;
                  } else {
                    settings.defaultExportDir = '';
                  }
                }
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
                      value: ExportFormat.csv, child: Text(localizations.csv)),
                  DropdownMenuItem(
                      value: ExportFormat.pdf, child: Text(localizations.pdf)),
                  DropdownMenuItem(
                      value: ExportFormat.db, child: Text(localizations.db)),
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
                        }
                      ),
                    ],
                  )
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
                          }),
                      SwitchListTile(
                          title: Text(localizations.exportPdfExportStatistics),
                          value: pdfExportSettings.exportStatistics,
                          onChanged: (value) {
                            pdfExportSettings.exportStatistics = value;
                          }),
                      SwitchListTile(
                          title: Text(localizations.exportPdfExportData),
                          value: pdfExportSettings.exportData,
                          onChanged: (value) {
                            pdfExportSettings.exportData = value;
                          }),
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
                    ]
                  )
                ),
              ActiveExportFieldCustomization(
                format: settings.exportFormat,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ExportButtonBar(),
    );
  }
}
