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
    const primaryBlue = Color(0xFF3B82F6);
    const secondaryGreen = Color(0xFF22C55E);

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
                style: GoogleFonts.inter(fontSize: 16),
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

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// --- HEADER ROW ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: secondaryGreen.withOpacity(0.1),
                              child: Icon(
                                budget.icon,
                                color: secondaryGreen,
                                size: 24,
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
                                    color: isOverspent ? Colors.red : secondaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// --- MODERN POPUP MENU ---
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
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Edit',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFFF43F5E), Color(0xFFF97316)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Delete',
                                    style: Theme.of(context).textTheme.bodyLarge,
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

                    /// --- PROGRESS BAR ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: primaryBlue.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverspent ? Colors.red : secondaryGreen,
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
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        Text(
                          'Budget: ₹${budget.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      /// --- FAB with gradient ---
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
