import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PaperShaders {
  static late ui.FragmentProgram _program;
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _program = await ui.FragmentProgram.fromAsset('shaders/paper.frag');
    _loaded = true;
  }

  static ui.FragmentShader newInstance() => _program.fragmentShader();
}

class ShaderPaperPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final Color baseColor;

  ShaderPaperPainter({
    required this.shader,
    this.baseColor = const Color(0xFFF5E6C8),
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, baseColor.r)
      ..setFloat(1, baseColor.g)
      ..setFloat(2, baseColor.b);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant ShaderPaperPainter old) =>
      old.baseColor != baseColor;
}

class TexturedPaper extends StatefulWidget {
  final Color baseColor;
  final double roughness;
  final double seed;
  final Widget? child;

  const TexturedPaper({
    super.key,
    this.baseColor = const Color(0xFFF5E6C8),
    this.roughness = 0.6,
    this.seed = 1.0,
    this.child,
  });

  @override
  State<TexturedPaper> createState() => _TexturedPaperState();
}

class _TexturedPaperState extends State<TexturedPaper> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    PaperShaders.load().then((_) {
      if (mounted) setState(() => _shader = PaperShaders.newInstance());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return ColoredBox(color: widget.baseColor, child: widget.child);
    }
    return CustomPaint(
      painter: ShaderPaperPainter(
        shader: _shader!,
        baseColor: widget.baseColor,
      ),
      child: widget.child ?? const SizedBox.expand(),
    );
  }
}
