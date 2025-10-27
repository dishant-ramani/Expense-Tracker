import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/budget_provider.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/screens/add_budget_screen.dart';
import 'package:provider/provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
            },
          ),
        ],
      ),
      body: Consumer3<BudgetProvider, TransactionProvider, CategoryProvider>(
        builder: (context, budgetProvider, transactionProvider, categoryProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetProvider.budgets.isEmpty) {
            return const Center(child: Text('No budgets added yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              final categoryId = categoryProvider.categories.firstWhere((c) => c.name == budget.category).id;
              final spent = transactionProvider.transactions
                  .where((t) => t.type == 'expense' && t.categoryId == categoryId)
                  .fold(0.0, (sum, t) => sum + t.amount);
              final remaining = budget.amount - spent;
              final isOverspent = remaining < 0;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(budget.icon, color: Colors.blue.shade800),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(budget.category, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text(
                                    isOverspent 
                                      ? 'Overspent: \$${remaining.abs().toStringAsFixed(2)}' 
                                      : 'Remaining: \$${remaining.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(color: isOverspent ? Colors.red : Colors.green),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              _showMoreOptions(context, budget.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: spent / budget.amount,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(isOverspent ? Colors.red : Colors.blue),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Spent: \$${spent.toStringAsFixed(2)}', style: GoogleFonts.poppins()),
                          Text('Budget: \$${budget.amount.toStringAsFixed(2)}', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddBudgetScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, String budgetId) {
    showModalBottomSheet(context: context, builder: (context) {
      return Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Provider.of<BudgetProvider>(context, listen: false).deleteBudget(budgetId);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }
}
