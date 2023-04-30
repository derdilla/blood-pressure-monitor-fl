import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/components/measurement_graph.dart';
import 'package:blood_pressure_app/components/measurement_list.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(80),
          child: Column(
            children: const [
              Expanded(
                  flex: 40,
                  child: MeasurementGraph()
              ),
              Expanded(
                flex: 60,
                  child: MeasurementList()
              ),
            ]
          ),
        ),
      ),
      floatingActionButton: Ink(
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

    );
  }
}