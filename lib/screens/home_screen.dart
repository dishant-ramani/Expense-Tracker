import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/screens/add_transaction_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Figma Colors
  static const Color kPrimaryText = Color(0xFF0C0121);
  static const Color kIncomeCard = Color(0xFFB4D8BD);
  static const Color kExpenseCard = Color(0xFFF5E7D8);

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ------------------- SUMMARY CARDS -------------------
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Total Income",
                    amount: totalIncome,
                    cardColor: kIncomeCard,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: "Total Expenses",
                    amount: totalExpenses,
                    cardColor: kExpenseCard,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ---------------- MONTHLY SPENDING -------------------
            _MonthlySpending(
              percentage: monthlySpendingPercentage,
              bgColor: kExpenseCard,
              fillColor: kPrimaryText,
            ),

            const SizedBox(height: 24),

            // ---------------- RECENT TRANSACTIONS ----------------
            Text(
              "Recent Transactions",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryText,
                  ),
            ),

            const SizedBox(height: 16),

            ...recentTransactions.map((tx) {
              final category = categoryProvider.categories.firstWhere(
                (cat) => cat.id == tx.categoryId,
                orElse: () => categoryProvider.categories.first,
              );

              return _CategoryTile(
                transaction: tx,
                category: category,
              );
            }),
          ],
        ),
      ),

      // ------------------- FLOATING ACTION BUTTON -------------------
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryText.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

//
// -----------------------------------------------------
// SUMMARY CARD (Figma-style rounded rectangle)
// -----------------------------------------------------
//
class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color cardColor;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20), // ← figma radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HomeScreen.kPrimaryText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Text(
            "₹${NumberFormat('#,##0', 'en_IN').format(amount)}",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: HomeScreen.kPrimaryText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

//
// -----------------------------------------------------
// MONTHLY SPENDING BLOCK (Striped progress bar)
// -----------------------------------------------------
//
class _MonthlySpending extends StatelessWidget {
  final double percentage;
  final Color bgColor;
  final Color fillColor;

  const _MonthlySpending({
    required this.percentage,
    required this.bgColor,
    required this.fillColor,
  });
  
  String _label(double p) => "${(p * 100).toStringAsFixed(0)}% of income spent";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title + label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Monthly Spending",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: HomeScreen.kPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              _label(percentage),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HomeScreen.kPrimaryText,
                  ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // striped progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 12,
            child: CustomPaint(
              painter: _StripedProgressPainter(
                progress: percentage,
                bgColor: bgColor,
                fillColor: fillColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//
// -----------------------------------------------------
// STRIPED PROGRESS BAR (Figma effect)
// -----------------------------------------------------
//
class _StripedProgressPainter extends CustomPainter {
  final double progress;
  final Color bgColor;
  final Color fillColor;

  _StripedProgressPainter({
    required this.progress,
    required this.bgColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );

    // Background
    canvas.drawRRect(r, Paint()..color = bgColor);

    final filled = size.width * progress;

    // Filled segment
    final filledRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, filled, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(filledRect, Paint()..color = fillColor);

    // Stripes
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 6;

    const spacing = 14;

    for (double x = -size.height; x < filled + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripedProgressPainter old) =>
      old.progress != progress;
}

//
// -----------------------------------------------------
// CATEGORY TILE (With auto icon placeholder system)
// -----------------------------------------------------
//
class _CategoryTile extends StatelessWidget {
  final dynamic transaction;
  final dynamic category;

  const _CategoryTile({
    required this.transaction,
    required this.category,
  });

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Automatically loads:
  /// assets/icons/<category_name>.png
  /// assets/icons/<category_name>.svg (treated as PNG unless flutter_svg added)
  ///
  /// If missing → falls back to MaterialIcons using iconCodePoint
  Widget _buildCategoryIcon(Color bgColor) {
    final safeName =
        category.name.toString().toLowerCase().replaceAll(" ", "_");

    final pngPath = "assets/icons/$safeName.png";
    final svgPath = "assets/icons/$safeName.svg";

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: FutureBuilder<bool>(
        future: _assetExists(pngPath),
        builder: (context, snapshotPng) {
          if (!snapshotPng.hasData) {
            return const SizedBox(width: 22, height: 22);
          }

          if (snapshotPng.data == true) {
            return Image.asset(pngPath, height: 22, width: 22);
          }

          return FutureBuilder<bool>(
            future: _assetExists(svgPath),
            builder: (context, snapshotSvg) {
              if (!snapshotSvg.hasData) {
                return const SizedBox(width: 22, height: 22);
              }

              if (snapshotSvg.data == true) {
                return SvgPicture.asset(
                  svgPath,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(
                    transaction.type == "income" ? Colors.green : Colors.red,
                    BlendMode.srcIn,
                  ),
                );
              }

              // fallback → material icon
              return Icon(
                IconData(category.iconCodePoint,
                    fontFamily: 'MaterialIcons'),
                color:
                    transaction.type == "income" ? Colors.green : Colors.red,
                size: 22,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';

    final amountColor =
        isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    final bgColor =
        isIncome ? const Color(0xFFE8F8EF) : const Color(0xFFFFF1F2);

    final formattedDate = DateFormat('dd MMM yyyy').format(transaction.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Figma radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          _buildCategoryIcon(bgColor),
          const SizedBox(width: 12),

          // name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: HomeScreen.kPrimaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HomeScreen.kPrimaryText.withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),

          // amount
          Text(
            "${isIncome ? '+' : '-'}₹${NumberFormat('#,##0', 'en_IN').format(transaction.amount)}",
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

          const SizedBox(width: 6),

          // menu
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
                    builder: (_) =>
                        AddTransactionScreen(transaction: transaction),
                  ),
                );
              } else if (value == 'delete') {
                Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(transaction.id);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "edit", child: Text("Edit")),
              PopupMenuItem(value: "delete", child: Text("Delete")),
            ],
            icon: const Icon(Icons.more_horiz_rounded,
                color: HomeScreen.kPrimaryText),
          ),
        ],
      ),
    );
  }
}
