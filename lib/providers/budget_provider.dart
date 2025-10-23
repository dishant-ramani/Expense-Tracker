import 'package:flutter/foundation.dart';
import 'package:myapp/models/budget.dart';
import 'package:myapp/services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  List<Budget> _budgets = [];

  List<Budget> get budgets => _budgets;

  BudgetProvider() {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    _budgets = await _budgetService.getBudgets();
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await _budgetService.addBudget(budget);
    await _loadBudgets();
  }

  Future<void> updateBudget(Budget budget) async {
    await _budgetService.updateBudget(budget);
    await _loadBudgets();
  }

  Future<void> deleteBudget(Budget budget) async {
    await _budgetService.deleteBudget(budget);
    await _loadBudgets();
  }
}
