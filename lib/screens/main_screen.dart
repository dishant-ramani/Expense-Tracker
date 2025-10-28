import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/budget_screen.dart';
import 'package:myapp/screens/insights_screen.dart';
import 'package:myapp/widgets/main_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const BudgetScreen(),
    const InsightsScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Budgets',
    'Insights',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      drawer: const MainDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
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
    );
  }
}
