import 'dart:collection';

import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/elements/blood_pressure_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart' hide BloodPressureRecord;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A old more compact [BloodPressureRecord] list, that lacks some of the new
/// features.
class LegacyMeasurementsList extends StatelessWidget {
  /// Create a more compact measurement list without all new features.
  LegacyMeasurementsList(BuildContext context, {super.key}) {
    if (MediaQuery.of(context).size.width < 1000) {
      _tableElementsSizes = [33, 9, 9, 9, 30];
      _sideFlex = 1;
    } else {
      _tableElementsSizes = [20, 5, 5, 5, 60];
      _sideFlex = 5;
    }
  }
  late final List<int> _tableElementsSizes;
  late final int _sideFlex;

  @override
  Widget build(BuildContext context) => Consumer<Settings>(builder: (context, settings, child) =>
      Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: _sideFlex,
              child: const SizedBox(),
            ),
            Expanded(
                flex: _tableElementsSizes[0],
                child: Text(AppLocalizations.of(context)!.time, style: const TextStyle(fontWeight: FontWeight.bold)),),
            Expanded(
                flex: _tableElementsSizes[1],
                child: Text(AppLocalizations.of(context)!.sysShort, style: TextStyle(fontWeight: FontWeight.bold, color: settings.sysColor)),),
            Expanded(
                flex: _tableElementsSizes[2],
                child: Text(AppLocalizations.of(context)!.diaShort, style: TextStyle(fontWeight: FontWeight.bold, color: settings.diaColor)),),
            Expanded(
                flex: _tableElementsSizes[3],
                child: Text(AppLocalizations.of(context)!.pulShort, style: TextStyle(fontWeight: FontWeight.bold, color: settings.pulColor)),),
            Expanded(
                flex: _tableElementsSizes[4],
                child: Text(AppLocalizations.of(context)!.notes, style: const TextStyle(fontWeight: FontWeight.bold)),),
            Expanded(
              flex: _sideFlex,
              child: const SizedBox(),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          height: 0,
          thickness: 2,
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        Expanded(
          child: BloodPressureBuilder(
            rangeType: IntervallStoreManagerLocation.mainPage,
            onData: (BuildContext context, UnmodifiableListView<BloodPressureRecord> data) {
              if (data.isNotEmpty) {
                return ListView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(2),
                    itemBuilder: (context, index) {
                      final formatter = DateFormat(settings.dateFormatString);
                      return Column(
                        children: [
                          Dismissible(
                            key: Key(data[index].creationTime.toIso8601String()),
                            confirmDismiss: (direction) async {
                              final model = Provider.of<BloodPressureModel>(context, listen: false);
                              if (direction == DismissDirection.startToEnd) { // edit
                                final model = Provider.of<BloodPressureModel>(context, listen: false);
                                final entry = await showAddEntryDialoge(context,
                                  Provider.of<Settings>(context, listen: false),
                                  RepositoryProvider.of<MedicineRepository>(context),
                                  data[index],
                                );
                                if (entry?.$1 != null) {
                                  if (context.mounted) {
                                    model.addAndExport(context, entry!.$1!);
                                  } else {
                                    model.add(entry!.$1!);
                                  }
                                }
                                assert(entry?.$2 == null);
                                return false;
                              } else { // delete
                                bool dialogeDeletionConfirmed = false;
                                if (settings.confirmDeletion) {
                                  await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                          title: Text(AppLocalizations.of(context)!.confirmDelete),
                                          content: Text(AppLocalizations.of(context)!.confirmDeleteDesc),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () => Navigator.pop(context, ),
                                                child: Text(AppLocalizations.of(context)!.btnCancel),),
                                            ElevatedButton(
                                                onPressed: () {
                                                  model.delete(data[index].creationTime);

                                                  dialogeDeletionConfirmed = true;
                                                  Navigator.pop(context, );
                                                },
                                                child: Text(AppLocalizations.of(context)!.btnConfirm),),
                                          ],
                                        ),);
                                } else {
                                  model.delete(data[index].creationTime);
                                  dialogeDeletionConfirmed = true;
                                }

                                if (dialogeDeletionConfirmed) {
                                  if (!context.mounted) return true;
                                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    duration: const Duration(seconds: 5),
                                    content: Text(AppLocalizations.of(context)!.deletionConfirmed),
                                    action: SnackBarAction(
                                      label: AppLocalizations.of(context)!.btnUndo,
                                      onPressed: () async {
                                        model.addAndExport(context, BloodPressureRecord(
                                            data[index].creationTime,
                                            data[index].systolic,
                                            data[index].diastolic,
                                            data[index].pulse,
                                            data[index].notes,),);
                                      },
                                    ),
                                  ),);
                                }
                                return dialogeDeletionConfirmed;
                              }
                            },
                            onDismissed: (direction) {},
                            background: Container(
                              width: 10,
                              decoration:
                              BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                              child: const Align(alignment: Alignment(-0.95, 0), child: Icon(Icons.edit)),
                            ),
                            secondaryBackground: Container(
                              width: 10,
                              decoration:
                              BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                              child: const Align(alignment: Alignment(0.95, 0), child: Icon(Icons.delete)),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 40),
                              child: Row(children: [
                                Expanded(
                                  flex: _sideFlex,
                                  child: const SizedBox(),
                                ),
                                Expanded(
                                    flex: _tableElementsSizes[0],
                                    child: Text(formatter.format(data[index].creationTime)),),
                                Expanded(
                                    flex: _tableElementsSizes[1],
                                    child: Text((data[index].systolic ?? '').toString()),),
                                Expanded(
                                    flex: _tableElementsSizes[2],
                                    child: Text((data[index].diastolic ?? '').toString()),),
                                Expanded(
                                    flex: _tableElementsSizes[3],
                                    child: Text((data[index].pulse ?? '').toString()),),
                                Expanded(
                                    flex: _tableElementsSizes[4],
                                    child: Text(data[index].notes),),
                                Expanded(
                                  flex: _sideFlex,
                                  child: const SizedBox(),
                                ),
                              ],),
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            height: 1,
                          ),
                        ],
                      );
                    },);
              } else {
                return Text(AppLocalizations.of(context)!.errNoData);
              }
            },),
        ),
      ],
    ),);
}
