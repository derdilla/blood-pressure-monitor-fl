import 'package:blood_pressure_app/data_util/interval_picker.dart';
import 'package:blood_pressure_app/data_util/repository_builder.dart';
import 'package:blood_pressure_app/features/statistics/blood_pressure_distribution.dart';
import 'package:blood_pressure_app/features/statistics/clock_bp_graph.dart';
import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';

/// A page that shows statistics about stored blood pressure values.
class StatisticsScreen extends StatefulWidget {
  /// Create a screen to various display statistics.
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.statistics),
      ),
      body: RepositoryBuilder<BloodPressureRecord, BloodPressureRepository>(
        rangeType: IntervalStoreManagerLocation.statsPage,
        onData: (context, data) {
          final analyzer = BloodPressureAnalyser(data.toList());
          return ListView(
            children: [
              _buildSubTitle(localizations.statistics,),
              ListTile(
                title: Text(localizations.measurementCount),
                trailing: Text(
                  data.length.toString(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                title: Text(localizations.measurementsPerDay),
                trailing: Text(
                  analyzer.measurementsPerDay?.toString() ?? '-',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              _buildSubTitle(localizations.valueDistribution,),
              Container(
                height: 260,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BloodPressureDistribution(
                  records: data,
                ),
              ),
              _buildSubTitle(localizations.timeResolvedMetrics),
              ClockBpGraph(measurements: data),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(top: 15, bottom: 5),
        child: const IntervalPicker(type: IntervalStoreManagerLocation.statsPage,),
      ),
    );
  }

  Widget _buildSubTitle(String text) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge!,
    ),
  );
}
