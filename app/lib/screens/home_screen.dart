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
import 'package:provider/provider.dart';

/// 0 when add entry dialoge has not been shown, 1 when dialoge is scheduled, 2 when dialoge was launched.
int _appStart = 0;

/// Central screen of the app with graph and measurement list that is the center
/// of navigation.
class AppHome extends StatelessWidget {
  /// Create a home screen.
  const AppHome({super.key});

  Widget _buildValueGraph(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8, top: 16),
    child: SizedBox(
      height: 240.0,
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
  );

  Widget _buildMeasurementList(BuildContext context) => FullEntryBuilder(
    rangeType: IntervalStoreManagerLocation.mainPage,
    onEntries: (context, entries) => Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: (context.select<Settings, bool>((s) => s.compactList))
        ? CompactMeasurementList(data: entries)
        : MeasurementList(entries: entries),
    ),
  );

  @override
  Widget build(BuildContext context) => OrientationBuilder(
    builder: (BuildContext context, Orientation orientation) {
      // direct use of settings possible as no listening is required
      if (_appStart == 0) {
        if (Provider.of<Settings>(context, listen: false).startWithAddMeasurementPage) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.createEntry();
              _appStart++;
            } else {
              _appStart--;
            }

          });
        }
        _appStart++;
      }

      if (orientation == Orientation.landscape) return _buildValueGraph(context);
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildValueGraph(context),),
              const SliverToBoxAdapter(child: IntervalPicker(type: IntervalStoreManagerLocation.mainPage)),
              if (!(context.select<Settings, bool>((s) => s.weightInput)))
                SliverFillRemaining(child: _buildMeasurementList(context)),

              if ((context.select<Settings, bool>((s) => s.weightInput)))
                const SliverToBoxAdapter(child: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.monitor_heart)),
                    Tab(icon: Icon(Icons.scale)),
                  ],
                )),
              if ((context.select<Settings, bool>((s) => s.weightInput)))
                SliverFillRemaining(
                  child: TabBarView(
                      children: [
                        _buildMeasurementList(context),
                        Text('data2'), // TODO
                      ]
                  ),
                )
            ],
          ),
          floatingActionButton: const NavigationActionButtons(),
        ),
      );
    },
  );
}
