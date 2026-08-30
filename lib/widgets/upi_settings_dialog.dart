import 'dart:math';

import 'package:flutter/material.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/tape.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';
import 'package:splitsies/services/expense_validators.dart';
import 'package:splitsies/services/service_locator.dart';
import 'package:splitsies/services/user_settings_service.dart';
import 'package:splitsies/widgets/scrap_button.dart';

Future<void> showUpiSettingsDialog(BuildContext context) {
  final settings = getIt<UserSettingsService>();
  final upiCtrl = TextEditingController(text: settings.upiId);
  final nameCtrl = TextEditingController(text: settings.displayName);
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: _UpiSettingsCard(
        formKey: formKey,
        upiCtrl: upiCtrl,
        nameCtrl: nameCtrl,
        onSave: () async {
          if (!(formKey.currentState?.validate() ?? false)) return;
          await settings.setUpiId(upiCtrl.text);
          await settings.setDisplayName(nameCtrl.text);
          if (dialogContext.mounted) Navigator.pop(dialogContext);
        },
      ),
    ),
  );
}

class _UpiSettingsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController upiCtrl;
  final TextEditingController nameCtrl;
  final VoidCallback onSave;

  const _UpiSettingsCard({
    required this.formKey,
    required this.upiCtrl,
    required this.nameCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        TornPaper(
          color: ScrapbookColors.receiptWhite,
          rotation: -0.008,
          seed: 71,
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'your UPI details',
                      style: ScrapbookStyles.title(size: 40),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  'Name',
                  style: ScrapbookStyles.typewriter(
                    size: 16,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                _paperField(
                  child: TextFormField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: ScrapbookStyles.body(size: 15),
                    decoration: _fieldDeco('e.g. Lorenzo Von Matterhorn'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'UPI ID',
                  style: ScrapbookStyles.typewriter(
                    size: 16,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                _paperField(
                  child: TextFormField(
                    controller: upiCtrl,
                    style: ScrapbookStyles.body(size: 15),
                    decoration: _fieldDeco('yourname@bank'),
                    validator: ExpenseValidators.upiId,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(0, 4, 0, 0),
                        child: Text(
                          'Cancel',
                          style: ScrapbookStyles.typewriter(
                            size: 14,
                            color: ScrapbookColors.inkBrown,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ScrapButton(
                      label: 'Save',
                      dense: true,
                      color: ScrapbookColors.washiSage,
                      tapeColor: ScrapbookColors.washiYellow,
                      seed: 72,
                      onPressed: onSave,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -12,
          left: 24,
          child: WashiTape(
            color: ScrapbookColors.washiMint,
            pattern: WashiPattern.dots,
            width: 78,
            height: 22,
            rotation: -0.09,
            seed: 73,
          ),
        ),
      ],
    );
  }

  Widget _paperField({required Widget child}) {
    final colors = [
      ScrapbookColors.washiBlue,
      ScrapbookColors.washiCoral,
      ScrapbookColors.washiLilac,
      ScrapbookColors.washiPink,
      ScrapbookColors.washiPeach,
    ];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: ScrapbookColors.indexCard,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: ScrapbookColors.inkBlack.withAlpha(100)),
          ),
          child: child,
        ),
        Positioned(
          left: -5,
          child: WashiTape(
            color: colors[Random().nextInt(colors.length)],
            pattern: WashiPattern.grid,
            rotation: -pi / 4,
            width: 20,
            height: 10,
            hasShadow: false,
          ),
        ),
        Positioned(
          right: -5,
          bottom: 0,
          child: WashiTape(
            color: colors[Random().nextInt(colors.length)],
            pattern: WashiPattern.grid,
            rotation: -pi / 4,
            width: 20,
            height: 10,
            hasShadow: false,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: ScrapbookStyles.handwriting(
      size: 18,
      color: ScrapbookColors.inkBlack.withValues(alpha: 0.35),
    ),
    border: InputBorder.none,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 12),
    errorStyle: ScrapbookStyles.typewriter(
      size: 11,
      color: ScrapbookColors.oweRed,
    ),
  );
}
