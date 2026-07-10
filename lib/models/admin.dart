import 'package:isar/isar.dart';

part 'admin.g.dart';

@collection
class Admin {
  Id id = Isar.autoIncrement;

  late String username;
  late String password;
}