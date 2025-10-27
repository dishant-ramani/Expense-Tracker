import 'package:flutter/foundation.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final List<my_category.Category> _categories = [
    my_category.Category()
      ..id = '1'
      ..name = 'Groceries'
      ..iconCodePoint = Icons.shopping_cart.codePoint
      ..colorValue = Colors.green.value
      ..type = 'expense',
    my_category.Category()
      ..id = '2'
      ..name = 'Salary'
      ..iconCodePoint = Icons.attach_money.codePoint
      ..colorValue = Colors.green.value
      ..type = 'income',
    my_category.Category()
      ..id = '3'
      ..name = 'Rent'
      ..iconCodePoint = Icons.home.codePoint
      ..colorValue = Colors.red.value
      ..type = 'expense',
    my_category.Category()
      ..id = '4'
      ..name = 'Freelance'
      ..iconCodePoint = Icons.work.codePoint
      ..colorValue = Colors.blue.value
      ..type = 'income',
  ];

  List<my_category.Category> get categories => _categories;
  bool get isLoading => false;
}
