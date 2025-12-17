import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/budget_screen.dart';
import 'package:myapp/screens/insights_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/add_transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BudgetScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF0C0121);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------
            // TOP HEADER (Figma exact)
            // -------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  // Left circular icon
                  Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0C0121),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/coin.svg', // Make sure this path matches your SVG file's location
                        width: 24,
                        height: 24,
                        //color: Colors.white, // Optional: if you want to change the color
                      ),
                    ),                  ),

                  const SizedBox(width: 12),

                  // App Name
                  const Text(
                    "Paynest",
                    style: TextStyle(
                      fontFamily: "ClashGrotesk",
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),

                  const Spacer(),

                  // + Button (Right)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTransactionScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C0121),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 24, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            // ACTIVE SCREEN
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),

      // -------------------------
      // BOTTOM NAV BAR (Figma exact)
      // -------------------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                assetPath: 'assets/icons/home.svg',
                isSelected: _selectedIndex == 0,
              ),

              _buildNavItem(
                index: 1,
                assetPath: 'assets/icons/budget.svg',
                isSelected: _selectedIndex == 1,
              ),

              _buildNavItem(
                index: 2,
                assetPath: 'assets/icons/insights.svg',
                isSelected: _selectedIndex == 2,
              ),

              _buildNavItem(
                index: 3,
                assetPath: 'assets/icons/setting.svg',
                isSelected: _selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Bottom Nav Item Builder
  // -------------------------
  Widget _buildNavItem({
  required int index,
  required String assetPath,
  required bool isSelected,
}) {
  // Extract the base name and extension
  final pathSegments = assetPath.split('/');
  final fileName = pathSegments.last;
  final baseName = fileName.split('.').first;
  final extension = fileName.split('.').last;
  
  // Create the filled asset path
  final filledAssetPath = '${assetPath.substring(0, assetPath.lastIndexOf('/'))}/$baseName-fill.$extension';

  return GestureDetector(
    onTap: () => _onItemTapped(index),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 56 : 48,
        height: isSelected ? 56 : 48,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C0121) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            isSelected ? filledAssetPath : assetPath,
            width: isSelected ? 48 : 40,
            height: isSelected ? 48 : 40,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.white : const Color(0xFF000000),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    ),
  );

}
}
