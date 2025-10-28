import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/budget_screen.dart';
import 'package:myapp/screens/insights_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Custom Top Bar (Logo + Settings)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔸 App Logo only
                  Image.asset(
                    'assets/logo.png',
                    height: 35,
                    fit: BoxFit.contain,
                  ),

                  // 🔸 Settings Icon
                  IconButton(
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: Colors.black87,
                      size: 30,
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

            // 🔹 Body content (current screen)
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(icon: const Icon(Icons.home), title: const Text('Home')),
          BottomNavyBarItem(icon: const Icon(Icons.account_balance_wallet), title: const Text('Budgets')),
          BottomNavyBarItem(icon: const Icon(Icons.insights), title: const Text('Insights')),
        ],
      ),

      // // 🔹 Bottom Navigation Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedItemColor: Colors.blueAccent,
      //   unselectedItemColor: Colors.grey,
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: Colors.white,
      //   elevation: 8,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_rounded),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.account_balance_wallet_rounded),
      //       label: 'Budgets',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.bar_chart_rounded),
      //       label: 'Settings',
      //     ),
      //   ],
      // ),
    );
  }
}
