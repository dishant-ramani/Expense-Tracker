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

    final recentTransactions = transactionProvider.transactions.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

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

            _MonthlySpending(
              percentage: monthlySpendingPercentage,
              bgColor: kExpenseCard,
              fillColor: kPrimaryText,
            ),

            const SizedBox(height: 24),

            Text(
              "Recent Transactions",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryText,
                  ),
            ),

            const SizedBox(height: 16),

            /// ------------------ OVERLAPPING TILE LIST ------------------
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTransactions.length,
              itemBuilder: (context, index) {
                final tx = recentTransactions[index];
                final category = categoryProvider.categories.firstWhere(
                  (cat) => cat.id == tx.categoryId,
                  orElse: () => categoryProvider.categories.first,
                );

                return Transform.translate(
                  offset: Offset(0, index == 0 ? 0 : -18),
                  child: _CategoryTile(
                    transaction: tx,
                    category: category,
                  ),
                );
              },
            )
          ],
        ),
      ),

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
// ------------------------- SUMMARY CARD --------------------------
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
        borderRadius: BorderRadius.circular(20),
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
// ----------------------- MONTHLY SPENDING ------------------------
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
// ----------------------- STRIPED PROGRESS ------------------------
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

    canvas.drawRRect(r, Paint()..color = bgColor);

    final filled = size.width * progress;

    final filledRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, filled, size.height),
      const Radius.circular(10),
    );

    canvas.drawRRect(filledRect, Paint()..color = fillColor);

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
// -------------------------- CATEGORY TILE --------------------------
class _CategoryTile extends StatelessWidget {
  final dynamic transaction;
  final dynamic category;

  const _CategoryTile({
    required this.transaction,
    required this.category,
  });

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _buildIcon(Color tint, Color bg) {
    final safe = category.name.toString().toLowerCase().replaceAll(" ", "_");

    final png = "assets/icons/$safe.png";
    final svg = "assets/icons/$safe.svg";

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: FutureBuilder(
        future: _assetExists(png),
        builder: (context, snap) {
          if (!snap.hasData) return const SizedBox(width: 22, height: 22);

          if (snap.data == true) {
            return Image.asset(png, width: 22, height: 22);
          }

          return FutureBuilder(
            future: _assetExists(svg),
            builder: (context, svgSnap) {
              if (!svgSnap.hasData) return const SizedBox(width: 22, height: 22);

              if (svgSnap.data == true) {
                return SvgPicture.asset(
                  svg,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
                );
              }

              return Icon(
                IconData(category.iconCodePoint, fontFamily: "MaterialIcons"),
                color: tint,
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
    final isIncome = transaction.type == "income";

    final tileBg = isIncome ? const Color(0xFFB4D8BD) : const Color(0xFFF5E7D8);
    final iconBg = isIncome ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

    final iconColor = Colors.black87; // matches screenshot
    final amountColor = isIncome ? const Color(0xFF15803D) : const Color(0xFFB91C1C);

    final date = DateFormat("dd MMM yyyy").format(transaction.date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIcon(iconColor, iconBg),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -------- TITLE + AMOUNT (same row) --------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: HomeScreen.kPrimaryText,
                          ),
                    ),

                    Text(
                      "${isIncome ? '+' : '-'}₹${NumberFormat('#,##0', 'en_IN').format(transaction.amount)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: amountColor,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8A),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(width: 8),

          PopupMenuButton<String>(
            elevation: 12,
            itemBuilder: (_) => const [
              PopupMenuItem(value: "edit", child: Text("Edit")),
              PopupMenuItem(value: "delete", child: Text("Delete")),
            ],
            onSelected: (v) {},
            icon: const Icon(Icons.more_horiz_rounded,
                color: HomeScreen.kPrimaryText),
          ),
        ],
      ),
    );
  }
}
