// Core Flutter and third-party imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

// Local application imports
import 'package:myapp/models/budget.dart';
import 'package:myapp/providers/budget_provider.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/screens/add_budget_screen.dart';

/// BudgetScreen displays a list of user's budgets with their spending progress
/// and allows managing (add/edit/delete) budgets.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  // Helper method to check if an asset exists
  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Build category icon with fallback
  Widget _buildCategoryIcon(String categoryName) {
    final safeName = categoryName.toLowerCase().replaceAll(' ', '_');
    final svgPath = 'assets/icons/$safeName.svg';
    
    return FutureBuilder<bool>(
      future: _assetExists(svgPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
          return SvgPicture.asset(
            svgPath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Color(0xFF000000), BlendMode.srcIn),
          );
        }
        
        // Fallback to default icon if SVG doesn't exist
        return const Icon(
          Icons.category_rounded,
          color: Color(0xFF000000),
          size: 24,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Color constants for the budget screen
    const primaryBlue = Color(0xFF3B82F6);
    const secondaryGreen = Color(0xFF22C55E);

    return Scaffold(
      backgroundColor: Colors.white,
      // Main content area showing budgets list
      body: Consumer3<BudgetProvider, TransactionProvider, CategoryProvider>(
        // Using Consumer3 to access multiple providers
        builder: (context, budgetProvider, transactionProvider, categoryProvider, child) {
          // Show loading indicator while budgets are being loaded
          if (budgetProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show empty state when no budgets exist
          if (budgetProvider.budgets.isEmpty) {
            return Center(
              child: Text(
                'No budgets added yet.',
                style: GoogleFonts.inter(fontSize: 16),
              ),
            );
          }

          // Build a scrollable list of budget items with title
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  'Budgets',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  itemCount: budgetProvider.budgets.length,
            itemBuilder: (context, index) {
              // Get current budget item and its corresponding category ID
              final budget = budgetProvider.budgets[index];
              final categoryId = categoryProvider.categories
                  .firstWhere((c) => c.name == budget.category)
                  .id;

              // Calculate total spent in this budget category
              final spent = transactionProvider.transactions
                  .where((t) => t.type == 'expense' && t.categoryId == categoryId)
                  .fold(0.0, (sum, t) => sum + t.amount);

              // Calculate remaining budget and check if overspent
              final remaining = budget.amount - spent;
              final isOverspent = remaining < 0;
              // Calculate progress value between 0.0 and 1.0 for the progress bar
              final progressValue =
                  budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB4D8BD), // Light green background with 20% opacity
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
                    // =============================
                    // BUDGET ITEM HEADER
                    // Contains category icon, name, and menu button
                    // =============================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                              child: _buildCategoryIcon(budget.category),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget.category,
                                  style: const TextStyle(
                                    fontFamily: 'ClashGrotesk',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  isOverspent
                                      ? 'Overspent: ₹${remaining.abs().toStringAsFixed(2)}'
                                      : 'Remaining: ₹${remaining.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'ClashGrotesk',
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ).copyWith(
                                    color: isOverspent ? Colors.red : const Color(0xFF0C0121),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // =============================
                    // BUDGET ACTIONS MENU
                    // Shows edit/delete options when menu button is pressed
                    // =============================
                        PopupMenuButton<String>(
                          elevation: 12,
                          
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            // minWidth: 160,
                            // maxWidth: 200,
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              height: 40,
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/edit.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Edit',
                                    style: const TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'delete',
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              height: 40,
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/delete.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Delete',
                                    style: const TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Color(0xFF0C0121),
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // =============================
                    // BUDGET PROGRESS BAR
                    // Visual indicator of spending vs budget
                    // =============================
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Color(0xFF499465).withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverspent ? Colors.red : Color(0xFF499465),
                        ),
                        minHeight: 10,
                      ),
                    ),

                    const SizedBox(height: 8),
                    // =============================
                    // BUDGET SUMMARY ROW
                    // Shows spent amount and total budget
                    // =============================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: ₹${spent.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Budget: ₹${budget.amount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500, // Slightly bolder for budget amount
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
              ),
        ],
      );
        }
      )
    );
  }
}
