import 'package:flutter/foundation.dart';
import 'package:myapp/models/transaction.dart';
import 'package:myapp/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _transactionService.getTransactions();
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionService.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint("Error adding transaction: $e");
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionService.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint("Error updating transaction: $e");
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transactionToDelete = _transactions.firstWhere((t) => t.id == transactionId);
      await _transactionService.deleteTransaction(transactionToDelete);
      await loadTransactions();
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
    }
  }
}
