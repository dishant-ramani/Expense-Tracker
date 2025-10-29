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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    context,
                    'Total Income',
                    totalIncome,
                    isDark
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF22C55E),
                    const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    'Total Expenses',
                    totalExpenses,
                    isDark
                        ? const Color(0xFFF87171)
                        : const Color(0xFFEF4444),
                    const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// --- MONTHLY SPENDING BAR ---
            _buildMonthlySpending(context, monthlySpendingPercentage),
            const SizedBox(height: 24),

            /// --- RECENT TRANSACTIONS HEADER ---
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  /// --- SUMMARY CARD ---
  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color textColor,
    LinearGradient gradient,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.colors.first.withOpacity(isDark ? 0.2 : 0.1),
            gradient.colors.last.withOpacity(isDark ? 0.2 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##0', 'en_IN').format(amount)}',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// --- MONTHLY SPENDING BAR ---
  Widget _buildMonthlySpending(BuildContext context, double percentage) {
    Color getSpendingColor(double percentage) {
      if (percentage < 0.5) return const Color(0xFF22C55E);
      if (percentage < 0.8) return const Color(0xFF3B82F6);
      return const Color(0xFFF97316);
    }

    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFDDEFFA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Spending',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}% of income spent',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: bgColor,
            valueColor:
                AlwaysStoppedAnimation<Color>(getSpendingColor(percentage)),
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
    final color = isIncome
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    final iconBgColor = isIncome
        ? const Color(0xFFE8F8EF)
        : const Color(0xFFFFF1F2);

    // Format the date selected in AddTransactionScreen
    final formattedDate = DateFormat('dd MMM yyyy').format(transaction.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
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
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          /// --- NAME & DATE (date replaces type) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  formattedDate, // Replaces the transaction type text
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          /// --- AMOUNT + MENU ---
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

              /// --- POPUP MENU ---
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
                            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text('Edit',
                            style: Theme.of(context).textTheme.bodyLarge),
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
                        Text('Delete',
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
                icon: Icon(Icons.more_horiz_rounded,
                    color: Theme.of(context).iconTheme.color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
