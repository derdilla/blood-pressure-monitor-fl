import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeasurementList extends StatelessWidget {
  const MeasurementList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        child: Consumer<BloodPressureModel>(
          builder: (context, model, child) {
            List<BloodPressureRecord> items = model.getLastX(30);
            if (items.isNotEmpty && items.first.diastolic > 0) {
              return ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return buildListItem(items[index]);
                  }
              );
            } else {
              return const Text('Es existieren noch keine Werte');
            }
        })
    );
  }

  Widget buildListItem(BloodPressureRecord record) {
    return Container(
      child: Row(
          children: [
            Expanded(
                flex: 10,
                child: Text(record.systolic.toString())
            ),
            Expanded(
                flex: 10,
                child: Text(record.diastolic.toString())
            ),
            Expanded(
                flex: 10,
                child: Text(record.pulse.toString())
            ),
            Expanded(
                flex: 70,
                child: Text(record.notes)
            ),
          ]
      ),
    );
  }

  Widget buildColumnSeperator() {
    return const SizedBox(
      width: 8,
    );
  }
}

class _MeasuredValueListItem {


}
