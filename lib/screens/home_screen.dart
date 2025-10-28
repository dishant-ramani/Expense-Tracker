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
    final monthlySpendingPercentage = totalIncome > 0 ? (totalExpenses / totalIncome).clamp(0.0, 1.0) : 0.0;

    final recentTransactions = transactionProvider.transactions.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF2D3748), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Home', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Income', totalIncome, Colors.green, isIncome: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Total Expenses', totalExpenses, Colors.red, isIncome: false)),
              ],
            ),
            const SizedBox(height: 24),
            _buildMonthlySpending(monthlySpendingPercentage),
            const SizedBox(height: 24),
            Text('Categories', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ...recentTransactions.map((transaction) {
              final category = categoryProvider.categories.firstWhere((cat) => cat.id == transaction.categoryId, orElse: () => categoryProvider.categories.first);
              return _buildCategoryTile(transaction, category, context);
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, {required bool isIncome}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat('#,##0', 'en_IN').format(amount)}',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySpending(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Monthly Spending', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${(percentage * 100).toStringAsFixed(0)}% of income spent', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[700],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(dynamic transaction, dynamic category, BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'), color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(isIncome ? 'Income' : 'Expense', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}₹${NumberFormat('#,##0', 'en_IN').format(transaction.amount)}',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
