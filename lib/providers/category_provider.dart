import 'package:flutter/foundation.dart' hide Category;
import 'package:myapp/models/category.dart';
import 'package:myapp/services/category_service.dart';
import 'dart:developer' as developer;

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _categoryService.getCategories();
    } catch (e, s) {
      developer.log(
        'Error loading categories',
        name: 'myapp.category_provider',
        error: e,
        stackTrace: s,
      );
      _categories = [];
    }
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await _categoryService.updateCategory(category);
    await _loadCategories();
  }

  Future<void> deleteCategory(Category category) async {
    await _categoryService.deleteCategory(category);
    await _loadCategories();
  }
}
