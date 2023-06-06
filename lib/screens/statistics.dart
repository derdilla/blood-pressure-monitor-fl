import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(child: Consumer<BloodPressureModel>(
        builder: (context, model, child) {
          return Consumer<Settings>(builder: (context, settings, child) {
            return Column(
              children: [
                Statistic(caption: const Text('Measurement count'), child: futureInt(model.count)),
                // special measurements
                StatisticsRow(
                  caption1: Text(
                    'Systolic avg.',
                    style: TextStyle(color: settings.sysColor, fontWeight: FontWeight.w700),
                  ),
                  child1: futureInt(model.avgSys),
                  caption2: Text(
                    'Diastolic avg.',
                    style: TextStyle(color: settings.diaColor, fontWeight: FontWeight.w700),
                  ),
                  child2: futureInt(model.avgDia),
                  caption3: Text(
                    'Pulse avg.',
                    style: TextStyle(color: settings.pulColor, fontWeight: FontWeight.w700),
                  ),
                  child3: futureInt(model.avgPul),
                ),
                Statistic(
                    caption: const Text('Measurements per Day'),
                    child: futureInt(BloodPressureAnalyser(model).measurementsPerDay)),
                StatisticsRow(
                  caption2: Text(
                    'Diastolic min.',
                    style: TextStyle(color: settings.diaColor, fontWeight: FontWeight.w700),
                  ),
                  child2: futureInt(model.minDia),
                  caption1: Text(
                    'Systolic min.',
                    style: TextStyle(color: settings.sysColor, fontWeight: FontWeight.w700),
                  ),
                  child1: futureInt(model.minSys),
                  caption3: Text(
                    'Pulse min.',
                    style: TextStyle(color: settings.pulColor, fontWeight: FontWeight.w700),
                  ),
                  child3: futureInt(model.minPul),
                ),
                StatisticsRow(
                  caption2: Text(
                    'Diastolic max.',
                    style: TextStyle(color: settings.diaColor, fontWeight: FontWeight.w700),
                  ),
                  child2: futureInt(model.maxDia),
                  caption1: Text(
                    'Systolic max.',
                    style: TextStyle(color: settings.sysColor, fontWeight: FontWeight.w700),
                  ),
                  child1: futureInt(model.maxSys),
                  caption3: Text(
                    'Pulse max.',
                    style: TextStyle(color: settings.pulColor, fontWeight: FontWeight.w700),
                  ),
                  child3: futureInt(model.maxPul),
                ),
                // Time-Resolved Metrics
                Statistic(
                  caption: const Text('Time-Resolved Metrics'),
                  child: FutureBuilder<List<List<int>>>(
                      future: BloodPressureAnalyser(model).allAvgsRelativeToDaytime,
                      builder: (BuildContext context, AsyncSnapshot<List<List<int>>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return const Text('not started');
                          case ConnectionState.waiting:
                            return const Text('loading...');
                          default:
                            if (snapshot.hasError) {
                              return Text('ERROR: ${snapshot.error}');
                            }
                            assert(snapshot.hasData);
                            assert(snapshot.data != null);
                            final daytimeAvgs = snapshot.data ?? [];
                            const opacity = 0.5;
                            return SizedBox(
                              width: 500,
                              height: 270,
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
                                        dataEntries: intListToRadarEntry(daytimeAvgs[0]),
                                        borderColor: settings.diaColor,
                                        fillColor: settings.diaColor.withOpacity(opacity),
                                        entryRadius: 0,
                                        borderWidth: settings.graphLineThickness),
                                    RadarDataSet(
                                        dataEntries: intListToRadarEntry(daytimeAvgs[1]),
                                        borderColor: settings.sysColor,
                                        fillColor: settings.sysColor.withOpacity(opacity),
                                        entryRadius: 0,
                                        borderWidth: settings.graphLineThickness),
                                    RadarDataSet(
                                        dataEntries: intListToRadarEntry(daytimeAvgs[2]),
                                        borderColor: settings.pulColor,
                                        fillColor: settings.pulColor.withOpacity(opacity),
                                        entryRadius: 0,
                                        borderWidth: settings.graphLineThickness),
                                  ],
                                ),
                              ),
                            );
                        }
                      }),
                ),
              ],
            );
          });
        },
      )),
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
  final bool smallEdges;

  const Statistic({super.key, required this.caption, required this.child, this.smallEdges = false});

  @override
  Widget build(BuildContext context) {
    double sides = 20;
    double top = 20;
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
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 40),
                child: child,
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

Widget futureInt(Future<int> value) {
  return FutureBuilder<int>(
      future: value,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Text('not started');
          case ConnectionState.waiting:
            return const Text('loading...');
          default:
            if (snapshot.hasError) {
              return Text('ERROR: ${snapshot.error}');
            }
            assert(snapshot.hasData);
            if ((snapshot.data ?? -1) < 0) {
              return const Text('-');
            }
            return Text(snapshot.data?.toString() ?? 'error');
        }
      });
}
