import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/measurement_graph.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:blood_pressure_app/screens/settings.dart';
import 'package:blood_pressure_app/screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../components/measurement_list/measurement_list.dart';

/// The only use of this variable is to avoid loading the AddMeasurementPage twice,
/// when startWithAddMeasurementPage is active
bool _appStart = true;

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

    // direct use of settings possible as no listening is required
    if (_appStart && Provider.of<Settings>(context, listen: false).startWithAddMeasurementPage) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddMeasurementPage()));
      });
    }
    _appStart = false;

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
        if (orientation == Orientation.landscape && MediaQuery.of(context).size.height < 500) {
          return MeasurementGraph(
            height: MediaQuery.of(context).size.height,
          );
        }
        return Center(
          child: Container(
            padding: padding,
            child: Column(children: [
              const MeasurementGraph(),
              ModernListHeader(),
              Expanded(
                flex: 50,
                child: Consumer<BloodPressureModel>(
                  builder: (context, model, child) {
                    return Consumer<Settings>(
                      builder: (context, settings, child) {
                        return ConsistentFutureBuilder(
                            future: model.getInTimeRange(settings.displayDataStart, settings.displayDataEnd),
                            onData: (context, data) {
                              return MeasurementList(
                                entries: data
                              );
                            }
                        );
                      },
                    );
                  },
                )
              ),
            ]),
          ),
        );
      },
      ),
      floatingActionButton: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape && MediaQuery.of(context).size.height < 500) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
            return const SizedBox.shrink();
          }
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          return Consumer<Settings>(builder: (context, settings, child) {
            return Column(
              verticalDirection: VerticalDirection.up,
              children: [
                FloatingActionButton(
                  tooltip: 'Add measurement',
                  autofocus: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      _buildTransition(const AddMeasurementPage(), settings.animationSpeed),
                    );
                  },
                  child: const Icon(Icons.add,),
                ),
                const SizedBox(
                  height: 10,
                ),
                Ink(
                  decoration: ShapeDecoration(shape: const CircleBorder(), color: Theme.of(context).unselectedWidgetColor),
                  child: IconButton(
                    tooltip: 'Statistics',
                    iconSize: settings.iconSize,
                    icon: const Icon(Icons.insights, color: Colors.black),
                    onPressed: () {
                      Navigator.push(context, _buildTransition(const StatisticsPage(), settings.animationSpeed));
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Ink(
                  decoration: ShapeDecoration(shape: const CircleBorder(), color: Theme.of(context).unselectedWidgetColor),
                  child: IconButton(
                    tooltip: 'Settings',
                    iconSize: settings.iconSize,
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                      Navigator.push(context, _buildTransition(const SettingsPage(), settings.animationSpeed));
                    },
                  ),
                ),
              ],
            );
          });
        })
    );
  }
}

PageRoute _buildTransition(Widget page, int duration) {
  return TimedMaterialPageRouter(duration: Duration(milliseconds: duration), builder: (context) => page);
}

class TimedMaterialPageRouter extends MaterialPageRoute {
  Duration _duration = Duration.zero;

  TimedMaterialPageRouter({required WidgetBuilder builder, required Duration duration}) : super(builder: builder) {
    _duration = duration;
  }

  @override
  Duration get transitionDuration => _duration;
}
