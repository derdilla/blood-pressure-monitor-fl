import 'dart:math' as math;
import 'dart:ui';

import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// A graph that displays the averages blood pressure values across by time in
/// the familiar shape of a clock.
class ClockBpGraph extends StatelessWidget {
  /// Create a clock shaped graph of average by time.
  const ClockBpGraph({super.key, required this.measurements});

  //
  final List<BloodPressureRecord> measurements;

  @override
  Widget build(BuildContext context) {
    final analyzer = BloodPressureAnalyser(measurements);
    final groups = analyzer.groupAnalysers();
    return SizedBox.square(
      dimension: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CustomPaint(
          painter: _RadarChartPainter(
            brightness: Theme.of(context).brightness,
            labels: List.generate(groups.length, (i) => i.toString()),
            values: [
              (context.watch<Settings>().sysColor, groups
                .map((e) => (e.avgSys ?? analyzer.avgSys)?.mmHg ?? 0).toList(growable: false)),
              (context.watch<Settings>().diaColor, groups
                .map((e) => (e.avgDia ?? analyzer.avgDia)?.mmHg ?? 0).toList(growable: false)),
              (context.watch<Settings>().pulColor, groups
                .map((e) => e.avgPul ?? analyzer.avgPul ?? 0).toList(growable: false)),
            ]
          ),
        ),
      ),
  );
  }
}

class _RadarChartPainter extends CustomPainter {
  /// Create a new radar chart painter.
  ///
  /// Each value must be as many data points as there are labels.
  _RadarChartPainter({
    required this.brightness,
    required this.labels,
    required this.values,
  }) : assert(labels.length >= 3),
       assert(!values.any((v) => v.$2.length != labels.length)) {
    _maxValue = values.map((v) =>v.$2).flattened.max;
  }

  final Brightness brightness;

  final List<String> labels;

  final List<(Color, List<int>)> values;

  /// Highest number in values.
  late final int _maxValue;

  static const double _kPadding = 20.0;
  static const double _kHelperCircleInterval = 60.0;

  @override
  void paint(Canvas canvas, Size size) {
    final decoPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = (brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.3);

    // static decorations
    double l = (size.shortestSide / 2) - _kPadding;
    while (l > 10.0) {
      canvas.drawCircle(size.center(Offset.zero), l, decoPaint);
      l -= _kHelperCircleInterval;
    }

    // compute directions & add remaining decorations
    const fullCircle = 2 * math.pi;
    final sectionWidth = fullCircle / labels.length;
    final List<double> angles = [];
    for (int i = 0; i < labels.length; i++) {
      angles.add(i * sectionWidth);
      canvas.drawLine(
        size.center(Offset.zero),
        size.center(_offset(i * sectionWidth, size.shortestSide / 2)),
        decoPaint,
      );
    }

    // draw content
    for (final dataRow in values) {
      Path? path;
      for (int i = 0; i < labels.length; i++) {
        final pos = size.center(_offsetFromValue(angles[i], size.shortestSide / 2, dataRow.$2[i]));
        if (path == null) {
          path = Path();
          path.moveTo(pos.dx, pos.dy);
        } else {
          path.lineTo(pos.dx, pos.dy);
        }
      }
      final startPos = size.center(_offsetFromValue(angles[0], size.shortestSide / 2, dataRow.$2[0]));
      path!.lineTo(startPos.dx, startPos.dy);

      canvas.drawPath(path, Paint()
        ..color = dataRow.$1.withOpacity(0.4));
      canvas.drawPath(path, Paint()
        ..color = dataRow.$1
        ..strokeWidth = 5.0
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke);
    }

    // draw labels on top content
    for (int i = 0; i < labels.length; i += 2) {
      _drawTextInsideBounds(canvas, i * sectionWidth, size, labels[i]);
    }
  }

  /// Draws a given [text] at the end of [angle], but withing [size].
  void _drawTextInsideBounds(Canvas canvas, double angle, Size size, String text) {
    final textStyle = TextStyle(
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
      backgroundColor: (brightness == Brightness.dark ? Colors.black : Colors.white).withOpacity(0.6),
      fontSize: 24.0
    );

    final builder = ParagraphBuilder(textStyle.getParagraphStyle());
    builder.pushStyle(textStyle.getTextStyle());
    builder.addText(text);
    final paragraph = builder.build();
    paragraph.layout(ParagraphConstraints(width: size.width));

    Offset off = _offset(angle, size.shortestSide / 2);
    off = size.center(off);
    off = Offset(off.dx - (paragraph.minIntrinsicWidth / 2), off.dy - (paragraph.height / 2));
    if ((off.dy + paragraph.height) > size.height) { // right overflow
      off = Offset(off.dx, off.dy - ((off.dy + paragraph.height) - size.height));
    }
    if ((off.dx + paragraph.minIntrinsicWidth) > size.width) { // right overflow
      off = Offset(off.dx - ((off.dx + paragraph.minIntrinsicWidth) - size.width), off.dy);
    }

    //print('${size.height} > ${off.dy + paragraph.height}');
    canvas.drawParagraph(paragraph, off);
  }

  Offset _offsetFromValue(double angle, double fullRadius, int value) {
    final percent = value / _maxValue;
    final r = fullRadius * percent;
    return _offset(angle, r);
  }

  /// Rotate so up is 0deg and transform to [Offset] from center.
  Offset _offset(double angle, double radius) => Offset(
    radius * math.cos(angle - 0.5 * math.pi),
    radius * math.sin(angle - 0.5 * math.pi),
  );

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    final a = 0;
    return true;
  }
}
