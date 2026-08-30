import 'package:flutter/material.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/tape.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';

/// A tactile "paper tab" button: a torn scrap held down by a strip of washi
/// tape, that presses in when you tap it. Purely presentational — hand it an
/// [onPressed].
class ScrapButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color tapeColor;
  final WashiPattern tapePattern;
  final double rotation;
  final int seed;
  final bool dense;

  const ScrapButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = ScrapbookColors.stickyYellow,
    this.tapeColor = ScrapbookColors.washiMint,
    this.tapePattern = WashiPattern.dots,
    this.rotation = -0.02,
    this.seed = 1,
    this.dense = false,
  });

  @override
  State<ScrapButton> createState() => _ScrapButtonState();
}

class _ScrapButtonState extends State<ScrapButton> {
  bool _down = false;

  void _set(bool v) {
    if (mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final pad = widget.dense
        ? const EdgeInsets.fromLTRB(14, 8, 14, 10)
        : const EdgeInsets.fromLTRB(22, 12, 22, 14);

    final tab = TornPaper(
      color: widget.color,
      rotation: widget.rotation,
      seed: widget.seed,
      padding: pad,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: widget.dense ? 16 : 20,
              color: ScrapbookColors.inkBlack,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: ScrapbookStyles.marker(size: widget.dense ? 14 : 17),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(padding: const EdgeInsets.only(top: 9), child: tab),
                Positioned(
                  top: -2,
                  child: WashiTape(
                    color: widget.tapeColor,
                    pattern: widget.tapePattern,
                    width: widget.dense ? 60 : 78,
                    height: 20,
                    rotation: 0.06,
                    seed: widget.seed + 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
