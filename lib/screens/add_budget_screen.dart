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
    {'name': 'Food', 'icon': Icons.fastfood},
    {'name': 'Transport', 'icon': Icons.emoji_transportation},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Bills', 'icon': Icons.receipt},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Others', 'icon': Icons.category},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['name'],
                    child: Row(
                      children: [
                        Icon(category['icon']),
                        const SizedBox(width: 10),
                        Text(category['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value as String?;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newBudget = Budget(
                      id: DateTime.now().toString(),
                      category: _selectedCategory!,
                      amount: _amount!,
                      iconCodePoint: (_categories.firstWhere((c) => c['name'] == _selectedCategory!)['icon'] as IconData).codePoint,
                    );
                    Provider.of<BudgetProvider>(context, listen: false).addBudget(newBudget);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
