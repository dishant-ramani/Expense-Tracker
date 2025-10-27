import 'package:flutter/material.dart';
import 'package:myapp/models/budget.dart';
import 'package:myapp/models/transaction.dart';
import 'package:myapp/services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  final BudgetService _budgetService = BudgetService();

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  BudgetProvider() {
    loadBudgets();
  }

  void setTransactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();
    _budgets = await _budgetService.getBudgets();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await _budgetService.addBudget(budget);
    await loadBudgets();
  }

  Future<void> updateBudget(Budget budget) async {
    await _budgetService.updateBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _budgetService.deleteBudget(id);
    await loadBudgets();
  }

  double getSpentAmount(String category) {
    return _transactions
        .where((t) => t.categoryId == category && t.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}
