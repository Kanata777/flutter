import 'package:agro/screens/chat.dart'; // Pastikan import ini sesuai dengan struktur project Anda
import 'package:flutter/material.dart';

class ProductDetail extends StatelessWidget {
  final String sellerName; // Nama penjual
  final List<Map<String, dynamic>> initialMessages; // Daftar pesan awal
  final Map<String, dynamic> product;
  final String storeName;
  final double rating;
  final Function(Map<String, dynamic>) onAddToCart;

  ProductDetail({
    required this.product,
    required this.storeName,
    required this.sellerName,
    required this.rating,
    required this.initialMessages, // Tambahkan initialMessages sebagai parameter
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']!),
        backgroundColor: const Color.fromARGB(255, 42, 226, 42),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: product['name']!,
                child: Image.asset(
                  product['image']!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product['name']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${product['price']!}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text(
              'Informasi Toko',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nama Toko: $storeName'),
            Text('Nama Penjual: $sellerName'),
            Text('Rating: ${rating.toStringAsFixed(1)} ⭐'),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ini adalah deskripsi dari produk ${product['name']}.',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onAddToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${product['name']} ditambahkan ke keranjang!')),
                      );
                    },
                    child: const Text('Tambah ke Keranjang'),
                  ),
                  const SizedBox(height: 16), // Jarak antar tombol
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Chat(sellerName: '', initialMessages: [], initialChatWith: '',),
                        ),
                      );
                    },
                    child: const Text('Chat dengan Penjual'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
