import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitsies/scrapbook_theme/highlight.dart';
import 'package:uuid/uuid.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/scrapbook_theme/paper.dart';
import 'package:splitsies/scrapbook_theme/styles.dart';
import 'package:splitsies/scrapbook_theme/tape.dart';
import 'package:splitsies/scrapbook_theme/torn_note.dart';
import 'package:splitsies/services/service_locator.dart';
import 'package:splitsies/services/expense_service.dart';
import 'package:splitsies/services/expense_validators.dart';
import 'package:splitsies/services/user_settings_service.dart';
import 'package:splitsies/widgets/category.dart';
import 'package:splitsies/widgets/scrap_button.dart';
import 'package:splitsies/widgets/upi_settings_dialog.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key});

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  static const String _selfName = 'You';

  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _personCtrl = TextEditingController();

  final List<String> _participants = [_selfName];
  ExpenseCategory _category = ExpenseCategory.food;
  final String _paidBy = _selfName;
  String? _participantError;

  late final int _pageSeed;

  @override
  void initState() {
    super.initState();
    _pageSeed = Random().nextInt(1 << 32);
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _personCtrl.dispose();
    super.dispose();
  }

  double? get _previewSplit {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0 || _participants.isEmpty) return null;
    return amount / _participants.length;
  }

  void _addPerson() {
    final name = _personCtrl.text.trim();
    if (name.isEmpty) return;
    if (_participants.any((p) => p.toLowerCase() == name.toLowerCase())) {
      _personCtrl.clear();
      return;
    }
    setState(() {
      _participants.add(name);
      _personCtrl.clear();
      _participantError = null;
    });
  }

  void _removePerson(String name) {
    if (name == _selfName) return;
    setState(() => _participants.remove(name));
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    final peopleError =
        ExpenseValidators.participants(_participants) ??
        ExpenseValidators.payer(_paidBy, _participants, selfName: _selfName);
    setState(() => _participantError = peopleError);
    if (!formOk || peopleError != null) return;

    final settings = getIt<UserSettingsService>();
    if (!settings.hasUpiId) {
      await showUpiSettingsDialog(context);

      if (!settings.hasUpiId) return;
    }

    final expense = Expense(
      id: const Uuid().v4(),
      description: _descCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category,
      participants: List.of(_participants),
      payer: _paidBy,
      createdAt: DateTime.now(),
    );
    getIt<ExpenseService>().addExpense(expense);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScrapbookColors.creamPaper,
      body: TexturedPaper(
        baseColor: ScrapbookColors.creamPaper,
        roughness: 0,
        seed: 7,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      _label('what was it for?'),
                      _paperField(
                        seed: 1,
                        child: TextFormField(
                          controller: _descCtrl,
                          textCapitalization: TextCapitalization.sentences,
                          style: ScrapbookStyles.handwriting(size: 20),
                          decoration: _fieldDeco('e.g. Auto to campus'),
                          validator: ExpenseValidators.description,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _label('how much?'),
                      _paperField(
                        seed: 2,
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          style: ScrapbookStyles.title(size: 30),
                          decoration: _fieldDeco('0.00').copyWith(
                            prefixText: '₹ ',
                            prefixStyle: ScrapbookStyles.title(size: 30),
                          ),
                          validator: ExpenseValidators.amount,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _label('category'),
                      const SizedBox(height: 4),
                      _categoryPicker(),
                      const SizedBox(height: 24),
                      _label("who's splitting?"),
                      const SizedBox(height: 4),
                      _participantPicker(),
                      if (_participantError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _participantError!,
                          style: ScrapbookStyles.typewriter(
                            size: 11,
                            color: ScrapbookColors.oweRed,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _splitPreview(),
                      const SizedBox(height: 28),
                      Center(
                        child: ScrapButton(
                          label: 'save expense',
                          icon: Icons.push_pin_rounded,
                          color: ScrapbookColors.washiSage,
                          tapeColor: ScrapbookColors.washiYellow,
                          tapePattern: WashiPattern.chevron,
                          seed: 8,
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── pieces ───────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: ScrapbookColors.inkBrown,
            tooltip: 'Back',
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              'New Expense',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ScrapbookStyles.title(size: 36),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: WashiTape(
              color: ScrapbookColors.washiMint,
              pattern: WashiPattern.dots,
              width: 64,
              height: 20,
              rotation: 0.12,
              seed: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    final rnd = Random(_pageSeed ^ text.hashCode);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Highlight(
        overshoot: 0,
        rotation: ((rnd.nextDouble() * 12) - 6) / 100,
        color: ScrapbookColors.washiPink,
        coverage: 50,
        child: Text(
          text,
          style: ScrapbookStyles.typewriter(
            size: 16,
          ).copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _paperField({required Widget child, int seed = 0}) {
    final rnd = Random(_pageSeed ^ seed);
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
            color: colors[rnd.nextInt(colors.length)],
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
            color: colors[rnd.nextInt(colors.length)],
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

  Widget _categoryPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in ExpenseCategory.values)
          _WashiChip(
            selected: _category == c,
            color: c.color,
            icon: c.icon,
            label: c.label,
            onTap: () => setState(() => _category = c),
          ),
      ],
    );
  }

  Widget _participantPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in _participants)
              Chip(
                label: Text(p, style: ScrapbookStyles.body(size: 13)),
                backgroundColor: ScrapbookColors.washiSky.withValues(
                  alpha: 0.6,
                ),
                side: BorderSide(
                  color: ScrapbookColors.inkBrown.withValues(alpha: 0.25),
                ),
                deleteIcon: p == _selfName
                    ? null
                    : const Icon(Icons.close_rounded, size: 16),
                onDeleted: p == _selfName ? null : () => _removePerson(p),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _paperField(
                seed: 3,
                child: TextField(
                  controller: _personCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: ScrapbookStyles.body(size: 15),
                  decoration: _fieldDeco('add a name'),
                  onSubmitted: (_) => _addPerson(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Highlight(
              padding: EdgeInsetsGeometry.zero,
              overshoot: 0,
              child: IconButton(
                onPressed: _addPerson,
                icon: Icon(Icons.add),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _splitPreview() {
    final each = _previewSplit;
    if (each == null) return Container();
    return Center(
      child: TornNote(
        text:
            '≈ ₹${each.toStringAsFixed(2)} each\n${_participants.length} people, split equally',
        color: ScrapbookColors.indexCard,
        font: NoteFont.typewriter,
        fontSize: 13,
        rotation: -0.02,
        seed: 21,
      ),
    );
  }
}

class _WashiChip extends StatelessWidget {
  final bool selected;
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WashiChip({
    required this.selected,
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.95 : 0.4),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected
                ? ScrapbookColors.inkBrown
                : ScrapbookColors.inkBrown.withValues(alpha: 0.15),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ScrapbookColors.inkBrown),
            const SizedBox(width: 6),
            Text(label, style: ScrapbookStyles.marker(size: 13)),
          ],
        ),
      ),
    );
  }
}
