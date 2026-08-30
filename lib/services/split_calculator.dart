import 'package:splitsies/models/balance.dart';
import 'package:splitsies/models/expense.dart';

class SplitCalculator {
  static Map<String, double> equalShares(
    double amount,
    List<String> participants, {
    String selfName = 'You',
  }) {
    int eqShare = amount ~/ participants.length;
    int leftover = (amount - (eqShare * participants.length)).round();

    Map<String, double> shares = {};
    for (String i in participants) {
      shares[i] = eqShare as double;

      // Makes sure you dont get the leftover hehe
      if (i == selfName) {
        continue;
      }
      if (shares.containsKey(i)) {
        shares[i] = shares[i]! + leftover;
      }
    }

    return shares;
  }

  static List<Balance> balances(
    List<Expense> expenses, {
    String selfName = 'You',
  }) {
    List<Balance> out = [];

    for (Expense e in expenses) {
      List<Balance> expenseShares =
          SplitCalculator.equalShares(e.amount, e.participants).entries.map((
            share,
          ) {
            String group = generateGroupID(e.participants);
            if (e.payer == selfName) {
              return Balance(person: e.payer, group: group, net: -e.amount);
            }
            return Balance(person: share.key, group: group, net: share.value);
          }).toList();
      out.addAll(expenseShares);
    }

    return out;
  }

  static double totalSpent(List<Expense> expenses) {
    return expenses.fold(0.0, (i, expense) => i + expense.amount);
  }

  static double totalSpentSelf(List<Expense> expenses) {
    return expenses.fold(
      0.0,
      (i, expense) => i + expense.amount / expense.participants.length,
    );
  }
}
