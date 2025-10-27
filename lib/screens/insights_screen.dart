
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/transaction.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  // Define the exact colors from the image for each category
  static const Map<String, Color> _categoryColors = {
    // Income
    'Salary': Color(0xFF00FFFF), // Cyan
    'Business': Color(0xFF8B4513), // SaddleBrown
    'Investment': Color(0xFFDAA520), // GoldenRod
    'Gift': Color(0xFFFA8072), // Salmon
    'Others_Income': Color(0xFF9400D3), // DarkViolet
    // Expense
    'Food': Color(0xFF483D8B), // DarkSlateBlue
    'Transport': Color(0xFFA0522D), // Sienna
    'Bills': Color(0xFF556B2F), // DarkOliveGreen
    'Shopping': Color(0xFFADFF2F), // GreenYellow
    'Entertainment': Color(0xFF0000FF), // Blue
    'Others_Expense': Color(0xFFFFA500), // Orange
  };

  static const Color _incomeColor = Color(0xFF228B22); // ForestGreen
  static const Color _expenseColor = Color(0xFFDC143C); // Crimson

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Insights',
          style: GoogleFonts.lora(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.transactions.isEmpty) {
            return Center(
              child: Text(
                'No transaction data to display.',
                style: GoogleFonts.lora(),
              ),
            );
          }

          // Calculate totals
          final incomeTransactions = provider.transactions
              .where((t) => t.type == 'income')
              .toList();
          final expenseTransactions = provider.transactions
              .where((t) => t.type == 'expense')
              .toList();

          if (expenseTransactions.isEmpty) {
            return const Center(child: Text('No expense data for insights.'));
          }

          Map<String, double> dataMap = {};
          for (var transaction in expenseTransactions) {
            dataMap.update(
              transaction.category,
              (value) => value + transaction.amount,
              ifAbsent: () => transaction.amount,
            );
          }

          List<PieChartSectionData> pieChartSections = dataMap.entries.map((
            entry,
          ) {
            return PieChartSectionData(
              value: entry.value,
              title: entry.key,
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList();

  Widget _buildLegend(String title, Color titleColor,
      List<MapEntry<String, Color>> legendItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        ...legendItems.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: item.value,
                ),
                const SizedBox(width: 8),
                Text(
                  item.key.replaceAll('_Income', '').replaceAll('_Expense', ''),
                  style: GoogleFonts.lora(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
