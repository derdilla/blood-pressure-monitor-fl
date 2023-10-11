
import 'package:blood_pressure_app/components/blood_pressure_builder.dart';
import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';


class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statistics),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Consumer<Settings>(builder: (context, settings, child) {
          return BloodPressureBuilder(
            rangeType: IntervallStoreManagerLocation.statsPage,
            onData: (context, data) {
              final analyzer = BloodPressureAnalyser(data.toList());
              return Column(
                children: [
                  Statistic(
                      key: const Key('measurementCount'),
                      caption: Text(AppLocalizations.of(context)!.measurementCount), child: displayInt(analyzer.count)),
                  // special measurements
                  StatisticsRow(
                    caption1: Text(
                      AppLocalizations.of(context)!.avgOf(AppLocalizations.of(context)!.sysLong),
                      style: TextStyle(color: settings.sysColor, fontWeight: FontWeight.w700),
                    ),
                    child1: displayInt(analyzer.avgSys),
                    caption2: Text(
                      AppLocalizations.of(context)!.avgOf(AppLocalizations.of(context)!.diaLong),
                      style: TextStyle(color: settings.diaColor, fontWeight: FontWeight.w700),
                    ),
                    child2: displayInt(analyzer.avgDia),
                    caption3: Text(
                      AppLocalizations.of(context)!.avgOf(AppLocalizations.of(context)!.pulLong),
                      style: TextStyle(color: settings.pulColor, fontWeight: FontWeight.w700),
                    ),
                    child3: displayInt(analyzer.avgPul),
                  ),
                  Statistic(
                      caption: Text(AppLocalizations.of(context)!.measurementsPerDay),
                      child: displayInt(analyzer.measurementsPerDay)),
                  StatisticsRow(
                    caption1: Text(
                      AppLocalizations.of(context)!.minOf(AppLocalizations.of(context)!.sysLong),
                      style: TextStyle(color: settings.sysColor, fontWeight: FontWeight.w700),
                    ),
                    child1: displayInt(analyzer.minSys),
                    caption2: Text(
                      AppLocalizations.of(context)!.minOf(AppLocalizations.of(context)!.diaLong),
                      style: TextStyle(color: settings.diaColor, fontWeight: FontWeight.w700),
                    ),
                    child2: displayInt(analyzer.minDia),
                    caption3: Text(
                      AppLocalizations.of(context)!.minOf(AppLocalizations.of(context)!.pulLong),
                      style: TextStyle(color: settings.pulColor, fontWeight: FontWeight.w700),
                    ),
                    child3: displayInt(analyzer.minPul),
                  ),
                  StatisticsRow(
                    caption2: Text(
                      AppLocalizations.of(context)!.maxOf(AppLocalizations.of(context)!.diaLong),
                      style: TextStyle(color: settings.diaColor, fontWeight: FontWeight.w700),
                    ),
                    child2: displayInt(analyzer.maxDia),
                    caption1: Text(
                      AppLocalizations.of(context)!.maxOf(AppLocalizations.of(context)!.sysLong),
                      style: TextStyle(color: settings.sysColor, fontWeight: FontWeight.w700),
                    ),
                    child1: displayInt(analyzer.maxSys),
                    caption3: Text(
                      AppLocalizations.of(context)!.maxOf(AppLocalizations.of(context)!.pulLong),
                      style: TextStyle(color: settings.pulColor, fontWeight: FontWeight.w700),
                    ),
                    child3: displayInt(analyzer.maxPul),
                  ),
                  // Time-Resolved Metrics
                  Statistic(
                    caption: Text(AppLocalizations.of(context)!.timeResolvedMetrics),
                    child: () {
                      final data = analyzer.allAvgsRelativeToDaytime;
                      const opacity = 0.5;
                      return SizedBox(
                        width: 500,
                        height: 500,
                        child: RadarChart(
                          RadarChartData(
                            radarShape: RadarShape.circle,
                            radarBorderData: const BorderSide(color: Colors.transparent),
                            gridBorderData: BorderSide(color: Theme.of(context).dividerColor, width: 2),
                            tickBorderData: BorderSide(color: Theme.of(context).dividerColor, width: 2),
                            ticksTextStyle: const TextStyle(color: Colors.transparent),
                            tickCount: 5,
                            titleTextStyle: const TextStyle(fontSize: 25),
                            getTitle: (pos, value) {
                              if (pos % 2 == 0) {
                                return RadarChartTitle(text: '$pos', positionPercentageOffset: 0.05);
                              }
                              return const RadarChartTitle(text: '');
                            },
                            dataSets: [
                              RadarDataSet(
                                  dataEntries: intListToRadarEntry(data[0]),
                                  borderColor: settings.diaColor,
                                  fillColor: settings.diaColor.withOpacity(opacity),
                                  entryRadius: 0,
                                  borderWidth: settings.graphLineThickness),
                              RadarDataSet(
                                  dataEntries: intListToRadarEntry(data[1]),
                                  borderColor: settings.sysColor,
                                  fillColor: settings.sysColor.withOpacity(opacity),
                                  entryRadius: 0,
                                  borderWidth: settings.graphLineThickness),
                              RadarDataSet(
                                  dataEntries: intListToRadarEntry(data[2]),
                                  borderColor: settings.pulColor,
                                  fillColor: settings.pulColor.withOpacity(opacity),
                                  entryRadius: 0,
                                  borderWidth: settings.graphLineThickness),
                            ],
                          ),
                        ),
                      );
                    }(),
                  ),
                ],
              );
            }
          );
        }
      )),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(top: 15, bottom: 5),
        child: const IntervalPicker(type: IntervallStoreManagerLocation.statsPage,),
      )
    );
  }

  List<RadarEntry> intListToRadarEntry(List<int> data) {
    var res = <RadarEntry>[];
    for (var v in data) {
      res.add(RadarEntry(value: v.toDouble()));
    }
    return res;
  }
}

class Statistic extends StatelessWidget {
  final Widget caption;
  final Widget child;
  /// Reduces the padding at the sites to allow packing [Statistic] widgets tighter together.
  ///
  /// TODO: should not depend on property and padding should be added outside of Statistic
  final bool smallEdges;

  const Statistic({super.key, required this.caption, required this.child, this.smallEdges = false});

  @override
  Widget build(BuildContext context) {
    const double top = 20;
    double sides = 20;
    double padding = 20;
    if (smallEdges) {
      sides = 0;
      padding = 10;
    }
    return Container(
      margin: EdgeInsets.only(left: sides, right: sides, top: top),
      constraints: const BoxConstraints(minHeight: 50, minWidth: 110),
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white38),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 12,
            child: DefaultTextStyle(
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white38),
                child: caption),
          ),
          Container(
            padding: EdgeInsets.only(left: padding, right: padding, bottom: padding, top: padding + 5),
            child: Align(
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.displaySmall!,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: child
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatisticsRow extends StatelessWidget {
  final Widget caption1;
  final Widget caption2;
  final Widget caption3;
  final Widget child1;
  final Widget child2;
  final Widget child3;

  const StatisticsRow(
      {super.key,
      required this.caption1,
      required this.caption2,
      required this.caption3,
      required this.child1,
      required this.child2,
      required this.child3});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Statistic(
            smallEdges: true,
            caption: caption1,
            child: child1,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Statistic(
            smallEdges: true,
            caption: caption2,
            child: child2,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Statistic(
            smallEdges: true,
            caption: caption3,
            child: child3,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }
}

Widget displayInt(int value) {
  if (value < 0) {
    return const Text('-');
  }
  return Text(value.toString());
}
