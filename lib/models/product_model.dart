class Product {
  final int? id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  // Digunakan saat menyimpan/mengupdate data ke Database SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category, // Wajib dimasukkan ke database!
      'imageUrl': imageUrl, // Path foto galeri wajib disimpan ke database!
    };
  }

  // Digunakan saat membaca data dari Database SQLite
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0),
      category: map['category'] ?? "Men's Shoes",
      // Membaca path foto asli yang disimpan dari galeri HP:
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
