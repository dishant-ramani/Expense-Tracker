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
      // ✅ No AppBar (defined in default layout)
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, transactionProvider, categoryProvider, child) {
          if (transactionProvider.isLoading || categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionProvider.transactions.isEmpty) {
            return Center(
              child: Text(
                'No transaction data to display.',
                style: GoogleFonts.lora(fontSize: 16, color: Colors.black87),
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
            final category = categories.firstWhere(
              (c) => c.id == t.categoryId,
              orElse: () => my_category.Category()..name = 'Others',
            );

            if (t.type == 'income') {
              incomeCategoryTotals.update(
                category.name,
                (sum) => sum + t.amount,
                ifAbsent: () => t.amount,
              );
            } else {
              expenseCategoryTotals.update(
                category.name,
                (sum) => sum + t.amount,
                ifAbsent: () => t.amount,
              );
            }
          }

          final Map<String, Color> categoryColors = {
            'Salary': const Color(0xFF00BFA6),
            'Business': const Color(0xFF795548),
            'Investment': const Color(0xFFF9A825),
            'Gift': const Color(0xFFFF7043),
            'Others': const Color(0xFF7B1FA2),
            'Food': const Color(0xFF5C6BC0),
            'Transport': const Color(0xFF8D6E63),
            'Bills': const Color(0xFF689F38),
            'Shopping': const Color(0xFF43A047),
            'Entertainment': const Color(0xFF1E88E5),
          };

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Pie chart container
                  SizedBox(
                    height: 360,
                    width: 360,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sections: _buildOuterRing(
                              totalIncome,
                              totalExpenses,
                              grandTotal,
                            ),
                            startDegreeOffset: -90,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4,
                            centerSpaceRadius: 120,
                          ),
                        ),
                        PieChart(
                          PieChartData(
                            sections: _buildInnerPie(
                              incomeCategoryTotals,
                              expenseCategoryTotals,
                              grandTotal,
                              categoryColors,
                            ),
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

                  // Legends section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(
                        'INCOME',
                        const Color(0xFF2E8B57),
                        incomeCategoryTotals,
                        categoryColors,
                        true,
                      ),
                      _buildLegend(
                        'EXPENSE',
                        const Color(0xFFD22B2B),
                        expenseCategoryTotals,
                        categoryColors,
                        false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Outer ring for income vs expense
  List<PieChartSectionData> _buildOuterRing(
      double income, double expenses, double total) {
    if (total == 0) return [];

    final incomePercentage = income / total;
    final expensePercentage = expenses / total;

    return [
      PieChartSectionData(
        value: income,
        color: const Color(0xFF2E8B57),
        radius: 70,
        showTitle: true,
        title: '${(incomePercentage * 100).toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: expenses,
        color: const Color(0xFFD22B2B),
        radius: 70,
        showTitle: true,
        title: '${(expensePercentage * 100).toStringAsFixed(0)}%',
        titleStyle: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  /// Inner ring with category percentages
  List<PieChartSectionData> _buildInnerPie(
    Map<String, double> incomeTotals,
    Map<String, double> expenseTotals,
    double grandTotal,
    Map<String, Color> colors,
  ) {
    if (grandTotal == 0) return [];

    List<PieChartSectionData> sections = [];

    // Combine both income and expense categories
    final allKeys = {...incomeTotals.keys, ...expenseTotals.keys};

    for (var category in allKeys) {
      final amount =
          (incomeTotals[category] ?? 0) + (expenseTotals[category] ?? 0);
      final percentage = (amount / grandTotal) * 100;

      sections.add(
        PieChartSectionData(
          value: amount,
          color: colors[category] ?? Colors.grey,
          radius: 60,
          showTitle: true,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: GoogleFonts.lora(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  /// Legend builder
  Widget _buildLegend(
    String title,
    Color titleColor,
    Map<String, double> categoryTotals,
    Map<String, Color> colors,
    bool isIncome,
  ) {
    final defaultColor =
        isIncome ? const Color(0xFF7B1FA2) : const Color(0xFFFFA500);

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
                  decoration: BoxDecoration(
                    color: colors[category] ?? defaultColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
