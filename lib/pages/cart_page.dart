import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatCurrency(num amount) {
    return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildCartImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
      );
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 30),
      );
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 30),
      );
    }

    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 30),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shop, child) {
          if (shop.cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Keranjang Anda masih kosong',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // Menghitung total harga keranjang secara langsung
          final double totalPrice = shop.cartItems.fold(
            0.0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shop.cartItems.length,
                  itemBuilder: (ctx, i) {
                    final item = shop.cartItems[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: _buildCartImage(item.imageUrl),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatCurrency(item.price)}',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 22),
                                onPressed: () {
                                  shop.removeFromCart(item.id);
                                },
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 22),
                                onPressed: () {
                                  // Jika ada method tambah quantity di provider Anda
                                  try {
                                    shop.addToCart(
                                      shop.products
                                          .firstWhere((p) => p.id == item.id),
                                    );
                                  } catch (_) {}
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatCurrency(totalPrice)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        // Mengosongkan keranjang satu per satu menggunakan item ID
                        final ids = shop.cartItems.map((e) => e.id).toList();
                        for (var id in ids) {
                          shop.removeFromCart(id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Pesanan Berhasil Dibuat!')),
                        );
                      },
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
