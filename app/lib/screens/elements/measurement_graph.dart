import 'dart:math';

import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/elements/blood_pressure_builder.dart';
import 'package:blood_pressure_app/screens/elements/display_interval_picker.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class _LineChart extends StatefulWidget {

  const _LineChart({this.height = 200});
  final double height;

  @override
  State<_LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<_LineChart> {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        child: Consumer<IntakeHistory>(
          builder: (context, intakeHistory, child) => Consumer<Settings>(
          builder: (context, settings, child) => BloodPressureBuilder(
              rangeType: IntervallStoreManagerLocation.mainPage,
              onData: (BuildContext context, UnmodifiableListView<BloodPressureRecord> records) {
                final List<BloodPressureRecord> data = records.toList();
                data.sort((a, b) => a.creationTime.compareTo(b.creationTime));

                // calculate lines for graph
                final pulSpots = <FlSpot>[];
                final diaSpots = <FlSpot>[];
                final sysSpots = <FlSpot>[];
                int maxValue = 0;
                final int minValue = (settings.validateInputs ? 30 : 0);
                /// Horizontally first value
                double? graphBegin;
                /// Horizontally last value
                double? graphEnd;
                for (final e in data) {
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
                  graphBegin ??= x;
                  graphEnd ??= x;
                  if (x < graphBegin) graphBegin = x;
                  if (x > graphEnd) graphEnd = x;
                }

                if (diaSpots.length < 2 && sysSpots.length < 2 && pulSpots.length < 2 || graphBegin == null || graphEnd == null) {
                  return Text(AppLocalizations.of(context)!.errNotEnoughDataToGraph);
                }

                // Add padding to avoid overflowing vertical lines.
                final len = graphEnd - graphBegin;
                graphBegin -= len / 40;
                graphEnd += len / 40;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: settings.animationSpeed), // interacts with LineChart duration property
                  tween: Tween<double>(begin: 0, end: settings.graphLineThickness),
                  builder: (context, animatedThickness, child) => LineChart(
                      duration: const Duration(milliseconds: 200),
                      LineChartData(
                          minY: minValue.toDouble(),
                          maxY: maxValue + 5,
                          minX: graphBegin,
                          maxX: graphEnd,
                          clipData: const FlClipData.all(),
                          titlesData: _buildFlTitlesData(settings,
                              DateTimeRange(start: data.first.creationTime, end: data.last.creationTime),),
                          lineTouchData: const LineTouchData(
                              touchTooltipData: LineTouchTooltipData(tooltipMargin: -200, tooltipRoundedRadius: 20),
                          ),
                          lineBarsData: buildBars(animatedThickness, settings, sysSpots, diaSpots, pulSpots,
                              maxValue, minValue, graphBegin, graphEnd, records,
                              intakeHistory.getIntakes(
                                  DateTimeRange(
                                      start: DateTime.fromMillisecondsSinceEpoch(graphBegin!.toInt()),
                                      end: DateTime.fromMillisecondsSinceEpoch(graphEnd!.toInt()),
                                  ),
                              ),
                          ),
                      ),
                    ),
                );
              },
            ),
        ),
      ),
    );

  List<LineChartBarData> buildBars(
      double animatedThickness, 
      Settings settings, 
      List<FlSpot> sysSpots, 
      List<FlSpot> diaSpots,
      List<FlSpot> pulSpots,
      int maxValue,
      int minValue,
      /// Horizontally earliest value (same as first timestamp).
      double? graphBegin,
      /// Horizontally furthest value (same as last timestamp).
      double? graphEnd, 
      Iterable<BloodPressureRecord> allRecords,
      Iterable<OldMedicineIntake> allIntakes,
      ) {
    final bars = [
      _buildBarData(animatedThickness, sysSpots, settings.sysColor, true, settings.sysWarn.toDouble()),
      _buildBarData(animatedThickness, diaSpots, settings.diaColor, true, settings.diaWarn.toDouble()),
      _buildBarData(animatedThickness, pulSpots, settings.pulColor, false),
      for (final horizontalLine in settings.horizontalGraphLines)
        if (horizontalLine.height < maxValue && horizontalLine.height > minValue)
          _buildHorizontalLine(horizontalLine, graphBegin!, graphEnd!),
    ];
    if (settings.drawRegressionLines) {
      bars.addAll([
          _buildRegressionLine(sysSpots),
          _buildRegressionLine(diaSpots),
          _buildRegressionLine(pulSpots),
      ]);
    }
    bars.addAll(_buildNeedlePins(allRecords, minValue, maxValue, settings));
    for (final intake in allIntakes) {
      bars.add(LineChartBarData(
        spots: [
          FlSpot(intake.timestamp.millisecondsSinceEpoch.toDouble(), minValue.toDouble()),
          FlSpot(intake.timestamp.millisecondsSinceEpoch.toDouble(), maxValue + 5),
        ],
        barWidth: settings.needlePinBarWidth,
        dotData: const FlDotData(show: false),
        dashArray: [8,7],
        color: intake.medicine.color,
      ),);
    }
    return bars;
  }

  FlTitlesData _buildFlTitlesData(Settings settings, DateTimeRange graphRange) {
    const noTitels = AxisTitles(sideTitles: SideTitles(reservedSize: 40));
    return FlTitlesData(
      topTitles: noTitels,
      rightTitles: noTitels,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double pos, TitleMeta meta) {
            // don't show fixed titles, as they are replaced by long dates below
            if (meta.axisPosition <= 1 || pos >= meta.max) {
              return const SizedBox.shrink();
            }

            // format of titles
            late final DateFormat formatter;
            if (graphRange.duration < const Duration(days: 2)) {
              formatter = DateFormat.Hm();
            } else if (graphRange.duration < const Duration(days: 15)) {
              formatter = DateFormat.E();
            } else if (graphRange.duration < const Duration(days: 30)) {
              formatter = DateFormat.d();
            } else if (graphRange.duration < const Duration(days: 500)) {
              formatter = DateFormat.MMM();
            } else {
              formatter = DateFormat.y();
            }
              return Text(
                formatter.format(DateTime.fromMillisecondsSinceEpoch(pos.toInt())),
              );
          },
        ),
      ),
    );
  }

  List<LineChartBarData> _buildNeedlePins(Iterable<BloodPressureRecord> allRecords, int min, int max, Settings settings,) {
    final pins = <LineChartBarData>[];
    for (final r in allRecords.where((e) => e.needlePin != null)) {
      pins.add(LineChartBarData(
        spots: [
          FlSpot(r.creationTime.millisecondsSinceEpoch.toDouble(), min.toDouble()),
          FlSpot(r.creationTime.millisecondsSinceEpoch.toDouble(), max + 5),
        ],
        barWidth: settings.needlePinBarWidth,
        dotData: const FlDotData(show: false),
        color: r.needlePin!.color.withAlpha(100),
      ),);
    }
    return pins;
  }

  LineChartBarData _buildBarData(double lineThickness, List<FlSpot> spots, Color color, bool hasAreaData, [double? areaDataCutOff]) => LineChartBarData(
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
              applyCutOffY: true,),
    );

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
        FlSpot(end, y(end)),
      ],
      dotData: const FlDotData(
        show: false,
      ),
    );
  }

  LineChartBarData _buildHorizontalLine(HorizontalGraphLine line, double start, double end) => LineChartBarData(
      color: line.color,
      spots: [
        FlSpot(start, line.height.toDouble()),
        FlSpot(end, line.height.toDouble()),
      ],
      barWidth: 1,
      dotData: const FlDotData(
        show: false,
      ),
      dashArray: [10,5,],
    );
}

// TODO: document
class MeasurementGraph extends StatelessWidget {

  const MeasurementGraph({super.key, this.height = 290});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 6, top: 22),
        child: Column(
          children: [
            _LineChart(height: height - 100),
            const IntervalPicker(type: IntervallStoreManagerLocation.mainPage,),
          ],
        ),
      ),
    );
}

extension Sum<T> on List<T> {
  double sum(num Function(T value) f) => fold<double>(0, (prev, e) => prev + f(e).toDouble());
}
