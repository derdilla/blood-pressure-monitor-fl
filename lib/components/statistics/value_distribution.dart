// TODO: test

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A statistic that shows how often values occur in a list of values.
///
/// Shows in form of a graph that has centered columns of different height and
/// labels that indicate min, max and average.
class LinearBarDistribution extends StatelessWidget {
  /// Create a statistic to show how often values occur.
  const LinearBarDistribution({
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
    final distribution = <int, double>{};
    for (final v in values) {
      if(distribution.containsKey(v)) {
        distribution[v] = distribution[v]! + 1.0;
      } else {
        distribution[v] = 1.0;
      }
    }
    // Fill values between
    for (int x = distribution.keys.min + 1; x < distribution.keys.max -1; x++) {
      if (!distribution.containsKey(x)) distribution[x] = 0;
    }
    assert(distribution[distribution.keys.max]! > 0);
    assert(distribution[distribution.keys.min]! > 0);
    return CustomPaint(
      painter: _LinearBarDistributionPainter(
        distribution,
        AppLocalizations.of(context)!,
        color,
      ),
    );
  }
  
}

/// Painter of a horizontal array vertical bars.
class _LinearBarDistributionPainter extends CustomPainter {
  /// Painter of a horizontal array vertical bars.
  _LinearBarDistributionPainter(
    this.distribution,
    this.localizations,
    this.barColor,
  );

  /// Positions and height of bars that make up the distribution.
  ///
  /// The key is the x order on the bar and it's value indicates it's relative
  /// height.
  final Map<int, double> distribution;

  final AppLocalizations localizations;

  /// Color of the data bars.
  final Color barColor;

  static const double _kDefaultBarGapWidth = 5.0;
  static const Color _kDecorationColor = Colors.white70;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the values:
    final barWidth = ((size.width + _kDefaultBarGapWidth) // no trailing space
        / distribution.length) - _kDefaultBarGapWidth;

    // Set height so that the largest element takes up the full height.
    final double heightUnit = (size.height - barWidth * 2)
        / distribution.values.max;

    final barPainter = Paint()
      ..color = barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    double xOffset = barWidth / 2;
    for (final xPos in distribution.keys) {
      final length = heightUnit * distribution[xPos]!;
      final startPos = (size.height - length) / 2; // centered
      canvas.drawLine(
        Offset(xOffset, startPos),
        Offset(xOffset, startPos + length),
        barPainter,
      );

      xOffset += barWidth + _kDefaultBarGapWidth;
    }

    // Draw decorations on top:
    final decorationsPainter = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    double centerLineLength = 0.0;
    while (centerLineLength < size.width) {
      canvas.drawLine(
        Offset(centerLineLength, size.height / 2),
        Offset(centerLineLength + 8.0, size.height / 2),
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
        fontSize: 12,
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
        Alignment.centerRight => size.width - textPainter.width,
        Alignment.center => (size.width / 2) - (textPainter.width / 2),
        _ => throw ArgumentError('Invalid '),
      };
      final position = Offset(
        posX,
        size.height / 2 - textPainter.height, // above center
      );
      textPainter.paint(canvas, position);
    }

    drawLabel(localizations.minOf(distribution.keys.min.toString()),
        Alignment.centerLeft,);
    drawLabel(localizations.avgOf(distribution.keys.average.round().toString()),
        Alignment.center,);
    drawLabel(localizations.maxOf(distribution.keys.max.toString()),
        Alignment.centerRight,);
  }

  @override
  bool shouldRepaint(covariant _LinearBarDistributionPainter oldDelegate) =>
      distribution == oldDelegate.distribution;
  
}