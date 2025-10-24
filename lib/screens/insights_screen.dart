
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

          final totalIncome =
              incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
          final totalExpenses =
              expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
          final grandTotal = totalIncome + totalExpenses;

          // Prepare data for the inner chart
          final Map<String, double> categoryTotals = {};
          for (var t in provider.transactions) {
            String key = t.category;
            categoryTotals.update(key, (sum) => sum + t.amount,
                ifAbsent: () => t.amount);
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 350,
                    width: 350,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Ring: Income vs Expense
                        PieChart(
                          PieChartData(
                            sections: _buildOuterRing(
                                totalIncome, totalExpenses, grandTotal),
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 100,
                          ),
                        ),
                        // Inner Pie: Category Breakdown
                        PieChart(
                          PieChartData(
                            sections: _buildInnerPie(categoryTotals, grandTotal, transactionProvider),
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 1,
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Legends
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(
                        'INCOME',
                        _incomeColor,
                        _categoryColors.entries
                            .where((e) => incomeTransactions
                                .any((t) => t.category == e.key))
                            .toList(),
                      ),
                      _buildLegend(
                        'EXPENSE',
                        _expenseColor,
                        _categoryColors.entries
                            .where((e) => expenseTransactions
                                .any((t) => t.category == e.key))
                            .toList(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildOuterRing(
      double income, double expenses, double total) {
    if (total == 0) return [];
    final incomePercentage = income / total;
    final expensePercentage = expenses / total;

    return [
      PieChartSectionData(
        value: income,
        color: _incomeColor,
        radius: 40,
        showTitle: true,
        title: '${(incomePercentage * 100).toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.lora(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        value: expenses,
        color: _expenseColor,
        radius: 40,
        showTitle: true,
        title: '${(expensePercentage * 100).toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.lora(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      ),
    ];
  }

  List<PieChartSectionData> _buildInnerPie(
      Map<String, double> categoryTotals, double grandTotal, TransactionProvider provider) {
    if (grandTotal == 0) return [];
    return categoryTotals.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / grandTotal) * 100;
      final transactionType = provider.transactions.firstWhere((t) => t.category == category).type;
      final colorKey = _categoryColors.containsKey(category)
          ? category
          : (transactionType == 'income'
              ? 'Others_Income'
              : 'Others_Expense');

      return PieChartSectionData(
        value: amount,
        color: _categoryColors[colorKey],
        radius: 100,
        showTitle: true,
        title: '${percentage.toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.lora(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

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
