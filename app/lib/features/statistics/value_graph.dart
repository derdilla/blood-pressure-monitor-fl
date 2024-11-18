import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/loading_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A graph of [BloodPressureRecord] values.
///
/// Note that this can't follow the users preferred unit as this would not allow
/// to put all data on one graph
class BloodPressureValueGraph extends StatelessWidget {
  /// Create a new graph of [BloodPressureRecord] values.
  const BloodPressureValueGraph({super.key, // TODO: intakes ??
    required this.records,
    required this.colors,
    required this.intakes,
  });

  /// Data to draw lines and determine decorations from.
  ///
  /// Must be more than two and sorted.
  final List<BloodPressureRecord> records;

  /// Notes that should render as colored lines if present.
  final List<Note> colors;

  /// Intake dates get painted as tiny colored medicines at the bottom of the
  /// graph.
  final List<MedicineIntake> intakes;

  @override
  Widget build(BuildContext context) {
    if (records.sysGraph().length < 2
      && records.diaGraph().length < 2
      && records.pulGraph().length < 2) {
      return Center(
        child: Text(AppLocalizations.of(context)!.errNotEnoughDataToGraph),
      );
    }
    final r = records.toList();
    r.sort((a, b) => a.time.compareTo(b.time));
    final settings = context.watch<Settings>();
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.slowMiddle,
        duration: Duration(milliseconds: settings.animationSpeed),
        builder: (BuildContext context, double value, Widget? child) => CustomPaint(
          painter: _ValueGraphPainter(
            brightness: Theme.of(context).brightness,
            settings: settings,
            labelStyle: Theme.of(context).textTheme.bodySmall ?? TextStyle(),
            records: r,
            colors: colors,
            progress: value,
            intakes: intakes,
          ),
        ),
      ),
    );
  }
}

class _ValueGraphPainter extends CustomPainter {
  _ValueGraphPainter({
    required this.brightness,
    required this.settings,
    required this.labelStyle,
    required this.records,
    required this.colors,
    required this.intakes,
    required this.progress,
  }): assert(1.0 >= progress && progress >= 0.0);

  final Settings settings;

  final ui.Brightness brightness;

  final TextStyle labelStyle;

  /// Ordered list of all records to display.
  ///
  /// Must be at least 2 records long.
  final List<BloodPressureRecord> records;

  final List<Note> colors;

  final List<MedicineIntake> intakes;

  static const double _kLeftLegendWidth = 35.0;
  static const double _kBottomLegendHeight = 50.0;

  /// Percentage of data line rendering (from 0 to 1).
  final double progress;

  void _paintDecorations(Canvas canvas, Size size, DateTimeRange range, double minY, double maxY) {
    assert(size.width > _kLeftLegendWidth && size.height > _kBottomLegendHeight);

    final graphBorderLinesPaint = Paint()
      ..color = brightness == Brightness.dark ? Colors.white : Colors.black
      ..strokeWidth = 1.0
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
    final leftLabelWidth = _kLeftLegendWidth - 6.0 - 2.0;
    final leftLegendLabelCount = drawHeight / leftLabelHeight;

    // draw horizontal decorations
    for (int i = 0; i < leftLegendLabelCount; i += 2) {
      final h = (size.height - _kBottomLegendHeight) - i * leftLabelHeight;
      canvas.drawLine(
        Offset(_kLeftLegendWidth - 5.0, h),
        Offset(size.width, h),
        graphDecoLinesPaint,
      );
      final labelY = minY + ((maxY - minY) / leftLegendLabelCount) * i;

      final paragraph = _paragraph(ui.TextAlign.end, labelY.round().toString(), leftLabelWidth);
      canvas.drawParagraph(paragraph, ui.Offset(2.0, h - (leftLabelHeight / 2)));
    }
    }();

    // calculate horizontal decoration positions
    final double drawWidth = size.width - _kLeftLegendWidth;
    int bottomLabelCount = 20;
    Duration? stepDuration;
    late DateFormat format;
    while (stepDuration == null && bottomLabelCount > 4) {
      stepDuration = range.duration ~/ bottomLabelCount;
      format = switch(stepDuration) {
        < const Duration(hours: 4) => DateFormat('H:m EEE'),
        < const Duration(days: 1) => DateFormat('EEE'),
        < const Duration(days: 5) => DateFormat('dd'),
        < const Duration(days: 30) => DateFormat('MMM, dd'),
        < const Duration(days: 30*6) => DateFormat('MMM yyyy'),
        _ => DateFormat('yyyy'),
      };
      // Approximate total width needed with duration
      final paragraph = _paragraph(ui.TextAlign.center, format.format(range.start), drawWidth);
      final totalWidthOccupiedByLabels = bottomLabelCount * paragraph.minIntrinsicWidth;
      if (totalWidthOccupiedByLabels > drawWidth) {
        stepDuration = null;
        bottomLabelCount--;
      }
    }

