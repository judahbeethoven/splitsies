import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/tape.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';
import 'package:splitsies/services/upi_service.dart';
import 'package:splitsies/widgets/scrap_button.dart';

/// Bottom sheet a participant sees when they tap the QR icon next to their
/// name: a UPI QR (and a direct "open UPI app" button) that pays [payeeName]
/// at [vpa] exactly [amount].
Future<void> showPayQrSheet(
  BuildContext context, {
  required String vpa,
  required String payeeName,
  required double amount,
  String? note,
}) {
  final uri = UpiService.buildPayUri(
    vpa: vpa,
    payeeName: payeeName,
    amount: amount,
    note: note,
  );
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        _PayQrSheet(uri: uri, payeeName: payeeName, amount: amount),
  );
}

class _PayQrSheet extends StatelessWidget {
  final String uri;
  final String payeeName;
  final double amount;

  const _PayQrSheet({
    required this.uri,
    required this.payeeName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            TornPaper(
              color: ScrapbookColors.receiptWhite,
              rotation: -0.006,
              seed: 55,
              padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('pay $payeeName', style: ScrapbookStyles.title(size: 28)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: ScrapbookStyles.marker(size: 22),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(1, 3),
                        ),
                      ],
                    ),
                    child: QrImageView(data: uri, size: 200),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'scan this with any UPI app',
                    style: ScrapbookStyles.typewriter(size: 11),
                  ),
                  const SizedBox(height: 18),
                  ScrapButton(
                    label: 'open UPI app',
                    icon: Icons.qr_code_rounded,
                    color: ScrapbookColors.washiSage,
                    tapeColor: ScrapbookColors.washiYellow,
                    seed: 56,
                    onPressed: () => UpiService.launch(uri),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -6,
              child: WashiTape(
                color: ScrapbookColors.washiPink,
                pattern: WashiPattern.chevron,
                width: 84,
                height: 22,
                rotation: 0.08,
                seed: 57,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
