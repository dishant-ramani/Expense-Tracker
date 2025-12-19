import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final int iconCodePoint;
  
  @HiveField(4)
  final String? note;
  
  @HiveField(5)
  final String categoryId;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.iconCodePoint,
    this.note,
    required this.categoryId,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  
  // For editing existing budgets
  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    int? iconCodePoint,
    String? note,
    String? categoryId,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
