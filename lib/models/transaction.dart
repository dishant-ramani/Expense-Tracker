import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String type;

  @HiveField(2)
  late String category;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String? note;
}
