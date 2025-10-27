import 'package:hive/hive.dart';
import 'package:myapp/models/category.dart' as my_category;

class CategoryService {
  static const String _boxName = 'categories';

  Future<Box<my_category.Category>> get _box async =>
      await Hive.openBox<my_category.Category>(_boxName);

  Future<void> addCategory(my_category.Category category) async {
    final box = await _box;
    await box.put(category.id, category);
  }

  Future<void> updateCategory(my_category.Category category) async {
    final box = await _box;
    await box.put(category.id, category);
  }

  Future<void> deleteCategory(my_category.Category category) async {
    final box = await _box;
    await box.delete(category.id);
  }

  Future<List<my_category.Category>> getCategories() async {
    final box = await _box;
    return box.values.toList();
  }
}
