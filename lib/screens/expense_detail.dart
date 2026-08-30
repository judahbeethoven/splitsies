import 'package:flutter/material.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/scrapbook_theme/paper.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/tape.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';
import 'package:splitsies/services/expense_service.dart';
import 'package:splitsies/services/service_locator.dart';
import 'package:splitsies/services/user_settings_service.dart';
import 'package:splitsies/widgets/category.dart';
import 'package:splitsies/widgets/pay_qr_sheet.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    final service = getIt<ExpenseService>();

    return Scaffold(
      backgroundColor: ScrapbookColors.creamPaper,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _topBar(context),
        iconTheme: IconThemeData(color: ScrapbookColors.inkBrown),
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      body: TexturedPaper(
        baseColor: ScrapbookColors.creamPaper,
        roughness: 0,
        seed: 9,
        child: SafeArea(
          child: StreamBuilder<List<Expense>>(
            stream: service.expenses$,
            initialData: service.expenses,
            builder: (context, snapshot) {
              final expenses = snapshot.data ?? const <Expense>[];
              Expense? expense;
              for (final e in expenses) {
                if (e.id == expenseId) expense = e;
              }
              if (expense == null) {
                // Deleted out from under us — back out quietly.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                });
                return const SizedBox.shrink();
              }
              return _body(context, expense);
            },
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Expense expense) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _summaryCard(expense),
          const SizedBox(height: 32),
          Expanded(child: _payments(context, expense)),
        ],
      ),
    );
  }

  Widget _payments(BuildContext context, Expense expense) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentGeometry.topCenter,
      children: [
        TornPaper(
          hasInner: false,
          hasCrease: false,
          padding: EdgeInsetsGeometry.all(12),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              spacing: 2.0,
              children: [
                const SizedBox(height: 10),
                _sectionLabel("Payments"),
                const SizedBox(height: 10),
                _payerRow(context, expense),

                if (expense.owers.isNotEmpty) ...[
                  // const SizedBox(height: 10),
                  for (final person in expense.owers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: _owerRow(context, expense, person),
                    ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          top: -16,
          child: WashiTape(
            color: ScrapbookColors.washiLilac,
            pattern: WashiPattern.diagonal,
            // width: 90,
            // height: 30,
            rotation: -0.1,
            seed: 62,
            hasShadow: false,
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context) {
    return Text(
      'the slip',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ScrapbookStyles.title(size: 34),
    );
  }

  Widget _summaryCard(Expense expense) {
    return TornPaper(
      color: ScrapbookColors.receiptWhite,
      shadow: false,
      tornDepth: 1,
      rotation: -0.006,
      seed: 61,
      edgeColor: expense.allSettled
          ? ScrapbookColors.owedGreen
          : ScrapbookColors.oweRed,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryStamp(category: expense.category),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: ScrapbookStyles.handwriting(size: 22),
                ),
                const SizedBox(height: 2),
                Text(
                  'split ${expense.participants.length} ways',
                  style: ScrapbookStyles.typewriter(size: 11),
                ),
              ],
            ),
          ),
          Text(
            '₹${expense.amount.toStringAsFixed(2)}',
            style: ScrapbookStyles.marker(size: 20),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: ScrapbookStyles.title(size: 48, color: ScrapbookColors.inkBrown),
  );

  Widget _payerRow(BuildContext context, Expense expense) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: ScrapbookColors.inkBlack.withAlpha(200),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_rounded, color: ScrapbookColors.inkBrown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.payer, style: ScrapbookStyles.body(size: 15)),
                Text(
                  '₹${expense.amount.toStringAsFixed(2)} to the vendor',
                  style: ScrapbookStyles.typewriter(size: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _owerRow(BuildContext context, Expense expense, String person) {
    final paid = expense.isPaidBy(person);
    final settings = getIt<UserSettingsService>();
    final color = paid ? ScrapbookColors.owedGreen : ScrapbookColors.inkBrown;

    return GestureDetector(
      onTap: () =>
          getIt<ExpenseService>().setParticipantPaid(expense.id, person, !paid),
      child: Container(
        padding: const EdgeInsets.all(12.0),

        color: ScrapbookColors.indexCard.withAlpha(1),
        child: Row(
          children: [
            Icon(
              paid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person, style: ScrapbookStyles.body(size: 15)),
                  Text(
                    paid
                        ? 'paid ₹${expense.nominalShare.toStringAsFixed(2)}'
                        : 'owes ₹${expense.nominalShare.toStringAsFixed(2)}',
                    style: ScrapbookStyles.typewriter(size: 10, color: color),
                  ),
                ],
              ),
            ),
            if (!paid && expense.payer == 'You')
              IconButton(
                tooltip: 'show QR to pay',
                icon: const Icon(Icons.qr_code_rounded),
                color: ScrapbookColors.inkBrown,
                onPressed: () => showPayQrSheet(
                  context,
                  vpa: settings.upiId,
                  payeeName: settings.displayName,
                  amount: expense.nominalShare,
                  note: expense.description,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
