import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:splitsies/models/expense.dart';

// For DI
abstract class ExpenseRepository {
  Future<List<Expense>> load();
  Future<void> save(List<Expense> expenses);
}

// File Storage
class LocalRepo implements ExpenseRepository {
  static const _fileName = 'expenses.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<List<Expense>> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<Expense> expenses) async {
    final file = await _file();
    final raw = jsonEncode(expenses.map((e) => e.toJson()).toList());
    await file.writeAsString(raw, flush: true);
  }
}

class MemoryRepo implements ExpenseRepository {
  List<Expense> _store;

  MemoryRepo([List<Expense>? seed]) : _store = List.of(seed ?? []);

  @override
  Future<List<Expense>> load() async => List.of(_store);

  @override
  Future<void> save(List<Expense> expenses) async => _store = List.of(expenses);
}
