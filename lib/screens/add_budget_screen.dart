import 'package:flutter/material.dart';
import 'package:myapp/models/budget.dart';
import 'package:myapp/providers/budget_provider.dart';
import 'package:provider/provider.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  late TextEditingController _amountController;

  bool get _isEditing => widget.budget != null;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
    {'name': 'Transport', 'icon': Icons.directions_bus, 'color': Colors.green},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.purple},
    {'name': 'Bills', 'icon': Icons.receipt_long, 'color': Colors.blue},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.redAccent},
    {'name': 'Others', 'icon': Icons.category, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedCategory = widget.budget!.category;
      _amountController = TextEditingController(text: widget.budget!.amount.toString());
    } else {
      _amountController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔙 Back Button + Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing ? 'Edit Budget' : 'Add Budget',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🏷 Category Dropdown with Avatar Icons
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: (category['color'] as Color).withOpacity(0.15),
                            child: Icon(
                              category['icon'],
                              color: category['color'],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category['name'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),

                // 💰 Budget Amount Field
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Budget Amount (₹)',
                    filled: true,
                    fillColor: Colors.grey.shade100,
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
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // 💾 Add Budget Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 3,
                    ),
                    onPressed: _saveBudget,
                    child: Text(
                      _isEditing ? 'Save Changes' : 'Save Budget',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
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

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final amount = double.parse(_amountController.text);
      final categoryName = _selectedCategory!;
      final categoryData = _categories.firstWhere((c) => c['name'] == categoryName);
      final icon = categoryData['icon'] as IconData;

      if (_isEditing) {
        final updatedBudget = Budget(
          id: widget.budget!.id,
          category: categoryName,
          amount: amount,
          iconCodePoint: icon.codePoint,
        );
        Provider.of<BudgetProvider>(context, listen: false)
            .updateBudget(updatedBudget);
      } else {
        final newBudget = Budget(
          id: DateTime.now().toString(),
          category: categoryName,
          amount: amount,
          iconCodePoint: icon.codePoint,
        );
        Provider.of<BudgetProvider>(context, listen: false)
            .addBudget(newBudget);
      }
      Navigator.of(context).pop();
    }
  }
}
