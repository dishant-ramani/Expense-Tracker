import 'package:flutter/material.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:myapp/models/transaction.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  my_category.Category? _selectedCategory;
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final categories = categoryProvider.categories
        .where((c) => c.type == _selectedType)
        .toList();
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories
        .where((c) => c.type == _selectedType)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['expense', 'income'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedType = newValue!;
                    final updatedCategories = categoryProvider.categories
                        .where((c) => c.type == _selectedType)
                        .toList();
                    _selectedCategory = updatedCategories.isNotEmpty
                        ? updatedCategories.first
                        : null;
                  });
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              if (categories.isNotEmpty)
                DropdownButtonFormField<my_category.Category>(
                  value: _selectedCategory,
                  items: categories.map((my_category.Category category) {
                    return DropdownMenuItem<my_category.Category>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                )
              else
                const Text('Please add categories for this type in settings'),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
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
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedCategory != null) {
                    final transaction = Transaction()
                      ..id = const Uuid().v4()
                      ..amount = double.parse(_amountController.text)
                      ..categoryId = _selectedCategory!.id
                      ..date = _selectedDate
                      ..note = _noteController.text
                      ..type = _selectedType;

                    Provider.of<TransactionProvider>(context, listen: false)
                        .addTransaction(transaction);

                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
