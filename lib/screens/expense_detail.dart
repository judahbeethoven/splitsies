import 'package:flutter/material.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/scrapbook_theme/paper.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/tape.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';
import 'package:splitsies/screens/qr_scanner_screen.dart';
import 'package:splitsies/services/expense_service.dart';
import 'package:splitsies/services/service_locator.dart';
import 'package:splitsies/services/upi_service.dart';
import 'package:splitsies/services/user_settings_service.dart';
import 'package:splitsies/widgets/category.dart';
import 'package:splitsies/widgets/pay_qr_sheet.dart';

/// Who owes what on one expense, and the tap-to-settle / QR-to-pay flow for
/// clearing it. Pushed when an [ExpenseItem] on the home screen is tapped.
class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    final service = getIt<ExpenseService>();

    return Scaffold(
      backgroundColor: ScrapbookColors.creamPaper,
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _topBar(context),
        const SizedBox(height: 4),
        _summaryCard(expense),
        const SizedBox(height: 18),
        _statusBanner(expense),
        const SizedBox(height: 22),
        _sectionLabel('paid the vendor'),
        const SizedBox(height: 10),
        _payerRow(context, expense),
        const SizedBox(height: 22),
        if (expense.owers.isNotEmpty) ...[
          _sectionLabel('owes ${expense.payer}'),
          const SizedBox(height: 6),
          Text(
            'tap a name once they\'ve paid you back',
            style: ScrapbookStyles.typewriter(size: 10),
          ),
          const SizedBox(height: 10),
          for (final person in expense.owers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _owerRow(context, expense, person),
            ),
        ],
      ],
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: ScrapbookColors.inkBrown,
          tooltip: 'Back',
        ),
        Expanded(
          child: Text(
            'the slip',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ScrapbookStyles.title(size: 34),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(Expense expense) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TornPaper(
          color: ScrapbookColors.receiptWhite,
          rotation: -0.006,
          seed: 61,
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
                      '${expense.payer} paid · split ${expense.participants.length} ways',
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
        ),
        Positioned(
          top: -10,
          left: 20,
          child: WashiTape(
            color: ScrapbookColors.washiMint,
            pattern: WashiPattern.dots,
            width: 70,
            height: 20,
            rotation: -0.1,
            seed: 62,
          ),
        ),
      ],
    );
  }

  Widget _statusBanner(Expense expense) {
    final (Color color, String label, IconData icon) = switch (expense
        .settleStatus) {
      SettleStatus.all => (
        ScrapbookColors.owedGreen,
        'all settled up',
        Icons.check_circle_rounded,
      ),
      SettleStatus.partial => (
        ScrapbookColors.darkKraft,
        '${expense.paidOwerCount}/${expense.owers.length} paid back',
        Icons.hourglass_bottom_rounded,
      ),
      SettleStatus.none => (
        ScrapbookColors.oweRed,
        'nobody has paid back yet',
        Icons.error_outline_rounded,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: ScrapbookStyles.marker(size: 13, color: color)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: ScrapbookStyles.marker(size: 15),
  );

  Widget _payerRow(BuildContext context, Expense expense) {
    final isSelf = expense.payer == 'You';
    return TornPaper(
      color: ScrapbookColors.indexCard,
      rotation: 0.006,
      seed: 63,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          if (isSelf)
            IconButton(
              tooltip: "scan vendor's QR",
              icon: const Icon(Icons.qr_code_scanner_rounded),
              color: ScrapbookColors.inkBrown,
              onPressed: () => _scanVendor(context),
            ),
        ],
      ),
    );
  }

  Future<void> _scanVendor(BuildContext context) async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (scanned == null || !context.mounted) return;

    if (!UpiService.looksLikeUpiUri(scanned)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("That doesn't look like a UPI QR")),
        );
      return;
    }
    final opened = await UpiService.launch(scanned);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not open a UPI app')),
        );
    }
  }

  Widget _owerRow(BuildContext context, Expense expense, String person) {
    final paid = expense.isPaidBy(person);
    final settings = getIt<UserSettingsService>();
    final color = paid ? ScrapbookColors.owedGreen : ScrapbookColors.inkBrown;

    return GestureDetector(
      onTap: () => getIt<ExpenseService>().setParticipantPaid(
        expense.id,
        person,
        !paid,
      ),
      child: TornPaper(
        color: paid
            ? ScrapbookColors.owedGreen.withValues(alpha: 0.16)
            : ScrapbookColors.receiptWhite,
        rotation: 0,
        seed: person.hashCode,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
