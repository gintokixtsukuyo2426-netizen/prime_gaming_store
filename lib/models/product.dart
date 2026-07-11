<<<<<<< HEAD
import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

=======
import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

>>>>>>> 9b4bb509a7b1889b3d30e46da9dfed0349681c1e
  String name = '';
  String category = '';
  int price = 0;
  int stock = 0;
  String description = '';
<<<<<<< HEAD
  String imagePath = '';
=======
  String imagePath = '';
>>>>>>> 9b4bb509a7b1889b3d30e46da9dfed0349681c1e
}
