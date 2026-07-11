<<<<<<< HEAD

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/sales_transaction.dart';
import '../models/admin.dart';

class IsarService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ProductSchema, SalesTransactionSchema, AdminSchema],
      directory: dir.path,
    );
  }

  // ============ ADMIN ============

  Future<void> initAdmin() async {
    final count = await isar.admins.count();
    if (count == 0) {
      final admin = Admin()
        ..username = 'admin'
        ..password = 'admin123';
      await isar.writeTxn(() async {
        await isar.admins.put(admin);
      });
    }
  }
Future<void> initDummyProducts() async {
  final count = await isar.products.count();
  if (count > 0) return;
  // ... sisanya sama

  final dummyProducts = [
    Product()
      ..name = 'Mouse Razer DeathAdder V3'
      ..category = 'Mouse'
      ..price = 850000
      ..stock = 15
      ..description = 'Mouse gaming ergonomis dengan sensor optik 30K DPI, cocok untuk gaming FPS profesional.'
      ..imagePath = 'assets/image/mouse_razer.jpg',
    Product()
      ..name = 'Keyboard Mechanical HyperX'
      ..category = 'Keyboard'
      ..price = 1200000
      ..stock = 8
      ..description = 'Keyboard mechanical TKL dengan switch Red linear, backlight RGB per tombol.'
      ..imagePath = 'assets/image/keyboard_hyperx.jpg',
    Product()
      ..name = 'Headset Logitech G435'
      ..category = 'Headset'
      ..price = 950000
      ..stock = 5
      ..description = 'Headset wireless ringan dengan suara surround DTS 7.1, baterai 18 jam.'
      ..imagePath = 'assets/image/headset_logitech.jpg',
    Product()
      ..name = 'Controller PS5 DualSense'
      ..category = 'Controller'
      ..price = 1050000
      ..stock = 3
      ..description = 'Controller original PlayStation 5 dengan haptic feedback dan adaptive trigger.'
      ..imagePath = 'assets/image/controller_ps5.jpg',
    Product()
      ..name = 'Monitor ASUS TUF 144Hz'
      ..category = 'Monitor'
      ..price = 3200000
      ..stock = 2
      ..description = 'Monitor gaming 24 inch Full HD 144Hz IPS, response time 1ms, AMD FreeSync.'
      ..imagePath = 'assets/image/monitor_asus.jpg',
    Product()
      ..name = 'Voucher Mobile Legends 1000 Diamond'
      ..category = 'Voucher Game'
      ..price = 280000
      ..stock = 50
      ..description = 'Voucher top-up Mobile Legends 1000 Diamond, dikirim via kode dalam 5 menit.'
      ..imagePath = 'assets/image/voucher_ml.jpg',
    Product()
      ..name = 'Mouse Pad Steelseries QcK XL'
      ..category = 'Aksesoris'
      ..price = 320000
      ..stock = 20
      ..description = 'Mouse pad gaming ukuran XL 900x300mm, permukaan kain halus anti-slip.'
      ..imagePath = 'assets/image/mousepad_steelseries.jpg', // ← sesuaikan nama ini
    Product()
      ..name = 'Mouse Logitech G102'
      ..category = 'Mouse'
      ..price = 280000
      ..stock = 4
      ..description = 'Mouse gaming entry-level dengan sensor 8000 DPI, RGB 16.8 juta warna.'
      ..imagePath = 'assets/image/mouse_logitech.jpg',
    Product()
      ..name = 'Headset Rexus Vonix F55'
      ..category = 'Headset'
      ..price = 175000
      ..stock = 0
      ..description = 'Headset gaming budget dengan suara stereo jernih, microphone noise-cancelling.'
      ..imagePath = 'assets/image/headset_rexus.jpg',
    Product()
      ..name = 'Keyboard Rexus Daxa M71'
      ..category = 'Keyboard'
      ..price = 450000
      ..stock = 6
      ..description = 'Keyboard mechanical 75% compact dengan RGB, switch Blue clicky.'
      ..imagePath = 'assets/image/keyboard_rexus.jpg',
  ];

  await isar.writeTxn(() async {
    for (final product in dummyProducts) {
      await isar.products.put(product);
    }
  });
}
  Future<Admin?> login(String username, String password) async {
    return await isar.admins
        .filter()
        .usernameEqualTo(username)
        .and()
        .passwordEqualTo(password)
        .findFirst();
  }

  Future<bool> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    final admin = await login(username, oldPassword);
    if (admin == null) return false;
    admin.password = newPassword;
    await isar.writeTxn(() async {
      await isar.admins.put(admin);
    });
    return true;
  }

  Future<Admin?> getAdmin(String username) async {
    return await isar.admins
        .filter()
        .usernameEqualTo(username)
        .findFirst();
  }

  // ============ PRODUCT ============

  Future<void> addProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
  }

  bool _isValidProduct(Product product) {
    return product.name.trim().isNotEmpty &&
        product.category.trim().isNotEmpty &&
        product.price >= 0 &&
        product.stock >= 0;
  }

  Future<List<Product>> getAllProducts() async {
    final products = await isar.products.where().findAll();
    return products.where(_isValidProduct).toList();
  }

  

  Future<List<Product>> searchProducts(String query) async {
    return await isar.products
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }

  Future<List<Product>> getProductsFiltered({
    String query = '',
    String category = 'Semua',
  }) async {
    final allProducts = await getAllProducts();
    return allProducts.where((p) {
      final matchQuery =
          query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
      final matchCategory = category == 'Semua' || p.category == category;
      return matchQuery && matchCategory;
    }).toList();
  }

  Future<void> updateProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
  }

  Future<void> deleteProduct(int id) async {
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });
  }

  Future<void> clearProducts() async {
    await isar.writeTxn(() async {
      await isar.products.clear();
    });
  }

  Future<Map<String, dynamic>> getStats() async {
    final products = await getAllProducts();
    int totalStock = 0;
    int totalValue = 0;
    for (var p in products) {
      totalStock += p.stock;
      totalValue += p.price * p.stock;
    }
    return {
      'totalProducts': products.length,
      'totalStock': totalStock,
      'totalValue': totalValue,
    };
  }

  // ============ TRANSAKSI ============

  Future<bool> createTransaction({
    required Product product,
    required int quantity,
  }) async {
    if (quantity > product.stock) return false;

    final transaction = SalesTransaction()
      ..productId = product.id
      ..productName = product.name
      ..quantity = quantity
      ..pricePerItem = product.price
      ..totalPrice = product.price * quantity
      ..date = DateTime.now();

    await isar.writeTxn(() async {
      product.stock -= quantity;
      await isar.products.put(product);
      await isar.salesTransactions.put(transaction);
    });

    return true;
  }

  Future<List<SalesTransaction>> getAllTransactions() async {
    return await isar.salesTransactions
        .where()
        .sortByDateDesc()
        .findAll();
  }

  Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.salesTransactions.delete(id);
    });
  }

  Future<Map<String, dynamic>> getAllTimeSalesStats() async {
    final transactions = await getAllTransactions();
    int totalRevenue = 0;
    int totalItems = 0;
    for (var t in transactions) {
      totalRevenue += t.totalPrice;
      totalItems += t.quantity;
    }
    return {
      'totalTransactions': transactions.length,
      'totalRevenue': totalRevenue,
      'totalItems': totalItems,
    };
  }
}
=======

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/sales_transaction.dart';
import '../models/admin.dart';

