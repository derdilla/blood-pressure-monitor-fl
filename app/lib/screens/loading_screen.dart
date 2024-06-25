import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Loading page that is displayed on app start.
///
/// Contains a simplified app logo animation.
class LoadingScreen extends StatelessWidget {
  /// Loading page that is displayed on app start.
  const LoadingScreen({super.key});

  static const _duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    return MaterialApp(
      home: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: _duration,
          builder: (BuildContext context, double value, Widget? child) => Container(
              padding: const EdgeInsets.only(bottom: 100),
              child: SizedBox.square(
                dimension: max(0, dimensions.width - 20),
                child: CustomPaint(
                  painter: _LogoPainter(progress: value),
                ),
              ),
            ),
        ),
      ),
    );
  }
}

/// Paints the logo of the App.
class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.progress});

  /// Percentage of the logo to be drawn (ranges from 0 to 1).
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 0xb0, 0x18, 0x22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide / 20
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.15, size.height * 0.4);
    path.lineTo(size.width * 0.27, size.height * 0.3);
    path.lineTo(size.width * 0.37, size.height * 0.31);
    path.lineTo(size.width * 0.5, size.height * 0.43);
    path.lineTo(size.width * 0.63, size.height * 0.32);
    path.lineTo(size.width * 0.74, size.height * 0.31);
    path.lineTo(size.width * 0.76, size.height * 0.32);
    path.lineTo(size.width * 0.82, size.height * 0.42);
    path.lineTo(size.width * 0.818, size.height * 0.45);
    path.lineTo(size.width * 0.65, size.height * 0.65);
    canvas.drawPath(_subPath(path, progress), paint);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.progress != progress;

  /// Get a percentage of [originalPath].
  ///
  /// [animationPercent] is a value from 0 to 1.
  Path _subPath(Path originalPath, double animationPercent,) {
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    return _extractPathUntilLength(originalPath, totalLength * animationPercent);
  }

  Path _extractPathUntilLength(Path originalPath, double length,) {
    final path = Path();

    final metricsIterator = originalPath.computeMetrics().iterator;
    var isLastSegment = false;
    var currentLength = 0.0;

    while (metricsIterator.moveNext() && !isLastSegment) {
      final metric = metricsIterator.current;

      final nextLength = currentLength + metric.length;
      isLastSegment = (nextLength > length);

      assert(length - currentLength >= 0);
      final pathSegment = metric.extractPath(0.0,
          min(length - currentLength, metric.length),);

      path.addPath(pathSegment, Offset.zero);

      currentLength = nextLength;
    }

    return path;
  }
}
