import 'package:flutter/material.dart';
import 'package:myapp/providers/budget_provider.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/services/database_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),

              // 👇 APPLY CLASH GROTESK GLOBALLY (Light Theme)
              fontFamily: 'ClashGrotesk',
              textTheme: ThemeData.light().textTheme.apply(
                    fontFamily: 'ClashGrotesk',
                    bodyColor: Colors.black87,
                    displayColor: Colors.black87,
                  ),

              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),

              // 👇 APPLY CLASH GROTESK GLOBALLY (Dark Theme)
              fontFamily: 'ClashGrotesk',
              textTheme: ThemeData.dark().textTheme.apply(
                    fontFamily: 'ClashGrotesk',
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),

              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1F1F1F),
              ),
            ),

            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
