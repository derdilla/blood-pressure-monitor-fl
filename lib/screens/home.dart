import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:blood_pressure_app/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/components/measurement_graph.dart';
import 'package:blood_pressure_app/components/measurement_list.dart';
import 'package:flutter/services.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    if (MediaQuery.of(context).size.width < 1000) {
      padding = const EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 30);
    } else {
      padding = const EdgeInsets.all(80);
    }

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape && MediaQuery.of(context).size.height < 500) {
            return MeasurementGraph(height: MediaQuery.of(context).size.height,);
          }
          return Center(
            child: Container(
              padding: padding,
              child: Column(
                  children: [
                    const MeasurementGraph(),
                    Expanded(
                        flex: 50,
                        child: MeasurementList(context)
                    ),
                  ]
              ),
            ),
          );
        },
      ),
      floatingActionButton: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
            return const SizedBox.shrink();
          }
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          return SizedBox(
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
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ),

              ],
            ),
          );
        })
    );
  }
}