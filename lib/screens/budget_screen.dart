import 'package:flutter/material.dart';
import 'package:myapp/providers/budget_provider.dart';
import 'package:myapp/screens/add_budget_screen.dart';
import 'package:provider/provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          if (provider.budgets.isEmpty) {
            return const Center(child: Text('No budgets set yet.'));
          }
          return ListView.builder(
            itemCount: provider.budgets.length,
            itemBuilder: (context, index) {
              final budget = provider.budgets[index];
              return ListTile(
                title: Text(budget.period),
                trailing: Text('${budget.amount}'),
              );
            },
          );
        },
      ),
    );
  }
}
