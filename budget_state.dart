import 'package:flutter/material.dart';
import 'package:financial_manager_appv5/financial_table.dart';

class Transaction {
  DateTime date;
  FinancialType? type;
  String? category;
  double amount;

  Transaction({
    required this.date,
    this.type,
    this.category,
    required this.amount,
  });
}

class FinancialColumn {
  String name;
  final List<TextEditingController> controllers;

  FinancialColumn({
    required this.name,
    required this.controllers,
  });

  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
  }
}

class BudgetState extends ChangeNotifier {
  final Map<FinancialType, List<FinancialColumn>> _columns = {
    FinancialType.income: [],
    FinancialType.expense: [],
    FinancialType.savings: [],
  };

  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  // Add a new transaction
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  // Remove a transaction
  void removeTransaction(Transaction transaction) {
    _transactions.remove(transaction);
    notifyListeners();
  }

  // Update a transaction
  void updateTransaction(Transaction transaction) {
    notifyListeners();
  }

  // Get categories for a specific type
  List<String> getCategoriesForType(FinancialType type) {
    return _columns[type]!.map((col) => col.name).toList();
  }

  // Get monthly totals for transactions
  double getMonthlyTransactionTotal(FinancialType type, int month, int year) {
    return _transactions
        .where((t) =>
            t.type == type && t.date.month == month && t.date.year == year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<FinancialColumn> getColumns(FinancialType type) => _columns[type]!;

  void addColumn(FinancialType type) {
    final columns = _columns[type]!;
    final columnNumber = columns.length + 1;
    final name = '${type.name.capitalize()} $columnNumber';

    columns.add(FinancialColumn(
      name: name,
      controllers: List.generate(12, (_) => TextEditingController()),
    ));

    notifyListeners();
  }

  void updateColumnName(FinancialType type, int columnIndex, String newName) {
    if (_columns[type]!.length > columnIndex) {
      _columns[type]![columnIndex].name = newName;
      notifyListeners();
    }
  }

  void deleteColumn(FinancialType type, int columnIndex) {
    if (_columns[type]!.length > columnIndex) {
      // Update any transactions that use this category
      final deletedCategory = _columns[type]![columnIndex].name;
      for (var transaction in _transactions) {
        if (transaction.type == type &&
            transaction.category == deletedCategory) {
          transaction.category = null;
        }
      }

      // Dispose of the controllers before removing the column
      _columns[type]![columnIndex].dispose();
      _columns[type]!.removeAt(columnIndex);
      notifyListeners();
    }
  }

  double getMonthlyTotal(FinancialType type, int monthIndex) {
    double total = 0;
    for (var column in _columns[type]!) {
      final value = double.tryParse(column.controllers[monthIndex].text) ?? 0;
      total += value;
    }
    return total;
  }

  double getYearlyTotalForColumn(FinancialType type, FinancialColumn column) {
    double total = 0;
    for (var controller in column.controllers) {
      total += double.tryParse(controller.text) ?? 0;
    }
    return total;
  }

  double getGrandTotal(FinancialType type) {
    double total = 0;
    for (var column in _columns[type]!) {
      total += getYearlyTotalForColumn(type, column);
    }
    return total;
  }

  @override
  void dispose() {
    for (var columns in _columns.values) {
      for (var column in columns) {
        column.dispose();
      }
    }
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

