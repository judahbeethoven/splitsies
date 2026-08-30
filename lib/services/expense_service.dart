import 'package:rxdart/rxdart.dart';
import 'package:splitsies/models/balance.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/services/expense_repository.dart';
import 'package:splitsies/services/split_calculator.dart';

class ExpenseService {
  final ExpenseRepository _repository;

  final _expenses = BehaviorSubject<List<Expense>>.seeded(const []);

  ExpenseService(this._repository);

  Stream<List<Expense>> get expenses$ => _expenses.stream;
  List<Expense> get expenses => _expenses.value;

  Stream<double> get totalSpent$ {
    return expenses$.map((event) => SplitCalculator.totalSpent(event));
  }

  Stream<List<Balance>> get balances$ {
    return expenses$.map((event) => SplitCalculator.balances(event));
  }

  Stream<List<Settlement>> get settlements$ {
    return expenses$.map((event) => SplitCalculator.settleUp(event));
  }

  Stream<int> get peopleCount$ {
    return expenses$.map((event) => event.length);
  }

  Future<void> init() async {
    _expenses.add(_sorted(await _repository.load()));
  }

  Future<void> addExpense(Expense expense) async {
    final next = _sorted([..._expenses.value, expense]);
    _expenses.add(next);
    await _repository.save(next);
  }

  Future<void> deleteExpense(String id) async {
    final next = _expenses.value.where((e) => e.id != id).toList();
    _expenses.add(next);
    await _repository.save(next);
  }

  Future<void> restoreExpense(Expense expense) => addExpense(expense);

  /// Flips whether [person] has paid back the payer of [expenseId].
  Future<void> setParticipantPaid(
    String expenseId,
    String person,
    bool paid,
  ) async {
    final next = _expenses.value.map((e) {
      if (e.id != expenseId) return e;
      final status = Map<String, bool>.of(e.paidStatus)..[person] = paid;
      return e.copyWith(paidStatus: status);
    }).toList();
    _expenses.add(next);
    await _repository.save(next);
  }

  void dispose() => _expenses.close();

  List<Expense> _sorted(List<Expense> list) =>
      [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
