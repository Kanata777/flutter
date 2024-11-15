import 'package:agro/screens/dashboard.dart';
import 'package:agro/screens/mystore.dart';
import 'package:agro/screens/trs.dart';
import 'package:agro/screens/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key, required String userId}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    List<Map<String, dynamic>> items = [];

    try {
      if (userId != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('carts')
            .doc(userId)
            .collection('items')
            .get();

        items = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Menyimpan ID dokumen
          return data;
        }).toList();

        setState(() {
          cartItems = items; // Perbarui daftar cartItems
        });
      } else {
        print('User ID tidak tersedia.');
      }
    } catch (e) {
      print('Error mengambil data keranjang: $e');
    }
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    if (quantity < 1) {
      await deleteItem(itemId);
    } else {
      try {
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(userId)
            .collection('items')
            .doc(itemId)
            .update({'quantity': quantity});
        print('Jumlah barang berhasil diupdate menjadi: $quantity');
      } catch (e) {
        print('Error mengupdate jumlah barang: $e');
      }
    }
    await fetchCartItems(); // Ambil ulang data setelah mengupdate
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .delete();
      print('Item berhasil dihapus dari keranjang.');
    } catch (e) {
      print('Error menghapus item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete(); // Hapus setiap item
      }
      print('Semua item di keranjang berhasil dihapus.');

      // Memperbarui tampilan setelah penghapusan
      await fetchCartItems();
    } catch (e) {
      print('Error menghapus item di keranjang: $e');
    }
  }

  Future<void> handleClearCart() async {
    await clearCart(); // Panggil fungsi clearCart yang sudah ada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Belum ada barang di keranjang'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nama Produk: ${item['name'] ?? 'Nama tidak tersedia'}', // Menambahkan nama produk
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Harga: Rp ${item['price'] ?? 0}'),
                            Text(
                                'Kategori: ${item['category'] ?? 'Tidak tersedia'}'),
                            Text('Jumlah: ${item['quantity'] ?? 1}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                int currentQuantity = item['quantity'] ?? 1;
                                updateItemQuantity(
                                    item['id'], currentQuantity - 1);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                int currentQuantity = item['quantity'] ?? 1;
                                updateItemQuantity(
                                    item['id'], currentQuantity + 1);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Harga: Rp${cartItems.fold(0.0, (sum, item) {
                      final price =
                          item['price'] is num ? item['price'].toDouble() : 0.0;
                      final quantity =
                          item['quantity'] is int ? item['quantity'] : 0;
                      return sum + (price * quantity);
                    })} ',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (cartItems.isNotEmpty) {
                      // Ambil detail produk untuk pembayaran
                      List<Map<String, dynamic>> productsForPayment =
                          cartItems.map((item) {
                        return {
                          'id': item['id'], // Simpan productId di sini
                          'name': item['name'],
                          'price': item['price'],
                          'quantity': item['quantity'],
                        };
                      }).toList();

                      // Navigasi ke halaman pembayaran
                      bool paymentSuccess = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Payment(
                            totalPrice: cartItems.fold(0.0, (sum, item) {
                              final price = item['price'] is num
                                  ? item['price'].toDouble()
                                  : 0.0;
                              final quantity = item['quantity'] is int
                                  ? item['quantity']
                                  : 0;
                              return sum + (price * quantity);
                            }),
                            products: productsForPayment,
                            onPaymentSuccess: handleClearCart,
                            onClearCart: handleClearCart,
                          ),
                        ),
                      );

                      // Jika pembayaran berhasil, bersihkan keranjang
                      if (paymentSuccess) {
                        await clearCart();
                      }
                    }
                  },
                  child: const Text('Ke Pembayaran'),
                )
              ],
            ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    int _currentIndex = 1; // Index untuk Cart

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
          backgroundColor: Color.fromRGBO(168, 207, 69, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Pesanan',
          backgroundColor: Color.fromRGBO(168, 207, 69, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Toko Saya',
          backgroundColor: Color.fromRGBO(168, 207, 69, 1),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transaksi',
          backgroundColor: Color.fromRGBO(168, 207, 69, 1),
        ),
      ],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.blueGrey,
      onTap: (int index) {
        if (index == _currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(products: []),
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Cart(userId: ''), // Perbaiki di sini
              ),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Mystore(),
              ),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Trs(),
              ),
            );
            break;
        }
      },
    );
  }
}
