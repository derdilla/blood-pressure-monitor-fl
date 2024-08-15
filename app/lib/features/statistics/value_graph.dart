import 'dart:ui' as ui;

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
              records: [],
              range: DateTimeRange(
                start: DateTime.now().subtract(Duration(days: 265*3)),
                end: DateTime.now(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class BloodPressureValueGraph extends StatelessWidget {
  const BloodPressureValueGraph({super.key, required this.records, required this.range});

  /// Data that make up graph lines.
  ///
  /// Data outside [range] will be ignored.
  final List<BloodPressureRecord> records;

  final DateTimeRange range;

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: _ValueGraphPainter(
        brightness: Brightness.dark,
        labelStyle: TextStyle(),
        records: records,
        range: range,
      ),
    );
}

class _ValueGraphPainter extends CustomPainter {
  _ValueGraphPainter({super.repaint,
    required this.brightness,
    required this.labelStyle,
    required this.records,
    required this.range,
  });

  final Brightness brightness;

  final TextStyle labelStyle;

  final List<BloodPressureRecord> records;

  final DateTimeRange range;

  void _paintDecorations(Canvas canvas, Size size, DateTimeRange range, double minY, double maxY) {
    const leftLegendWidth = 35.0;
    const bottomLegendHeight = 50.0;
    final graphBorderLinesPaint = Paint()
      ..color = brightness == Brightness.dark ? Colors.white : Colors.black
      ..strokeCap = ui.StrokeCap.round;
    final graphDecoLinesPaint = Paint()
      ..color = brightness == Brightness.dark ? Colors.white60 : Colors.black45
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round;

    assert(size.width > leftLegendWidth && size.height > bottomLegendHeight);

    // draw border
    final bottomLeftOfGraph = Offset(leftLegendWidth, size.height - bottomLegendHeight);
    canvas.drawLine(bottomLeftOfGraph, Offset(size.width, size.height - bottomLegendHeight), graphBorderLinesPaint);
    canvas.drawLine(bottomLeftOfGraph, Offset(leftLegendWidth, 0.0), graphBorderLinesPaint);

    final labelTextHeight = ((labelStyle.height ?? 1.0) * (labelStyle.fontSize ?? 14.0));
    (){
    // calculate horizontal decoration positions
    final double drawHeight = size.height - bottomLegendHeight;

    final leftLabelHeight = labelTextHeight + 4.0; // padding
    final leftLegendLabelCount = drawHeight / leftLabelHeight;

    // draw horizontal decorations
    for (int i = 0; i < leftLegendLabelCount; i += 2) {
      final h = (size.height - bottomLegendHeight) - i * leftLabelHeight;
      canvas.drawLine(
        Offset(leftLegendWidth, h),
        Offset(size.width, h),
        graphDecoLinesPaint,
      );
      canvas.drawLine(
        Offset(leftLegendWidth, h),
        Offset(leftLegendWidth - 5.0, h),
        graphBorderLinesPaint,
      );
      final label = minY + ((maxY - minY) / leftLegendLabelCount) * i;
      final paragraphBuilder = ui.ParagraphBuilder(labelStyle.getParagraphStyle(
          textAlign: ui.TextAlign.end
      ))
        ..pushStyle(labelStyle.getTextStyle())
        ..addText(label.round().toString());
      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: leftLegendWidth - 6.0 - 2.0));
      canvas.drawParagraph(paragraph, ui.Offset(2.0, h - (leftLabelHeight / 2)));
    }
    }();

    // calculate vertical decoration positions
    final double drawWidth = size.width - leftLegendWidth;
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
      final x = leftLegendWidth + i * (drawWidth / bottomLabelCount);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - bottomLegendHeight + 4.0),
        graphDecoLinesPaint,
      );
      final paragraphBuilder = ui.ParagraphBuilder(labelStyle.getParagraphStyle(
          textAlign: ui.TextAlign.center
      ))..pushStyle(labelStyle.getTextStyle())
        ..addText(format.format(range.start.add(stepDuration! * i)));
      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: drawWidth / bottomLabelCount + 8.0));
      canvas.drawParagraph(paragraph, ui.Offset(x - ((drawWidth / bottomLabelCount + 8.0) / 2), size.height - bottomLegendHeight + (bottomLabelHeight / 2)));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintDecorations(canvas, size, range, 40, 135);
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}
