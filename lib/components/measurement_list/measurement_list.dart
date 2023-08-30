import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';

class MeasurementList extends StatelessWidget {
  final List<BloodPressureRecord> entries;
  
  const MeasurementList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length + 2,
      //separatorBuilder: (context, idx) => const Divider(),
      itemBuilder: (context, idx) {
        if (idx == 0) { // first row
          // TODO
          return Text("TODO");
        }
        if (idx > entries.length) { // last row
          // Fix actions blocked by floating buttons
          // This way of doing it seems to be the most common: https://stackoverflow.com/q/29362284
          return const SizedBox(height: 300,);
        }
        return MeasurementListRow(
            record: entries[idx-1]
        );
      },
    );
  }

}