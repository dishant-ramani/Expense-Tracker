import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:myapp/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text('No categories added yet.'));
          }

          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return ListTile(
                leading: Icon(IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'), color: Color(category.colorValue)),
                title: Text(category.name),
                subtitle: Text(category.type),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    provider.deleteCategory(category);
                  },
                ),
                onTap: () {
                  _showAddCategoryDialog(context, category: category);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, {my_category.Category? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    IconData? selectedIcon = isEditing ? IconData(category!.iconCodePoint, fontFamily: 'MaterialIcons') : null;
    Color? selectedColor = isEditing ? Color(category!.colorValue) : null;
    String selectedType = category?.type ?? 'expense';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: ['expense', 'income'].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Icon: '),
                      IconButton(
                        icon: Icon(selectedIcon ?? Icons.add_reaction),
                        onPressed: () async {
                          final IconData? icon = (await showIconPicker(context)) as IconData?;
                          if (icon != null) {
                            setState(() {
                              selectedIcon = icon;
                            });
                          }
                        },
                      ),
                      const Spacer(),
                      const Text('Color: '),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Pick a color'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: selectedColor ?? Colors.blue,
                                    onColorChanged: (Color color) {
                                      setState(() {
                                        selectedColor = color;
                                      });
                                    },
                                    showLabel: true,
                                    pickerAreaHeightPercent: 0.8,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Got it'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: selectedColor ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty && selectedIcon != null && selectedColor != null) {
                  final newCategory = my_category.Category()
                    ..id = category?.id ?? const Uuid().v4()
                    ..name = name
                    ..iconCodePoint = selectedIcon!.codePoint
                    ..colorValue = selectedColor!.value
                    ..type = selectedType;

                  if (isEditing) {
                    Provider.of<CategoryProvider>(context, listen: false)
                        .updateCategory(newCategory);
                  } else {
                    Provider.of<CategoryProvider>(context, listen: false)
                        .addCategory(newCategory);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
