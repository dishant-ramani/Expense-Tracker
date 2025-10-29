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

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.iconCodePoint, IconData? icon,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
}
