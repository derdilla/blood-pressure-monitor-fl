import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:blood_pressure_app/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/components/measurement_graph.dart';
import 'package:blood_pressure_app/components/measurement_list.dart';
import 'package:provider/provider.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    var _padding;
    if (MediaQuery.of(context).size.width < 1000) {
      _padding = const EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 30);
    } else {
      _padding = const EdgeInsets.all(80);
    }

    return Scaffold(
      body: Center(
        child: Container(
          padding: _padding,
          child: Column(
            children: [
              MeasurementGraph(),
              Expanded(
                flex: 50,
                  child: MeasurementList(context)
              ),
            ]
          ),
        ),
      ),
      floatingActionButton:
        SizedBox(
          height: 150,
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: [
              Ink(
                decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: Theme.of(context).primaryColor
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddMeasurementPage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10,),
              Ink(
                decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: Theme.of(context).unselectedWidgetColor
                ),
                child: IconButton(
                  icon: const Icon(
                      Icons.settings,
                      color: Colors.black
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
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