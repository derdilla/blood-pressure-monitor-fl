import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/components/export_item_order.dart';
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jsaver/jSaver.dart';
import 'package:provider/provider.dart';

class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exportImport),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Settings>(builder: (context, settings, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const ExportWarnBanner(),
              const SizedBox(height: 15,),
              Opacity(
                opacity: (settings.exportFormat == ExportFormat.db) ? 0.5 : 1, // TODO: centralize opacity when restyle
                child: const IntervalPicker(),
              ),
              SettingsTile(
                title: Text(AppLocalizations.of(context)!.exportDir),
                description: Text(settings.defaultExportDir),
                onPressed: (context) async {
                  final appDir = await JSaver.instance.setDefaultSavingDirectory();
                  settings.defaultExportDir = appDir.value;
                }
              ),
              SwitchSettingsTile(
                  title: Text(AppLocalizations.of(context)!.exportAfterEveryInput),
                  description: Text(AppLocalizations.of(context)!.exportAfterEveryInputDesc),
                  initialValue: settings.exportAfterEveryEntry,
                  onToggle: (value) {
                    settings.exportAfterEveryEntry = value;
                  }
              ),
              DropDownSettingsTile<ExportFormat>(
                key: const Key('exportFormat'),
                title: Text(AppLocalizations.of(context)!.exportFormat),
                value: settings.exportFormat,
                items: [
                  DropdownMenuItem(value: ExportFormat.csv, child: Text(AppLocalizations.of(context)!.csv)),
                  DropdownMenuItem(value: ExportFormat.pdf, child: Text(AppLocalizations.of(context)!.pdf)),
                  DropdownMenuItem(value: ExportFormat.db, child: Text(AppLocalizations.of(context)!.db)),
                ],
                onChanged: (ExportFormat? value) {
                  if (value != null) {
                    settings.exportFormat = value;
                  }
                },
              ),
              InputSettingsTile(
                title: Text(AppLocalizations.of(context)!.fieldDelimiter),
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
                title: Text(AppLocalizations.of(context)!.textDelimiter),
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
                  title: Text(AppLocalizations.of(context)!.exportCsvHeadline),
                  description: Text(AppLocalizations.of(context)!.exportCsvHeadlineDesc),
                  initialValue: settings.exportCsvHeadline,
                  disabled: !(settings.exportFormat == ExportFormat.csv),
                  onToggle: (value) {
                    settings.exportCsvHeadline = value;
                  }
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

class ExportFieldCustomisationSetting extends StatelessWidget {
  const ExportFieldCustomisationSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return Column(
        children: [
          SwitchSettingsTile(
              title: Text(AppLocalizations.of(context)!.exportCustomEntries),
              initialValue: settings.exportCustomEntries,
              disabled: settings.exportFormat != ExportFormat.csv,
              onToggle: (value) {
                settings.exportCustomEntries = value;
              }
          ),
          (settings.exportFormat == ExportFormat.csv && settings.exportCustomEntries) ?
            ExportItemsCustomizer(
              exportItems: settings.exportItems,
              exportAddableItems: settings.exportAddableItems,
              onReorder: (exportItems, exportAddableItems) {
                settings.exportItems = exportItems;
                settings.exportAddableItems = exportAddableItems;
              },
            ) : const SizedBox.shrink()
        ],
      );
    });
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
                  child:  Text(AppLocalizations.of(context)!.export),
                  onPressed: () => Exporter(settings, model, messenger, localizations, theme).export(),
                )
            ),
            const VerticalDivider(),
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(AppLocalizations.of(context)!.import),
                  onPressed: () => Exporter(settings, model, messenger, localizations, theme).import(),
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
    String? message;
    return Consumer<Settings>(builder: (context, settings, child) {
      if (_showWarnBanner && ![ExportFormat.csv, ExportFormat.db].contains(settings.exportFormat) ||
          settings.exportCsvHeadline == false ||
          settings.exportCustomEntries && !(['timestampUnixMs','isoUTCTime'].any((i) => settings.exportItems.contains(i))) ||
          ![',', '|'].contains(settings.csvFieldDelimiter) ||
          !['"', '\''].contains(settings.csvTextDelimiter)
      ) {
        message = AppLocalizations.of(context)!.exportWarnConfigNotImportable;
      } else if (_showWarnBanner && settings.exportCustomEntries &&
          !(['systolic','diastolic', 'pulse', 'notes'].every((i) => settings.exportItems.contains(i)))) {
        var missingAttributes = {'systolic','diastolic', 'pulse', 'notes'};
        missingAttributes.removeWhere((e) => settings.exportItems.contains(e));

        message = AppLocalizations.of(context)!.exportWarnNotEveryFieldExported(missingAttributes.length, missingAttributes.toString());
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
                  child: Text(AppLocalizations.of(context)!.btnConfirm))
            ]
        );
      }
      return const SizedBox.shrink();
    });
    }
  }

