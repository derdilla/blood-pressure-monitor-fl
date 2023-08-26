import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/components/export_item_order.dart';
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
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
      body: Consumer<Settings>(builder: (context, settings, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const ExportWarnBanner(),
              const SizedBox(height: 15,),
              Opacity(
                opacity: (settings.exportFormat == ExportFormat.db) ? 0.7 : 1,
                child: IgnorePointer(ignoring: (settings.exportFormat == ExportFormat.db), child: const IntervalPicker()),
              ),
              SettingsTile(
                title: Text(localizations.exportDir),
                description: Text(settings.defaultExportDir),
                onPressed: (context) async {
                  final appDir = await JSaver.instance.setDefaultSavingDirectory();
                  settings.defaultExportDir = appDir.value;
                }
              ),
              SwitchSettingsTile(
                  title: Text(localizations.exportAfterEveryInput),
                  description: Text(localizations.exportAfterEveryInputDesc),
                  initialValue: settings.exportAfterEveryEntry,
                  onToggle: (value) {
                    settings.exportAfterEveryEntry = value;
                  }
              ),
              DropDownSettingsTile<ExportFormat>(
                key: const Key('exportFormat'),
                title: Text(localizations.exportFormat),
                value: settings.exportFormat,
                items: [
                  DropdownMenuItem(value: ExportFormat.csv, child: Text(localizations.csv)),
                  DropdownMenuItem(value: ExportFormat.pdf, child: Text(localizations.pdf)),
                  DropdownMenuItem(value: ExportFormat.db, child: Text(localizations.db)),
                ],
                onChanged: (ExportFormat? value) {
                  if (value != null) {
                    settings.exportFormat = value;
                  }
                },
              ),
              InputSettingsTile(
                title: Text(localizations.fieldDelimiter),
                inputWidth: 40,
                initialValue: settings.csvFieldDelimiter,
                disabled: !(settings.exportFormat == ExportFormat.csv),
                onEditingComplete: (value) {
                  if (value != null) {
                    settings.csvFieldDelimiter = value;
                  }
                },
              ),
              InputSettingsTile(
                title: Text(localizations.textDelimiter),
                inputWidth: 40,
                initialValue: settings.csvTextDelimiter,
                disabled: !(settings.exportFormat == ExportFormat.csv),
                onEditingComplete: (value) {
                  if (value != null) {
                    settings.csvTextDelimiter = value;
                  }
                },
              ),
              SwitchSettingsTile(
                title: Text(localizations.exportCsvHeadline),
                description: Text(localizations.exportCsvHeadlineDesc),
                initialValue: settings.exportCsvHeadline,
                disabled: settings.exportFormat != ExportFormat.csv,
                onToggle: (value) {
                  settings.exportCsvHeadline = value;
                }
              ),
              SwitchSettingsTile(
                title: Text(localizations.exportPdfExportTitle),
                initialValue: settings.exportPdfExportTitle,
                disabled: settings.exportFormat != ExportFormat.pdf,
                onToggle: (value) {
                  settings.exportPdfExportTitle = value;
                }
              ),
              SwitchSettingsTile(
                title: Text(localizations.exportPdfExportStatistics),
                initialValue: settings.exportPdfExportStatistics,
                disabled: settings.exportFormat != ExportFormat.pdf,
                onToggle: (value) {
                  settings.exportPdfExportStatistics = value;
                }
              ),
              SwitchSettingsTile(
                title: Text(localizations.exportPdfExportData),
                initialValue: settings.exportPdfExportData,
                disabled: settings.exportFormat != ExportFormat.pdf,
                onToggle: (value) {
                  settings.exportPdfExportData = value;
                }
              ),
              InputSettingsTile(
                initialValue: settings.exportPdfHeaderHeight.toString(),
                title: Text(localizations.exportPdfHeaderHeight),
                onEditingComplete: (value) {
                  final pV = double.tryParse(value??'');
                  if (pV != null) settings.exportPdfHeaderHeight = pV;
                },
                disabled: !(settings.exportFormat == ExportFormat.pdf && settings.exportPdfExportData),
                keyboardType: TextInputType.number,
                inputWidth: 40,
              ),
              InputSettingsTile(
                initialValue: settings.exportPdfCellHeight.toString(),
                title: Text(localizations.exportPdfCellHeight),
                onEditingComplete: (value) {
                  final pV = double.tryParse(value??'');
                  if (pV != null) settings.exportPdfCellHeight = pV;
                },
                disabled: !(settings.exportFormat == ExportFormat.pdf && settings.exportPdfExportData),
                keyboardType: TextInputType.number,
                inputWidth: 40,
              ),
              InputSettingsTile(
                initialValue: settings.exportPdfHeaderFontSize.toString(),
                title: Text(localizations.exportPdfHeaderFontSize),
                onEditingComplete: (value) {
                  final pV = double.tryParse(value??'');
                  if (pV != null) settings.exportPdfHeaderFontSize = pV;
                },
                disabled: !(settings.exportFormat == ExportFormat.pdf && settings.exportPdfExportData),
                keyboardType: TextInputType.number,
                inputWidth: 40,
              ),
              InputSettingsTile(
                initialValue: settings.exportPdfCellFontSize.toString(),
                title: Text(localizations.exportPdfCellFontSize),
                onEditingComplete: (value) {
                  final pV = double.tryParse(value??'');
                  if (pV != null) settings.exportPdfCellFontSize = pV;
                },
                disabled: !(settings.exportFormat == ExportFormat.pdf && settings.exportPdfExportData),
                keyboardType: TextInputType.number,
                inputWidth: 40,
              ),
              const ExportFieldCustomisationSetting(),
            ],
          ),
        );
      }),
      bottomNavigationBar: const ExportImportButtons(),
    );
  }
}

