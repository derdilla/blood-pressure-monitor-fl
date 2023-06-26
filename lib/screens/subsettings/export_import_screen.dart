import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
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
      body: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: Consumer<Settings>(builder: (context, settings, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const ExportWarnBanner(),
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
                    //DropdownMenuItem(value: ExportFormat.pdf, child: Text(AppLocalizations.of(context)!.pdf)),
                    DropdownMenuItem(value: ExportFormat.db, child: Text(AppLocalizations.of(context)!.db)),
                  ],
                  onChanged: (ExportFormat? value) {
                    if (value != null) {
                      settings.exportFormat = value;
                    }
                  },
                ),
                const ExportDataRangeSettings(),
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
        })
      ),
      floatingActionButton: const ExportImportButtons(),
    );
  }
}

class ExportDataRangeSettings extends StatelessWidget {
  const ExportDataRangeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      var exportRange = settings.exportDataRange;
      String exportRangeText;
      if (exportRange.start.millisecondsSinceEpoch != 0 && exportRange.end.millisecondsSinceEpoch != 0) {
        var formatter = DateFormat.yMMMd(AppLocalizations.of(context)!.localeName);
        exportRangeText = '${formatter.format(exportRange.start)} - ${formatter.format(exportRange.end)}';
      } else {
        exportRangeText = AppLocalizations.of(context)!.errPleaseSelect;
      }
      return Column(
        children: [
          SwitchSettingsTile(
            title: Text(AppLocalizations.of(context)!.exportLimitDataRange),
            initialValue: settings.exportLimitDataRange,
            onToggle: (value) {
              settings.exportLimitDataRange = value;
            },
            disabled: settings.exportFormat == ExportFormat.db,
          ),
          SettingsTile(
            title: Text(AppLocalizations.of(context)!.exportInterval),
            description: Text(exportRangeText),
            disabled: !settings.exportLimitDataRange || settings.exportFormat == ExportFormat.db,
            onPressed: (context) async {
              var model = Provider.of<BloodPressureModel>(context, listen: false);
              var newRange = await showDateRangePicker(context: context, firstDate: await model.firstDay, lastDate: await model.lastDay);
              if (newRange == null && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errNoRangeForExport)));
                return;
              }
              settings.exportDataRange = newRange ?? DateTimeRange(start: DateTime.fromMillisecondsSinceEpoch(0), end: DateTime.fromMillisecondsSinceEpoch(0));
            }
          ),
        ],
      );
    });
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
          (settings.exportFormat == ExportFormat.csv && settings.exportCustomEntries) ? const CsvItemsOrderCreator() : const SizedBox.shrink()
        ],
      );
    });
  }
}

class CsvItemsOrderCreator extends StatelessWidget {
  const CsvItemsOrderCreator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, settings, child) {
      return Container(
        margin: const EdgeInsets.fromLTRB(45, 20, 10, 0),
        padding: const EdgeInsets.all(20),
        height: 320,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).textTheme.labelLarge?.color ?? Colors.teal),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        clipBehavior: Clip.hardEdge,
        child: ReorderableListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            var exportItems = settings.exportItems;
            final String item = exportItems.removeAt(oldIndex);
            exportItems.insert(newIndex, item);

            settings.exportItems = exportItems;
          },
          footer: (settings.exportItems.length < 5) ? InkWell(
            onTap: () async {
              await showDialog(context: context,
                builder: (context) {
                  var exportItems = settings.exportItems;
                  var exportAddableItems = settings.exportAddableItems;
                  return Dialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))
                    ),
                    child: Container(
                      height: 330,
                      padding: const EdgeInsets.all(30),
                      child: ListView(
                        children: [
                          for (int i = 0; i < exportAddableItems.length; i += 1)
                            ListTile(
                              title: Text(exportAddableItems[i]),
                              onTap: () {
                                var addedItem = exportAddableItems.removeAt(i);
                                exportItems.add(addedItem);
                                Navigator.of(context).pop();
                                settings.exportItems = exportItems;
                                settings.exportAddableItems = exportAddableItems;
                              },
                            )
                        ],
                      ),
                    ),
                  );
                }
              );
            },
            child: Container(
              margin: const EdgeInsets.only(top: 15),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 10,),
                    Text(AppLocalizations.of(context)!.addEntry)
                  ],
                ),
              ),
            ),
          ) : null,
          children: <Widget>[
            for (int i = 0; i < settings.exportItems.length; i += 1)
              SizedBox(
                key: Key(settings.exportItems[i]),
                child: Dismissible(
                  key: Key('dism${settings.exportItems[i]}'),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    var exportItems = settings.exportItems;
                    var exportAddableItems = settings.exportAddableItems;
                    var removedItem = exportItems.removeAt(i);
                    exportAddableItems.add(removedItem);
                    settings.exportItems = exportItems;
                    settings.exportAddableItems = exportAddableItems;
                  },
                  child: ListTile(
                    title: Text(settings.exportItems[i]),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class ExportImportButtons extends StatelessWidget {
  const ExportImportButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.onBackground,
      child: Center(
        child: Row(
          children: [
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child:  Text(AppLocalizations.of(context)!.export),
                  onPressed: () => Exporter(context).export(),
                )
            ),
            const VerticalDivider(),
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(AppLocalizations.of(context)!.import),
                  onPressed: () => Exporter(context).import(),
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
    return Consumer<Settings>(builder: (context, settings, child) {
      if (_showWarnBanner && ![ExportFormat.csv, ExportFormat.db].contains(settings.exportFormat) ||
          settings.exportCsvHeadline == false ||
          settings.exportCustomEntries && !(
              (settings.exportItems.contains('timestampUnixMs') || settings.exportItems.contains('isoUTCTime')) &&
                  settings.exportItems.contains('systolic') &&
                  settings.exportItems.contains('diastolic') &&
                  settings.exportItems.contains('pulse') &&
                  settings.exportItems.contains('notes')
          ) ||
          ![',', '|'].contains(settings.csvFieldDelimiter) ||
          !['"', '\''].contains(settings.csvTextDelimiter)
      ) {
        return MaterialBanner(
            padding: const EdgeInsets.all(20),
            content: Text(AppLocalizations.of(context)!.exportWarnConfigNotImportable),
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

