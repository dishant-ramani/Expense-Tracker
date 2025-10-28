import 'package:flutter/material.dart';
import 'package:myapp/models/budget.dart';
import 'package:myapp/providers/budget_provider.dart';
import 'package:provider/provider.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  double? _amount;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
    {'name': 'Transport', 'icon': Icons.directions_bus, 'color': Colors.green},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.purple},
    {'name': 'Bills', 'icon': Icons.receipt_long, 'color': Colors.blue},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.redAccent},
    {'name': 'Others', 'icon': Icons.category, 'color': Colors.grey},
  ];

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
                    const Text(
                      'Add Budget',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🏷 Category Dropdown with Avatar Icons
                DropdownButtonFormField(
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
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
                      _selectedCategory = value as String?;
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
                  onSaved: (value) {
                    _amount = double.parse(value!);
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final newBudget = Budget(
                          id: DateTime.now().toString(),
                          category: _selectedCategory!,
                          amount: _amount!,
                          iconCodePoint: (_categories.firstWhere(
                            (c) => c['name'] == _selectedCategory!,
                          )['icon'] as IconData)
                              .codePoint,
                        );
                        Provider.of<BudgetProvider>(context, listen: false)
                            .addBudget(newBudget);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Save Budget',
                      style: TextStyle(
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
}
