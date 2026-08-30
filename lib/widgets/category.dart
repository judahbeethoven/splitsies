import 'package:flutter/material.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';

export 'package:splitsies/models/expense.dart' show ExpenseCategory;

extension ExpenseCategoryStyle on ExpenseCategory {
  String get label => switch (this) {
    ExpenseCategory.travel => 'Travel',
    ExpenseCategory.subscription => 'Subscription',
    ExpenseCategory.food => 'Food',
    ExpenseCategory.supplies => 'Supplies',
    ExpenseCategory.other => 'Other',
    ExpenseCategory.outing => 'Outing',
  };

  IconData get icon => switch (this) {
    ExpenseCategory.travel => Icons.local_taxi_rounded,
    ExpenseCategory.subscription => Icons.subscriptions_rounded,
    ExpenseCategory.food => Icons.restaurant_rounded,
    ExpenseCategory.supplies => Icons.print_rounded,
    ExpenseCategory.other => Icons.receipt_long_rounded,
    ExpenseCategory.outing => Icons.forest,
  };

  Color get color => switch (this) {
    ExpenseCategory.travel => ScrapbookColors.washiYellow,
    ExpenseCategory.subscription => ScrapbookColors.washiLilac,
    ExpenseCategory.food => ScrapbookColors.washiCoral,
    ExpenseCategory.supplies => ScrapbookColors.washiSky,
    ExpenseCategory.other => ScrapbookColors.washiSage,
    ExpenseCategory.outing => const Color.fromARGB(255, 233, 133, 161),
  };
}

class CategoryStamp extends StatelessWidget {
  final ExpenseCategory category;
  final double size;
  final double rotation;

  const CategoryStamp({
    super.key,
    required this.category,
    this.size = 44,
    this.rotation = -0.04,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 3,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Icon(
          category.icon,
          size: size * 0.52,
          color: ScrapbookColors.inkBrown,
        ),
      ),
    );
  }
}
