import 'package:flutter/material.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';

/// One person's net standing, pinned up like a polaroid.
///
/// [net] > 0  → they're owed money (green, "gets back")
/// [net] < 0  → they owe money    (red, "owes")
/// [net] ≈ 0  → settled
class BalanceCard extends StatelessWidget {
  final String name;
  final double net;
  final bool isYou;
  final double rotation;
  final int seed;

  const BalanceCard({
    super.key,
    required this.name,
    required this.net,
    this.isYou = false,
    this.rotation = -0.03,
    this.seed = 1,
  });

  bool get _settled => net.abs() < 0.01;

  @override
  Widget build(BuildContext context) {
    final Color ink = _settled
        ? ScrapbookColors.inkBrown
        : net > 0
        ? ScrapbookColors.owedGreen
        : ScrapbookColors.oweRed;

    final String caption = _settled
        ? 'all square'
        : net > 0
        ? 'gets back'
        : 'owes';

    final IconData glyph = _settled
        ? Icons.check_rounded
        : net > 0
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 156,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
        decoration: BoxDecoration(
          color: ScrapbookColors.polaroid,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "photo" area
            Container(
              height: 66,
              alignment: Alignment.center,
              color: ink.withValues(alpha: 0.12),
              child: Icon(glyph, size: 28, color: ink),
            ),
            const SizedBox(height: 6),
            Text(
              isYou ? '$name (you)' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ScrapbookStyles.marker(size: 15),
            ),
            Text(caption, style: ScrapbookStyles.typewriter(size: 10)),
            const SizedBox(height: 2),
            Text(
              _settled ? '—' : '₹${net.abs().toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ScrapbookStyles.title(size: 24, color: ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single hand-scribbled settle-up instruction, e.g. "Rohan → You  ₹120".
class SettleLine extends StatelessWidget {
  final String from;
  final String to;
  final double amount;
  final double rotation;
  final int seed;

  const SettleLine({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    this.rotation = 0.015,
    this.seed = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TornPaper(
        color: ScrapbookColors.indexCard,
        rotation: rotation,
        seed: seed,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: ScrapbookStyles.handwriting(size: 17),
                  children: [
                    TextSpan(text: from),
                    TextSpan(
                      text: '  →  ',
                      style: ScrapbookStyles.handwriting(
                        size: 17,
                        color: ScrapbookColors.inkBrown,
                      ),
                    ),
                    TextSpan(text: to),
                  ],
                ),
              ),
            ),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: ScrapbookStyles.marker(size: 15),
            ),
          ],
        ),
      ),
    );
  }
}
