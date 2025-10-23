import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/models/budget.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/models/transaction.dart';

class DatabaseService {
  static const String transactionsBoxName = 'transactions';
  static const String categoriesBoxName = 'categories';
  static const String budgetsBoxName = 'budgets';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(BudgetAdapter());
    await Hive.openBox<Transaction>(transactionsBoxName);
    await Hive.openBox<Category>(categoriesBoxName);
    await Hive.openBox<Budget>(budgetsBoxName);
  }
}
