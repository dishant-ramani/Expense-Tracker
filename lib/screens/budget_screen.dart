import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/budget.dart';
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
      body: Consumer3<BudgetProvider, TransactionProvider, CategoryProvider>(
        builder: (context, budgetProvider, transactionProvider, categoryProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetProvider.budgets.isEmpty) {
            return Center(
              child: Text(
                'No budgets added yet.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              final budget = budgetProvider.budgets[index];
              final categoryId = categoryProvider.categories
                  .firstWhere((c) => c.name == budget.category)
                  .id;

              final spent = transactionProvider.transactions
                  .where((t) => t.type == 'expense' && t.categoryId == categoryId)
                  .fold(0.0, (sum, t) => sum + t.amount);

              final remaining = budget.amount - spent;
              final isOverspent = remaining < 0;
              final progressValue =
                  budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Colors.black12,
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
                                radius: 22,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  budget.icon,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.category,
                                    style: GoogleFonts.inter(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    isOverspent
                                        ? 'Overspent: ₹${remaining.abs().toStringAsFixed(2)}'
                                        : 'Remaining: ₹${remaining.toStringAsFixed(2)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: isOverspent ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // 👇 Stylish Popup Menu (same as TransactionScreen)
                          PopupMenuButton<String>(
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            offset: const Offset(0, 40),
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddBudgetScreen(budget: budget),
                                  ),
                                );
                              } else if (value == 'delete') {
                                Provider.of<BudgetProvider>(context, listen: false)
                                    .deleteBudget(budget.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            colors: [Colors.blue, Colors.cyan],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                      child: const Icon(Icons.edit,
                                          color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Edit',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            colors: [Colors.red, Colors.orange],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ).createShader(bounds),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Delete',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            icon: const Icon(Icons.more_horiz_rounded),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverspent ? Colors.red : Theme.of(context).colorScheme.primary,
                          ),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spent: ₹${spent.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Budget: ₹${budget.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                            ),
                          ),
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
