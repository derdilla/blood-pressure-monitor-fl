import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';

class MeasurementList extends StatelessWidget {
  final List<BloodPressureRecord> entries;
  
  const MeasurementList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      //separatorBuilder: (context, idx) => const Divider(),
      itemBuilder: (context, idx) => MeasurementListRow(
        record: entries[idx]
      ),
    );
  }

}