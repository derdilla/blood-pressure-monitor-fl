import 'package:blood_pressure_app/components/dialoges/add_measurement.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/blood_pressure_builder.dart';
import 'package:blood_pressure_app/screens/legacy_measurement_list.dart';
import 'package:blood_pressure_app/screens/measurement_graph.dart';
import 'package:blood_pressure_app/screens/settings_screen.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../components/measurement_list/measurement_list.dart';

/// Is true during the first [AppHome.build] before creating the widget.
bool _appStart = true;

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // direct use of settings possible as no listening is required
    if (_appStart) {
      if (Provider.of<Settings>(context, listen: false).startWithAddMeasurementPage) {
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          final future = showAddMeasurementDialoge(context, Provider.of<Settings>(context, listen: false));
          final model = Provider.of<BloodPressureModel>(context, listen: false);
          final measurement = await future;
          if (measurement == null) return;
          if (context.mounted) {
            model.addAndExport(context, measurement);
          } else {
            model.add(measurement);
          }
        });
      }
    }
    _appStart = false;

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return MeasurementGraph(
            height: MediaQuery.of(context).size.height,
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Consumer<Settings>(
              builder: (context, settings, child) {
                return Column(children: [
                  const MeasurementGraph(),
                  Expanded(
                    child: (settings.useLegacyList) ?
                      LegacyMeasurementsList(context) :
                      BloodPressureBuilder(
                        rangeType: IntervallStoreManagerLocation.mainPage,
                        onData: (context, records) => MeasurementList(
                          settings: settings,
                          records: records,
                        )
                      )
                  )
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
                      onPressed: () async {
                        final future = showAddMeasurementDialoge(context, settings);
                        final model = Provider.of<BloodPressureModel>(context, listen: false);
                        final measurement = await future;
                        if (measurement == null) return;
                        if (context.mounted) {
                          model.addAndExport(context, measurement);
                        } else {
                          model.add(measurement);
                        }
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
