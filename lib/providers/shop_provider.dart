import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class CartItem {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class ShopProvider with ChangeNotifier {
  List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  Product? _promoProduct;
  // Baris 26: Tambahkan kata kunci 'final'
  final double _discountPercentage = 50.0; // Persentase Diskon Default (50%)
  Database? _db;

  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  Product? get promoProduct => _promoProduct;
  double get discountPercentage => _discountPercentage;

  // Getter Perhitungan Harga Sesudah Diskon
  double get discountedPromoPrice {
    if (_promoProduct == null) return 0.0;
    return _promoProduct!.price * (1 - (_discountPercentage / 100));
  }

  ShopProvider() {
    _initDatabase().then((_) => fetchProducts());
  }

  Future<Database> _initDatabase() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, 'toko_digital.db');

    _db = await openDatabase(
      pathString,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            category TEXT,
            imageUrl TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE promo (
            id INTEGER PRIMARY KEY,
            productId INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS promo (
              id INTEGER PRIMARY KEY,
              productId INTEGER
            )
          ''');
        }
      },
    );
    return _db!;
  }

  Future<void> fetchProducts() async {
    final db = await _initDatabase();
    final List<Map<String, dynamic>> maps = await db.query('products');
    _products = maps.map((item) => Product.fromMap(item)).toList();

    // Load Promo dari SQLite
    final List<Map<String, dynamic>> promoMaps = await db.query('promo');
    if (promoMaps.isNotEmpty && _products.isNotEmpty) {
      final savedPromoId = promoMaps.first['productId'] as int;
      try {
        _promoProduct = _products.firstWhere((p) => p.id == savedPromoId);
      } catch (_) {
        _promoProduct = _products.first;
      }
    } else if (_products.isNotEmpty) {
      _promoProduct = _products.first;
    }

    notifyListeners();
  }

  Future<void> fetchAndSetData() async {
    await fetchProducts();
  }

  // Set Promo dan Simpan ke SQLite
  Future<void> setPromoProduct(Product product) async {
    _promoProduct = product;
    notifyListeners();

    final db = await _initDatabase();
    await db.delete('promo');
    if (product.id != null) {
      await db.insert('promo', {'id': 1, 'productId': product.id});
    }
  }

  // Tambah Produk
  Future<void> addProduct(
      String name, double price, String? imageUrl, String category) async {
    final db = await _initDatabase();
    final newProductMap = {
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl ?? '',
    };

    final id = await db.insert('products', newProductMap);
    final newProd = Product(
      id: id,
      name: name,
      price: price,
      category: category,
      imageUrl: imageUrl ?? '',
    );
    _products.add(newProd);

    if (_promoProduct == null) {
      setPromoProduct(newProd);
    } else {
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    final db = await _initDatabase();
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    _products.removeWhere((p) => p.id == id);
    _cartItems.removeWhere((item) => item.id == id);
    if (_promoProduct?.id == id) {
      _promoProduct = _products.isNotEmpty ? _products.first : null;
    }
    notifyListeners();
  }

  void addToCart(Product product) {
    if (product.id == null) return;
    final index = _cartItems.indexWhere((item) => item.id == product.id);

    if (index >= 0) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(CartItem(
        id: product.id!,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(int id) {
    final index = _cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
