import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A statistic that shows how often values occur in a list of values.
///
/// Shows in form of a graph that has centered columns of different height and
/// labels that indicate min, max and average.
///
/// The widgets takes a width of at least 180 units and a height of at least 50.
///
/// First draws the graph lines, then draws the decorations in the color
/// [Colors.white70].
class ValueDistribution extends StatelessWidget {
  /// Create a statistic to show how often values occur.
  const ValueDistribution({
    super.key,
    required this.values,
    required this.color,
  });

  /// Raw list of all values to calculate the distribution from.
  ///
  /// Sample distribution calculation:
  /// ```
  /// [1, 9, 9, 9, 3, 4, 4] => {
  ///   1: 1,
  ///   9: 3,
  ///   3: 1,
  ///   4: 2
  /// }
  /// ```
  final Iterable<int> values;

  /// Color of the data bars on the graph.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (values.isEmpty) {
      return Center(
        child: Text(localizations.errNoData),
      );
    }

    final distribution = <int, int>{};
    for (final v in values) {
      if(distribution.containsKey(v)) {
        distribution[v] = distribution[v]! + 1;
      } else {
        distribution[v] = 1;
      }
    }

    assert(distribution[distribution.keys.max]! > 0);
    assert(distribution[distribution.keys.min]! > 0);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 180,
        minHeight: 50,
      ),
      child: CustomPaint(
        painter: _ValueDistributionPainter(
          distribution,
          localizations,
          color,
        ),
      ),
    );
  }
  
}

/// Painter of a horizontal array of vertical bars.
class _ValueDistributionPainter extends CustomPainter {
  /// Create a painter of a horizontal array of vertical bars.
  _ValueDistributionPainter(
    this.distribution,
    this.localizations,
    this.barColor,
  );

  /// Positions and height of bars that make up the distribution.
  ///
  /// The key is the x order on the bar and it's value indicates it's relative
  /// height.
  ///
  /// The height of the bar is how often it occurs in a list of values.
  final Map<int, int> distribution;

  /// Text for labels on the graph and for semantics.
  final AppLocalizations localizations;

  /// Color of the data bars.
  final Color barColor;

  static const double _kDefaultBarGapWidth = 5.0;
  static const Color _kDecorationColor = Colors.white70;

