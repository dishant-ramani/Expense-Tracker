import 'package:hive/hive.dart';
import 'package:myapp/models/category.dart';

class CategoryService {
  static const String _boxName = 'categories';

  Future<Box<Category>> get _box async =>
      await Hive.openBox<Category>(_boxName);

  Future<void> addCategory(Category category) async {
    final box = await _box;
    await box.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    final box = await _box;
    await box.put(category.id, category);
  }

  Future<void> deleteCategory(Category category) async {
    final box = await _box;
    await box.delete(category.id);
  }

  Future<List<Category>> getCategories() async {
    final box = await _box;
    return box.values.toList();
  }
}
