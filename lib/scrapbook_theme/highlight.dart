import 'dart:math';
import 'package:flutter/material.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';

class Highlight extends StatelessWidget {
  final Widget child;
  final Color color;
  final double rotation;
  final int seed;
  final EdgeInsetsGeometry padding;
  final double coverage;
  final double overshoot;

  const Highlight({
    super.key,
    required this.child,
    this.color = ScrapbookColors.washiYellow,
    this.rotation = -0.01,
    this.seed = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    this.coverage = 100.0,
    this.overshoot = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      // alignment: AlignmentGeometry.center,
      children: [
        Transform.rotate(
          angle: rotation,
          child: CustomPaint(
            painter: _HighlightPainter(
              color: color,
              seed: seed,
              coverage: coverage,
              overshoot: overshoot,
            ),
            child: Padding(
              padding: padding,
              child: Opacity(opacity: 0.0, child: child),
            ),
          ),
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}

class _HighlightPainter extends CustomPainter {
  final Color color;
  final int seed;
  final double coverage;
  final double overshoot;

  _HighlightPainter({
    required this.color,
    required this.seed,
    required this.coverage,
    required this.overshoot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed * 7919 + 13);
    final stroke = _strokePath(size, rnd);

    canvas.drawPath(
      stroke,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..blendMode = BlendMode.multiply,
    );
  }

  Path _strokePath(Size _size, Random rnd) {
    // y corerction for when the coverage is lower than 100 so that the highlight is always centered
    final yCorrection = _size.height * (0.5 - coverage * 0.005);
    final Size size = Size(
      _size.width,
      yCorrection + _size.height * coverage * 0.01,
    );

    double overshootX = overshoot;
    const depth = 2.5;
    final left = -overshootX;
    final right = size.width + overshootX;

    final path = Path()..moveTo(left, yCorrection);
    path.lineTo(right, yCorrection); // straight top

    double y = yCorrection;
    while (y < size.height) {
      y = min(size.height, y + 2 + rnd.nextDouble() * 3);
      path.lineTo(right + (rnd.nextDouble() - 0.5) * depth, y);
    }

    path.lineTo(left, size.height); // straight bottom

    double ly = size.height;
    while (ly > yCorrection) {
      ly = max(yCorrection, ly - (2 + rnd.nextDouble() * 3));
      path.lineTo(left + (rnd.nextDouble() - 0.5) * depth, ly);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter old) =>
      old.color != color || old.seed != seed;
}
