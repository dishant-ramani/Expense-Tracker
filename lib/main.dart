import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:myapp/providers/budget_provider.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize database
  await DatabaseService().init();

  // ✅ Initialize AdMob (NO test device ID)
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob initialization failed: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider<TransactionProvider>(
          create: (context) => TransactionProvider(
            Provider.of<CategoryProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),

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
