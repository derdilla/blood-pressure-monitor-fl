import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/measurement_list/measurement_list.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/elements/blood_pressure_builder.dart';
import 'package:blood_pressure_app/screens/elements/legacy_measurement_list.dart';
import 'package:blood_pressure_app/screens/elements/measurement_graph.dart';
import 'package:blood_pressure_app/screens/settings_screen.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Is true during the first [AppHome.build] before creating the widget.
bool _appStart = true;

/// Central screen of the app with graph and measurement list that is the center
/// of navigation.
class AppHome extends StatelessWidget {
  /// Create a home screen.
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // direct use of settings possible as no listening is required
    if (_appStart) {
      if (Provider.of<Settings>(context, listen: false).startWithAddMeasurementPage) {
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          final model = Provider.of<BloodPressureModel>(context, listen: false);
          final intakes = Provider.of<IntakeHistory>(context, listen: false);
          final measurement = await showAddEntryDialoge(context, Provider.of<Settings>(context, listen: false));
          if (measurement == null) return;
          if (measurement.$1 != null) {
            if (context.mounted) {
              model.addAndExport(context, measurement.$1!);
            } else {
              model.add(measurement.$1!);
            }
          }
          if (measurement.$2 != null) {
            intakes.addIntake(measurement.$2!);
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
              child: Consumer<IntakeHistory>(builder: (context, intakeHistory, child) =>
                  Consumer<IntervallStoreManager>(builder: (context, intervalls, child) =>
                      Consumer<Settings>(builder: (context, settings, child) =>
                          Column(children: [
                            const MeasurementGraph(),
                            Expanded(
                              child: (settings.useLegacyList) ?
                              LegacyMeasurementsList(context) :
                              BloodPressureBuilder(
                                rangeType: IntervallStoreManagerLocation.mainPage,
                                onData: (context, records) => MeasurementList(
                                  settings: settings,
                                  records: records,
                                  intakes: intakeHistory.getIntakes(intervalls.mainPage.currentRange),
                                ),
                              ),
                            ),
                          ],),
                      ),),
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
          return Consumer<Settings>(builder: (context, settings, child) => Column(
            verticalDirection: VerticalDirection.up,
            children: [
              SizedBox.square(
                dimension: 75,
                child: FittedBox(
                  child: FloatingActionButton(
                    heroTag: 'floatingActionAdd',
                    tooltip: localizations.addMeasurement,
                    autofocus: true,
                    onPressed: () async {
                      final model = Provider.of<BloodPressureModel>(context, listen: false);
                      final intakes = Provider.of<IntakeHistory>(context, listen: false);
                      final measurement = await showAddEntryDialoge(context, Provider.of<Settings>(context, listen: false));
                      if (measurement == null) return;
                      if (measurement.$1 != null) {
                        if (context.mounted) {
                          model.addAndExport(context, measurement.$1!);
                        } else {
                          model.add(measurement.$1!);
                        }
                      }
                      if (measurement.$2 != null) {
                        intakes.addIntake(measurement.$2!);
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
                heroTag: 'floatingActionStatistics',
                tooltip: localizations.statistics,
                backgroundColor: const Color(0xFF6F6F6F),
                onPressed: () {
                  _buildTransition(context, const StatisticsScreen(), settings.animationSpeed);
                },
                child: const Icon(Icons.insights, color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                heroTag: 'floatingActionSettings',
                tooltip: localizations.settings,
                backgroundColor: const Color(0xFF6F6F6F),
                child: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  _buildTransition(context, const SettingsPage(), settings.animationSpeed);
                },
              ),
            ],
          ),);
        },),
    );
  }
}

// TODO: consider removing duration override that only occurs in one on home.
void _buildTransition(BuildContext context, Widget page, int duration) {
  Navigator.push(context,
    TimedMaterialPageRouter(
      transitionDuration: Duration(milliseconds: duration),
      builder: (context) => page,
    ),
  );
}

class TimedMaterialPageRouter extends MaterialPageRoute {
  TimedMaterialPageRouter({
    required super.builder,
    required this.transitionDuration,});

  @override
  final Duration transitionDuration;
}