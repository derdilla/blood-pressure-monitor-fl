import 'dart:io';

import 'package:blood_pressure_app/features/data_picker/interval_picker.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/active_column_customizer.dart';
import 'package:blood_pressure_app/features/export_import/ui/export_button.dart';
import 'package:blood_pressure_app/features/export_import/ui/export_column_management_screen.dart';
import 'package:blood_pressure_app/features/export_import/ui/export_field_format_documentation_screen.dart';
import 'package:blood_pressure_app/features/export_import/ui/export_warn_banner.dart';
import 'package:blood_pressure_app/features/export_import/ui/import_button.dart';
import 'package:blood_pressure_app/features/settings/tiles/dropdown_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/input_list_tile.dart';
import 'package:blood_pressure_app/features/settings/tiles/number_input_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter/material.dart';
import 'package:persistent_user_dir_access_android/persistent_user_dir_access_android.dart';
import 'package:provider/provider.dart';

/// Screen to configure and perform exports and imports of blood pressure values.
class ExportImportScreen extends StatelessWidget {
  /// Create a screen that shows options for ex- and importing data.
  const ExportImportScreen({super.key});

  static const String _documentationText = '''
## Export / import basics

- Choose CSV for spreadsheet workflows and for importing data back into the app.
- Keep the headline enabled and include a time column so the import can be restored reliably.
- Use the field-format dialog to add custom columns for values such as systolic, diastolic, pulse, notes, and medicine intakes.

## CSV import in LibreOffice and similar tools

- Export as CSV and keep the headline enabled.
- Use the default delimiter and text delimiter unless you know you need something different.
- When you open the file in LibreOffice, Excel, or similar apps, make sure the time column is recognized as a date/time value.
- If you want to re-import the file later, keep the same CSV settings and include a valid time column.

## Color columns

- The plain `color` column exports the note color as a simple value.
- The legacy `needlePin` column stores a JSON payload such as `{"color":4291681337}` for compatibility with older workflows.
- Use the plain `color` column when you want a straightforward spreadsheet-friendly export.

## Useful placeholders

- `\$INTAKES` exports medicine intakes.
- `\$NOTE`, `\$SYS`, `\$DIA`, `\$PUL`, `\$COLOR`, and `\$TIMESTAMP` can be mixed into custom field formats.
- The time formatter can be customized with [time format help](screen://TimeFormattingHelp).

## Example workflow

1. Enter a measurement and any notes.
2. Open Export / Import and switch to CSV.
3. Add a custom field or time column if you need one.
4. Export the data and open it in LibreOffice or another spreadsheet app.
5. Re-import the same file later when you want to restore or review the data.
''';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settings = context.watch<ExportSettings>();
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.exportImport),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExportWarnBanner(),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('How to use export/import'),
              subtitle: const Text(
                  'Guides for CSV import, color columns, and sample workflows'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (context) =>
                          InformationScreen(text: _documentationText)),
                );
              },
            ),
            if (settings.exportFormat != ExportFormat.db)
              const IntervalPicker(type: IntervalStoreManagerLocation.exportPage),
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
            if (Platform.isAndroid) // only makes sense with exportDir, which is supported only for android
              SwitchListTile(
                title: Text(localizations.exportAddTimestamp),
                subtitle: Text(localizations.exportAddTimestampDesc),
                value: settings.addTimestamp,
                onChanged: (value) {
                  settings.addTimestamp = value;
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
                    value: ExportFormat.csv, child: Text(localizations.csv)),
                DropdownMenuItem(
                    value: ExportFormat.pdf, child: Text(localizations.pdf)),
                DropdownMenuItem(
                    value: ExportFormat.db, child: Text(localizations.db)),
                DropdownMenuItem(
                  value: ExportFormat.xls, child: Text(localizations.xls)),
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
            if (settings.exportFormat == ExportFormat.csv
                || settings.exportFormat == ExportFormat.pdf
                || settings.exportFormat == ExportFormat.xls) ...[
              ListTile(
                title: Text(localizations.manageExportColumns),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const ExportColumnsManagementScreen()));
                },
              ),
              ActiveColumnCustomizer(),
            ],
          ],
        ),
      ),
      persistentFooterButtons: const [
        ExportButton(share: true),
        ExportButton(share: false),
        ImportButton(),
      ],
    );
  }
}
