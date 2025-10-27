import 'package:flutter/foundation.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:myapp/services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<my_category.Category> _categories = [];
  bool _isLoading = false;

  List<my_category.Category> get categories => _categories;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    _categories = await _categoryService.getCategories();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(my_category.Category category) async {
    await _categoryService.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(my_category.Category category) async {
    await _categoryService.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(my_category.Category category) async {
    await _categoryService.deleteCategory(category);
    await loadCategories();
  }
}
