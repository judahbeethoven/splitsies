import 'package:flutter/material.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';

/// Re-export so existing UI imports of `widgets/category.dart` keep working;
/// the canonical enum lives on the model.
export 'package:splitsies/models/expense.dart' show ExpenseCategory;

/// Presentation for each [ExpenseCategory] — label, icon, washi colour.
/// Kept out of the model so the domain layer stays Flutter-free.
extension ExpenseCategoryStyle on ExpenseCategory {
  String get label => switch (this) {
    ExpenseCategory.autoRide => 'Auto ride',
    ExpenseCategory.subscription => 'Subscription',
    ExpenseCategory.food => 'Food',
    ExpenseCategory.printout => 'Printout',
    ExpenseCategory.other => 'Other',
  };

  IconData get icon => switch (this) {
    ExpenseCategory.autoRide => Icons.local_taxi_rounded,
    ExpenseCategory.subscription => Icons.subscriptions_rounded,
    ExpenseCategory.food => Icons.restaurant_rounded,
    ExpenseCategory.printout => Icons.print_rounded,
    ExpenseCategory.other => Icons.receipt_long_rounded,
  };

  /// Washi tint used behind the category's icon stamp.
  Color get color => switch (this) {
    ExpenseCategory.autoRide => ScrapbookColors.washiYellow,
    ExpenseCategory.subscription => ScrapbookColors.washiLilac,
    ExpenseCategory.food => ScrapbookColors.washiCoral,
    ExpenseCategory.printout => ScrapbookColors.washiSky,
    ExpenseCategory.other => ScrapbookColors.washiSage,
  };
}

/// A little rubber-stamp square with the category icon — used in list rows
/// and as the leading glyph on the form.
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
