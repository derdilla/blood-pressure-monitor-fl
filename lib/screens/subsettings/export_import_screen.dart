import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/diabled.dart';
import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/components/export_item_order.dart';
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/common_settings_interfaces.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
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
              SettingsTile(
                  title: Text(localizations.exportDir),
                  description: Text(settings.defaultExportDir),
                  onPressed: (context) async {
                    final appDir =
                        await JSaver.instance.setDefaultSavingDirectory();
                    settings.defaultExportDir = appDir.value;
                  }),
              SwitchSettingsTile(
                  title: Text(localizations.exportAfterEveryInput),
                  description: Text(localizations.exportAfterEveryInputDesc),
                  initialValue: settings.exportAfterEveryEntry,
                  onToggle: (value) {
                    settings.exportAfterEveryEntry = value;
                  }),
              DropDownSettingsTile<ExportFormat>(
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
                      InputSettingsTile(
                        title: Text(localizations.fieldDelimiter),
                        inputWidth: 40,
                        initialValue: csvExportSettings.fieldDelimiter,
                        disabled: !(settings.exportFormat == ExportFormat.csv),
                        onEditingComplete: (value) {
                          if (value != null) {
                            csvExportSettings.fieldDelimiter = value;
                          }
                        },
                      ),
                      InputSettingsTile(
                        title: Text(localizations.textDelimiter),
                        inputWidth: 40,
                        initialValue: csvExportSettings.textDelimiter,
                        disabled: !(settings.exportFormat == ExportFormat.csv),
                        onEditingComplete: (value) {
                          if (value != null) {
                            csvExportSettings.textDelimiter = value;
                          }
                        },
                      ),
                      SwitchSettingsTile(
                        title: Text(localizations.exportCsvHeadline),
                        description: Text(localizations.exportCsvHeadlineDesc),
                        initialValue: csvExportSettings.exportHeadline,
                        disabled: settings.exportFormat != ExportFormat.csv,
                        onToggle: (value) {
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
                      SwitchSettingsTile(
                          title: Text(localizations.exportPdfExportTitle),
                          initialValue: pdfExportSettings.exportTitle,
                          onToggle: (value) {
                            pdfExportSettings.exportTitle = value;
                          }),
                      SwitchSettingsTile(
                          title: Text(localizations.exportPdfExportStatistics),
                          initialValue: pdfExportSettings.exportStatistics,
                          onToggle: (value) {
                            pdfExportSettings.exportStatistics = value;
                          }),
                      SwitchSettingsTile(
                          title: Text(localizations.exportPdfExportData),
                          initialValue: pdfExportSettings.exportData,
                          onToggle: (value) {
                            pdfExportSettings.exportData = value;
                          }),
                      InputSettingsTile(
                        initialValue: pdfExportSettings.headerHeight.toString(),
                        title: Text(localizations.exportPdfHeaderHeight),
                        onEditingComplete: (value) {
                          final pV = double.tryParse(value ?? '');
                          if (pV != null) pdfExportSettings.headerHeight = pV;
                        },
                        disabled: !(pdfExportSettings.exportData),
                        keyboardType: TextInputType.number,
                        inputWidth: 40,
                      ),
                      InputSettingsTile(
                        initialValue: pdfExportSettings.cellHeight.toString(),
                        title: Text(localizations.exportPdfCellHeight),
                        onEditingComplete: (value) {
                          final pV = double.tryParse(value ?? '');
                          if (pV != null) pdfExportSettings.cellHeight = pV;
                        },
                        disabled: !pdfExportSettings.exportData,
                        keyboardType: TextInputType.number,
                        inputWidth: 40,
                      ),
                      InputSettingsTile(
                        initialValue: pdfExportSettings.headerFontSize.toString(),
                        title: Text(localizations.exportPdfHeaderFontSize),
                        onEditingComplete: (value) {
                          final pV = double.tryParse(value ?? '');
                          if (pV != null) pdfExportSettings.headerFontSize = pV;
                        },
                        disabled: !pdfExportSettings.exportData,
                        keyboardType: TextInputType.number,
                        inputWidth: 40,
                      ),
                      InputSettingsTile(
                        initialValue: pdfExportSettings.cellFontSize.toString(),
                        title: Text(localizations.exportPdfCellFontSize),
                        onEditingComplete: (value) {
                          final pV = double.tryParse(value ?? '');
                          if (pV != null) pdfExportSettings.cellFontSize = pV;
                        },
                        disabled: !pdfExportSettings.exportData,
                        keyboardType: TextInputType.number,
                        inputWidth: 40,
                      ),
                      if (pdfExportSettings.exportData)
                        ExportFieldCustomisationSetting(
                          fieldsSettings: pdfExportSettings,
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
              SwitchSettingsTile(
                title: Text(localizations.exportCustomEntries),
                initialValue: fieldsSettings.exportCustomFields,
                onToggle: (value) {
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
                      missingAttributes.length, missingAttributes.join(', '));
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
