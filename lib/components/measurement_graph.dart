import 'dart:math';

import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  int _reloadsLeft = 30;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        child: Consumer<Settings>(
          builder: (context, settings, child) {
            return Consumer<BloodPressureModel>(builder: (context, model, child) {
              var end = settings.displayDataEnd;
              return ConsistentFutureBuilder<UnmodifiableListView<BloodPressureRecord>>(
                  future: (settings.graphStepSize == TimeStep.lifetime) ? model.all
                      : model.getInTimeRange(settings.displayDataStart, end),
                  onData: (context, fetchedData) {
                    List<BloodPressureRecord> data = fetchedData.toList();
                    data.sort((a, b) => a.creationTime.compareTo(b.creationTime));

                    // calculate lines for graph
                    List<FlSpot> pulSpots = [], diaSpots = [], sysSpots = [];
                    int maxValue = 0;
                    for (var e in data) {
                      final x = e.creationTime.millisecondsSinceEpoch.toDouble();
                      if (e.diastolic != null) {
                        diaSpots.add(FlSpot(x, e.diastolic!.toDouble()));
                        maxValue = max(maxValue, e.diastolic!);
                      }
                      if (e.systolic != null) {
                        sysSpots.add(FlSpot(x, e.systolic!.toDouble()));
                        maxValue = max(maxValue, e.systolic!);
                      }
                      if (e.pulse != null) {
                        pulSpots.add(FlSpot(x, e.pulse!.toDouble()));
                        maxValue = max(maxValue, e.pulse!);
                      }
                    }

                    if (diaSpots.length < 2 && sysSpots.length < 2 && pulSpots.length < 2) {
                      return Text(AppLocalizations.of(context)!.errNotEnoughDataToGraph);
                    }


                    return TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200), // interacts with LineChart duration property
                      tween: Tween<double>(begin: 0, end: settings.graphLineThickness),
                      builder: (context, animatedThickness, child) {
                        return LineChart(
                          duration: const Duration(milliseconds: 200),
                          LineChartData(
                              minY: settings.validateInputs ? 30 : 0,
                              maxY: maxValue + 5,
                              titlesData: _buildFlTitlesData(settings),
                              lineTouchData: const LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(tooltipMargin: -200, tooltipRoundedRadius: 20)
                              ),
                              lineBarsData: [
                                _buildBarData(animatedThickness, sysSpots, settings.sysColor, true, settings.sysWarn.toDouble()),
                                _buildBarData(animatedThickness, diaSpots, settings.diaColor, true, settings.diaWarn.toDouble()),
                                _buildBarData(animatedThickness, pulSpots, settings.pulColor, false),
                                if (settings.drawRegressionLines)
                                  _buildRegressionLine(sysSpots),
                                if (settings.drawRegressionLines)
                                  _buildRegressionLine(diaSpots),
                                if (settings.drawRegressionLines)
                                  _buildRegressionLine(pulSpots),
                              ]
                          ),
                        );
                      },
                    );
                  }
              );
            });
          },
        )
    );
  }

  FlTitlesData _buildFlTitlesData(Settings settings) {
    const noTitels = AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: false));
    return FlTitlesData(
      topTitles: noTitels,
      rightTitles: noTitels,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _lineChartTitleIntervall,
          getTitlesWidget: (double pos, TitleMeta meta) {
            // calculate new intervall
            // as graphWidth can technically be as low as one max is needed here to avoid freezes
            double graphWidth = meta.max - meta.min;
            if ((max(graphWidth - 2,1) / settings.graphTitlesCount) != _lineChartTitleIntervall && (_reloadsLeft > 0)) {
              // simple hack needed to change the state during build https://stackoverflow.com/a/63607696/21489239
              Future.delayed(Duration.zero, () async {
                setState(() {
                  _reloadsLeft--;
                  _lineChartTitleIntervall = max(graphWidth - 2,1) / settings.graphTitlesCount;
                });
              });
            }

            // don't show fixed titles, as they are replaced by long dates below
            if (meta.axisPosition <= 1 || pos >= meta.max) {
              return const SizedBox.shrink();
            }

            // format of titles
            late final DateFormat formatter;
            switch (settings.graphStepSize) {
              case TimeStep.day:
                formatter = DateFormat('H:m');
                break;
              case TimeStep.month:
              case TimeStep.last7Days:
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
                break;
              case TimeStep.last30Days:
              case TimeStep.custom:
                formatter = DateFormat.MMMd();
            }
            return Text(formatter
                .format(DateTime.fromMillisecondsSinceEpoch(pos.toInt())));
          }
        ),
      ),
    );
  }

  LineChartBarData _buildBarData(double lineThickness, List<FlSpot> spots, Color color, bool hasAreaData, [double? areaDataCutOff]) {
    return LineChartBarData(
        spots: spots,
        color: color,
        barWidth: lineThickness,
        dotData: const FlDotData(
          show: false,
        ),
          belowBarData: BarAreaData(
              show: hasAreaData,
              color: Colors.red.shade400.withAlpha(100),
              cutOffY: areaDataCutOff ?? 0,
              applyCutOffY: true)
    );
  }

  // Real world use is limited
  LineChartBarData _buildRegressionLine(List<FlSpot> data) {
    final d = data.length * (data.sum((e) => pow(e.x, 2))) - pow(data.sum((e) => e.x), 2);
    final gradient = (1/d) * (data.length * data.sum((e) => e.x * e.y) - data.sum((e) => e.x) * data.sum((e) => e.y));
    final yIntercept = (1/d) * (data.sum((e) => pow(e.x,2)) * data.sum((e) => e.y) -
                                data.sum((e) => (e.x * e.y)) * data.sum((e) => e.x));

    double y(x) => x * gradient + yIntercept;
    final start = data.map<double>((e) => e.x).min;
    final end = data.map<double>((e) => e.x).max;

    return LineChartBarData(
      color: Colors.grey,
      spots: [
        FlSpot(start, y(start)),
        FlSpot(end, y(end))
      ],
      barWidth: 2,
      dotData: const FlDotData(
        show: false,
      ),
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
        padding: const EdgeInsets.only(right: 16, left: 6, top: 22),
        child: Column(
          children: [
            _LineChart(height: height - 100),
            const IntervalPicker()
          ],
        ),
      ),
    );
  }
}

extension Sum<T> on List<T> {
  double sum(num Function(T value) f) {
    return fold<double>(0, (prev, e) => prev + f(e).toDouble());
  }
}

