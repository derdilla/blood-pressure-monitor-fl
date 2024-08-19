import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';

void main() => runApp(Tmp());

class Tmp extends StatelessWidget {
  const Tmp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      appBar: AppBar(),
      body: ClipRect(
        child: SizedBox(
          height: 256,
          width: 1000,
          child: BloodPressureValueGraph(
            settings: Settings(
              drawRegressionLines: true,
              horizontalGraphLines: [
                HorizontalGraphLine(Colors.blue, 117),
                HorizontalGraphLine(Colors.red, 12)
              ],
            ),
            records: [
              BloodPressureRecord(time: DateTime(2000), sys: Pressure.mmHg(123), dia: Pressure.mmHg(80) , pul: 40),
              BloodPressureRecord(time: DateTime(2001), sys: Pressure.mmHg(140), pul: 77),
              BloodPressureRecord(time: DateTime(2001, 6), dia: Pressure.mmHg(111)),
              BloodPressureRecord(time: DateTime(2002), sys: Pressure.mmHg(100)),
              BloodPressureRecord(time: DateTime(2002, 2), pul: 60,),
              BloodPressureRecord(time: DateTime(2003), sys: Pressure.mmHg(123), dia: Pressure.mmHg(93)),
              BloodPressureRecord(time: DateTime(2003, 2), pul: 140,),
            ],
            colors: [
              Note(time: DateTime(2000), note: 'no color'),
              Note(time: DateTime(2001), color: Colors.teal.value),
            ]
          ),
        ),
      ),
    ),
  );
}

/// A graph of [BloodPressureRecord] values.
///
/// Note that this can't follow the users preferred unit as this would not allow
/// to put all data on one graph
class BloodPressureValueGraph extends StatelessWidget {
  /// Create a new graph of [BloodPressureRecord] values.
  BloodPressureValueGraph({super.key,
    required this.settings,
    required this.records,
    required this.colors,
  }): assert(records.sysGraph().length >= 2
        || records.diaGraph().length >= 2
        || records.pulGraph().length >= 2),
      assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

  // TODO Add missing:
  // - belowBarData (warn values)
  // New features:
  // - load lines animation

  /// Data to draw lines and determine decorations from.
  ///
  /// Must be more than two and sorted.
  final List<BloodPressureRecord> records;

  /// Notes that should render as colored lines if present.
  final List<Note> colors;

  /// Settings to determine style and behavior.
  final Settings settings;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: CustomPaint(
      painter: _ValueGraphPainter(
        brightness: Theme.of(context).brightness,
        settings: settings,
        labelStyle: Theme.of(context).textTheme.bodySmall ?? TextStyle(),
        records: records,
        colors: colors,
      ),
    ),
  );
}

class _ValueGraphPainter extends CustomPainter {
  _ValueGraphPainter({
    required this.brightness,
    required this.settings,
    required this.labelStyle,
    required this.records,
    required this.colors,
  });

  final Settings settings;

  final ui.Brightness brightness;

  final TextStyle labelStyle;

  /// Ordered list of all records to display.
  ///
  /// Must be at least 2 records long.
  final List<BloodPressureRecord> records;

  final List<Note> colors;

  static const double _kLeftLegendWidth = 35.0;
  static const double _kBottomLegendHeight = 50.0;

