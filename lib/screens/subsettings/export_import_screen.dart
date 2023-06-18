
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
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
        var exportRange = settings.exportDataRange;
        String? exportRangeText;
        if (exportRange != null) {
          var formatter = DateFormat.yMMMd(AppLocalizations.of(context)!.localeName);
          exportRangeText = '${formatter.format(exportRange.start)} - ${formatter.format(exportRange.end)}';
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
            CsvItemsOrderCreator()
          ];
        }

        List<Widget> options = [
          SettingsTile(
            title: Text(AppLocalizations.of(context)!.exportInterval),
            description: (exportRangeText != null) ? Text(exportRangeText) : null,
            onPressed: (context) async {
              var model = Provider.of<BloodPressureModel>(context, listen: false);
              var newRange = await showDateRangePicker(context: context, firstDate: await model.firstDay, lastDate: await model.lastDay);
              if (newRange == null && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errNoRangeForExport)));
                return;
              }
              settings.exportDataRange = newRange;

            }
          ),
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
        return ListView(
          children: options,
        );
      }),
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
                      var settings = Provider.of<Settings>(context);
                      var range = settings.exportDataRange;
                      if (range == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errNoRangeForExport)));
                        return;
                      }

                      var entries = await Provider.of<BloodPressureModel>(context, listen: false).getInTimeRange(settings.exportDataRange!.start, settings.exportDataRange!.end);
                      var fileContents = DataExporter(settings).createFile(entries);

                      /*
                      .save((success, msg) {
                        if (success && msg != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.success(msg))));
                        } else if (!success && msg != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error(msg))));
                        }
                      }, exportAsText: false);
                       */
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

class CsvItemsOrderCreator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CsvItemsOrderCreatorState();
}

class _CsvItemsOrderCreatorState extends State<CsvItemsOrderCreator> {
  List<String> _items = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes'];
  List<String> _addable = [];

  @override
  Widget build(BuildContext context) {
    print(_addable);
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
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        footer: (_addable.isNotEmpty) ? InkWell(
          onTap: () {
            showDialog(context: context,
                builder: (context) {
                  return Dialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))
                    ),
                    child: Container(
                      height: 330,
                      padding: const EdgeInsets.all(30),
                      child: ListView(
                        children: [
                          for (int i = 0; i < _addable.length; i += 1)
                            ListTile(
                              title: Text(_addable[i]),
                              onTap: () {
                                setState(() {
                                  var addedItem = _addable.removeAt(i);
                                  _items.add(addedItem);
                                });
                                Navigator.of(context).pop();

                              },
                            )
                        ],
                      ),
                    ),
                  );
                }
            );
          },
          child:  const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 10,),
                Text('ADD ENTRY')
              ],
            ),
          ),
        ) : null,
        children: <Widget>[
          for (int i = 0; i < _items.length; i += 1)
            SizedBox(
              key: Key(_items[i]),
              child: Dismissible(
                key: Key('dism$_items[i]'),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  setState(() {
                    var removedItem = _items.removeAt(i);
                    _addable.add(removedItem);
                  });
                },
                child: ListTile(
                  title: Text(_items[i]),
                  trailing: const Icon(Icons.drag_handle),
                ),
              ),
            ),
        ],
      ),
    );
  }

}

