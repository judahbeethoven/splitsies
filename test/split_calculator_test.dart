import 'package:flutter_test/flutter_test.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/services/split_calculator.dart';

Expense _expense({
  required double amount,
  required List<String> participants,
  required String payer,
  String id = 'x',
  DateTime? at,
}) {
  return Expense(
    id: id,
    description: 'test',
    amount: amount,
    category: ExpenseCategory.other,
    participants: participants,
    payer: payer,
    createdAt: at ?? DateTime(2026, 1, 1),
  );
}

void main() {
  group('equalShares', () {
    test('divides evenly', () {
      final shares = SplitCalculator.equalShares(120, ['a', 'b', 'c', 'd']);
      expect(shares.values, everyElement(closeTo(30, 0.001)));
    });

    test('distributes the odd paise so shares sum to the total exactly', () {
      final shares = SplitCalculator.equalShares(100, ['a', 'b', 'c']);
      expect(shares['a'], closeTo(33.34, 0.001));
      expect(shares['b'], closeTo(33.33, 0.001));
      expect(shares['c'], closeTo(33.33, 0.001));
      final sum = shares.values.reduce((x, y) => x + y);
      expect(sum, closeTo(100, 0.001));
    });

    test('handles decimal amounts', () {
      final shares = SplitCalculator.equalShares(99.99, ['a', 'b']);
      final sum = shares.values.reduce((x, y) => x + y);
      expect(sum, closeTo(99.99, 0.001));
    });
  });

  group('balances', () {
    test('payer is up by what everyone else owes them', () {
      final balances = SplitCalculator.balances([
        _expense(amount: 120, participants: ['You', 'Aditya', 'Meera'], payer: 'You'),
      ]);
      final you = balances.firstWhere((b) => b.person == 'You');
      final aditya = balances.firstWhere((b) => b.person == 'Aditya');
      expect(you.net, closeTo(80, 0.001));
      expect(aditya.net, closeTo(-40, 0.001));
    });

    test('every net nets to zero across the group', () {
      final balances = SplitCalculator.balances([
        _expense(amount: 100, participants: ['a', 'b', 'c'], payer: 'a'),
        _expense(amount: 57.5, participants: ['b', 'c'], payer: 'c'),
        _expense(amount: 240, participants: ['a', 'b', 'c'], payer: 'b'),
      ]);
      final sum = balances.map((b) => b.net).reduce((x, y) => x + y);
      expect(sum, closeTo(0, 0.001));
    });

    test('"You" is sorted first', () {
      final balances = SplitCalculator.balances([
        _expense(amount: 90, participants: ['Aditya', 'You', 'Meera'], payer: 'Aditya'),
      ]);
      expect(balances.first.person, 'You');
    });
  });

  group('settleUp', () {
    test('transfers clear every balance and never exceed people-1', () {
      final expenses = [
        _expense(amount: 100, participants: ['a', 'b', 'c'], payer: 'a'),
        _expense(amount: 60, participants: ['a', 'b', 'c'], payer: 'b'),
      ];
      final transfers = SplitCalculator.settleUp(expenses);
      expect(transfers.length, lessThanOrEqualTo(2));

      // Apply the transfers on top of the balances — everyone should end at ~0.
      final net = {for (final b in SplitCalculator.balances(expenses)) b.person: b.net};
      for (final t in transfers) {
        net[t.from] = net[t.from]! + t.amount;
        net[t.to] = net[t.to]! - t.amount;
      }
      expect(net.values, everyElement(closeTo(0, 0.02)));
    });
  });

  test('totalSpent sums all amounts', () {
    expect(
      SplitCalculator.totalSpent([
        _expense(amount: 120, participants: ['a', 'b'], payer: 'a'),
        _expense(amount: 79.99, participants: ['a', 'b'], payer: 'b'),
      ]),
      closeTo(199.99, 0.001),
    );
  });
}