class IsarService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ProductSchema, SalesTransactionSchema, AdminSchema],
      directory: dir.path,
    );
  }

  // ============ ADMIN ============

  Future<void> initAdmin() async {
    final count = await isar.admins.count();
    if (count == 0) {
      final admin = Admin()
        ..username = 'admin'
        ..password = 'admin123';
      await isar.writeTxn(() async {
        await isar.admins.put(admin);
      });
    }
  }
Future<void> initDummyProducts() async {
  final count = await isar.products.count();
  if (count > 0) return;
  // ... sisanya sama

  final dummyProducts = [
    Product()
      ..name = 'Mouse Razer DeathAdder V3'
      ..category = 'Mouse'
      ..price = 850000
      ..stock = 15
      ..description = 'Mouse gaming ergonomis dengan sensor optik 30K DPI, cocok untuk gaming FPS profesional.'
      ..imagePath = 'assets/image/mouse_razer.jpg',
    Product()
      ..name = 'Keyboard Mechanical HyperX'
      ..category = 'Keyboard'
      ..price = 1200000
      ..stock = 8
      ..description = 'Keyboard mechanical TKL dengan switch Red linear, backlight RGB per tombol.'
      ..imagePath = 'assets/image/keyboard_hyperx.jpg',
    Product()
      ..name = 'Headset Logitech G435'
      ..category = 'Headset'
      ..price = 950000
      ..stock = 5
      ..description = 'Headset wireless ringan dengan suara surround DTS 7.1, baterai 18 jam.'
      ..imagePath = 'assets/image/headset_logitech.jpg',
    Product()
      ..name = 'Controller PS5 DualSense'
      ..category = 'Controller'
      ..price = 1050000
      ..stock = 3
      ..description = 'Controller original PlayStation 5 dengan haptic feedback dan adaptive trigger.'
      ..imagePath = 'assets/image/controller_ps5.jpg',
    Product()
      ..name = 'Monitor ASUS TUF 144Hz'
      ..category = 'Monitor'
      ..price = 3200000
      ..stock = 2
      ..description = 'Monitor gaming 24 inch Full HD 144Hz IPS, response time 1ms, AMD FreeSync.'
      ..imagePath = 'assets/image/monitor_asus.jpg',
    Product()
      ..name = 'Voucher Mobile Legends 1000 Diamond'
      ..category = 'Voucher Game'
      ..price = 280000
      ..stock = 50
      ..description = 'Voucher top-up Mobile Legends 1000 Diamond, dikirim via kode dalam 5 menit.'
      ..imagePath = 'assets/image/voucher_ml.jpg',
    Product()
      ..name = 'Mouse Pad Steelseries QcK XL'
      ..category = 'Aksesoris'
      ..price = 320000
      ..stock = 20
      ..description = 'Mouse pad gaming ukuran XL 900x300mm, permukaan kain halus anti-slip.'
      ..imagePath = 'assets/image/mousepad_steelseries.jpg', // ← sesuaikan nama ini
    Product()
      ..name = 'Mouse Logitech G102'
      ..category = 'Mouse'
      ..price = 280000
      ..stock = 4
      ..description = 'Mouse gaming entry-level dengan sensor 8000 DPI, RGB 16.8 juta warna.'
      ..imagePath = 'assets/image/mouse_logitech.jpg',
    Product()
      ..name = 'Headset Rexus Vonix F55'
      ..category = 'Headset'
      ..price = 175000
      ..stock = 0
      ..description = 'Headset gaming budget dengan suara stereo jernih, microphone noise-cancelling.'
      ..imagePath = 'assets/image/headset_rexus.jpg',
    Product()
      ..name = 'Keyboard Rexus Daxa M71'
      ..category = 'Keyboard'
      ..price = 450000
      ..stock = 6
      ..description = 'Keyboard mechanical 75% compact dengan RGB, switch Blue clicky.'
      ..imagePath = 'assets/image/keyboard_rexus.jpg',
  ];

  await isar.writeTxn(() async {
    for (final product in dummyProducts) {
      await isar.products.put(product);
    }
  });
}
  Future<Admin?> login(String username, String password) async {
    return await isar.admins
        .filter()
        .usernameEqualTo(username)
        .and()
        .passwordEqualTo(password)
        .findFirst();
  }

  Future<bool> changePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    final admin = await login(username, oldPassword);
    if (admin == null) return false;
    admin.password = newPassword;
    await isar.writeTxn(() async {
      await isar.admins.put(admin);
    });
    return true;
  }

  Future<Admin?> getAdmin(String username) async {
    return await isar.admins
        .filter()
        .usernameEqualTo(username)
        .findFirst();
  }

  // ============ PRODUCT ============

  Future<void> addProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
  }

  bool _isValidProduct(Product product) {
    return product.name.trim().isNotEmpty &&
        product.category.trim().isNotEmpty &&
        product.price >= 0 &&
        product.stock >= 0;
  }

  Future<List<Product>> getAllProducts() async {
    final products = await isar.products.where().findAll();
    return products.where(_isValidProduct).toList();
  }

  

  Future<List<Product>> searchProducts(String query) async {
    return await isar.products
        .filter()
        .nameContains(query, caseSensitive: false)
        .findAll();
  }

  Future<List<Product>> getProductsFiltered({
    String query = '',
    String category = 'Semua',
  }) async {
    final allProducts = await getAllProducts();
    return allProducts.where((p) {
      final matchQuery =
          query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase());
      final matchCategory = category == 'Semua' || p.category == category;
      return matchQuery && matchCategory;
    }).toList();
  }

  Future<void> updateProduct(Product product) async {
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
  }

  Future<void> deleteProduct(int id) async {
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });
  }

  Future<void> clearProducts() async {
    await isar.writeTxn(() async {
      await isar.products.clear();
    });
  }

  Future<Map<String, dynamic>> getStats() async {
    final products = await getAllProducts();
    int totalStock = 0;
    int totalValue = 0;
    for (var p in products) {
      totalStock += p.stock;
      totalValue += p.price * p.stock;
    }
    return {
      'totalProducts': products.length,
      'totalStock': totalStock,
      'totalValue': totalValue,
    };
  }

  // ============ TRANSAKSI ============

  Future<bool> createTransaction({
    required Product product,
    required int quantity,
  }) async {
    if (quantity > product.stock) return false;

    final transaction = SalesTransaction()
      ..productId = product.id
      ..productName = product.name
      ..quantity = quantity
      ..pricePerItem = product.price
      ..totalPrice = product.price * quantity
      ..date = DateTime.now();

    await isar.writeTxn(() async {
      product.stock -= quantity;
      await isar.products.put(product);
      await isar.salesTransactions.put(transaction);
    });

    return true;
  }

  Future<List<SalesTransaction>> getAllTransactions() async {
    return await isar.salesTransactions
        .where()
        .sortByDateDesc()
        .findAll();
  }

  Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.salesTransactions.delete(id);
    });
  }

  Future<Map<String, dynamic>> getAllTimeSalesStats() async {
    final transactions = await getAllTransactions();
    int totalRevenue = 0;
    int totalItems = 0;
    for (var t in transactions) {
      totalRevenue += t.totalPrice;
      totalItems += t.quantity;
    }
    return {
      'totalTransactions': transactions.length,
      'totalRevenue': totalRevenue,
      'totalItems': totalItems,
    };
  }
}
>>>>>>> 9b4bb509a7b1889b3d30e46da9dfed0349681c1e