  void _paintDecorations(Canvas canvas, Size size, DateTimeRange range, double minY, double maxY) {
    assert(size.width > _kLeftLegendWidth && size.height > _kBottomLegendHeight);

    final graphBorderLinesPaint = Paint()
      ..color = brightness == Brightness.dark ? Colors.white : Colors.black
      ..strokeCap = ui.StrokeCap.round;
    final graphDecoLinesPaint = Paint()
      ..color = brightness == Brightness.dark ? Colors.white60 : Colors.black45
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round;

    // draw border
    final bottomLeftOfGraph = Offset(_kLeftLegendWidth, size.height - _kBottomLegendHeight);
    canvas.drawLine(bottomLeftOfGraph, Offset(size.width, size.height - _kBottomLegendHeight), graphBorderLinesPaint);
    canvas.drawLine(bottomLeftOfGraph, Offset(_kLeftLegendWidth, 0.0), graphBorderLinesPaint);

    final labelTextHeight = ((labelStyle.height ?? 1.0) * (labelStyle.fontSize ?? 14.0));
    (){
    // calculate horizontal decoration positions
    final double drawHeight = size.height - _kBottomLegendHeight;

    final leftLabelHeight = labelTextHeight + 4.0; // padding
    final leftLegendLabelCount = drawHeight / leftLabelHeight;

    // draw horizontal decorations
    for (int i = 0; i < leftLegendLabelCount; i += 2) {
      final h = (size.height - _kBottomLegendHeight) - i * leftLabelHeight;
      canvas.drawLine(
        Offset(_kLeftLegendWidth, h),
        Offset(size.width, h),
        graphDecoLinesPaint,
      );
      canvas.drawLine(
        Offset(_kLeftLegendWidth, h),
        Offset(_kLeftLegendWidth - 5.0, h),
        graphBorderLinesPaint,
      );
      final labelY = minY + ((maxY - minY) / leftLegendLabelCount) * i;
      final paragraphBuilder = ui.ParagraphBuilder(labelStyle.getParagraphStyle(
          textAlign: ui.TextAlign.end,
      ))
        ..pushStyle(labelStyle.getTextStyle())
        ..addText(labelY.round().toString());
      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: _kLeftLegendWidth - 6.0 - 2.0));
      canvas.drawParagraph(paragraph, ui.Offset(2.0, h - (leftLabelHeight / 2)));
    }
    }();

    // calculate vertical decoration positions
    final double drawWidth = size.width - _kLeftLegendWidth;
    final bottomLabelHeight = labelTextHeight + 4.0;
    int bottomLabelCount = 20;
    Duration? stepDuration;
    late DateFormat format;
    while (stepDuration == null && bottomLabelCount > 4) {
      final duration = range.duration ~/ bottomLabelCount;
      format = (){
        switch (duration) {
          case < const Duration(hours: 8):
            return DateFormat('H:m');
          case < const Duration(days: 1):
            return DateFormat('EEE');
          case < const Duration(days: 5):
            return DateFormat('dd');
          case < const Duration(days: 30):
            return DateFormat('MMM, dd');
          case < const Duration(days: 30*6):
            return DateFormat('MMM yyyy');
          default:
            return DateFormat('yyyy');
        }
      }();
      final paragraphBuilder = ui.ParagraphBuilder(labelStyle.getParagraphStyle(
          textAlign: ui.TextAlign.end
      ))..pushStyle(labelStyle.getTextStyle())
        ..addText(format.format(range.start));
      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: drawWidth));
      // Not 100% accurate but avoids expensive text layout
      final totalWidthOccupiedByLabels = bottomLabelCount * paragraph.minIntrinsicWidth;
      if (totalWidthOccupiedByLabels < drawWidth) {
        stepDuration = duration;
      } else {
        bottomLabelCount--;
      }
    }

    // draw vertical decorations
    for (int i = 0; i < bottomLabelCount; i += 2) {
      final x = _kLeftLegendWidth + i * (drawWidth / bottomLabelCount);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - _kBottomLegendHeight + 4.0),
        graphDecoLinesPaint,
      );
      final paragraphBuilder = ui.ParagraphBuilder(labelStyle.getParagraphStyle(
          textAlign: ui.TextAlign.center
      ))..pushStyle(labelStyle.getTextStyle())
        ..addText(format.format(range.start.add(stepDuration! * i)));
      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: drawWidth / bottomLabelCount + 8.0));
      canvas.drawParagraph(paragraph, ui.Offset(x - ((drawWidth / bottomLabelCount + 8.0) / 2), size.height - _kBottomLegendHeight + (bottomLabelHeight / 2)));
    }
  }

  void _paintLine(
    Canvas canvas,
    Size size,
    Iterable<(DateTime, double)> data,
    Color color,
    DateTimeRange range,
    double minY,
    double maxY,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = settings.graphLineThickness
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round;

    ui.Offset transformPoint((DateTime, double) p) {
      final width = size.width - _kLeftLegendWidth;
      final double factorX = width / range.duration.inMilliseconds;
      final x = _kLeftLegendWidth + (p.$1.millisecondsSinceEpoch - range.start.millisecondsSinceEpoch) * factorX;
      
      final height = size.height - _kBottomLegendHeight;
      final double factorY = height / (maxY - minY);
      final yBottom = _kBottomLegendHeight + (p.$2 - minY) * factorY;
      final y = size.height - yBottom;

      return ui.Offset(x, y);
    }

    ui.Offset? lastPoint;
    for (final e in data) {
      final point = transformPoint(e);
      if (lastPoint != null) {
        canvas.drawLine(lastPoint, point, paint);
      }

      lastPoint = point;
    }
  }

  // https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/regression-and-correlation/simple-linear-regression.html
  void _paintRegressionLine(Canvas canvas, Size size, List<(DateTime, double)> data, double minY, double maxY) {
    final List<double> xValues = data.map((e) => e.$1.millisecondsSinceEpoch.toDouble()).toList();
    final List<double> yValues = data.map((e) => e.$2).toList();

    final double meanX = xValues.sum / data.length;
    final double meanY = yValues.sum / data.length;

    // Calculate slope
    final slopeTop = data.fold(0.0, (double last, (DateTime, double) e) {
      final xErr = e.$1.millisecondsSinceEpoch - meanX;
      final yErr = e.$2 - meanY;
      return last + xErr * yErr;
    });
    final slopeBtm = data.fold(0.0, (double last, (DateTime, double) e) {
      final xErr = e.$1.millisecondsSinceEpoch - meanX;
      return last + xErr * xErr;
    });
    final slope = slopeTop / slopeBtm;

    // Calculate where the function intercepts the Y axis
    final yIntercept = meanY - slope * meanX;

    // Convert data points to canvas coordinates
    final minX = xValues.reduce(math.min);
    final maxX = xValues.reduce(math.max);

    // Scale x and y coordinates to the canvas
    final scaleY = (size.height - _kBottomLegendHeight) / (maxY - minY);

    // Draw the regression line from the first point to the last point
    final start = ui.Offset(
      _kLeftLegendWidth,
      size.height - _kBottomLegendHeight - ((slope * minX + yIntercept - minY) * scaleY),
    );
    final end = ui.Offset(
      size.width,
      size.height - _kBottomLegendHeight - ((slope * maxX + yIntercept - minY) * scaleY),
    );

    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3.0;
    canvas.drawLine(start, end, paint);
  }

  void _paintHorizontalLines(Canvas canvas, Size size, List<HorizontalGraphLine> lines, double minY, double maxY) {
    final height = size.height - _kBottomLegendHeight;
    final double factorY = height / (maxY - minY);
    for (final line in lines) {
      double y = _kBottomLegendHeight + (line.height - minY) * factorY;
      y = size.height - y;
      final path = Path();
      double x = _kLeftLegendWidth;
      bool drawNext = true;
      while (x < size.width) { // Dotted
        if (drawNext) {
          final newX = x + 10;
          path.moveTo(x, y);
          path.lineTo(newX, y);
          x = newX;
          drawNext = false;
        } else {
          x += 5;
          drawNext = true;
        }
      }
      canvas.drawPath(
        path,
        ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = line.color,
      );
    }
  }

  void _buildNeedlePins(Canvas canvas, Size size, List<Note> colors, DateTimeRange range, double minY, double maxY) {
    for (final color in colors.where((n) => n.color != null)) {
      // TODO: stop duplicating transform code across functions
      final width = size.width - _kLeftLegendWidth;
      final double factorX = width / range.duration.inMilliseconds;
      final x = _kLeftLegendWidth + (color.time.millisecondsSinceEpoch - range.start.millisecondsSinceEpoch) * factorX;

      canvas.drawLine(
          ui.Offset(x, 0),
          ui.Offset(x, size.height - _kBottomLegendHeight),
          ui.Paint()
            ..strokeWidth = settings.needlePinBarWidth
            ..color = Color(color.color!).withOpacity(0.4),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    assert(records.length >= 2);
    assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

    final DateTimeRange range = DateTimeRange(
      start: records.first.time,
      end: records.last.time,
    );

    double min = double.infinity;
    double max = double.negativeInfinity;
    for (final r in records) {
      if (r.sys != null && r.sys!.mmHg < min) { min = r.sys!.mmHg.toDouble(); }
      if (r.dia != null && r.dia!.mmHg < min) { min = r.dia!.mmHg.toDouble(); }
      if (r.pul != null && r.pul! < min) { min = r.pul!.toDouble(); }
      if (r.sys != null && r.sys!.mmHg > max) { max = r.sys!.mmHg.toDouble(); }
      if (r.dia != null && r.dia!.mmHg > max) { max = r.dia!.mmHg.toDouble(); }
      if (r.pul != null && r.pul! > max) { max = r.pul!.toDouble(); }
    }
    for (final l in settings.horizontalGraphLines) {
      max = math.max(l.height.toDouble(), max);
      min = math.min(l.height.toDouble(), min);
    }
    assert(min != double.infinity);
    assert(max != double.negativeInfinity);

    _paintDecorations(canvas, size, range, min, max);

    _buildNeedlePins(canvas, size, colors, range, min, max);

    _paintLine(canvas, size, records.sysGraph(), settings.sysColor, range, min, max);
    _paintLine(canvas, size, records.diaGraph(), settings.diaColor, range, min, max);
    _paintLine(canvas, size, records.pulGraph(), settings.pulColor, range, min, max);

    if (settings.drawRegressionLines) {
      _paintRegressionLine(canvas, size, records.sysGraph().toList(), min, max);
      _paintRegressionLine(canvas, size, records.diaGraph().toList(), min, max);
    }

    _paintHorizontalLines(canvas, size, settings.horizontalGraphLines, min, max);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => oldDelegate is! _ValueGraphPainter
    || oldDelegate.brightness != brightness
    || oldDelegate.settings.preferredPressureUnit != settings.preferredPressureUnit
    || oldDelegate.settings.sysColor != settings.sysColor
    || oldDelegate.settings.diaColor != settings.diaColor
    || oldDelegate.settings.graphLineThickness != settings.graphLineThickness
    || oldDelegate.settings.pulColor != settings.pulColor
    || oldDelegate.settings.sysWarn != settings.sysWarn
    || oldDelegate.settings.diaWarn != settings.diaWarn
    || oldDelegate.settings.drawRegressionLines != settings.drawRegressionLines
    || oldDelegate.settings.needlePinBarWidth != settings.needlePinBarWidth
    || oldDelegate.records != records
    || oldDelegate.colors != colors;

}

/// Create graph data from a list of blood pressure records.
extension GraphData on List<BloodPressureRecord> {
  /// Get the timestamps and mmHg values of all non-null sys values.
  Iterable<(DateTime, double)> sysGraph() => this
    .map((r) => (r.time, r.sys?.mmHg.toDouble()))
    .whereNot(((DateTime, double?) e) => e.$2 == null)
    .cast<(DateTime, double)>();
  /// Get the timestamps and mmHg values of all non-null dia values.
  Iterable<(DateTime, double)> diaGraph() => this
    .map((r) => (r.time, r.dia?.mmHg.toDouble()))
    .whereNot(((DateTime, double?) e) => e.$2 == null)
    .cast<(DateTime, double)>();
  /// Get the timestamps and values as doubles of all non-null pul values.
  Iterable<(DateTime, double)> pulGraph() => this
    .map((r) => (r.time, r.pul?.toDouble()))
    .whereNot(((DateTime, double?) e) => e.$2 == null)
    .cast<(DateTime, double)>();
}
