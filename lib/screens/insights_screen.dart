import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/category.dart' as my_category;

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int touchedIndex = -1;
  bool _showIncomeChart = true;  // Tracks which tab is selected
  
  // Build legend for the pie chart
  Widget _buildLegend(
    Map<String, double> categoryTotals,
    Map<String, Color> colors,
  ) {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        final total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
        final percentage = total > 0 
            ? (entry.value / total * 100).toStringAsFixed(1)
            : '0.0';
            
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[entry.key] ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontFamily: 'ClashGrotesk', fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '₹${entry.value.toStringAsFixed(2)} ($percentage%)',
                style: const TextStyle(
                  fontFamily: 'ClashGrotesk',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Build tab button widget
  Widget _buildTabButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive 
                ? const Color(0xFF1C1B20)  // Dark purple for active tab
                : const Color(0xFFF1F1F1), // Light grey for inactive tab
            borderRadius: BorderRadius.circular(10), // More rounded corners
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'ClashGrotesk',
              color: isActive 
                  ? Colors.white 
                  : const Color(0xFF707070), // Dark grey for inactive text
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, transactionProvider, categoryProvider, child) {
          if (transactionProvider.isLoading || categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionProvider.transactions.isEmpty) {
            return Center(
              child: Text(
                'No transaction data to display.',
                style: const TextStyle(fontFamily: 'ClashGrotesk', fontSize: 16),
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

          return Column(
            children: [
              // Tab Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildTabButton(
                      'Income',
                      _showIncomeChart,
                      () => setState(() => _showIncomeChart = true),
                    ),
                    const SizedBox(width: 12),
                    _buildTabButton(
                      'Expense',
                      !_showIncomeChart,
                      () => setState(() => _showIncomeChart = false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Income Section
                      if (_showIncomeChart && totalIncome > 0) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Income Breakdown',
                          style: const TextStyle(
                            fontFamily: 'ClashGrotesk',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: _buildPieSections(
                                    incomeCategoryTotals,
                                    totalIncome,
                                    categoryColors,
                                    isIncome: true,
                                  ),
                                  startDegreeOffset: -90,
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 80,
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, response) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            response == null ||
                                            response.touchedSection == null) {
                                          touchedIndex = -1;
                                          return;
                                        }
                                        touchedIndex =
                                            response.touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total Income',
                                    style: const TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildLegend(incomeCategoryTotals, categoryColors),
                      ],
                      // Expense Section
                      if (!_showIncomeChart && totalExpenses > 0) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Expense Breakdown',
                          style: const TextStyle(
                            fontFamily: 'ClashGrotesk',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sections: _buildPieSections(
                                    expenseCategoryTotals,
                                    totalExpenses,
                                    categoryColors,
                                    isIncome: false,
                                  ),
                                  startDegreeOffset: -90,
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 80,
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, response) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            response == null ||
                                            response.touchedSection == null) {
                                          touchedIndex = -1;
                                          return;
                                        }
                                        touchedIndex =
                                            response.touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total Expenses',
                                    style: const TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalExpenses.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontFamily: 'ClashGrotesk',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildLegend(expenseCategoryTotals, categoryColors),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build pie chart sections for either income or expense categories
  List<PieChartSectionData> _buildPieSections(
    Map<String, double> categoryTotals,
    double totalAmount,
    Map<String, Color> colors, {
    required bool isIncome,
  }) {
    if (totalAmount == 0) return [];

    List<PieChartSectionData> sections = [];
    final categories = categoryTotals.entries.toList();

    for (int i = 0; i < categories.length; i++) {
      final entry = categories[i];
      final percentage = (entry.value / totalAmount) * 100;
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 100.0 : 90.0;

      sections.add(
        PieChartSectionData(
          color: colors[entry.key] ?? (isIncome ? Colors.green : Colors.red),
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: const TextStyle(
            fontFamily: 'ClashGrotesk',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return sections;
  }
}

