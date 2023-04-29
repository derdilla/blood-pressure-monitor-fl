import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:flutter/material.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement body
    return Scaffold(
      body: ListView(

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