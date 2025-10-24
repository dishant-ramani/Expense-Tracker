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
    // Notify listeners at the beginning of the load to show a loading indicator.
    notifyListeners(); 
    try {
      _transactions = await _transactionService.getTransactions();
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      _transactions = [];
    } finally {
      _isLoading = false;
      // Notify listeners at the end to update the UI with data or an empty state.
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionService.addTransaction(transaction);
      // Optimistic add: update the UI immediately.
      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding transaction: $e");
      // Optional: If the DB write fails, you could remove the transaction 
      // and notify the user.
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionService.updateTransaction(transaction);
      // Optimistic update: find and replace the transaction in the list.
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating transaction: $e");
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      // Find the transaction object to delete from the service layer.
      final transactionToDelete = _transactions.firstWhere((t) => t.id == transactionId);
      await _transactionService.deleteTransaction(transactionToDelete);
      // Optimistic delete: remove the transaction from the list.
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
    }
  }
}
