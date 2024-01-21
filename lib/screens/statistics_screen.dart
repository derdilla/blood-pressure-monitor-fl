// TODO: test

import 'package:blood_pressure_app/components/statistics/blood_pressure_distribution.dart';
import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/elements/blood_pressure_builder.dart';
import 'package:blood_pressure_app/screens/elements/display_interval_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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
      body: Consumer<Settings>(
        builder: (context, settings, child) => BloodPressureBuilder(
          rangeType: IntervallStoreManagerLocation.statsPage,
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
                    settings: settings,
                  ),
                ),
                _buildSubTitle(localizations.timeResolvedMetrics),
                () {
                  final data = analyzer.allAvgsRelativeToDaytime;
                  const opacity = 0.5;
                  final helperLinesStyle = BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 2,
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: MediaQuery.of(context).size.width,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.circle,
                        gridBorderData: helperLinesStyle,
                        tickBorderData: helperLinesStyle,
                        ticksTextStyle: const TextStyle(
                          color: Colors.transparent,
                        ),
                        tickCount: 5,
                        titleTextStyle: const TextStyle(fontSize: 25),
                        getTitle: (pos, value) {
                          if (pos % 2 == 0) {
                            return RadarChartTitle(
                              text: '$pos',
                              positionPercentageOffset: 0.05,
                            );
                          }
                          return const RadarChartTitle(text: '');
                        },
                        dataSets: [
                          RadarDataSet(
                            dataEntries: _intListToRadarEntry(data[0]),
                            borderColor: settings.diaColor,
                            fillColor: settings.diaColor.withOpacity(opacity),
                            entryRadius: 0,
                            borderWidth: settings.graphLineThickness,
                          ),
                          RadarDataSet(
                            dataEntries: _intListToRadarEntry(data[1]),
                            borderColor: settings.sysColor,
                            fillColor: settings.sysColor.withOpacity(opacity),
                            entryRadius: 0,
                            borderWidth: settings.graphLineThickness,
                          ),
                          RadarDataSet(
                            dataEntries: _intListToRadarEntry(data[2]),
                            borderColor: settings.pulColor,
                            fillColor: settings.pulColor.withOpacity(opacity),
                            entryRadius: 0,
                            borderWidth: settings.graphLineThickness,
                          ),
                        ],
                      ),
                    ),
                  );
                }(),
              ],
            );
          },
        ),
            ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(top: 15, bottom: 5),
        child: const IntervalPicker(type: IntervallStoreManagerLocation.statsPage,),
      ),
    );
  }

  List<RadarEntry> _intListToRadarEntry(List<int> data) {
    final res = <RadarEntry>[];
    for (final v in data) {
      res.add(RadarEntry(value: v.toDouble()));
    }
    return res;
  }

  Widget _buildSubTitle(String text) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge!,
    ),
  );
}
