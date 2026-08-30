import 'package:flutter/material.dart';
import 'package:splitsies/models/balance.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/scrapbook_theme/highlight.dart';
import 'package:splitsies/scrapbook_theme/paper.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/tape.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';
import 'package:splitsies/screens/expense_detail.dart';
import 'package:splitsies/screens/new_expense.dart';
import 'package:splitsies/services/service_locator.dart';
import 'package:splitsies/services/expense_service.dart';
import 'package:splitsies/services/split_calculator.dart';
import 'package:splitsies/widgets/expense_item.dart';
import 'package:splitsies/widgets/scrap_button.dart';
import 'package:splitsies/widgets/upi_settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseService _service = getIt<ExpenseService>();

  void _deleteExpense(Expense expense) {
    _service.deleteExpense(expense.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Deleted "${expense.description}"',
            style: ScrapbookStyles.body(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: ScrapbookColors.washiYellow,
            onPressed: () => _service.restoreExpense(expense),
          ),
        ),
      );
  }

  void _openNewExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewExpense()),
    );
  }

  void _openExpenseDetail(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(expenseId: expense.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScrapbookColors.creamPaper,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScrapButton(
        label: 'add expense',
        icon: Icons.add_rounded,
        color: ScrapbookColors.stickyYellow,
        tapeColor: ScrapbookColors.washiPink,
        tapePattern: WashiPattern.diagonal,
        seed: 42,
        onPressed: _openNewExpense,
      ),
      body: TexturedPaper(
        baseColor: ScrapbookColors.creamPaper,
        roughness: 0,
        seed: 3,
        child: SafeArea(
          child: StreamBuilder<List<Expense>>(
            stream: _service.expenses$,
            initialData: _service.expenses,
            builder: (context, snapshot) {
              final expenses = snapshot.data ?? const <Expense>[];
              final total = SplitCalculator.totalSpent(expenses);
              final totalSelf = SplitCalculator.totalSpentSelf(expenses);
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _totalCard(total, totalSelf),
                  const SizedBox(height: 28),
                  _sectionLabel('activity', ScrapbookColors.washiYellow),
                  const SizedBox(height: 14),
                  _activityLog(expenses, total, expenses.length),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Flexible(
              flex: 2,
              child: Text(
                'Splitsies',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ScrapbookStyles.title(size: 46),
              ),
            ),
            Spacer(),
            Highlight(
              coverage: 100,
              overshoot: 0,
              rotation: 0.05,
              color: ScrapbookColors.washiBlue,
              child: IconButton(
                onPressed: () => showUpiSettingsDialog(context),
                icon: const Icon(Icons.qr_code_2_rounded, size: 28),
                color: ScrapbookColors.inkBlack,
                tooltip: 'your UPI details',
              ),
            ),
          ],
        ),
        Text('MAKE THEM PAY!!', style: ScrapbookStyles.typewriter(size: 11)),
      ],
    );
  }

  Widget _totalCard(double total, double totalSelf) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentGeometry.topCenter,
      children: [
        TornPaper(
          color: ScrapbookColors.receiptWhite,
          rotation: -0.008,
          seed: 11,
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL SPENT TOGETHER',
                style: ScrapbookStyles.typewriter(size: 11),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: ScrapbookStyles.title(size: 52),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1.4,
                color: ScrapbookColors.inkBrown.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _tallyChip('₹${totalSelf.toStringAsFixed(0)}', 'by you'),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -18,
          // right: 24,
          child: WashiTape(
            color: ScrapbookColors.washiYellow,
            pattern: WashiPattern.grid,
            width: 96,
            height: 32,
            rotation: -0.1,
            seed: 12,
          ),
        ),
      ],
    );
  }

  Widget _tallyChip(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: ScrapbookStyles.marker(size: 20)),
        Text(label, style: ScrapbookStyles.typewriter(size: 10)),
      ],
    );
  }

  Widget _sectionLabel(String text, Color tape) {
    return Row(
      children: [
        Transform.rotate(
          angle: -0.02,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            color: tape.withValues(alpha: 0.85),
            child: Text(text, style: ScrapbookStyles.marker(size: 16)),
          ),
        ),
      ],
    );
  }

  Widget _activityLog(List<Expense> expenses, double total, int slips) {
    if (expenses.isEmpty) {
      return TornNote(
        text: 'go touch some grass vro 😭✌️',
        color: ScrapbookColors.stickyYellow,
        font: NoteFont.handwriting,
        rotation: -0.02,
        seed: 99,
      );
    }
    return Column(
      children: [
        for (var i = 0; i < expenses.length; i++)
          Dismissible(
            key: ValueKey(expenses[i].id),
            direction: DismissDirection.endToStart,
            background: _dismissBackground(),
            onDismissed: (_) => _deleteExpense(expenses[i]),
            child: ExpenseItem(
              expense: expenses[i],
              onTap: () => _openExpenseDetail(expenses[i]),
              rotation: i.isEven ? -0.01 : 0.012,
              seed: 30 + i,
            ),
          ),
      ],
    );
  }

  Widget _dismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 28),
      decoration: BoxDecoration(
        color: ScrapbookColors.oweRed.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(Icons.delete_outline_rounded, color: ScrapbookColors.oweRed),
    );
  }
}
