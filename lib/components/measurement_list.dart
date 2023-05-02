import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;

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
                    return const Text('no data');
                  }
                }
              ),
            )
          ],
        )
    );
  }

  Widget buildListItem(BloodPressureRecord record) {
    final DateFormat formater = DateFormat('yy-MM-dd H:mm:s');
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: Row(
          children: [
            Expanded(
              flex: _sideFlex,
              child: const SizedBox(),
            ),
            Expanded(
                flex: _tableElementsSizes[0],
                child: Text(formater.format(record.creationTime))
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
    );
  }


  Widget buildTableHeader(BuildContext context) {
    return Container(
      child: Column (
        children: [
          const SizedBox(height: 15 ),
          Row(
          children: [
            Expanded(
              flex: _sideFlex,
              child: SizedBox(),
            ),
            Expanded(
                flex: _tableElementsSizes[0],
                child: Text("time", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Expanded(
                flex: _tableElementsSizes[1],
                child: Text("sys",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))
            ),
            Expanded(
                flex: _tableElementsSizes[2],
                child: const Text("dia",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
            ),
            Expanded(
                flex: _tableElementsSizes[3],
                child: const Text("pul",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
            ),
            Expanded(
                flex: _tableElementsSizes[4],
                child: Text("notes", style: TextStyle(fontWeight: FontWeight.bold))
            ),
            Expanded(
              flex: _sideFlex,
              child: SizedBox(),
            ),
          ],
          ),
          Divider(
            height: 20,
            thickness: 2,
            color: Theme.of(context).primaryColor,
          )
        ]
      ),
    );
  }
}

class _MeasuredValueListItem {


}