class ExportFieldCustomisationSetting extends StatefulWidget {
  const ExportFieldCustomisationSetting({super.key});

  @override
  State<ExportFieldCustomisationSetting> createState() => _ExportFieldCustomisationSettingState();
}

class _ExportFieldCustomisationSettingState extends State<ExportFieldCustomisationSetting> {
  // hack so that FutureBuilder doesn't always rebuild
  Future<ExportConfigurationModel>? _future;
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _future ??= ExportConfigurationModel.get(Provider.of<Settings>(context, listen: false), localizations);

    return ConsistentFutureBuilder(
      future: _future!,
      onData: (context, result) {
        return Consumer<Settings>(builder: (context, settings, child) {
          final formats = result.availableFormats.toSet();
          List<ExportColumn> activeFields = [];
          List<ExportColumn> hiddenFields = [];
          for (final internalName in settings.exportItemsCsv) {
            activeFields.add(formats.singleWhere((e) => e.internalName == internalName));
            formats.removeWhere((e) => e.internalName == internalName);
          }
          hiddenFields = formats.toList();
          
          return Column(
            children: [
              SwitchSettingsTile(
                  title: Text(localizations.exportCustomEntries),
                  initialValue: settings.exportCustomEntriesCsv,
                  disabled: !(settings.exportFormat == ExportFormat.csv || settings.exportFormat == ExportFormat.pdf &&
                      settings.exportPdfExportData),
                  onToggle: (value) {
                    settings.exportCustomEntriesCsv = value;
                  }
              ),
              (settings.exportCustomEntriesCsv && (settings.exportFormat == ExportFormat.csv || settings.exportFormat == ExportFormat.pdf &&
                  settings.exportPdfExportData)) ?
                ExportItemsCustomizer(
                  shownItems: activeFields,
                  disabledItems: hiddenFields,
                  onReorder: (exportItems, exportAddableItems) {
                    settings.exportItemsCsv = exportItems.map((e) => e.internalName).toList();
                  },
                ) : const SizedBox.shrink()
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
    final settings = Provider.of<Settings>(context, listen: false);
    final model = Provider.of<BloodPressureModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                  child:  Text(localizations.export),
                  onPressed: () async => Exporter(settings, model, messenger, localizations, theme, await ExportConfigurationModel.get(settings, localizations)).export(),
                )
            ),
            const VerticalDivider(),
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(localizations.import),
                  onPressed: () async => Exporter(settings, model, messenger, localizations, theme, await ExportConfigurationModel.get(settings, localizations)).import(),
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
    String? message;
    return Consumer<Settings>(builder: (context, settings, child) {
      if (_showWarnBanner && ![ExportFormat.csv, ExportFormat.db].contains(settings.exportFormat) ||
          settings.exportCsvHeadline == false ||
          settings.exportCustomEntriesCsv && !(['timestampUnixMs'].any((i) => settings.exportItemsCsv.contains(i))) ||
          ![',', '|'].contains(settings.csvFieldDelimiter) ||
          !['"', '\''].contains(settings.csvTextDelimiter)
      ) {
        message = localizations.exportWarnConfigNotImportable;
      } else if (_showWarnBanner && settings.exportCustomEntriesCsv &&
          !(['systolic','diastolic', 'pulse', 'notes'].every((i) => settings.exportItemsCsv.contains(i)))) {
        var missingAttributes = {'systolic','diastolic', 'pulse', 'notes'};
        missingAttributes.removeWhere((e) => settings.exportItemsCsv.contains(e));

        message = localizations.exportWarnNotEveryFieldExported(missingAttributes.length, missingAttributes.toString());
      }

      if (message != null) {
        return MaterialBanner(
            padding: const EdgeInsets.all(20),
            content: Text(message!),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _showWarnBanner = false;
                    });
                  },
                  child: Text(localizations.btnConfirm))
            ]
        );
      }
      return const SizedBox.shrink();
    });
    }
  }

