import 'dart:collection';
import 'dart:math';

import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class _LineChart extends StatefulWidget {
  final double height;

  const _LineChart({this.height = 200});

  @override
  State<_LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<_LineChart> {
  double _lineChartTitleIntervall = 100000000;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
              height: widget.height,
              child: Consumer<Settings>(
                builder: (context, settings, child) {
                  return Consumer<BloodPressureModel>(builder: (context, model, child) {
                    var end = settings.displayDataEnd;

                    return FutureBuilder<UnmodifiableListView<BloodPressureRecord>>(
                        future: (settings.graphStepSize == TimeStep.lifetime)
                            ? model.all
                            : model.getInTimeRange(settings.displayDataStart, end),
                        builder:
                            (BuildContext context, AsyncSnapshot<UnmodifiableListView<BloodPressureRecord>> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                              return const Text('not started');
                            case ConnectionState.waiting:
                              return const Text('loading...');
                            default:
                              if (snapshot.hasError) {
                                return Text('ERROR: ${snapshot.error}');
                              } else if (snapshot.hasData && snapshot.data!.length < 2) {
                                return const Text('not enough data to draw graph');
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

                                final noTitels =
                                    AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: false));
                                return LineChart(
                                    swapAnimationDuration: const Duration(milliseconds: 250),
                                    LineChartData(
                                        minY: settings.validateInputs ? 30 : 0,
                                        maxY: max(pulMax.toDouble(), max(diaMax.toDouble(), sysMax.toDouble())) + 5,
                                        titlesData: FlTitlesData(
                                          topTitles: noTitels,
                                          rightTitles: noTitels,
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: _lineChartTitleIntervall,
                                                getTitlesWidget: (double pos, TitleMeta meta) {
                                                  // calculate new intervall
                                                  double graphWidth = meta.max - meta.min;
                                                  assert(graphWidth > 0);
                                                  if (((graphWidth - 2) / settings.graphTitlesCount) !=
                                                      _lineChartTitleIntervall) {
                                                    // simple hack needed to change the state during build
                                                    // https://stackoverflow.com/a/63607696/21489239
                                                    Future.delayed(Duration.zero, () async {
                                                      setState(() {
                                                        _lineChartTitleIntervall =
                                                            (graphWidth - 2) / settings.graphTitlesCount;
                                                      });
                                                    });
                                                  }

                                                  // don't show fixed titles, as they are replaced by long dates below
                                                  if (meta.axisPosition <= 1 || pos >= meta.max) {
                                                    return const SizedBox.shrink();
                                                  }

                                                  late final DateFormat formatter;
                                                  switch (settings.graphStepSize) {
                                                    case TimeStep.day:
                                                      formatter = DateFormat('H:m');
                                                      break;
                                                    case TimeStep.month:
                                                      formatter = DateFormat('d');
                                                      break;
                                                    case TimeStep.week:
                                                      formatter = DateFormat('E');
                                                      break;
                                                    case TimeStep.year:
                                                      formatter = DateFormat('MMM');
                                                      break;
                                                    case TimeStep.lifetime:
                                                      formatter = DateFormat('yyyy');
                                                  }
                                                  return Text(formatter
                                                      .format(DateTime.fromMillisecondsSinceEpoch(pos.toInt())));
                                                }),
                                          ),
                                        ),
                                        lineTouchData: LineTouchData(
                                            touchTooltipData:
                                                LineTouchTooltipData(tooltipMargin: -200, tooltipRoundedRadius: 20)),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: pulseSpots,
                                            dotData: FlDotData(
                                              show: false,
                                            ),
                                            color: settings.pulColor,
                                            barWidth: settings.graphLineThickness,
                                          ),
                                          LineChartBarData(
                                              spots: diastolicSpots,
                                              color: settings.diaColor,
                                              barWidth: settings.graphLineThickness,
                                              dotData: FlDotData(
                                                show: false,
                                              ),
                                              belowBarData: BarAreaData(
                                                  show: true,
                                                  color: Colors.red.shade400.withAlpha(100),
                                                  cutOffY: settings.diaWarn,
                                                  applyCutOffY: true)),
                                          LineChartBarData(
                                              spots: systolicSpots,
                                              color: settings.sysColor,
                                              barWidth: settings.graphLineThickness,
                                              dotData: FlDotData(
                                                show: false,
                                              ),
                                              belowBarData: BarAreaData(
                                                  show: true,
                                                  color: Colors.red.shade400.withAlpha(100),
                                                  cutOffY: settings.sysWarn,
                                                  applyCutOffY: true))
                                        ]));
                              }
                          }
                        });
                  });
                },
              )),
        ),
      ],
    );
  }
}

class MeasurementGraph extends StatelessWidget {
  final double height;

  const MeasurementGraph({super.key, this.height = 290});

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
            const SizedBox(height: 2,),
            Consumer<Settings>(
                builder: (context, settings, child) {
                  final formatter = DateFormat(settings.dateFormatString);
                  return Row(
                    children: [
                      (settings.graphStepSize == TimeStep.lifetime) ?
                          const Text('-') :
                          Text(formatter.format(settings.displayDataStart)),
                      const Spacer(),
                      (settings.graphStepSize == TimeStep.lifetime) ?
                        const Text('now') :
                        Text(formatter.format(settings.displayDataEnd)),
                    ],
                  );
                }
            ),
            const SizedBox(height: 2,),
            const IntervalPicker()
          ],
        ),
      ),
    );
  }
}