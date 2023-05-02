import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:blood_pressure_app/model/settings.dart';

class _LineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const pulseColor = Colors.red;
    const diaColor = Colors.green;
    const sysColor = Colors.teal;

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
              height: 200,
              child: Consumer<Settings>(
                builder: (context, settings, child) {
                  return Consumer<BloodPressureModel>(
                    builder: (context, model, child) {
                      late final Future<UnmodifiableListView<BloodPressureRecord>> dataFuture;
                      DateTime now = DateTime.now();
                      switch (settings.graphStepSize) {
                        case TimeStep.day:
                          dataFuture = model.getInTimeRange(DateTime(now.year, now.month, now.day), now);
                          break;
                        case TimeStep.month:
                          dataFuture = model.getInTimeRange(DateTime(now.year, now.month), now);
                          break;
                        case TimeStep.year:
                          dataFuture = model.getInTimeRange(DateTime(now.year), now);
                          break;
                        case TimeStep.lifetime:
                          dataFuture = model.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), now);
                          break;
                      }

                      return FutureBuilder<UnmodifiableListView<BloodPressureRecord>>(
                          future: dataFuture,
                          builder: (BuildContext context, AsyncSnapshot<UnmodifiableListView<BloodPressureRecord>> snapshot) {
                            Widget res;
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                res = const Text('not started');
                                break;
                              case ConnectionState.waiting:
                                res = const Text('loading...');
                                break;
                              default:
                                if (snapshot.hasError) {
                                  res = Text('ERROR: ${snapshot.error}');
                                } else {
                                  assert(snapshot.hasData);
                                  final data = snapshot.data ?? [];

                                  List<FlSpot> pulseSpots = [];
                                  List<FlSpot> diastolicSpots = [];
                                  List<FlSpot> systolicSpots = [];
                                  int pulMax = 0;
                                  int diaMax = 0;
                                  int sysMax = 0;
                                  for (var element in data) {
                                    final x = element.creationTime.millisecondsSinceEpoch.toDouble();
                                    diastolicSpots.add(FlSpot(x, element.diastolic.toDouble()));
                                    systolicSpots.add(FlSpot(x, element.systolic.toDouble()));
                                    pulseSpots.add(FlSpot(x, element.pulse.toDouble()));
                                    pulMax = max(pulMax, element.pulse);
                                    diaMax = max(diaMax, element.diastolic);
                                    sysMax = max(sysMax, element.systolic);
                                  }


                                  final noTitels = AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: false));
                                  res = LineChart(
                                      swapAnimationDuration: const Duration(milliseconds: 250),
                                      LineChartData(
                                          minY: 30,
                                          maxY: max(pulMax.toDouble(), max(diaMax.toDouble(), sysMax.toDouble())) + 5,
                                          titlesData: FlTitlesData(topTitles: noTitels, rightTitles:  noTitels,
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (double pos, TitleMeta meta) {
                                                      late final DateFormat formater;
                                                      switch (settings.graphStepSize) {
                                                        case TimeStep.day:
                                                          formater = DateFormat('H:mm');
                                                          break;
                                                        case TimeStep.month:
                                                          formater = DateFormat('d');
                                                          break;
                                                        case TimeStep.year:
                                                          formater = DateFormat('MMM');
                                                          break;
                                                        case TimeStep.lifetime:
                                                          formater = DateFormat('yyyy');
                                                      }
                                                      return Text(
                                                          formater.format(DateTime.fromMillisecondsSinceEpoch(pos.toInt()))
                                                      );
                                                    }
                                                ),
                                              )
                                          ),
                                          lineBarsData: [
                                            // high blood pressure marking acordning to https://www.texasheart.org/heart-health/heart-information-center/topics/high-blood-pressure-hypertension/
                                            LineChartBarData(
                                                spots: pulseSpots,
                                                color: pulseColor,
                                                barWidth: 4,
                                                isCurved: true,
                                                preventCurveOverShooting: true
                                            ),
                                            LineChartBarData(
                                                spots: diastolicSpots,
                                                color: diaColor,
                                                barWidth: 4,
                                                isCurved: true,
                                                preventCurveOverShooting: true,
                                                belowBarData: BarAreaData(
                                                    show: true,
                                                    color: Colors.red.shade400.withAlpha(100),
                                                    cutOffY: 80,
                                                    applyCutOffY: true
                                                )
                                            ),
                                            LineChartBarData(
                                                spots: systolicSpots,
                                                color: sysColor,
                                                barWidth: 4,
                                                isCurved: true,
                                                preventCurveOverShooting: true,
                                                belowBarData: BarAreaData(
                                                    show: true,
                                                    color: Colors.red.shade400.withAlpha(100),
                                                    cutOffY: 130,
                                                    applyCutOffY: true
                                                )
                                            )
                                          ]
                                      )
                                  );
                                }
                            }
                            return res;
                          }
                      );
                    }
                  );
                },
              )
          ),
        ),
      ],
    );
  }
}

class MeasurementGraph extends StatelessWidget {
  const MeasurementGraph({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      height: 1000,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 6, top: 2),
        child: Column(
          children: [
            _LineChart(),
            Consumer<Settings>(
                builder: (context, settings, child) {
                  return Container(
                    color: Colors.white,
                    child: DropdownButton<int>(
                      value: settings.graphStepSize,
                      onChanged: (int? value) {
                        if (value != null) {
                          settings.graphStepSize = value;
                        }
                      },
                      dropdownColor: Colors.white,
                      items: TimeStep.options.map<DropdownMenuItem<int>>((v) {
                        return DropdownMenuItem(
                            value: v,
                            child: Text(
                                TimeStep.getName(v)
                            )
                        );
                      }).toList(),
                    ),
                  );
                }
            )
          ],
        ),
      ),
    );
  }
}