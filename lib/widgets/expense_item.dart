import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';
import 'package:splitsies/widgets/category.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final double rotation;
  final int seed;

  const ExpenseItem({
    super.key,
    required this.expense,
    this.onTap,
    this.rotation = 0,
    this.seed = 1,
  });

  Color _statusColor() => switch (expense.settleStatus) {
    SettleStatus.all => ScrapbookColors.owedGreen,
    SettleStatus.partial => ScrapbookColors.washiYellow,
    SettleStatus.none => ScrapbookColors.oweRed,
  };

  @override
  Widget build(BuildContext context) {
    final stamp = DateFormat('MMM d · h:mm a').format(expense.createdAt);
    final statusColor = _statusColor();

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TornPaper(
          color: ScrapbookColors.receiptWhite,
          rotation: rotation,
          seed: seed,
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 54,
                margin: const EdgeInsets.only(right: 10, top: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              CategoryStamp(
                category: expense.category,
                rotation: -0.05 + rotation,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ScrapbookStyles.handwriting(size: 19),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'split ${expense.participants.length} ways',
                      style: ScrapbookStyles.typewriter(size: 11),
                    ),
                    Text(stamp, style: ScrapbookStyles.typewriter(size: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: ScrapbookStyles.marker(size: 17),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${expense.nominalShare.toStringAsFixed(2)} ea',
                    style: ScrapbookStyles.typewriter(size: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
