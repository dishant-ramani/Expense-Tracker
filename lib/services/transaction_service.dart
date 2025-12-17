import 'package:hive/hive.dart';
import 'package:myapp/models/transaction.dart';

class TransactionService {
  static const String _boxName = 'transactions';

  Future<Box<Transaction>> get _box async =>
      await Hive.openBox<Transaction>(_boxName);

  Future<void> addTransaction(Transaction transaction) async {
    final box = await _box;
    await box.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final box = await _box;
    await box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await transaction.delete();
  }

  Future<List<Transaction>> getTransactions() async {
    final box = await _box;
    final transactions = box.values.toList();
    // Sort by date in descending order (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> clearAllTransactions() async {
    final box = await _box;
    await box.clear();
  }
}
