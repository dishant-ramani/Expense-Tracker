import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/screens/add_transaction_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final totalIncome = transactionProvider.transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = transactionProvider.transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final monthlySpendingPercentage =
        totalIncome > 0 ? (totalExpenses / totalIncome).clamp(0.0, 1.0) : 0.0;

    final recentTransactions =
        transactionProvider.transactions.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- INCOME & EXPENSE CARDS ---
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Income',
                    totalIncome,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    totalExpenses,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// --- MONTHLY SPENDING BAR ---
            _buildMonthlySpending(monthlySpendingPercentage),
            const SizedBox(height: 24),

            /// --- RECENT TRANSACTIONS HEADER ---
            Text(
              'Recent Transactions',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            /// --- TRANSACTION TILES ---
            ...recentTransactions.map((transaction) {
              final category = categoryProvider.categories.firstWhere(
                (cat) => cat.id == transaction.categoryId,
                orElse: () => categoryProvider.categories.first,
              );

              return _buildCategoryTile(context, transaction, category);
            }),
          ],
        ),
      ),

      /// --- FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// --- SUMMARY CARD ---
  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##0', 'en_IN').format(amount)}',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// --- MONTHLY SPENDING BAR ---
  Widget _buildMonthlySpending(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Spending',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}% of income spent',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  /// --- TRANSACTION TILE ---
  Widget _buildCategoryTile(
      BuildContext context, dynamic transaction, dynamic category) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// --- CATEGORY ICON ---
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          /// --- NAME & TYPE ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  isIncome ? 'Income' : 'Expense',
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          /// --- AMOUNT + MENU
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isIncome ? '+' : '-'}₹${NumberFormat('#,##0', 'en_IN').format(transaction.amount)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),

              /// --- MODERN POPUP MENU ---
              PopupMenuButton<String>(
                elevation: 12,
                color: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                offset: const Offset(0, 40),
                shadowColor: Colors.blueAccent.withOpacity(0.2),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTransactionScreen(transaction: transaction),
                      ),
                    );
                  } else if (value == 'delete') {
                    Provider.of<TransactionProvider>(context, listen: false)
                        .deleteTransaction(transaction.id);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.blue, Colors.cyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child:
                              const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.red, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child:
                              const Icon(Icons.delete, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
