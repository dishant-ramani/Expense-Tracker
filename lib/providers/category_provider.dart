import 'package:flutter/foundation.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final List<my_category.Category> _categories = [
    // Income
    my_category.Category()
      ..id = '1'
      ..name = 'Salary'
      ..iconCodePoint = Icons.attach_money.codePoint
      ..colorValue = Colors.green.value
      ..type = 'income',
    my_category.Category()
      ..id = '2'
      ..name = 'Business'
      ..iconCodePoint = Icons.business.codePoint
      ..colorValue = Colors.green.value
      ..type = 'income',
    my_category.Category()
      ..id = '3'
      ..name = 'Investment'
      ..iconCodePoint = Icons.trending_up.codePoint
      ..colorValue = Colors.green.value
      ..type = 'income',
    my_category.Category()
      ..id = '4'
      ..name = 'Gift'
      ..iconCodePoint = Icons.card_giftcard.codePoint
      ..colorValue = Colors.green.value
      ..type = 'income',
    my_category.Category()
      ..id = '5'
      ..name = 'Others'
      ..iconCodePoint = Icons.more_horiz.codePoint
      ..colorValue = Colors.green.value
      ..type = 'income',
    // Expense
    my_category.Category()
      ..id = '6'
      ..name = 'Food'
      ..iconCodePoint = Icons.fastfood.codePoint
      ..colorValue = Colors.red.value
      ..type = 'expense',
    my_category.Category()
      ..id = '7'
      ..name = 'Transport'
      ..iconCodePoint = Icons.directions_car.codePoint
      ..colorValue = Colors.red.value
      ..type = 'expense',
    my_category.Category()
      ..id = '8'
      ..name = 'Bills'
      ..iconCodePoint = Icons.receipt.codePoint
      ..colorValue = Colors.red.value
      ..type = 'expense',
    my_category.Category()
      ..id = '9'
      ..name = 'Shopping'
      ..iconCodePoint = Icons.shopping_cart.codePoint
      ..colorValue = Colors.red.value
      ..type = 'expense',
    my_category.Category()
      ..id = '10'
      ..name = 'Entertainment'
      ..iconCodePoint = Icons.movie.codePoint
      ..colorValue = Colors.red.value
      ..type = 'expense',
    my_category.Category()
      ..id = '11'
      ..name = 'Others'
      ..iconCodePoint = Icons.more_horiz.codePoint
      ..colorValue = Colors.red.value
      ..type = 'expense',
  ];

  List<my_category.Category> get categories => _categories;
  bool get isLoading => false;
}
