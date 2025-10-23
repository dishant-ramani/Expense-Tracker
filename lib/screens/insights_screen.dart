import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
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

          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Expenses by Category',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: pieChartSections,
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Placeholder for the bar chart
              const Text('Spending Over Time (Coming Soon)'),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
