import 'package:flutter/foundation.dart';
import 'package:myapp/models/transaction.dart';
import 'package:myapp/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    _transactions = await _transactionService.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionService.addTransaction(transaction);
    await _loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionService.updateTransaction(transaction);
    await _loadTransactions();
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionService.deleteTransaction(transaction);
    await _loadTransactions();
  }
}
