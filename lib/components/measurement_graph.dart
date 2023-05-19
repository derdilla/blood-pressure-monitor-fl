import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:blood_pressure_app/model/settings_store.dart';

class _LineChart extends StatelessWidget {
  final double height;
  const _LineChart({super.key, this.height = 200});
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: height,
              child: Consumer<Settings>(
                builder: (context, settings, child) {
                  return Consumer<BloodPressureModel>(
                    builder: (context, model, child) {
                      var end = settings.displayDataEnd;
                      if (settings.graphStepSize == TimeStep.lifetime) end = DateTime.now();
                      final dataFuture = model.getInTimeRange(settings.displayDataStart, end);

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
                                } else if (snapshot.hasData && snapshot.data!.length < 2) {
                                  res = const Text('not enough data to draw graph');
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
                                              ),
                                          ),
                                          lineTouchData: LineTouchData(
                                            touchTooltipData: LineTouchTooltipData(
                                              tooltipMargin: -200,
                                              tooltipRoundedRadius: 20
                                            )
                                          ),
                                          lineBarsData: [
                                            // high blood pressure marking acordning to https://www.texasheart.org/heart-health/heart-information-center/topics/high-blood-pressure-hypertension/
                                            LineChartBarData(
                                              spots: pulseSpots,
                                              dotData: FlDotData(
                                                show: false,
                                              ),
                                              color: settings.pulColor,
                                              barWidth: 4,
                                            ),
                                            LineChartBarData(
                                                spots: diastolicSpots,
                                                color: settings.diaColor,
                                                barWidth: 4,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                    show: true,
                                                    color: Colors.red.shade400.withAlpha(100),
                                                    cutOffY: 80,
                                                    applyCutOffY: true
                                                )
                                            ),
                                            LineChartBarData(
                                                spots: systolicSpots,
                                                color: settings.sysColor,
                                                barWidth: 4,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
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
  final double height;
  const MeasurementGraph({super.key, this.height = 290});

  void moveGraphWithStep(int directionalStep, Settings settings) {
    final oldStart = settings.displayDataStart;
    final oldEnd = settings.displayDataEnd;
    switch (settings.graphStepSize) {
      case TimeStep.day:
        settings.displayDataStart = oldStart.copyWith(day: oldStart.day + directionalStep);
        settings.displayDataEnd = oldEnd.copyWith(day: oldEnd.day + directionalStep);
        break;
      case TimeStep.month:
        settings.displayDataStart = oldStart.copyWith(month: oldStart.month + directionalStep);
        settings.displayDataEnd = oldEnd.copyWith(month: oldEnd.month + directionalStep);
        break;
      case TimeStep.year:
        settings.displayDataStart = oldStart.copyWith(year: oldStart.year + directionalStep);
        settings.displayDataEnd = oldEnd.copyWith(year: oldEnd.year + directionalStep);
        break;
      case TimeStep.lifetime:
        settings.displayDataStart = DateTime.fromMillisecondsSinceEpoch(0);
        settings.displayDataEnd = oldStart;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 6, top: 2),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            _LineChart(height: height-100),
            const SizedBox(height: 7,),
            Consumer<Settings>(
                builder: (context, settings, child) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 30,
                        child: MaterialButton(
                          onPressed: () {
                            moveGraphWithStep(-1, settings);
                          },
                          child: const Icon(
                            Icons.chevron_left,
                            size: 48,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 40,
                          child: DropdownButton<int>(
                            value: settings.graphStepSize,
                            isExpanded: true,
                            onChanged: (int? value) {
                              if (value != null) {
                                settings.graphStepSize = value;
                                final now = DateTime.now();
                                switch (settings.graphStepSize) {
                                  case TimeStep.day:
                                    settings.displayDataStart = DateTime(now.year, now.month, now.day);
                                    settings.displayDataEnd = settings.displayDataStart.copyWith(day: now.day + 1);
                                    break;
                                  case TimeStep.month:
                                    settings.displayDataStart = DateTime(now.year, now.month);
                                    settings.displayDataEnd = settings.displayDataStart.copyWith(month: now.month + 1);
                                    break;
                                  case TimeStep.year:
                                    settings.displayDataStart = DateTime(now.year);
                                    settings.displayDataEnd = settings.displayDataStart.copyWith(year: now.year + 1);
                                    break;
                                  case TimeStep.lifetime:
                                    settings.displayDataStart = DateTime.fromMillisecondsSinceEpoch(0);
                                    settings.displayDataEnd = now;
                                    break;
                                }
                              }
                            },
                            items: TimeStep.options.map<DropdownMenuItem<int>>((v) {
                              return DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                      TimeStep.getName(v)
                                  )
                              );
                            }).toList(),
                          ),
                      ),


                      Expanded(
                        flex: 30,
                        child: MaterialButton(
                          onPressed: () {
                            moveGraphWithStep(1, settings);
                          },
                          child: const Icon(
                            Icons.chevron_right,
                            size: 48,
                          ),
                        ),
                      ),
                    ]
                  );
                }
            )
          ],
        ),
      ),
    );
  }
}