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
      backgroundColor: const Color(0xFFF8FAFC), // Light neutral background
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
                  color: Colors.grey[700],
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
                color: Colors.white,
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
                                backgroundColor: Colors.blue.shade50,
                                child: Icon(
                                  budget.icon,
                                  color: Colors.blue.shade700,
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
                                      color: Colors.black87,
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
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            color: Colors.grey[700],
                            onPressed: () {
                              _showMoreOptions(context, budget.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverspent ? Colors.red : Colors.blue,
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
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Budget: ₹${budget.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              color: Colors.grey[800],
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
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, String budgetId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: Text(
                'Delete',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              onTap: () {
                Provider.of<BudgetProvider>(context, listen: false)
                    .deleteBudget(budgetId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
