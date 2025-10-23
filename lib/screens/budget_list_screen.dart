import 'package:flutter/material.dart';
//import 'package:myapp/models/budget.dart';
import 'package:myapp/providers/budget_provider.dart';
import 'package:myapp/screens/add_budget_screen.dart';
import 'package:myapp/screens/edit_budget_screen.dart';
import 'package:provider/provider.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final budgets = budgetProvider.budgets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddBudgetScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          return ListTile(
            title: Text(budget.category),
            subtitle: Text('${budget.amount} / ${budget.period}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBudgetScreen(budget: budget),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    budgetProvider.deleteBudget(budget);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