  @override
  void paint(Canvas canvas, Size size) {
    assert(size.width >= 180, 'Canvas must be at least 180 pixels wide, to avoid overflows.');
    assert(size.height >= 50, 'Canvas must be at least 50 pixels high, to avoid overflows.');
    if (kDebugMode) {
      distribution.keys.every((e) => e >= 0);
    }

    // Adapt gap width in case of lots of gaps.
	  final int barNumber = distribution.keys.max - distribution.keys.min + 1;
    double barGapWidth = _kDefaultBarGapWidth;
    double barWidth = 0;
    while(barWidth < barGapWidth && barGapWidth > 1) {
      barGapWidth -= 1;
      barWidth = ((size.width + barGapWidth) // fix trailing gap
          / barNumber) - barGapWidth;
    }

	assert(barWidth > 0);
	assert(barGapWidth > 0);
	assert(barWidth*barNumber + barGapWidth*(barNumber-1) <= size.width);

    // Set height scale so that the largest element takes up the full height.
    // Ensures that the width of bars bars doesn't draw as overflow
    final double heightUnit = max(1, size.height - barWidth * 2)
        / distribution.values.max;
    assert(heightUnit > 0, '(${size.height} - $barWidth * 2) / '
        '${distribution.values.max}');

    final barPainter = Paint()
      ..color = barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    double barDrawXOffset = barWidth / 2; // don't clip left side of bar
    for (int xPos = distribution.keys.min; xPos <= distribution.keys.max; xPos++) {
      final length = heightUnit * (distribution[xPos] ?? 0);
      /// Offset from top so that the bar of [length] is centered.
      final startPos = (size.height - length) / 2;
      assert(barDrawXOffset >= 0 && barDrawXOffset <= size.width, '0 <= $barDrawXOffset <= ${size.width}');
      assert(startPos >= 0); assert(startPos <= size.height);
      assert((startPos + length) >= 0 && (startPos + length) <= size.height);
      canvas.drawLine(
        Offset(barDrawXOffset, startPos),
        Offset(barDrawXOffset, startPos + length),
        barPainter,
      );

      barDrawXOffset += barWidth + barGapWidth;
    }

    // Draw decorations on top:
    final decorationsPainter = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    double centerLineLength = 0.0;
    while (centerLineLength < size.width) {
      canvas.drawLine(
        Offset(centerLineLength, size.height / 2),
        Offset(min(centerLineLength + 8.0, size.width), size.height / 2),
        decorationsPainter..color = _kDecorationColor,
      );
      centerLineLength += 8.0 + 7.0;
    }

    /// Draws a decorative label above the center.
    ///
    /// [alignment] may only be [Alignment.centerLeft], [Alignment.center] or
    /// [Alignment.centerRight].
    void drawLabel(String text, Alignment alignment) {
      final style = TextStyle(
        color: _kDecorationColor,
        backgroundColor: Colors.black.withOpacity(0.5),
        fontSize: 16,
      );
      final textSpan = TextSpan(
        text: text,
        style: style,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final posX = switch(alignment) {
        Alignment.centerLeft => 0.0,
        Alignment.center => (size.width / 2)
            - (textPainter.width / 2).clamp(0, size.width),
        Alignment.centerRight => (size.width - textPainter.width)
            .clamp(0, size.width),
        _ => throw ArgumentError('Unsupported alignment'),
      };
      final position = Offset(
        posX.toDouble(),
        size.height / 2 - textPainter.height, // above center
      );
      assert(posX >= 0);
      assert((posX + textPainter.width) <= size.width);
      assert(position.dy >= 0);
      assert((position.dy + textPainter.height) <= size.height);
      textPainter.paint(canvas, position);
    }

    drawLabel(localizations.minOf(_min),
        Alignment.centerLeft,);
    drawLabel(localizations.avgOf(_average),
        Alignment.center,);
    drawLabel(localizations.maxOf(_max),
        Alignment.centerRight,);
  }

  @override
  bool shouldRepaint(covariant _ValueDistributionPainter oldDelegate) =>
      distribution == oldDelegate.distribution;

  @override
  bool shouldRebuildSemantics(covariant _ValueDistributionPainter oldDelegate)
      => distribution == oldDelegate.distribution;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => (Size size) {
    final oneThird = size.width / 3;
    return [
      CustomPainterSemantics(
        rect: Rect.fromLTRB(0, 0, oneThird, size.height),
        properties: SemanticsProperties(
          label: localizations.minOf(_min),
          textDirection: TextDirection.ltr,
        ),
      ),
      CustomPainterSemantics(
        rect: Rect.fromLTRB(oneThird, 0, 2 * oneThird, size.height),
        properties: SemanticsProperties(
          label: localizations.avgOf(_average),
          textDirection: TextDirection.ltr,
        ),
      ),
      CustomPainterSemantics(
        rect: Rect.fromLTRB(2 * oneThird, 0, size.width, size.height),
        properties: SemanticsProperties(
          label: localizations.maxOf(_max),
          textDirection: TextDirection.ltr,
        ),
      ),
    ];
  };

  /// Max (right end) value in distribution.
  String get _max => distribution.keys.max.toString();

  /// Min (left end) value in distribution.
  String get _min => distribution.keys.min.toString();

  /// Average value of distribution.
  String get _average {
    double sum = 0;
    int count = 0;
    for (int key = distribution.keys.min; key <= distribution.keys.max; key++) {
      sum += key * (distribution[key] ?? 0);
      count += (distribution[key] ?? 0);
    }
    return (sum / count).round().toString();
  }
}
