import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/components/measurement_graph.dart';
import 'package:blood_pressure_app/components/measurement_list.dart';
import 'package:provider/provider.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    double _padding;
    if (MediaQuery.of(context).size.width < 1000) {
      _padding = 10;
    } else {
      _padding = 80;
    }

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(_padding),
          child: Column(
            children: [
              const Expanded(
                  flex: 40,
                  child: MeasurementGraph()
              ),
              Expanded(
                flex: 60,
                  child: MeasurementList(context)
              ),
            ]
          ),
        ),
      ),
      floatingActionButton:
        Container(
          height: 100,
          child: Column(
            children: [
              Ink(
                decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: Theme.of(context).unselectedWidgetColor
                ),
                child: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    Provider.of<BloodPressureModel>(context, listen: false).save(context);
                  },
                ),
              ),
              const SizedBox(height: 10,),
              Ink(
                decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: Theme.of(context).primaryColor
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddMeasurementPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
}