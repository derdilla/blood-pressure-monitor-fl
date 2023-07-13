import 'dart:collection';
import 'dart:math';

import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/display_interval_picker.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
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
                    return ConsistentFutureBuilder<UnmodifiableListView<BloodPressureRecord>>(
                      future: (settings.graphStepSize == TimeStep.lifetime)
                          ? model.all
                          : model.getInTimeRange(settings.displayDataStart, end),
                      onData: (context, fetchedData) {
                        List<BloodPressureRecord> data = fetchedData.toList();
                        data.sort((a, b) => a.creationTime.compareTo(b.creationTime));

                        List<FlSpot> pulSpots = [];
                        List<FlSpot> diaSpots = [];
                        List<FlSpot> sysSpots = [];
                        int pulMax = 0;
                        int diaMax = 0;
                        int sysMax = 0;
                        for (var e in data) {
                          final x = e.creationTime.millisecondsSinceEpoch.toDouble();
                          if (e.diastolic != null) {
                            diaSpots.add(FlSpot(x, e.diastolic!.toDouble()));
                            diaMax = max(diaMax, e.diastolic!);
                          }
                          if (e.systolic != null) {
                            sysSpots.add(FlSpot(x, e.systolic!.toDouble()));
                            sysMax = max(sysMax, e.systolic!);
                          }
                          if (e.pulse != null) {
                            pulSpots.add(FlSpot(x, e.pulse!.toDouble()));
                            pulMax = max(pulMax, e.pulse!);
                          }
                        }

                        if (fetchedData.length < 2 || (diaSpots.length < 2 && sysSpots.length < 2 && pulSpots.length < 2)) {
                          return Text(AppLocalizations.of(context)!.errNotEnoughDataToGraph);
                        }

                        const noTitels = AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: false));
                        return LineChart(
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
                                    // as graphWidth can technically be as low as one max is needed here to avoid freezes
                                    double graphWidth = meta.max - meta.min;
                                    if ((max(graphWidth - 2,1) / settings.graphTitlesCount) != _lineChartTitleIntervall) {
                                      // simple hack needed to change the state during build
                                      // https://stackoverflow.com/a/63607696/21489239
                                      Future.delayed(Duration.zero, () async {
                                        setState(() {
                                          _lineChartTitleIntervall = max(graphWidth - 2,1) / settings.graphTitlesCount;
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
                                        formatter = DateFormat.MMMd();
                                    }
                                    return Text(formatter
                                        .format(DateTime.fromMillisecondsSinceEpoch(pos.toInt())));
                                  }),
                                ),
                              ),
                              lineTouchData: const LineTouchData(
                                  touchTooltipData:
                                  LineTouchTooltipData(tooltipMargin: -200, tooltipRoundedRadius: 20)),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: pulSpots,
                                  dotData: const FlDotData(
                                    show: false,
                                  ),
                                  color: settings.pulColor,
                                  barWidth: settings.graphLineThickness,
                                ),
                                LineChartBarData(
                                    spots: diaSpots,
                                    color: settings.diaColor,
                                    barWidth: settings.graphLineThickness,
                                    dotData: const FlDotData(
                                      show: false,
                                    ),
                                    belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.red.shade400.withAlpha(100),
                                        cutOffY: settings.diaWarn.toDouble(),
                                        applyCutOffY: true)),
                                LineChartBarData(
                                    spots: sysSpots,
                                    color: settings.sysColor,
                                    barWidth: settings.graphLineThickness,
                                    dotData: const FlDotData(
                                      show: false,
                                    ),
                                    belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.red.shade400.withAlpha(100),
                                        cutOffY: settings.sysWarn.toDouble(),
                                        applyCutOffY: true))
                              ]));
                      }
                    );
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
            const SizedBox(
              height: 20,
            ),
            _LineChart(height: height - 100),
            const SizedBox(
              height: 2,
            ),
            const IntervalPicker()
          ],
        ),
      ),
    );
  }
}
