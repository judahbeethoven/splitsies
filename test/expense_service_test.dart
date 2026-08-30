import 'package:flutter_test/flutter_test.dart';
import 'package:splitsies/models/expense.dart';
import 'package:splitsies/services/expense_repository.dart';
import 'package:splitsies/services/expense_service.dart';

Expense _e(String id, {DateTime? at}) => Expense(
  id: id,
  description: 'slip $id',
  amount: 90,
  category: ExpenseCategory.food,
  participants: const ['You', 'Aditya', 'Meera'],
  payer: 'You',
  createdAt: at ?? DateTime(2026, 1, 1),
);

void main() {
  late ExpenseService service;

  setUp(() async {
    service = ExpenseService(MemoryRepo());
    await service.init();
  });

  tearDown(() => service.dispose());

  test('starts empty', () {
    expect(service.expenses, isEmpty);
  });

  test('add keeps the list newest-first', () async {
    await service.addExpense(_e('old', at: DateTime(2026, 1, 1)));
    await service.addExpense(_e('new', at: DateTime(2026, 6, 1)));
    expect(service.expenses.map((e) => e.id), ['new', 'old']);
  });

  test('delete removes by id', () async {
    await service.addExpense(_e('a'));
    await service.addExpense(_e('b'));
    await service.deleteExpense('a');
    expect(service.expenses.map((e) => e.id), ['b']);
  });

  test('persists through the repository', () async {
    final repo = MemoryRepo();
    final a = ExpenseService(repo);
    await a.init();
    await a.addExpense(_e('a'));
    a.dispose();

    final b = ExpenseService(repo);
    await b.init();
    expect(b.expenses.map((e) => e.id), ['a']);
    b.dispose();
  });

  test('derived streams update on write', () async {
    expect(service.totalSpent$, emits(0.0));
    await service.addExpense(_e('a'));
    expect(service.totalSpent$, emits(90.0));
  });
}
