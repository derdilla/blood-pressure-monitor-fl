import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: ClockBpGraph(values: []),
    ),
  ));
}

class ClockBpGraph extends StatelessWidget {
  const ClockBpGraph({super.key, required this.values});

  final List<BloodPressureRecord> values;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: MediaQuery.of(context).size.width,
    child: CustomPaint(
      painter: _RadarChartPainter(labels: ["1", "2", "3"], values: [
        (Colors.red, [5,4,5]),
      ]),
    ),
  );
}

class _RadarChartPainter extends CustomPainter {
  /// Create a new radar chart painter.
  ///
  /// Each value must be as many data points as there are labels.
  _RadarChartPainter({
    required this.labels,
    required this.values,
  }) : assert(labels.length >= 3),
       assert(!values.any((v) => v.$2.length != labels.length)) {
    _maxValue = values.map((v) =>v.$2).flattened.max;
  }

  final List<String> labels;

  final List<(Color, List<int>)> values;

  /// Highest number in values.
  late final int _maxValue;

  static const double _kPadding = 20.0;
  static const double _kHelperCircleInterval = 60.0;

  @override
  void paint(Canvas canvas, Size size) {
    final decoPaint = Paint()
      //..blendMode = BlendMode.color
      //..maskFilter = MaskFilter.blur(_style, _sigma)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.black.withOpacity(0.4);

    // static decorations
    double l = (size.shortestSide / 2) - _kPadding;
    while (l > 10.0) {
      canvas.drawCircle(size.center(Offset.zero), l, decoPaint);
      l -= _kHelperCircleInterval;
    }
    canvas.drawCircle(size.center(Offset.zero), 10.0, Paint.from(decoPaint)
      ..style = PaintingStyle.fill,
    );

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
    for (int i = 0; i < labels.length; i++) {
      _drawTextInsideBounds(canvas, i * sectionWidth, size, labels[i]);
    }
  }

  /// Draws a given [text] at the end of [angle], but withing [size].
  void _drawTextInsideBounds(Canvas canvas, double angle, Size size, String text) {
    final textStyle = TextStyle(
      color: Colors.white,
        background: Paint()
          ..color = Colors.black.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15.0
          ..strokeJoin = StrokeJoin.round,
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

  Offset _offset(double angle, double radius) => Offset(
    radius * math.cos(angle),
    radius * math.sin(angle),
  );

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    final a = 0;
    return true;
  }
}
