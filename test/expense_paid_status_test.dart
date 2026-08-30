import 'package:flutter_test/flutter_test.dart';
import 'package:splitsies/models/expense.dart';

Expense _expense({Map<String, bool>? paidStatus}) => Expense(
  id: 'x',
  description: 'test',
  amount: 90,
  category: ExpenseCategory.other,
  participants: const ['You', 'Aditya', 'Meera'],
  payer: 'You',
  createdAt: DateTime(2026, 1, 1),
  paidStatus: paidStatus,
);

void main() {
  group('per-participant paid status', () {
    test('defaults to nobody paid except the payer', () {
      final e = _expense();
      expect(e.isPaidBy('You'), isTrue);
      expect(e.isPaidBy('Aditya'), isFalse);
      expect(e.isPaidBy('Meera'), isFalse);
      expect(e.owers, ['Aditya', 'Meera']);
      expect(e.settleStatus, SettleStatus.none);
    });

    test('is partial once some owers have paid', () {
      final e = _expense(paidStatus: {'You': true, 'Aditya': true, 'Meera': false});
      expect(e.paidOwerCount, 1);
      expect(e.settleStatus, SettleStatus.partial);
    });

    test('is all once every ower has paid', () {
      final e = _expense(paidStatus: {'You': true, 'Aditya': true, 'Meera': true});
      expect(e.allSettled, isTrue);
      expect(e.settleStatus, SettleStatus.all);
    });

    test('a solo expense (no owers) counts as settled', () {
      final e = Expense(
        id: 'solo',
        description: 'test',
        amount: 10,
        category: ExpenseCategory.other,
        participants: const ['You'],
        payer: 'You',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(e.owers, isEmpty);
      expect(e.settleStatus, SettleStatus.all);
    });

    test('copyWith updates paid status independently of other fields', () {
      final e = _expense();
      final updated = e.copyWith(
        paidStatus: {...e.paidStatus, 'Aditya': true},
      );
      expect(updated.isPaidBy('Aditya'), isTrue);
      expect(updated.isPaidBy('Meera'), isFalse);
      expect(updated.description, e.description);
    });

    test('round-trips through json', () {
      final e = _expense(paidStatus: {'You': true, 'Aditya': true, 'Meera': false});
      final restored = Expense.fromJson(e.toJson());
      expect(restored.isPaidBy('Aditya'), isTrue);
      expect(restored.isPaidBy('Meera'), isFalse);
    });
  });
}
