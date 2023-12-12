import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blood_pressure_app/components/diabled.dart';
import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/components/export_warn_banner.dart';
import 'package:blood_pressure_app/components/settings/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/export_import/pdf_converter.dart';
import 'package:blood_pressure_app/model/export_import/record_parsing_result.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/platform_integration/platform_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jsaver/jSaver.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

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
              ExportFieldCustomisationSetting(
                format: settings.exportFormat,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ExportImportButtons(),
    );
  }
}

class ExportFieldCustomisationSetting extends StatelessWidget { // TODO: consider extracting class into file
  const ExportFieldCustomisationSetting({super.key,
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
            margin: const EdgeInsets.all(16),
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
                                insetPadding: EdgeInsets.symmetric(
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
                        trailing: const Icon(Icons.drag_handle),
                        // TODO: removing columns
                      );
                    },
                    itemCount: activeColumns.length + 1,
                    onReorder: fieldsConfig.reorderUserColumns
                );
              }
            ),
          )
          // TODO implement adding / editing columns => separate ColumnsManagerScreen ?
        ],
    );
  }
}

class ExportImportButtons extends StatelessWidget {
  const ExportImportButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.onInverseSurface,
      child: Center(
        child: Row(
          children: [
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(localizations.export),
                  onPressed: () async {
                    final exportSettings = Provider.of<ExportSettings>(context, listen: false);
                    final filename = 'blood_press_${DateTime.now().toIso8601String()}';
                    switch (exportSettings.exportFormat) {
                      case ExportFormat.db:
                        final path = joinPath(await getDatabasesPath(), 'blood_pressure.db');

                        if (context.mounted) _exportFile(context, path, '$filename.db', 'text/db');
                        break;
                      case ExportFormat.csv:
                        final csvConverter = CsvConverter(
                          Provider.of<CsvExportSettings>(context, listen: false),
                          Provider.of<ExportColumnsManager>(context, listen: false),
                        );
                        final csvString = csvConverter.create(await _getRecords(context));
                        final data = Uint8List.fromList(utf8.encode(csvString));
                        if (context.mounted) _exportData(context, data, '$filename.csv', 'text/csv');
                        break;
                      case ExportFormat.pdf:
                        final pdfConverter = PdfConverter(
                            Provider.of<PdfExportSettings>(context, listen: false), 
                            localizations,
                            Provider.of<Settings>(context, listen: false),
                            Provider.of<ExportColumnsManager>(context, listen: false)
                        );
                        final pdf = await pdfConverter.create(await _getRecords(context));
                        if (context.mounted) _exportData(context, pdf, '$filename.pdf', 'text/pdf');
                    }
                  }
                )),
            const VerticalDivider(),
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(localizations.import),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    final file = (await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      withData: true,
                    ))?.files.firstOrNull;
                    if (file == null) {
                      _showError(messenger, localizations.errNoFileOpened);
                      return;
                    }
                    if (!context.mounted) return;
                    switch(file.extension?.toLowerCase()) {
                      case 'csv':
                        final binaryContent = file.bytes;
                        if (binaryContent == null) {
                          _showError(messenger, localizations.errCantReadFile);
                          return;
                        }
                        final converter = CsvConverter(
                          Provider.of<CsvExportSettings>(context, listen: false),
                          Provider.of<ExportColumnsManager>(context, listen: false),
                        );
                        final result = converter.parse(utf8.decode(binaryContent));
                        final importedRecords = result.getOr((error) {
                          switch (error) {
                            case RecordParsingErrorEmptyFile():
                              _showError(messenger, localizations.errParseEmptyCsvFile);
                              break;
                            case RecordParsingErrorTimeNotRestoreable():
                              _showError(messenger, localizations.errParseTimeNotRestoreable);
                              break;
                            case RecordParsingErrorUnknownColumn():
                              _showError(messenger, localizations.errParseUnknownColumn(error.title));
                              break;
                            case RecordParsingErrorExpectedMoreFields():
                              _showError(messenger, localizations.errParseLineTooShort(error.lineNumber));
                              break;
                            case RecordParsingErrorUnparsableField():
                              _showError(messenger, localizations.errParseFailedDecodingField(
                                  error.lineNumber, error.fieldContents));
                              break;
                          }
                          return null;
                        });
                        if (result.hasError()) return;
                        final model = Provider.of<BloodPressureModel>(context, listen: false);
                        for (final record in importedRecords) { // TODO: background thread
                          await model.add(record);
                        }
                        messenger.showSnackBar(SnackBar(content: Text(
                            localizations.importSuccess(importedRecords.length))));
                        break;
                      case 'db':
                        final model = Provider.of<BloodPressureModel>(context, listen: false);
                        final importedModel = await BloodPressureModel.create(dbPath: file.path, isFullPath: true);
                        for (final record in await importedModel.all) {
                          await model.add(record);
                        }
                        break;
                      default:
                        _showError(messenger, localizations.errWrongImportFormat);
                    }
                  },
                )
            ),
          ],
        ),
      ),
    );
  }

  void _showError(ScaffoldMessengerState messenger, String text) =>
    messenger.showSnackBar(SnackBar(content: Text(text)));
  
  /// Get the records that should be exported.
  Future<List<BloodPressureRecord>> _getRecords(BuildContext context) {
    final range = Provider.of<IntervallStoreManager>(context, listen: false).exportPage.currentRange;
    final model = Provider.of<BloodPressureModel>(context, listen: false);
    return model.getInTimeRange(range.start, range.end);
  }
  
  /// Save to default export path or share by providing a path. 
  Future<void> _exportFile(BuildContext context, String path, String fullFileName, String mimeType) async {
    final settings = Provider.of<ExportSettings>(context, listen: false);
    if (settings.defaultExportDir.isEmpty) {
      await PlatformClient.shareFile(path, mimeType, fullFileName);
    } else {
      JSaver.instance.save(
          fromPath: path,
          androidPathOptions: AndroidPathOptions(toDefaultDirectory: true)
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.success(settings.defaultExportDir))));
    }
  }

  /// Save to default export path or share by providing binary data.
  Future<void> _exportData(BuildContext context, Uint8List data, String fullFileName, String mimeType) async {
    final settings = Provider.of<ExportSettings>(context, listen: false);
    if (settings.defaultExportDir.isEmpty) {
      await PlatformClient.shareData(data, mimeType, fullFileName);
    } else {
      final file = File(joinPath(Directory.systemTemp.path, fullFileName));
      file.writeAsBytesSync(data);
      await _exportFile(context, file.path, fullFileName, mimeType);
    }
  }
}
