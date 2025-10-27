import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/budget.dart';

class BudgetService {
  static const String budgetsBoxName = 'budgets';

  Box<Budget> get budgetsBox => Hive.box<Budget>(budgetsBoxName);

  Future<List<Budget>> getBudgets() async {
    return budgetsBox.values.toList();
  }

  Future<void> addBudget(Budget budget) async {
    await budgetsBox.put(budget.id, budget);
  }

  Future<void> updateBudget(Budget budget) async {
    await budgetsBox.put(budget.id, budget);
  }

  Future<void> deleteBudget(String budgetId) async {
    await budgetsBox.delete(budgetId);
  }
}
