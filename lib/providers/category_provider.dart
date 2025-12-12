import 'package:flutter/foundation.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final List<my_category.Category> _categories = [
    // ---------------- INCOME ---------------- //
    // ---------------- INCOME ---------------- //
    my_category.Category()
      ..id = '1'
      ..name = 'Salary'
      ..iconCodePoint = Icons.attach_money.codePoint
      ..iconPath = 'assets/icons/salary.svg'
      ..colorValue = Colors.green.value
      ..type = 'income',

    my_category.Category()
      ..id = '2'
      ..name = 'Business'
      ..iconCodePoint = Icons.business.codePoint
      ..iconPath = 'assets/icons/business.svg'
      ..colorValue = Colors.green.value
      ..type = 'income',

    my_category.Category()
      ..id = '3'
      ..name = 'Investment'
      ..iconCodePoint = Icons.trending_up.codePoint
      ..iconPath = 'assets/icons/investment.svg'
      ..colorValue = Colors.green.value
      ..type = 'income',

    my_category.Category()
      ..id = '4'
      ..name = 'Gift'
      ..iconCodePoint = Icons.card_giftcard.codePoint
      ..iconPath = 'assets/icons/gift.svg'
      ..colorValue = Colors.green.value
      ..type = 'income',

    my_category.Category()
      ..id = '5'
      ..name = 'Others'
      ..iconCodePoint = Icons.more_horiz.codePoint
      ..iconPath = 'assets/icons/ic_others_income.svg'
      ..colorValue = Colors.green.value
      ..type = 'income',

    // ---------------- EXPENSE ---------------- //
    my_category.Category()
      ..id = '6'
      ..name = 'Food'
      ..iconCodePoint = Icons.fastfood.codePoint
      ..iconPath = 'assets/icons/food.svg'
      ..colorValue = Colors.red.value
      ..type = 'expense',

    my_category.Category()
      ..id = '7'
      ..name = 'Transport'
      ..iconCodePoint = Icons.directions_car.codePoint
      ..iconPath = 'assets/icons/transport.svg'
      ..colorValue = Colors.red.value
      ..type = 'expense',

    my_category.Category()
      ..id = '8'
      ..name = 'Bills'
      ..iconCodePoint = Icons.receipt.codePoint
      ..iconPath = 'assets/icons/bills.svg'
      ..colorValue = Colors.red.value
      ..type = 'expense',

    my_category.Category()
      ..id = '9'
      ..name = 'Shopping'
      ..iconCodePoint = Icons.shopping_cart.codePoint
      ..iconPath = 'assets/icons/shopping.svg'
      ..colorValue = Colors.red.value
      ..type = 'expense',

    my_category.Category()
      ..id = '10'
      ..name = 'Entertainment'
      ..iconCodePoint = Icons.movie.codePoint
      ..iconPath = 'assets/icons/entertainment.svg'
      ..colorValue = Colors.red.value
      ..type = 'expense',

    my_category.Category()
      ..id = '11'
      ..name = 'Others'
      ..iconCodePoint = Icons.more_horiz.codePoint
      ..iconPath = 'assets/icons/others_expense.svg'
      ..colorValue = Colors.red.value
      ..type = 'expense',
  ];

  List<my_category.Category> get categories => _categories;
  bool get isLoading => false;
}
