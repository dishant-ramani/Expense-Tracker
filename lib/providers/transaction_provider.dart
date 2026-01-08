import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/transaction.dart';
import 'package:myapp/services/transaction_service.dart';
import 'package:myapp/providers/category_provider.dart';

// Global key for navigator to access context in provider
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final CategoryProvider _categoryProvider;
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;
  String? _transactionType; // 'income' or 'expense'
  String _dateFilterType = 'all'; // 'all', 'this_week', 'this_month', 'this_year', 'last_month', 'custom'

  TransactionProvider(this._categoryProvider) {
    // Load transactions when the provider is created
    loadTransactions();
  }

  List<Transaction> get transactions => _filteredTransactions;
  bool get isFiltered => _dateFilterType != 'all' || _selectedCategoryId != null || _transactionType != null;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get transactionType => _transactionType;
  String get dateFilterType => _dateFilterType;
  
  void setDateFilter(String filterType, {DateTime? customStart, DateTime? customEnd}) {
    _dateFilterType = filterType;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filterType) {
      case 'this_week':
        _startDate = today.subtract(Duration(days: today.weekday - 1));
        _endDate = _startDate!.add(const Duration(days: 6));
        break;
      case 'this_month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'this_year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case 'last_month':
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final year = now.month == 1 ? now.year - 1 : now.year;
        _startDate = DateTime(year, lastMonth, 1);
        _endDate = DateTime(year, lastMonth + 1, 0);
        break;
      case 'custom':
        _startDate = customStart;
        _endDate = customEnd;
        break;
      case 'all':
      default:
        _startDate = null;
        _endDate = null;
        break;
    }
    _filterTransactions();
  }

  void setCategoryFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    _filterTransactions();
  }

  void setTransactionType(String? type) {
    _transactionType = type;
    _filterTransactions();
  }
  
  void clearFilters() {
    _dateFilterType = 'all';
    _startDate = null;
    _endDate = null;
    _selectedCategoryId = null;
    _transactionType = null;
    _filterTransactions();
  }
  
  void _filterTransactions() {
    _filteredTransactions = _transactions.where((transaction) {
      bool matches = true;
      
      // Date range filter
      if (_startDate != null) {
        final oneSecondBefore = _startDate!.subtract(const Duration(seconds: 1));
        matches = matches && (transaction.date.isAfter(oneSecondBefore) || 
                             transaction.date.isAtSameMomentAs(_startDate!));
      }
      if (_endDate != null) {
        final endOfDay = _endDate!.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
        matches = matches && (transaction.date.isBefore(endOfDay) ||
                             transaction.date.isAtSameMomentAs(_endDate!));
      }
      
      // Category filter
      if (_selectedCategoryId != null) {
        matches = matches && transaction.categoryId == _selectedCategoryId;
      }
      
          // Transaction type filter (income/expense)
      if (_transactionType != null) {
        final category = _categoryProvider.getCategoryById(transaction.categoryId);
        if (category != null) {
          matches = matches && category.type == _transactionType;
        } else {
          // If category is not found, exclude the transaction from results
          matches = false;
        }
      }
      
      return matches;
    }).toList();
    
    notifyListeners();
  }
  bool get isLoading => _isLoading;

  // Remove the default constructor since we're now requiring CategoryProvider

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _transactionService.getTransactions();
      _filterTransactions();
    } catch (e) {
      debugPrint("Error loading transactions: $e");
      _transactions = [];
      _filteredTransactions = [];
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
