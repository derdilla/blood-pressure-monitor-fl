import 'package:blood_pressure_app/data_util/entry_context.dart';
import 'package:blood_pressure_app/data_util/full_entry_builder.dart';
import 'package:blood_pressure_app/data_util/interval_picker.dart';
import 'package:blood_pressure_app/features/measurement_list/compact_measurement_list.dart';
import 'package:blood_pressure_app/features/measurement_list/measurement_list.dart';
import 'package:blood_pressure_app/features/statistics/value_graph.dart';
import 'package:blood_pressure_app/home/navigation_action_buttons.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
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

  Widget _buildValueGraph(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8, left: 2, top: 16),
    child: Column(
      children: [
        SizedBox(
          height: 240,
          width: MediaQuery.of(context).size.width,
          child: FullEntryBuilder(
            rangeType: IntervalStoreManagerLocation.mainPage,
            onData: (context, records, intakes, notes) => BloodPressureValueGraph(
              records: records,
              colors: notes,
              intakes: intakes,
            ),
          ),
        ),
        const IntervalPicker(type: IntervalStoreManagerLocation.mainPage),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // direct use of settings possible as no listening is required
    if (_appStart) {
      if (Provider.of<Settings>(context, listen: false).startWithAddMeasurementPage) {
        SchedulerBinding.instance.addPostFrameCallback((_) => context.createEntry());
      }
    }
    _appStart = false;

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
        if (orientation == Orientation.landscape) return _buildValueGraph(context);
        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Consumer<IntervalStoreManager>(builder: (context, intervalls, child) =>
              Column(children: [
                _buildValueGraph(context),
                Expanded(
                  child: FullEntryBuilder(
                    rangeType: IntervalStoreManagerLocation.mainPage,
                    onEntries: (context, entries) => (context.select<Settings, bool>((s) => s.compactList))
                      ? CompactMeasurementList(data: entries)
                      : MeasurementList(entries: entries),
                  ),
                ),
              ],),),
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
          return const NavigationActionButtons();
        },
      ),
    );
  }
}

// TODO: consider removing duration override that only occurs in one on home.
void _buildTransition(BuildContext context, Widget page, int duration) {
  Navigator.push(context,
    _TimedMaterialPageRouter(
      transitionDuration: Duration(milliseconds: duration),
      builder: (context) => page,
    ),
  );
}

class _TimedMaterialPageRouter extends MaterialPageRoute {
  _TimedMaterialPageRouter({
    required super.builder,
    required this.transitionDuration,});

  @override
  final Duration transitionDuration;
}