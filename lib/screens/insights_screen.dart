import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/category.dart' as my_category;

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, transactionProvider, categoryProvider, child) {
          if (transactionProvider.isLoading || categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (transactionProvider.transactions.isEmpty) {
            return Center(
              child: Text(
                'No transaction data to display.',
                style: GoogleFonts.lora(),
              ),
            );
          }

          final transactions = transactionProvider.transactions;
          final categories = categoryProvider.categories;

          final totalIncome = transactions
              .where((t) => t.type == 'income')
              .fold(0.0, (sum, t) => sum + t.amount);
          final totalExpenses = transactions
              .where((t) => t.type == 'expense')
              .fold(0.0, (sum, t) => sum + t.amount);
          final grandTotal = totalIncome + totalExpenses;

          final Map<String, double> incomeCategoryTotals = {};
          final Map<String, double> expenseCategoryTotals = {};

          for (var t in transactions) {
            final category = categories.firstWhere((c) => c.id == t.categoryId, orElse: () => my_category.Category()..name = 'Others');
            if (t.type == 'income') {
              incomeCategoryTotals.update(category.name, (sum) => sum + t.amount, ifAbsent: () => t.amount);
            } else {
              expenseCategoryTotals.update(category.name, (sum) => sum + t.amount, ifAbsent: () => t.amount);
            }
          }

          final Map<String, Color> categoryColors = {
            'Salary': const Color(0xFF00FFFF),
            'Business': const Color(0xFF8B4513),
            'Investment': const Color(0xFFDAA520),
            'Gift': const Color(0xFFFA8072),
            'Others': const Color(0xFF9400D3),
            'Food': const Color(0xFF483D8B),
            'Transport': const Color(0xFFA0522D),
            'Bills': const Color(0xFF556B2F),
            'Shopping': const Color(0xFFADFF2F),
            'Entertainment': const Color(0xFF0000FF),
          };

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
                        PieChart(
                          PieChartData(
                            sections: _buildOuterRing(totalIncome, totalExpenses, grandTotal),
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4,
                            centerSpaceRadius: 120,
                          ),
                        ),
                        PieChart(
                          PieChartData(
                            sections: _buildInnerPie(incomeCategoryTotals, expenseCategoryTotals, grandTotal, categoryColors),
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend('INCOME', const Color(0xFF2E8B57), incomeCategoryTotals, categoryColors, true),
                      _buildLegend('EXPENSE', const Color(0xFFD22B2B), expenseCategoryTotals, categoryColors, false),
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

  List<PieChartSectionData> _buildOuterRing(double income, double expenses, double total) {
    if (total == 0) return [];
    final incomePercentage = income / total;
    final expensePercentage = expenses / total;

    return [
      PieChartSectionData(
        value: income,
        color: const Color(0xFF2E8B57), // SeaGreen
        radius: 70,
        showTitle: true,
        title: '${(incomePercentage * 100).toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: expenses,
        color: const Color(0xFFD22B2B), // Firebrick
        radius: 70,
        showTitle: true,
        title: '${(expensePercentage * 100).toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  List<PieChartSectionData> _buildInnerPie(Map<String, double> incomeTotals, Map<String, double> expenseTotals, double grandTotal, Map<String, Color> colors) {
    if (grandTotal == 0) return [];

    List<PieChartSectionData> sections = [];

    final sortedIncomeKeys = incomeTotals.keys.toList();
    final sortedExpenseKeys = expenseTotals.keys.toList();

    for (var category in sortedIncomeKeys) {
      final amount = incomeTotals[category]!;
      final percentage = (amount / grandTotal) * 100;
      sections.add(
        PieChartSectionData(
          value: amount,
          color: colors[category] ?? Colors.grey,
          radius: 60,
          showTitle: true,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    for (var category in sortedExpenseKeys) {
      final amount = expenseTotals[category]!;
      final percentage = (amount / grandTotal) * 100;
      sections.add(
        PieChartSectionData(
          value: amount,
          color: colors[category] ?? Colors.grey,
          radius: 60,
          showTitle: true,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(String title, Color titleColor, Map<String, double> categoryTotals, Map<String, Color> colors, bool isIncome) {
    final defaultColor = isIncome ? const Color(0xFF9400D3) : const Color(0xFFFFA500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...categoryTotals.keys.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: colors[category] ?? defaultColor,
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: GoogleFonts.lora(fontSize: 16),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
