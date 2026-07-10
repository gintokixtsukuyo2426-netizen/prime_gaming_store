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
}