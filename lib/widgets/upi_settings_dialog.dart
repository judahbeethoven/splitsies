import 'package:flutter/material.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/services/expense_validators.dart';
import 'package:splitsies/services/service_locator.dart';
import 'package:splitsies/services/user_settings_service.dart';
import 'package:splitsies/widgets/scrap_button.dart';

/// Edit-your-own-UPI-details dialog. Since only you can ever be the payer,
/// this is asked for once and reused everywhere a QR needs to point at you.
Future<void> showUpiSettingsDialog(BuildContext context) {
  final settings = getIt<UserSettingsService>();
  final upiCtrl = TextEditingController(text: settings.upiId);
  final nameCtrl = TextEditingController(text: settings.displayName);
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: ScrapbookColors.receiptWhite,
      title: Text('your UPI details', style: ScrapbookStyles.title(size: 26)),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('name', style: ScrapbookStyles.marker(size: 13)),
            TextFormField(
              controller: nameCtrl,
              style: ScrapbookStyles.body(size: 15),
              decoration: const InputDecoration(hintText: 'e.g. Rohan'),
            ),
            const SizedBox(height: 14),
            Text('UPI ID', style: ScrapbookStyles.marker(size: 13)),
            TextFormField(
              controller: upiCtrl,
              style: ScrapbookStyles.body(size: 15),
              decoration: const InputDecoration(hintText: 'yourname@bank'),
              validator: ExpenseValidators.upiId,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('cancel'),
        ),
        ScrapButton(
          label: 'save',
          dense: true,
          color: ScrapbookColors.washiSage,
          onPressed: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            await settings.setUpiId(upiCtrl.text);
            await settings.setDisplayName(nameCtrl.text);
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
        ),
      ],
    ),
  );
}
