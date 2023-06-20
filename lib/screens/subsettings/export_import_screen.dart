
import 'dart:collection';
import 'dart:io';

import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
          var exportRange = settings.exportDataRange;
          String exportRangeText;
          if (exportRange.start.millisecondsSinceEpoch != 0 && exportRange.end.millisecondsSinceEpoch != 0) {
            var formatter = DateFormat.yMMMd(AppLocalizations.of(context)!.localeName);
            exportRangeText = '${formatter.format(exportRange.start)} - ${formatter.format(exportRange.end)}';
          } else {
            exportRangeText = AppLocalizations.of(context)!.errPleaseSelect;
          }

          List<Widget> modeSpecificSettings = [];
          if (settings.exportFormat == ExportFormat.csv) {
            modeSpecificSettings = [
              InputSettingsTile(
                title: Text(AppLocalizations.of(context)!.fieldDelimiter),
                inputWidth: 40,
                initialValue: settings.csvFieldDelimiter,
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
                onEditingComplete: (value) {
                  if (value != null) {
                    settings.csvTextDelimiter = value;
                  }
                },
              ),
              SwitchSettingsTile(
                title: Text(AppLocalizations.of(context)!.exportCustomEntries),
                initialValue: settings.exportCustomEntries,
                onToggle: (value) {
                  settings.exportCustomEntries = value;
                }
              ),
              (settings.exportCustomEntries) ? const CsvItemsOrderCreator(): const SizedBox.shrink()
            ];
          }

          List<Widget> options = [
            SwitchSettingsTile(
                title: Text(AppLocalizations.of(context)!.exportLimitDataRange),
                initialValue: settings.exportLimitDataRange,
                onToggle: (value) {
                  settings.exportLimitDataRange = value;
                }
            ),
            (settings.exportLimitDataRange) ? SettingsTile(
                title: Text(AppLocalizations.of(context)!.exportInterval),
                description: Text(exportRangeText),
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
            ) : const SizedBox.shrink(),
            DropDownSettingsTile<ExportFormat>(
              key: const Key('exportFormat'),
              title: Text(AppLocalizations.of(context)!.exportFormat),
              value: settings.exportFormat,
              items: [
                DropdownMenuItem(value: ExportFormat.csv, child: Text(AppLocalizations.of(context)!.csv)),
                DropdownMenuItem(value: ExportFormat.pdf, child: Text(AppLocalizations.of(context)!.pdf)),
              ],
              onChanged: (ExportFormat? value) {
                if (value != null) {
                  settings.exportFormat = value;
                }
              },
            ),
            /*
            DropDownSettingsTile<MimeType>(
              key: const Key('exportMimeType'),
              title: Text(AppLocalizations.of(context)!.exportMimeType),
              description: Text(AppLocalizations.of(context)!.exportMimeTypeDesc),
              value: settings.exportMimeType,
              items: [
                DropdownMenuItem(value: MimeType.csv, child: Text(AppLocalizations.of(context)!.csv)),
                DropdownMenuItem(value: MimeType.text, child: Text(AppLocalizations.of(context)!.text)),
                DropdownMenuItem(value: MimeType.pdf, child: Text(AppLocalizations.of(context)!.pdf)),
                DropdownMenuItem(value: MimeType.other, child: Text(AppLocalizations.of(context)!.other)),
              ],
              onChanged: (MimeType? value) {
                if (value != null) {
                  settings.exportMimeType = value;
                }
              },
            ),
             */
          ];
          options.addAll(modeSpecificSettings);
          options.add(const SizedBox(height: 20,));
          return ListView(
            children: options,
          );
        }),
      ),
      floatingActionButton: SizedBox(
        height: 60,
        child: Center(
          child: Row(
            children: [
              Expanded(
                  flex: 50,
                  child: MaterialButton(
                    height: 60,
                    child:  Text(AppLocalizations.of(context)!.export),
                    onPressed: () async {
                      var settings = Provider.of<Settings>(context, listen: false);

                      final UnmodifiableListView<BloodPressureRecord> entries;
                      if (settings.exportLimitDataRange) {
                        var range = settings.exportDataRange;
                        if (range.start.millisecondsSinceEpoch == 0 || range.end.millisecondsSinceEpoch == 0) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errNoRangeForExport)));
                          return;
                        }
                        entries = await Provider.of<BloodPressureModel>(context, listen: false).getInTimeRange(settings.exportDataRange.start, settings.exportDataRange.end);
                      } else {
                        entries = await Provider.of<BloodPressureModel>(context, listen: false).all;
                      }
                      var fileContents = DataExporter(settings).createFile(entries);

                      String filename = 'blood_press_${DateTime.now().toIso8601String()}';
                      String path = await FileSaver.instance.saveFile(name: filename, bytes: fileContents);

                      if ((Platform.isLinux || Platform.isWindows || Platform.isMacOS) && context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.success(path))));
                      } else if (Platform.isAndroid || Platform.isIOS) {
                        Share.shareXFiles([
                          XFile(
                            path,
                            mimeType: MimeType.csv.type
                          )
                        ]);
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('UNSUPPORTED PLATFORM')));
                      }
                    },
                  )
              ),
              const VerticalDivider(),
              Expanded(
                flex: 50,
                child: MaterialButton(
                  height: 60,
                  child: Text(AppLocalizations.of(context)!.import),
                  onPressed: () {
                    try {
                      Provider.of<BloodPressureModel>(context, listen: false).import((res) {
                        if (res) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                              Text(AppLocalizations.of(context)!.success(AppLocalizations.of(context)!.import))));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .error(AppLocalizations.of(context)!.errNoFileOpened))));
                        }
                      });
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error(e.toString()))));
                    }
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
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
          footer: (settings.exportAddableItems.isNotEmpty) ? InkWell(
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

