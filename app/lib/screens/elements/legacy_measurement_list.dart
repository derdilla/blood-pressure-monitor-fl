import 'dart:collection';

import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/dialoges/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/elements/blood_pressure_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
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
        Expanded(// TODO: intakes
          child: BloodPressureBuilder(
            rangeType: IntervallStoreManagerLocation.mainPage,
            onData: (BuildContext context, UnmodifiableListView<BloodPressureRecord> records) {
              if (records.isEmpty) return Text(AppLocalizations.of(context)!.errNoData);
              return ListView.builder(
                itemCount: records.length,
                shrinkWrap: true,
                padding: const EdgeInsets.all(2),
                itemBuilder: (context, index) {
                  final formatter = DateFormat(settings.dateFormatString);
                  return Column(
                    children: [
                      Dismissible(
                        key: Key(records[index].time.toIso8601String()),
                        confirmDismiss: (direction) async {
                          final repo = RepositoryProvider.of<BloodPressureRepository>(context);
                          if (direction == DismissDirection.startToEnd) {
                            // edit
                            await context.createEntry((records[index], Note(time: records[index].time), []));
                            return false;
                          } else { // delete
                            if (!settings.confirmDeletion || await showConfirmDeletionDialoge(context)) {
                              await repo.remove(records[index]);
                              if (!context.mounted) return true;
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!.deletionConfirmed),
                                action: SnackBarAction(
                                  label: AppLocalizations.of(context)!.btnUndo,
                                  onPressed: () async {
                                    await repo.add(records[index]);
                                  },
                                ),
                              ),);
                              return true;
                            }
                            return false;
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
                              child: Text(formatter.format(records[index].time)),),
                            Expanded(
                              flex: _tableElementsSizes[1],
                              // FIXME: "Instance of Pressure"
                              child: Text((records[index].sys ?? '').toString()),),
                            Expanded(
                              flex: _tableElementsSizes[2],
                              child: Text((records[index].dia ?? '').toString()),),
                            Expanded(
                              flex: _tableElementsSizes[3],
                              child: Text((records[index].pul ?? '').toString()),),
                            // FIXME: reimplement notes
                            /*Expanded(
                                  flex: _tableElementsSizes[4],
                                  child: Text(data[index].),),*/
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
            },
          ),
        ),
      ],
    ),);
}
