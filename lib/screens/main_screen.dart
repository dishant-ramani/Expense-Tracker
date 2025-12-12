import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/budget_screen.dart';
import 'package:myapp/screens/insights_screen.dart';
import 'package:myapp/screens/settings_screen.dart';

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
                      child: Icon(Icons.currency_exchange,
                          color: Colors.white, size: 22),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // App Name
                  const Text(
                    "Paynest",
                    style: TextStyle(
                      fontFamily: "ClashGrotesk",
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const Spacer(),

                  // + Button (Right)
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0C0121),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, size: 24, color: Colors.white),
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                isSelected: _selectedIndex == 0,
              ),

              _buildNavItem(
                index: 1,
                icon: Icons.account_balance_wallet_rounded,
                isSelected: _selectedIndex == 1,
              ),

              _buildNavItem(
                index: 2,
                icon: Icons.insights_rounded,
                isSelected: _selectedIndex == 2,
              ),

              _buildNavItem(
                index: 3,
                icon: Icons.settings_rounded,
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
    required IconData icon,
    required bool isSelected,
  }) {
    const Color primary = Color(0xFF0C0121);

    if (isSelected) {
      return GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          height: 52,
          width: 52,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, size: 26, color: primary),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        height: 52,
        width: 52,
        child: Icon(icon, size: 24, color: primary.withOpacity(0.45)),
      ),
    );
  }
}
