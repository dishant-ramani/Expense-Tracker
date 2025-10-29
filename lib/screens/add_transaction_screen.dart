import 'package:flutter/material.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:myapp/models/transaction.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  my_category.Category? _selectedCategory;
  late String _selectedType;
  late DateTime _selectedDate;
  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final transaction = widget.transaction!;
      _amountController = TextEditingController(text: transaction.amount.toString());
      _noteController = TextEditingController(text: transaction.note);
      _selectedType = transaction.type;
      _selectedDate = transaction.date;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _selectedType = 'expense';
      _selectedDate = DateTime.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (_isEditing) {
      _selectedCategory = categoryProvider.categories.firstWhere((c) => c.id == widget.transaction!.categoryId);
    } else {
      final categories = categoryProvider.categories.where((c) => c.type == _selectedType).toList();
      if (categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories =
        categoryProvider.categories.where((c) => c.type == _selectedType).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 Back Button and Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing ? 'Edit Transaction' : 'Add Transaction',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 💵 Amount Field
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (₹)',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 💰 Type Dropdown (with icons and colors)
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: [
                    {
                      'value': 'expense',
                      'icon': Icons.arrow_downward_rounded,
                      'color': Colors.redAccent,
                      'label': 'Expense'
                    },
                    {
                      'value': 'income',
                      'icon': Icons.arrow_upward_rounded,
                      'color': Colors.green,
                      'label': 'Income'
                    },
                  ].map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'] as String,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                (type['color'] as Color).withOpacity(0.15),
                            child: Icon(
                              type['icon'] as IconData,
                              color: type['color'] as Color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            type['label'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedType = newValue!;
                      final updatedCategories = categoryProvider.categories
                          .where((c) => c.type == _selectedType)
                          .toList();
                      _selectedCategory =
                          updatedCategories.isNotEmpty ? updatedCategories.first : null;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Transaction Type',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 🏷 Category Dropdown with Icons
                if (categories.isNotEmpty)
                  DropdownButtonFormField<my_category.Category>(
                    value: _selectedCategory,
                    items: categories.map((my_category.Category category) {
                      final color = _getCategoryColor(category.name);
                      final icon = _getCategoryIcon(category.name);

                      return DropdownMenuItem<my_category.Category>(
                        value: category,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: color.withOpacity(0.15),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  const Text(
                    'No categories found. Please add some in settings.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 16),

                // 📝 Note Field
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 📅 Date Picker Styled Like Text Field
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        filled: true,
                        suffixIcon:
                            Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedDate.toLocal().toString().split(' ')[0],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 💾 Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 3,
                    ),
                    onPressed: _saveTransaction,
                    child: Text(
                      _isEditing ? 'Save Changes' : 'Save Transaction',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📅 Date picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 💾 Save transaction
  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text;

      if (_isEditing) {
        final updatedTransaction = Transaction()
          ..id = widget.transaction!.id
          ..amount = amount
          ..categoryId = _selectedCategory!.id
          ..date = _selectedDate
          ..note = note
          ..type = _selectedType;

        Provider.of<TransactionProvider>(context, listen: false).updateTransaction(updatedTransaction);
      } else {
        final newTransaction = Transaction()
          ..id = const Uuid().v4()
          ..amount = amount
          ..categoryId = _selectedCategory!.id
          ..date = _selectedDate
          ..note = note
          ..type = _selectedType;

        Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTransaction);
      }

      Navigator.pop(context);
    }
  }

  // 🎨 Helper to get category color
  Color _getCategoryColor(String name) {
    switch (name) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.green;
      case 'Shopping':
        return Colors.purple;
      case 'Bills':
        return Colors.blue;
      case 'Entertainment':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // 🧩 Helper to get category icon
  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'Food':
        return Icons.fastfood;
      case 'Transport':
        return Icons.directions_bus;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
}
