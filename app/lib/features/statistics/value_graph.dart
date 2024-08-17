import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';

void main() => runApp(Tmp());

class Tmp extends StatelessWidget {
  const Tmp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(),
        body: ClipRect(
          child: SizedBox(
            height: 250,
            width: 600,
            child: BloodPressureValueGraph(
              records: [
                BloodPressureRecord(time: DateTime(2000), sys: Pressure.kPa(123)),
                BloodPressureRecord(time: DateTime(2001), sys: Pressure.kPa(140)),
                BloodPressureRecord(time: DateTime(2002), sys: Pressure.kPa(100)),
                BloodPressureRecord(time: DateTime(2003), sys: Pressure.kPa(123)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A graph of [BloodPressureRecord] values.
class BloodPressureValueGraph extends StatelessWidget {
  /// Create a new graph of [BloodPressureRecord] values.
  BloodPressureValueGraph({super.key,
    required this.records,
  }): assert(records.length >= 2),
      assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

  /// Data to draw lines and determine decorations from.
  ///
  /// Must be more than two and sorted.
  final List<BloodPressureRecord> records;

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: _ValueGraphPainter(
        brightness: Brightness.dark,
        labelStyle: TextStyle(),
        records: records,
      ),
    );
}

class _ValueGraphPainter extends CustomPainter {
  _ValueGraphPainter({super.repaint,
    required this.brightness,
    required this.labelStyle,
    required this.records,
  });

  final Brightness brightness;

  final TextStyle labelStyle;

  /// Ordered list of all records to display.
  ///
  /// Must be at least 2 records long.
  final List<BloodPressureRecord> records;

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
      print(duration);
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
      ..strokeWidth = 2.0
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
      if (r.sys?.kPa != null && r.sys!.kPa < min) { min = r.sys!.kPa; }
      if (r.dia?.kPa != null && r.dia!.kPa < min) { min = r.dia!.kPa; }
      if (r.pul != null && r.pul! < min) { min = r.pul!.toDouble(); }
      if (r.sys?.kPa != null && r.sys!.kPa > max) { max = r.sys!.kPa; }
      if (r.dia?.kPa != null && r.dia!.kPa > max) { max = r.dia!.kPa; }
      if (r.pul != null && r.pul! > max) { max = r.pul!.toDouble(); }
    }
    assert(min != double.infinity);
    assert(max != double.negativeInfinity);
    // TODO: convert to preferred units

    _paintDecorations(canvas, size, range, min, max);
    _paintLine(canvas, size, records.sysGraph(), Colors.blue, range, min, max);
    _paintLine(canvas, size, records.diaGraph(), Colors.green, range, min, max);
    _paintLine(canvas, size, records.pulGraph(), Colors.red, range, min, max);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}

/// Create graph data from a list of blood pressure records.
extension GraphData on List<BloodPressureRecord> {
  /// Get the timestamps and kPa values of all non-null sys values.
  Iterable<(DateTime, double)> sysGraph() => this
    .map((r) => (r.time, r.sys?.kPa))
    .whereNot(((DateTime, double?) e) => e.$2 == null)
    .cast<(DateTime, double)>();
  /// Get the timestamps and kPa values of all non-null dia values.
  Iterable<(DateTime, double)> diaGraph() => this
      .map((r) => (r.time, r.dia?.kPa))
      .whereNot(((DateTime, double?) e) => e.$2 == null)
      .cast<(DateTime, double)>();
  /// Get the timestamps and values as doubles of all non-null pul values.
  Iterable<(DateTime, double)> pulGraph() => this
      .map((r) => (r.time, r.pul?.toDouble()))
      .whereNot(((DateTime, double?) e) => e.$2 == null)
      .cast<(DateTime, double)>();
}