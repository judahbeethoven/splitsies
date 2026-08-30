import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

enum WashiPattern { solid, diagonal, dots, chevron, grid, confetti }

class WashiTape extends StatelessWidget {
  final Color color;
  final Color? accent; // second color for patterns (defaults to white)
  final WashiPattern pattern;
  final double width;
  final double height;
  final double rotation;
  final double opacity;
  final int seed;
  final bool hasShadow;

  const WashiTape({
    super.key,
    required this.color,
    this.accent,
    this.pattern = WashiPattern.solid,
    this.width = 100,
    this.height = 30,
    this.rotation = -0.05,
    this.opacity = 0.85,
    this.seed = 1,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(width, height),
        painter: WashiTapePainter(
          color: color,
          accent: accent ?? Colors.white,
          pattern: pattern,
          opacity: opacity,
          seed: seed,
          hasShadow: hasShadow,
        ),
      ),
    );
  }
}

class WashiTapePainter extends CustomPainter {
  final Color color;
  final Color accent;
  final WashiPattern pattern;
  final double opacity;
  final int seed;
  final bool hasShadow;

  WashiTapePainter({
    required this.color,
    required this.accent,
    required this.pattern,
    required this.opacity,
    required this.seed,
    required this.hasShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed * 9301 + 49297);
    final tapePath = _tornEndsPath(size, rnd);

    if (hasShadow) {
      canvas.save();
      canvas.translate(1.5, 2);
      canvas.drawPath(
        tapePath,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.restore();
    }

    canvas.save();
    canvas.clipPath(tapePath);

    // base wash
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = color.withValues(alpha: opacity),
    );

    // pattern
    final ap = Paint()..color = accent;
    switch (pattern) {
      case WashiPattern.solid:
        break;

      case WashiPattern.diagonal:
        ap.strokeWidth = 5;
        for (double x = -size.height; x < size.width + size.height; x += 11) {
          canvas.drawLine(
            Offset(x, size.height + 4),
            Offset(x + size.height + 8, -4),
            ap,
          );
        }

      case WashiPattern.dots:
        const spacing = 12.0, r = 2.4;
        var flip = false;
        for (double y = spacing / 2; y < size.height + r; y += spacing) {
          final off = flip ? spacing / 2 : 0.0;
          for (double x = spacing / 2 + off; x < size.width + r; x += spacing) {
            canvas.drawCircle(Offset(x, y), r, ap);
          }
          flip = !flip;
        }

      case WashiPattern.chevron:
        ap.strokeWidth = 3.5;
        ap.style = PaintingStyle.stroke;
        const amp = 4.0, wl = 12.0;
        for (double y = 3; y < size.height + amp; y += 12) {
          final path = Path()..moveTo(-amp, y);
          var up = true;
          for (double x = 0; x < size.width + wl; x += wl) {
            path.lineTo(x, up ? y - amp : y + amp);
            up = !up;
          }
          canvas.drawPath(path, ap);
        }

      case WashiPattern.grid:
        ap.strokeWidth = 1;
        for (double x = 6; x < size.width; x += 12) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), ap);
        }
        for (double y = 6; y < size.height; y += 12) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), ap);
        }

      case WashiPattern.confetti:
        final count = (size.width * size.height / 380).round();
        for (var i = 0; i < count; i++) {
          canvas.save();
          canvas.translate(
            rnd.nextDouble() * size.width,
            rnd.nextDouble() * size.height,
          );
          canvas.rotate(rnd.nextDouble() * pi);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: 4 + rnd.nextDouble() * 4,
              height: 1.8,
            ),
            ap..color = accent.withValues(alpha: 0.4 + rnd.nextDouble() * 0.5),
          );
          canvas.restore();
        }
    }

    // paper fiber speckle
    final speckles = (size.width * size.height / 260).round();
    for (var i = 0; i < speckles; i++) {
      final light = rnd.nextBool();
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        0.5 + rnd.nextDouble(),
        Paint()
          ..color = (light ? Colors.white : Colors.black).withValues(
            alpha: light ? 0.08 : 0.04,
          ),
      );
    }

    // glossy sheen
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.05),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    canvas.restore();

    // edge highlight
    canvas.drawPath(
      tapePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.2),
    );
  }

  /// Straight long edges, jagged short ends — like hand-torn tape off the roll.
  Path _tornEndsPath(Size size, Random rnd) {
    const depth = 3.0;
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);

    double y = 0;
    while (y < size.height) {
      y = min(size.height, y + 2 + rnd.nextDouble() * 4);
      path.lineTo(size.width - rnd.nextDouble() * depth, y);
    }
    path.lineTo(0, size.height);

    double ly = size.height;
    final pts = <Offset>[];
    while (ly > 0) {
      ly = max(0.0, ly - (2 + rnd.nextDouble() * 4));
      pts.add(Offset(rnd.nextDouble() * depth, ly));
    }
    for (final p in pts) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant WashiTapePainter old) =>
      old.color != color ||
      old.accent != accent ||
      old.pattern != pattern ||
      old.opacity != opacity ||
      old.seed != seed;
}
