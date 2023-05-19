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
        buildTableHeader(context),
        Expanded(
          flex: 100,
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
                        } else {
                          if (recordsSnapshot.hasError) {
                            return Text('Error loading data:\n${recordsSnapshot.error}');
                          } else {
                            final data = recordsSnapshot.data ?? [];
                            if (data.isNotEmpty && data.first.diastolic > 0) {
                              return ListView.builder(
                                  itemCount: data.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return buildListItem(data[index]);
                                  }
                              );
                            } else {
                              return const Text('no data');
                            }
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

  Widget buildListItem(BloodPressureRecord record) {
    return Consumer<Settings>(
        builder: (context, settings, child) {
          final formatter = DateFormat(settings.dateFormatString);
          return GestureDetector(
            onTap: () {
              Provider.of<BloodPressureModel>(context, listen: false).delete(record.creationTime);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMeasurementPage(
                  initTime: record.creationTime,
                  initSys: record.systolic,
                  initDia: record.diastolic,
                  initPul: record.pulse,
                  initNote: record.notes,
                  isEdit: true,
                )),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: Row(
                  children: [
                    Expanded(
                      flex: _sideFlex,
                      child: const SizedBox(),
                    ),
                    Expanded(
                        flex: _tableElementsSizes[0],
                        child: Text(formatter.format(record.creationTime))
                    ),
                    Expanded(
                        flex: _tableElementsSizes[1],
                        child: Text(record.systolic.toString())
                    ),
                    Expanded(
                        flex: _tableElementsSizes[2],
                        child: Text(record.diastolic.toString())
                    ),
                    Expanded(
                        flex: _tableElementsSizes[3],
                        child: Text(record.pulse.toString())
                    ),
                    Expanded(
                        flex: _tableElementsSizes[4],
                        child: Text(record.notes)
                    ),
                    Expanded(
                      flex: _sideFlex,
                      child: const SizedBox(),
                    ),
                  ]
              ),
            ),
          );
        }
    );

  }


  Widget buildTableHeader(BuildContext context) {
    return Consumer<Settings>(
        builder: (context, settings, child) {
          return Column (
              children: [
                const SizedBox(height: 15 ),
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
                Divider(
                  height: 20,
                  thickness: 2,
                  color: Theme.of(context).primaryColor,
                )
              ]
          );
        });
  }
}
