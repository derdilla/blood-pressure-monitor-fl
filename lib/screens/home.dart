import 'package:blood_pressure_app/components/legacy_measurement_list.dart';
import 'package:blood_pressure_app/components/measurement_graph.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/add_measurement.dart';
import 'package:blood_pressure_app/screens/settings.dart';
import 'package:blood_pressure_app/screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../components/measurement_list/measurement_list.dart';

/// The only use of this variable is to avoid loading the AddMeasurementPage twice,
/// when startWithAddMeasurementPage is active
bool _appStart = true;

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
            child: Consumer<Settings>(
              builder: (context, settings, child) {
                return Column(children: [
                  const MeasurementGraph(),
                  if (!settings.useLegacyList)
                    const Expanded(
                        flex: 50,
                        child: MeasurementList()
                    ),
                  if(settings.useLegacyList)
                    Expanded(
                      flex: 50,
                      child: LegacyMeasurementsList(context)),
                ]);
              }
            ),
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
                SizedBox.square(
                  dimension: 75,
                  child: FittedBox(
                    child: FloatingActionButton(
                      heroTag: "floatingActionAdd",
                      tooltip: localizations.addMeasurement,
                      autofocus: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          _buildTransition(const AddMeasurementPage(), settings.animationSpeed),
                        );
                      },
                      child: const Icon(Icons.add,),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  heroTag: "floatingActionStatistics",
                  tooltip: localizations.statistics,
                  backgroundColor: const Color(0xFF6F6F6F),
                  onPressed: () {
                    Navigator.push(context, _buildTransition(const StatisticsPage(), settings.animationSpeed));
                  },
                  child: const Icon(Icons.insights, color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  heroTag: "floatingActionSettings",
                  tooltip: localizations.settings,
                  backgroundColor: const Color(0xFF6F6F6F),
                  child: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.push(context, _buildTransition(const SettingsPage(), settings.animationSpeed));
                  },
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
