import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  String name = '';
  String category = '';
  int price = 0;
  int stock = 0;
  String description = '';
  String imagePath = '';
}
