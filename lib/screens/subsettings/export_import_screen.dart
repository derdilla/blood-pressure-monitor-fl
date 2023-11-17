import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/diabled.dart';
import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/components/export_item_order.dart';
import 'package:blood_pressure_app/components/settings/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export-import/export_column.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jsaver/jSaver.dart';
import 'package:provider/provider.dart';

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
              const ExportWarnBanner(),
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
                  final appDir = await JSaver.instance.setDefaultSavingDirectory();
                  settings.defaultExportDir = appDir.value;
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
                      ExportFieldCustomisationSetting(
                        fieldsSettings: csvExportSettings,
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
                            ExportFieldCustomisationSetting(
                              fieldsSettings: pdfExportSettings,
                            ),
                          ],
                        ),
                    ]
                  )
                ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ExportImportButtons(),
    );
  }
}

class ExportFieldCustomisationSetting extends StatelessWidget {
  const ExportFieldCustomisationSetting({super.key, required this.fieldsSettings});

  final CustomFieldsSettings fieldsSettings;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ConsistentFutureBuilder(
      future: ExportConfigurationModel.get(localizations),
      lastChildWhileWaiting: true,
      onData: (context, configurationModel) {
        return Consumer<ExportSettings>(builder: (context, settings, child) {
          final formats = configurationModel.availableFormats.toSet();
          List<ExportColumn> activeFields = configurationModel
              .getActiveExportColumns(settings.exportFormat, fieldsSettings);
          List<ExportColumn> hiddenFields = [];
          for (final internalName in fieldsSettings.customFields) {
            formats.removeWhere((e) => e.internalName == internalName);
          }
          hiddenFields = formats.toList();

          return Column(
            children: [
              SwitchListTile(
                title: Text(localizations.exportCustomEntries),
                value: fieldsSettings.exportCustomFields,
                onChanged: (value) {
                  fieldsSettings.exportCustomFields = value;
                }
              ),
              if (fieldsSettings.exportCustomFields)
                ExportItemsCustomizer(
                  shownItems: activeFields,
                  disabledItems: hiddenFields,
                  onReorder: (exportItems, exportAddableItems) {
                    fieldsSettings.customFields = exportItems.map((e) => e.internalName).toList();
                  },
                ),
            ],
          );
        });
      }
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
                    final model = Provider.of<BloodPressureModel>(context, listen: false);
                    final interval = Provider.of<IntervallStoreManager>(context, listen: false).exportPage.currentRange;

                    Exporter.load(context,
                        await model.getInTimeRange(interval.start, interval.end),
                        await ExportConfigurationModel.get(localizations)
                    ).export();
                  }
                )),
            const VerticalDivider(),
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(localizations.import),
                  onPressed: () async =>
                      Exporter.load(context, [], await ExportConfigurationModel.get(localizations)).import(),
                )
            ),
          ],
        ),
      ),
    );
  }
}

class ExportWarnBanner extends StatefulWidget {
  const ExportWarnBanner({super.key});

  @override
  State<StatefulWidget> createState() => _ExportWarnBannerState();
}

class _ExportWarnBannerState extends State<ExportWarnBanner> {
  bool _showWarnBanner = true;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<Settings>(builder: (context, settings, child) =>
      Consumer<ExportSettings>(builder: (context, exportSettings, child) =>
        Consumer<CsvExportSettings>(builder: (context, csvExportSettings, child) =>
          Consumer<PdfExportSettings>(builder: (context, pdfExportSettings, child) =>
            ConsistentFutureBuilder(
              future: ExportConfigurationModel.get(localizations),
              lastChildWhileWaiting: true,
              onData: (context, configurationModel) {
                String? message;
                final CustomFieldsSettings fieldSettings = (exportSettings.exportFormat == ExportFormat.csv
                    ? csvExportSettings : pdfExportSettings) as CustomFieldsSettings;

                final missingAttributes = _getMissingAttributes(exportSettings, fieldSettings, configurationModel);
                if (ExportFormat.db == exportSettings.exportFormat) {
                  // When exporting as database no wrong configuration is possible
                } else if (_showWarnBanner && _isExportable(exportSettings, csvExportSettings,
                    fieldSettings.exportCustomFields, missingAttributes)) {
                  message = localizations.exportWarnConfigNotImportable;
                } else if (_showWarnBanner && fieldSettings.exportCustomFields && missingAttributes.isNotEmpty) {
                  message = localizations.exportWarnNotEveryFieldExported(
                      missingAttributes.length, missingAttributes.map((e) => e.localize(localizations)).join(', '));
                }

                if (message != null) {
                  return MaterialBanner(
                      padding: const EdgeInsets.all(20),
                      content: Text(message),
                      actions: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _showWarnBanner = false;
                              });
                            },
                            child: Text(localizations.btnConfirm))
                      ]);
                }
                return const SizedBox.shrink();
              }))
        )
    ));
  }
}

bool _isExportable(ExportSettings exportSettings, CsvExportSettings csvExportSettings, bool exportCustomEntries, Set<RowDataFieldType> missingAttributes) {
  return ((ExportFormat.pdf == exportSettings.exportFormat) ||
      csvExportSettings.exportHeadline == false ||
      exportCustomEntries &&
          missingAttributes.contains(RowDataFieldType.timestamp) ||
      ![',', '|'].contains(csvExportSettings.fieldDelimiter) ||
      !['"', '\''].contains(csvExportSettings.textDelimiter));
}

Set<RowDataFieldType> _getMissingAttributes(ExportSettings exportSettings, CustomFieldsSettings fieldSettings,
    ExportConfigurationModel configurationModel) {
  final exportFormats = configurationModel
      .getActiveExportColumns(exportSettings.exportFormat, fieldSettings)
      .map((e) => e.parsableFormat);
  var missingAttributes = {
    RowDataFieldType.timestamp,
    RowDataFieldType.sys,
    RowDataFieldType.dia,
    RowDataFieldType.pul,
    RowDataFieldType.notes,
    RowDataFieldType.color
  };
  missingAttributes.removeWhere((e) => exportFormats.contains(e));
  return missingAttributes;
}
