import 'package:blood_pressure_app/components/display_interval_picker.dart';
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
      //settings.exportItems = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes'];
      return Container(
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(20),
        height: 420,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).textTheme.labelLarge?.color ?? Colors.teal),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        clipBehavior: Clip.hardEdge,
        child: ReorderableListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          onReorder: (oldIndex, newIndex) {
            /**
             * We have a list of items that is structured like the following:
             * [ exportItems.length, 1, exportAddableItems.length ]
             *
             * So oldIndex is either (0 <= oldIndex < exportItems.length) or
             * ((exportItems.length + 1) <= oldIndex < (exportItems.length + 1 + exportAddableItems.length))
             * newIndex is in the range (0 <= newIndex < (exportItems.length + 1 + exportAddableItems.length))
             *
             * In case the entry is moved upwards on the list the new position needs to have 1 subtracted because there
             * is an entry missing above it now.
             *
             * If the newIndex is (0 <= newIndex < (exportItems.length + 1)) the Item got moved above the divider.
             * The + 1 is needed to compensate for moving the item one position above the divider and thereby replacing
             * its index.
             */
            var exportItems = settings.exportItems;
            var exportAddableItems = settings.exportAddableItems;
            if (oldIndex < newIndex) { // The
              newIndex -= 1;
            }

            final String item;
            if (0 <= oldIndex && oldIndex < exportItems.length) {
              item = exportItems.removeAt(oldIndex);
            } else if ((exportItems.length + 1) <= oldIndex && oldIndex < (exportItems.length + 1 + exportAddableItems.length)) {
              item = exportAddableItems.removeAt(oldIndex - (exportItems.length + 1));
            } else {
              assert(false, 'oldIndex outside expected boundaries');
              return;
            }

            if (newIndex < (exportItems.length + 1)) {
              exportItems.insert(newIndex, item);
            } else {
              newIndex -= (exportItems.length + 1);
              exportAddableItems.insert(newIndex, item);
            }

            settings.exportItems = exportItems;
            settings.exportAddableItems = exportAddableItems;
          },
          /*
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
           */
          children: <Widget>[
            for (int i = 0; i < settings.exportItems.length; i += 1)
              ListTile(
                key: Key('l_${settings.exportItems[i]}'),
                title: Text(settings.exportItems[i]),
                trailing: const Icon(Icons.drag_handle),
              ),
            _buildListSectionDivider(context),
            for (int i = 0; i < settings.exportAddableItems.length; i += 1)
              ListTile(
                key: Key('ul_${settings.exportAddableItems[i]}'),
                title: Opacity(opacity: 0.7,child: Text(settings.exportAddableItems[i]),),
                trailing: const Icon(Icons.drag_handle),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildListSectionDivider(BuildContext context) {
    return IgnorePointer(
      key: UniqueKey(),
      child: Opacity(
        opacity: 0.7,
        child: Row(
          children: <Widget>[
            const Expanded(
              child: Divider()
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.arrow_downward)
            ),
            Text(AppLocalizations.of(context)!.exportHiddenFields),
            Container(
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.arrow_downward)
            ),
            const Expanded(
              child: Divider()
            ),
          ]
        ),
      ),
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
                  onPressed: () => Exporter(settings, model, messenger, localizations).export(),
                )
            ),
            const VerticalDivider(),
            Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(AppLocalizations.of(context)!.import),
                  onPressed: () => Exporter(settings, model, messenger, localizations).import(),
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