    // -> Graph to small to draw labels
    if (stepDuration == null) return;

    // draw horizontal decorations
    final labelWidth = drawWidth / bottomLabelCount + 8.0;
    for (int i = 0; i < bottomLabelCount; i += 2) {
      final x = _kLeftLegendWidth + i * (drawWidth / bottomLabelCount);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - _kBottomLegendHeight + 4.0),
        graphDecoLinesPaint,
      );
      final text = format.format(range.start.add(stepDuration * i));
      final paragraph = _paragraph(ui.TextAlign.center, text, labelWidth);
      canvas.drawParagraph(paragraph, ui.Offset(
        x - (labelWidth / 2),
        size.height - _kBottomLegendHeight + (labelTextHeight / 2),
      ));
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
    double? warnValue,
  ) {
    if (data.isEmpty) return;

    Path? path;
    Path? warnPath = warnValue == null ? null : Path();
    for (final e in data) {
      final point = ui.Offset(_transformX(size, e.$1, range), _transformY(size, e.$2, minY, maxY));
      if (path != null) {
        path.lineTo(point.dx, point.dy);
        warnPath?.lineTo(point.dx, point.dy);
      } else {
        path = Path();
        path.moveTo(point.dx, point.dy);

        warnPath?.moveTo(_kLeftLegendWidth, warnValue!);
        warnPath?.lineTo(point.dx, point.dy);
      }
    }

    if (path == null) return;
    path = subPath(path, progress);

    if (warnValue != null) {
      assert(warnPath != null);

      warnPath = subPath(warnPath!, progress);
      warnPath.relativeLineTo(0, size.height);

      final y = _transformY(size, warnValue, minY, maxY);

      final warnRect = Rect.fromLTRB(_kLeftLegendWidth, 0, size.width, y);
      final clippedPath = Path.combine(
        PathOperation.intersect,
        warnPath,
        Path()..addRect(warnRect),
      );
      canvas.drawPath(clippedPath, ui.Paint()
        ..color = Colors.redAccent
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.inner, 30.0)
        ..style = ui.PaintingStyle.fill
      );
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = settings.graphLineThickness
      ..strokeCap = ui.StrokeCap.round
      ..style = ui.PaintingStyle.stroke
      ..strokeJoin = ui.StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  // https://www.ncl.ac.uk/webtemplate/ask-assets/external/maths-resources/statistics/regression-and-correlation/simple-linear-regression.html
  void _paintRegressionLine(Canvas canvas, Size size, List<(DateTime, double)> data, double minY, double maxY) {
    final List<double> xValues = data.map((e) => e.$1.millisecondsSinceEpoch.toDouble()).toList();
    final List<double> yValues = data.map((e) => e.$2).toList();

    final double meanX = xValues.sum / data.length;
    final double meanY = yValues.sum / data.length;

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
    final yIntercept = meanY - slope * meanX;

    // Convert data points to canvas coordinates
    final minX = xValues.reduce(math.min);
    final maxX = xValues.reduce(math.max);

    final start = ui.Offset(
      _kLeftLegendWidth,
      _transformY(size, slope * minX + yIntercept, minY, maxY),
    );
    final end = ui.Offset(
      size.width,
      _transformY(size, slope * maxX + yIntercept, minY, maxY),
    );

    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3.0;
    canvas.drawLine(start, end, paint);
  }

  void _paintHorizontalLines(Canvas canvas, Size size, List<HorizontalGraphLine> lines, double minY, double maxY) {
    for (final line in lines) {
      final y = _transformY(size, line.height.toDouble(), minY, maxY);
      final path = Path();
      double x = _kLeftLegendWidth;
      bool drawNext = true;
      while (x < size.width) { // Create dotted line
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
      final x = _transformX(size, color.time, range);
      canvas.drawLine(
          ui.Offset(x, 0),
          ui.Offset(x, size.height - _kBottomLegendHeight),
          ui.Paint()
            ..strokeWidth = settings.needlePinBarWidth
            ..color = Color(color.color!).withOpacity(0.4),
      );
    }
  }

  void _buildIntakes(Canvas canvas, Size size, List<MedicineIntake> intakes, DateTimeRange range) {
    for (final iTake in intakes) {
      final x = _transformX(size, iTake.time, range);
      final icon = Icons.medication;
      final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: 18.0,
          backgroundColor: brightness == ui.Brightness.dark ? Colors.black : Colors.white,
          color: iTake.medicine.color == null ? null : Color(iTake.medicine.color!),
        ),
      );
      textPainter.layout();
      //  Paint centered at the bottom line
      final y = size.height -_kBottomLegendHeight - (textPainter.height / 2);
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    assert(records.length >= 2);
    assert(records.isSorted((a, b) => a.time.compareTo(b.time)));

    final DateTimeRange range = DateTimeRange(
      start: records.first.time,
      end: records.last.time, // TODO: fix intake, ... outside range
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

    _buildIntakes(canvas, size, intakes, range);
    _buildNeedlePins(canvas, size, colors, range, min, max);

    _paintLine(canvas, size, records.sysGraph(), settings.sysColor, range, min, max, settings.sysWarn.toDouble());
    _paintLine(canvas, size, records.diaGraph(), settings.diaColor, range, min, max, settings.diaWarn.toDouble());
    _paintLine(canvas, size, records.pulGraph(), settings.pulColor, range, min, max, null);

    if (settings.drawRegressionLines) {
      _paintRegressionLine(canvas, size, records.sysGraph().toList(), min, max);
      _paintRegressionLine(canvas, size, records.diaGraph().toList(), min, max);
    }

    _paintHorizontalLines(canvas, size, settings.horizontalGraphLines, min, max);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => oldDelegate is! _ValueGraphPainter
    || oldDelegate.progress != progress
    || oldDelegate.brightness != brightness
    || oldDelegate.settings.sysColor != settings.sysColor
    || oldDelegate.settings.diaColor != settings.diaColor
    || oldDelegate.settings.graphLineThickness != settings.graphLineThickness
    || oldDelegate.settings.pulColor != settings.pulColor
    || oldDelegate.settings.sysWarn != settings.sysWarn
    || oldDelegate.settings.diaWarn != settings.diaWarn
    || oldDelegate.settings.drawRegressionLines != settings.drawRegressionLines
    || oldDelegate.settings.needlePinBarWidth != settings.needlePinBarWidth
    || oldDelegate.settings.horizontalGraphLines != settings.horizontalGraphLines
    || oldDelegate.records != records
    || oldDelegate.colors != colors
    || oldDelegate.intakes != intakes;

  /// Transforms an untransformed [y] graph value to correct y-position on a
  /// canvas of [size].
  double _transformY(Size size, double y, double minY, double maxY) {
    final height = size.height - _kBottomLegendHeight;
    final double factorY = height / (maxY - minY);
    final yBottom = _kBottomLegendHeight + (y - minY) * factorY;
    return size.height - yBottom;
  }

  /// Transforms an untransformed [x] graph position to correct x-position on a
  /// canvas of [size].
  double _transformX(Size size, DateTime x, DateTimeRange range) {
    final width = size.width - _kLeftLegendWidth;
    final double factorX = width / range.duration.inMilliseconds;
    final offset = x.millisecondsSinceEpoch - range.start.millisecondsSinceEpoch;
    return _kLeftLegendWidth + offset * factorX;
  }

  /// Create and align a paragraph builder
  ui.Paragraph _paragraph(ui.TextAlign textAlign, String text, double width) {
    final paragraphBuilder = ui.ParagraphBuilder(
      labelStyle.getParagraphStyle(textAlign: textAlign),
    )
      ..pushStyle(labelStyle.getTextStyle())
      ..addText(text);

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: width));
    return paragraph;
  }
}

/// Create graph data from a list of blood pressure records.
extension GraphData on List<BloodPressureRecord> {
  /// Get the timestamps and mmHg values of all non-null sys values.
  Iterable<(DateTime, double)> sysGraph() => map((r) => (r.time, r.sys?.mmHg.toDouble()))
    .whereNot(((DateTime, double?) e) => e.$2 == null)
    .cast<(DateTime, double)>();
  /// Get the timestamps and mmHg values of all non-null dia values.
  Iterable<(DateTime, double)> diaGraph() => map((r) => (r.time, r.dia?.mmHg.toDouble()))
    .whereNot(((DateTime, double?) e) => e.$2 == null)
    .cast<(DateTime, double)>();
  /// Get the timestamps and values as doubles of all non-null pul values.
  Iterable<(DateTime, double)> pulGraph() => map((r) => (r.time, r.pul?.toDouble()))
    .whereNot(((DateTime, double?) e) => e.$2 == null)
    .cast<(DateTime, double)>();
}
