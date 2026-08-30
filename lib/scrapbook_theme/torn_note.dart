import 'dart:math';
import 'package:flutter/material.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';

class TornPaper extends StatelessWidget {
  final Widget? child;
  final Color color;
  final Color? edgeColor;
  final double rotation;
  final double tornDepth;
  final int seed;
  final EdgeInsetsGeometry padding;
  final bool shadow;
  final double? width;
  final double? height;

  const TornPaper({
    super.key,
    this.child,
    this.color = ScrapbookColors.receiptWhite,
    this.edgeColor,
    this.rotation = 0,
    this.tornDepth = 5,
    this.seed = 1,
    this.padding = const EdgeInsets.all(18),
    this.shadow = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: TornPaperPainter(
        color: color,
        edgeColor: edgeColor ?? Color.lerp(color, Colors.white, 0.55)!,
        tornDepth: tornDepth,
        seed: seed,
        shadow: shadow,
      ),
      child: child == null
          ? SizedBox(width: width, height: height)
          : Padding(padding: padding, child: child),
    );
    return Transform.rotate(angle: rotation, child: content);
  }
}

class TornPaperPainter extends CustomPainter {
  final Color color;
  final Color edgeColor;
  final double tornDepth;
  final int seed;
  final bool shadow;

  TornPaperPainter({
    required this.color,
    required this.edgeColor,
    required this.tornDepth,
    required this.seed,
    required this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _tornRectPath(size, Random(seed), tornDepth, bias: 0.35);
    final inner = _tornRectPath(
      Size(size.width - 5, size.height - 5),
      Random(seed + 77),
      tornDepth * 0.9,
      origin: const Offset(2.5, 2.5),
      bias: 0.5,
    );

    if (shadow) {
      canvas.save();
      canvas.translate(2, 3);
      canvas.drawPath(
        outer,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.restore();
    }

    // frayed fiber fringe peeking out around the edges
    canvas.drawPath(outer, Paint()..color = edgeColor);
    // main sheet
    canvas.drawPath(inner, Paint()..color = color);
    // crease shading just inside the tear
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black.withValues(alpha: 0.06),
    );
  }

  Path _tornRectPath(
    Size size,
    Random rnd,
    double depth, {
    Offset origin = Offset.zero,
    double bias = 0.5,
  }) {
    const step = 7.0;
    final sides = [
      (Offset.zero, Offset(size.width, 0), const Offset(0, -1)), // top
      (
        Offset(size.width, 0),
        Offset(size.width, size.height),
        const Offset(1, 0),
      ),
      (
        Offset(size.width, size.height),
        Offset(0, size.height),
        const Offset(0, 1),
      ),
      (Offset(0, size.height), Offset.zero, const Offset(-1, 0)), // left
    ];

    final path = Path();
    var first = true;
    for (final (a, b, normal) in sides) {
      final dist = (b - a).distance;
      final nSeg = (dist / step).ceil();
      for (var i = 0; i <= nSeg; i++) {
        final base = Offset.lerp(a, b, i / nSeg)!;
        final p = base + normal * ((rnd.nextDouble() - bias) * depth) + origin;
        first ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        first = false;
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant TornPaperPainter old) =>
      old.color != color ||
      old.edgeColor != edgeColor ||
      old.tornDepth != tornDepth ||
      old.seed != seed;
}

// ---------------------------------------------------------------------------
// TORN NOTE — text on a scrap, with a font role
// ---------------------------------------------------------------------------

enum NoteFont { handwriting, typewriter, marker }

class TornNote extends StatelessWidget {
  final String text;
  final Color color;
  final NoteFont font;
  final TextStyle? style; // wins over `font` if set
  final double? fontSize;
  final double rotation;
  final int seed;

  const TornNote({
    super.key,
    required this.text,
    this.color = ScrapbookColors.receiptWhite,
    this.font = NoteFont.handwriting,
    this.style,
    this.fontSize,
    this.rotation = 0,
    this.seed = 1,
  });

  @override
  Widget build(BuildContext context) {
    final effective =
        style ??
        switch (font) {
          NoteFont.handwriting => ScrapbookStyles.handwriting(
            size: fontSize ?? 18,
          ),
          NoteFont.typewriter => ScrapbookStyles.typewriter(
            size: fontSize ?? 13,
          ),
          NoteFont.marker => ScrapbookStyles.marker(size: fontSize ?? 15),
        };
    return TornPaper(
      color: color,
      rotation: rotation,
      seed: seed,
      child: Text(text, style: effective),
    );
  }
}
