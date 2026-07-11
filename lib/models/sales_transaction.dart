<<<<<<< HEAD
import 'package:isar/isar.dart';

part 'sales_transaction.g.dart';

@collection
class SalesTransaction {
  Id id = Isar.autoIncrement;

  late int productId;
  late String productName;
  late int quantity;
  late int pricePerItem;
  late int totalPrice;
  late DateTime date;
=======
import 'package:isar/isar.dart';

part 'sales_transaction.g.dart';

@collection
class SalesTransaction {
  Id id = Isar.autoIncrement;

  late int productId;
  late String productName;
  late int quantity;
  late int pricePerItem;
  late int totalPrice;
  late DateTime date;
>>>>>>> 9b4bb509a7b1889b3d30e46da9dfed0349681c1e
}