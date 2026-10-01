class CartItem {
  final int? id;
  final int productId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['product_id'],
      name: map['name'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
    );
  }
}
