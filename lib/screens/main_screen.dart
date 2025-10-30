import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/budget_screen.dart';
import 'package:myapp/screens/insights_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_bottom_navbar/ultimate_bottom_navbar.dart';

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
  ];

  final List<IconData> _navIcons = const [
    Icons.home,
    Icons.account_balance_wallet,
    Icons.insights,
  ];

  final List<String> _navTitles = const [
    '',
    '',
    '',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color selectedColor =
        isDark ? Colors.lightBlueAccent : theme.colorScheme.primary;
    final Color unselectedColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Glassy Top Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.blueAccent.withOpacity(0.25)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.blueGrey.withOpacity(0.7),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.97),
                                Colors.white.withOpacity(0.92),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 35,
                          fit: BoxFit.contain,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings_rounded,
                            size: 30,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Active Screen
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),

      // 🔹 Glassy Bottom Nav (Styled like Top Bar)
      bottomNavigationBar: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.blueAccent.withOpacity(0.25)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.blueGrey.withOpacity(0.7),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.97),
                              Colors.white.withOpacity(0.92),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: UltimateBottomNavBar(
                    icons: _navIcons,
                    titles: _navTitles,
                    currentIndex: _selectedIndex,
                    onTap: (index) => _onItemTapped(index),

                    // disable under-curve if it misaligns
                    underCurve: false,
                    staticCurve: false,
                    backgroundHeight: 75,
                    foregroundHeight: 75,
                    navMargin: EdgeInsets.zero,
                    backgroundBorderRadius: BorderRadius.circular(24),

                    // make transparent since we handle background manually
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    showForeGround: false,
                    showForeGroundStrokeAllSide: false,
                    showBackGroundStrokeAllSide: false,

                    // icon/text appearance
                    selectedIconColor: selectedColor,
                    selectedIconSize: 50,
                    unselectedIconColor: unselectedColor,
                    unselectedIconSize: 32,
                    selectedTextSize: 12,
                    unselectedTextSize: 12,
                    selectedTextColor: selectedColor,
                    unselectedTextColor: unselectedColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
