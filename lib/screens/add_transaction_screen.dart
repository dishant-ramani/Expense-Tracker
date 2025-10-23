import 'package:flutter/material.dart';
import 'package:myapp/models/transaction.dart';
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
  String? _selectedCategory;
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Entertainment',
    'Others',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Gift',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories[0];
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _selectedType == 'expense' ? _expenseCategories : _incomeCategories;

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
                    _selectedCategory = (newValue == 'expense'
                        ? _expenseCategories
                        : _incomeCategories)[0];
                  });
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
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
                  if (_formKey.currentState!.validate()) {
                    final transaction = Transaction()
                      ..id = const Uuid().v4()
                      ..amount = double.parse(_amountController.text)
                      ..category = _selectedCategory!
                      ..date = _selectedDate
                      ..note = _noteController.text
                      ..type = _selectedType;

                    Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    ).addTransaction(transaction);

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
