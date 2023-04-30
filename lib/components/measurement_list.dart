import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MeasurementList extends StatelessWidget {
  const MeasurementList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        child: Column(
          children: [
            buildTableHeader(context),
            Expanded(
              flex: 100,
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
                }
              ),
            )
          ],
        )
    );
  }

  Widget buildListItem(BloodPressureRecord record) {
    final DateFormat formater = DateFormat('yyyy-MM-dd H:mm:s');
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
          children: [
            const Expanded(
              flex: 5,
              child: SizedBox(),
            ),
            Expanded(
                flex: 9,
                child: Text(formater.format(record.creationTime))
            ),
            Expanded(
                flex: 7,
                child: Text(record.systolic.toString())
            ),
            Expanded(
                flex: 7,
                child: Text(record.diastolic.toString())
            ),
            Expanded(
                flex: 7,
                child: Text(record.pulse.toString())
            ),
            Expanded(
                flex: 60,
                child: Text(record.notes)
            ),
            const Expanded(
              flex: 5,
              child: SizedBox(),
            ),
          ]
      ),
    );
  }


  Widget buildTableHeader(BuildContext context) {
    return Container(
      child: Column (
        children: [
          Row(
          children: const [
            Expanded(
              flex: 5,
              child: SizedBox(),
            ),
            Expanded(
                flex: 9,
                child: Text("timestamp", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Expanded(
                flex: 7,
                child: Text("systolic", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Expanded(
                flex: 7,
                child: Text("diastolic", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Expanded(
                flex: 7,
                child: Text("pulse", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Expanded(
                flex: 60,
                child: Text("notes", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Expanded(
              flex: 5,
              child: SizedBox(),
            ),
          ],
          ),
          Divider(
            height: 20,
            thickness: 1,
            color: Theme.of(context).primaryColor,
          )
        ]
      ),
    );
  }
}

class _MeasuredValueListItem {


}
