import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'toko_digital.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE master_products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE local_cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER,
            name TEXT,
            price REAL,
            quantity INTEGER
          )
        ''');

        // Dummy Products
        await db.insert('master_products',
            {'name': 'Nike Blazer Low \'77 Jumbo', 'price': 120.11});
        await db.insert('master_products',
            {'name': 'Nike Air Force 1 \'07 LV8', 'price': 320.11});
        await db.insert('master_products',
            {'name': 'Air Jordan 7 Retro SE', 'price': 120.11});
        await db.insert('master_products',
            {'name': 'Nike Blazer Mid \'77', 'price': 100.99});
      },
    );
  }

  // Master Products CRUD
  static Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('master_products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  static Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('master_products', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('master_products', where: 'id = ?', whereArgs: [id]);
    await db.delete('local_cart',
        where: 'product_id = ?', whereArgs: [id]); // Hapus dari cart jika ada
  }

  // Cart CRUD
  static Future<List<CartItem>> getCart() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('local_cart');
    return List.generate(maps.length, (i) => CartItem.fromMap(maps[i]));
  }

  static Future<void> insertCartItem(CartItem item) async {
    final db = await database;
    await db.insert('local_cart', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateCartQuantity(int productId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await db.delete('local_cart',
          where: 'product_id = ?', whereArgs: [productId]);
    } else {
      await db.update(
        'local_cart',
        {'quantity': quantity},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    }
  }

  static Future<void> deleteCartItem(int productId) async {
    final db = await database;
    await db
        .delete('local_cart', where: 'product_id = ?', whereArgs: [productId]);
  }
}
