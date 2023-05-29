import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../screens/add_measurement.dart';

class MeasurementList extends StatelessWidget {
  late final _tableElementsSizes;
  late final _sideFlex;

  MeasurementList(BuildContext context, {super.key}) {
    if (MediaQuery.of(context).size.width < 1000) {
      _tableElementsSizes = [33,9,9,9,30];
      _sideFlex = 1;
    } else {
      _tableElementsSizes = [20,5,5,5,60];
      _sideFlex = 5;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Consumer<Settings>(
          builder: (context, settings, child) {
            return Column (
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: _sideFlex,
                      child: const SizedBox(),
                    ),
                    Expanded(
                        flex: _tableElementsSizes[0],
                        child: const Text("time", style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                    Expanded(
                        flex: _tableElementsSizes[1],
                        child: Text("sys",
                            style: TextStyle(fontWeight: FontWeight.bold, color: settings.sysColor))
                    ),
                    Expanded(
                        flex: _tableElementsSizes[2],
                        child: Text("dia",
                            style: TextStyle(fontWeight: FontWeight.bold, color: settings.diaColor))
                    ),
                    Expanded(
                        flex: _tableElementsSizes[3],
                        child: Text("pul",
                            style: TextStyle(fontWeight: FontWeight.bold, color: settings.pulColor))
                    ),
                    Expanded(
                        flex: _tableElementsSizes[4],
                        child: const Text("notes", style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                    Expanded(
                      flex: _sideFlex,
                      child: const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Divider(
                  height: 0,
                  thickness: 2,
                  color: Theme.of(context).primaryColor,
                )
              ]
            );
          }
        ),
        Expanded(
          child: Consumer<BloodPressureModel>(
            builder: (context, model, child) {
              return Consumer<Settings>(
                builder: (context, settings, child) {
                  final items = model.getInTimeRange(settings.displayDataStart, settings.displayDataEnd);
                  return FutureBuilder<UnmodifiableListView<BloodPressureRecord>>(
                    future: items,
                    builder: (BuildContext context, AsyncSnapshot<UnmodifiableListView<BloodPressureRecord>> recordsSnapshot) {
                      assert(recordsSnapshot.connectionState != ConnectionState.none);

                      if (recordsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Text('loading...');
                      } else if (recordsSnapshot.hasError) {
                          return Text('Error loading data:\n${recordsSnapshot.error}');
                      } else {
                        final data = recordsSnapshot.data ?? [];
                        if (data.isNotEmpty && data.first.diastolic > 0) {
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
                                      if (direction == DismissDirection.startToEnd) { // edit
                                        Provider.of<BloodPressureModel>(context, listen: false).delete(data[index].creationTime);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AddMeasurementPage(
                                            initTime: data[index].creationTime,
                                            initSys: data[index].systolic,
                                            initDia: data[index].diastolic,
                                            initPul: data[index].pulse,
                                            initNote: data[index].notes,
                                            isEdit: true,
                                          )),
                                        );
                                        return false;
                                      } else { // delete
                                        bool dialogeDeletionConfirmed = false;
                                        if (settings.confirmDeletion) {
                                          await showDialog(context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Confirm deletion"),
                                                content: const Text("Do you really want to delete this entry? You can turn of this question in the settings."),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () => Navigator.of(context).pop(),
                                                      child: const Text('CANCEL')
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Provider.of<BloodPressureModel>(context, listen: false).delete(data[index].creationTime);
                                                        dialogeDeletionConfirmed = true;
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('CONFIRM')
                                                  ),
                                                ],
                                              );
                                            }
                                          );
                                        } else {
                                          Provider.of<BloodPressureModel>(context, listen: false).delete(data[index].creationTime);
                                          dialogeDeletionConfirmed = true;
                                        }

                                        if (dialogeDeletionConfirmed) {
                                          if (!context.mounted) return true;
                                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                duration: const Duration(seconds: 5),
                                                content: const Text('entry has been deleted'),
                                                action: SnackBarAction(
                                                  label: "UNDO",
                                                  onPressed: () => model.add(BloodPressureRecord(
                                                      data[index].creationTime,
                                                      data[index].systolic,
                                                      data[index].diastolic,
                                                      data[index].pulse,
                                                      data[index].notes)),
                                                ),
                                              )
                                          );
                                        }
                                        return dialogeDeletionConfirmed;
                                      }
                                    },
                                    onDismissed: (direction) {
                                    },
                                    background: Container(
                                      width: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: const Align(
                                          alignment: Alignment(-0.95,0),
                                          child: Icon(Icons.edit)
                                      ),
                                    ),
                                    secondaryBackground: Container(
                                      width: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: const Align(
                                          alignment: Alignment(0.95, 0),
                                          child: Icon(Icons.delete)
                                      ),
                                    ),
                                    child: SizedBox(
                                      height: 40,
                                      child: Row(
                                          children: [
                                            Expanded(
                                              flex: _sideFlex,
                                              child: const SizedBox(),
                                            ),
                                            Expanded(
                                                flex: _tableElementsSizes[0],
                                                child: Text(formatter.format(data[index].creationTime))
                                            ),
                                            Expanded(
                                                flex: _tableElementsSizes[1],
                                                child: Text(data[index].systolic.toString())
                                            ),
                                            Expanded(
                                                flex: _tableElementsSizes[2],
                                                child: Text(data[index].diastolic.toString())
                                            ),
                                            Expanded(
                                                flex: _tableElementsSizes[3],
                                                child: Text(data[index].pulse.toString())
                                            ),
                                            Expanded(
                                                flex: _tableElementsSizes[4],
                                                child: Text(data[index].notes)
                                            ),
                                            Expanded(
                                              flex: _sideFlex,
                                              child: const SizedBox(),
                                            ),
                                          ]
                                      ),
                                    ),
                                  ),
                                  const Divider(thickness: 1, height: 1,)
                                ],
                              );
                            }
                          );
                        } else {
                          return const Text('no data');
                        }
                      }
                    }
                  );
                }
              );
            }
          ),
        )
      ],
    );
  }
}
