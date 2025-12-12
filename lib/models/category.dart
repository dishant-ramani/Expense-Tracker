import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int iconCodePoint;     // You can keep this or ignore it now

  @HiveField(3)
  late int colorValue;

  @HiveField(4)
  late String type; // 'expense' or 'income'

  @HiveField(5)
  late String iconPath;       // 👈 NEW FIELD FOR DIRECT ICON USAGE

  // Getters
  Widget get icon {
    if (iconPath != null && iconPath!.isNotEmpty) {
      return Image.asset(
        iconPath!,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) => 
            Icon(IconData(iconCodePoint, fontFamily: 'MaterialIcons')),
      );
    }
    return Icon(IconData(iconCodePoint, fontFamily: 'MaterialIcons'));
  }
  
  Color get color => Color(colorValue);
}
