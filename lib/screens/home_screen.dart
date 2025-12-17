import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

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

    final recentTransactions =
        transactionProvider.transactions.take(100).toList();

    const overlapDistance = 90.0; // ⭐ B: Spacing between overlapped tiles

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            
            Text(
              'Manage Your Money Smartly ✨',
              style: const TextStyle(
                fontFamily: 'ClashGrotesk',
                fontWeight: FontWeight.w500,
                color: kPrimaryText,
                fontSize: 30,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Total Income",
                    amount: totalIncome,
                    cardColor: kIncomeCard,
                    iconPath: 'assets/icons/ArrowRise.svg',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: "Total Expenses",
                    amount: totalExpenses,
                    cardColor: kExpenseCard,
                    iconPath: 'assets/icons/ArrowFall.svg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _MonthlySpending(
              percentage: monthlySpendingPercentage,
              bgColor: const Color(0xFFFFE5D1),
              fillColor: const Color(0xFFFF6B35),
            ),

            const SizedBox(height: 24),

            Text(
              "Recent Transactions",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: kPrimaryText,
                  ),
            ),

            const SizedBox(height: 16),

            //
            // ⭐ TRUE OVERLAPPING USING STACK
            //
            LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight =
                    (recentTransactions.length - 1) * overlapDistance + 140;

                return SizedBox(
                  height: totalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < recentTransactions.length; i++)
                        Positioned(
                          top: i * overlapDistance,
                          left: 0,
                          right: 0,
                          child: _CategoryTile(
                            transaction: recentTransactions[i],
                            category: categoryProvider.categories.firstWhere(
                              (cat) =>
                                  cat.id == recentTransactions[i].categoryId,
                              orElse: () =>
                                  categoryProvider.categories.first,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // floatingActionButton: Container(
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     gradient: const LinearGradient(
      //       colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: kPrimaryText.withOpacity(0.12),
      //         blurRadius: 12,
      //         offset: const Offset(0, 6),
      //       )
      //     ],
      //   ),
      //   child: FloatingActionButton(
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     child: const Icon(Icons.add, color: Colors.white),
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (_) => const AddTransactionScreen(),
      //         ),
      //       );
      //     },
      //   ),
      // ),
    );
  }
}

//
// ------------------------- SUMMARY CARD --------------------------
class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color cardColor;
  final String iconPath;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.cardColor,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 28,
                height: 28,
                color: title == "Total Income" 
                  ? Colors.green[700]
                  : Colors.red[700],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HomeScreen.kPrimaryText,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
Text(
            "₹${NumberFormat('#,##0', 'en_IN').format(amount)}",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: HomeScreen.kPrimaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  height: 1.2,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E7D8), // Light peach background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Spending",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: HomeScreen.kPrimaryText, // Dark text color
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
              ),
              Text(
                _label(percentage),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HomeScreen.kPrimaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStripedProgressBar(percentage, context),
        ],
      ),
    );
  }

  Widget _buildStripedProgressBar(double percentage, BuildContext context) {
    return Container(
      height: 20, // Increased from 8 to 12
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFFE8E8E8), // Light gray background for empty segments
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          painter: _StripedProgressPainter(
            progress: percentage,
            fillColor: const Color(0xFF1D1D1D), // Dark color for filled segments
            bgColor: const Color(0xFFE8E8E8), // Light gray background for empty segments
          ),
          size: const Size(double.infinity, 12), // Increased from 8 to 12 to match container height
        ),
      ),
    );
  }
}

//
// ----------------------- STRIPED PROGRESS ------------------------
class _StripedProgressPainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color bgColor;
  static const int _segmentCount = 73; // Increased number of segments to make them narrower
  static const double _segmentSpacing = 2.0; // Slightly reduced spacing between segments

  _StripedProgressPainter({
    required this.progress,
    required this.fillColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );

    // Calculate segment width and spacing
    final double totalSpacing = (_segmentCount - 1) * _segmentSpacing;
    final double segmentWidth = (size.width - totalSpacing) / _segmentCount;
    final int filledSegments = (progress * _segmentCount).round();

    // Draw filled segments
    if (filledSegments > 0) {
      final fillPaint = Paint()..color = fillColor;
      
      for (int i = 0; i < filledSegments; i++) {
        final double left = i * (segmentWidth + _segmentSpacing);
        final segmentRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left,
            0,
            segmentWidth,
            size.height,
          ),
          const Radius.circular(3), // Slightly increased corner radius for taller segments
        );
        canvas.drawRRect(segmentRect, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StripedProgressPainter old) {
    return old.progress != progress ||
        old.bgColor != bgColor ||
        old.fillColor != fillColor;
  }
  
  @override
  bool shouldRebuildSemantics(covariant _StripedProgressPainter oldDelegate) => false;
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
    final safe = category.name.toLowerCase().replaceAll(" ", "_");

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

  void _handleEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (context.mounted) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.deleteTransaction(transaction.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == "income";

    final tileBg =
        isIncome ? const Color(0xFFB4D8BD) : const Color(0xFFF5E7D8);
    final iconBg =
        isIncome ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

    final iconColor = Colors.black87;
    final amountColor =
        isIncome ? const Color(0xFF000000) : const Color(0xFF000000);

    final date = DateFormat("dd MMM yyyy").format(transaction.date);

    return Container(
      constraints: const BoxConstraints(minHeight: 120), // Increased minimum height
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
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
                /// -------- TITLE + AMOUNT ROW --------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: HomeScreen.kPrimaryText,
                          ),
                    ),
                    Text(
                      "${isIncome ? '+' : '-'}₹${NumberFormat('#,##0', 'en_IN').format(transaction.amount)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
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
                    fontWeight: FontWeight.w400,
                    color: HomeScreen.kPrimaryText,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(width: 8),

            // ====================== POPUP MENU BUTTON ======================
            // This is the three-dot menu that appears on each transaction card
            PopupMenuButton<String>(
              // Elevation of the popup menu (shadow effect)
              elevation: 12,
              
              // Background color of the popup menu
              color: Colors.white,
              
              // Shape of the popup menu
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              
              // Padding inside the popup menu
              padding: EdgeInsets.zero,
              
              // Items in the popup menu
              itemBuilder: (context) => [
                // ===== EDIT MENU ITEM =====
                PopupMenuItem<String>(
                  value: "edit",
                  // Custom padding for the menu item
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // Height of the menu item
                  height: 40,
                  // The actual widget for the menu item
                  child: Row(
                    children: [
                      // Icon for the menu item
                      SvgPicture.asset(
                        'assets/icons/edit.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 12),
                      // Text for the menu item
                      Text(
                        "Edit",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Divider between menu items
                const PopupMenuDivider(),
                
                // ===== DELETE MENU ITEM =====
                PopupMenuItem<String>(
                  value: "delete",
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 40,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/delete.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Delete",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Callback when a menu item is selected
              onSelected: (value) {
                if (value == "edit") {
                  _handleEdit(context);
                } else if (value == "delete") {
                  _handleDelete(context);
                }
              },
              
              // The icon that triggers the popup menu
              icon: const Icon(
                Icons.more_vert_rounded,
                color: HomeScreen.kPrimaryText,
                size: 24, // You can adjust the size of the icon here
              ),
              
              // Offset to adjust the position of the popup menu
              offset: const Offset(0, 40),
              
              // Constraints for the popup menu
              constraints: const BoxConstraints(
                minWidth: 160, // Minimum width of the popup menu
                maxWidth: 200, // Maximum width of the popup menu
              ),
            ),
        ],
      ),
    );
  }
}
