import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/budget_screen.dart';
import 'package:myapp/screens/insights_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:provider/provider.dart';

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Modern Glassy Top Bar
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        // App Logo
                        Image.asset(
                          'assets/logo.png',
                          height: 35,
                          fit: BoxFit.contain,
                        ),

                        // Settings Icon
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
                                builder: (context) => const SettingsScreen(),
                              ),
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

      // 🔹 Matching Modern Bottom Navbar
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
                      : Colors.grey.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.9),
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
                  child: BottomNavyBar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: _onItemTapped,
                    backgroundColor: Colors.transparent,
                    iconSize: 28,
                    itemCornerRadius: 20,
                    curve: Curves.easeOutCubic,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    items: <BottomNavyBarItem>[
                      BottomNavyBarItem(
                        icon: AnimatedScale(
                          scale: _selectedIndex == 0 ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.home),
                        ),
                        title: const Text('Home'),
                        activeColor: isDark
                            ? Colors.lightBlueAccent
                            : theme.colorScheme.primary,
                        inactiveColor:
                            isDark ? Colors.grey.shade400 : Colors.grey,
                      ),
                      BottomNavyBarItem(
                        icon: AnimatedScale(
                          scale: _selectedIndex == 1 ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.account_balance_wallet),
                        ),
                        title: const Text('Budgets'),
                        activeColor: isDark
                            ? Colors.lightBlueAccent
                            : theme.colorScheme.primary,
                        inactiveColor:
                            isDark ? Colors.grey.shade400 : Colors.grey,
                      ),
                      BottomNavyBarItem(
                        icon: AnimatedScale(
                          scale: _selectedIndex == 2 ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.insights),
                        ),
                        title: const Text('Insights'),
                        activeColor: isDark
                            ? Colors.lightBlueAccent
                            : theme.colorScheme.primary,
                        inactiveColor:
                            isDark ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ],
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
