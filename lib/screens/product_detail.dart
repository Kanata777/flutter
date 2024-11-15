import 'dart:typed_data';
import 'dart:convert'; // Tambahkan import ini untuk mendekode Base64
import 'package:agro/screens/chat/chatstart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetail extends StatefulWidget {
  final String productId;
  final String? storeId;
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic> item) onAddToCart;

  ProductDetail({
    Key? key,
    required this.productId,
    required this.product,
    required this.onAddToCart,
    this.storeId, required storeName, required sellerName,
  }) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String sellerName = '';
  String storeName = '';
  String category = '';
  String sellerId = ''; // Tambahkan variabel untuk sellerId
  int quantity = 1;
  Uint8List? productImage; // Untuk menyimpan gambar produk yang didekode

  @override
  void initState() {
    super.initState();
    fetchSellerAndStoreData();
    fetchProductData();
  }

  Future<void> fetchSellerAndStoreData() async {
    await fetchStoreName();
  }

  Future<void> fetchProductData() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;

        setState(() {
          category = productData['category'] ?? 'Kategori Tidak Tersedia';
          productImage =
              _decodeBase64Image(productData['productImage']); // Dekode gambar
          sellerId = productData['sellerId'] ?? ''; // Ambil sellerId dari data produk
        });
      } else {
        setState(() {
          category = 'Kategori tidak ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        category = 'Gagal mengambil kategori: ${e.toString()}';
      });
    }
  }

  Uint8List? _decodeBase64Image(String? base64String) {
    if (base64String != null && base64String.isNotEmpty) {
      return base64.decode(base64String); // Dekode Base64 menjadi Uint8List
    }
    return null;
  }

  Future<void> fetchStoreName() async {
    String? storeId = widget.storeId ?? widget.product['storeId'];
    if (storeId != null && storeId.isNotEmpty) {
      try {
        DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .get();

        if (storeSnapshot.exists) {
          setState(() {
            storeName =
                storeSnapshot['store_name'] ?? 'Nama toko tidak ditemukan';
            sellerName =
                storeSnapshot['seller_name'] ?? 'Nama penjual tidak ditemukan';
          });
        } else {
          setState(() {
            storeName = 'Toko tidak ditemukan';
            sellerName = 'Penjual tidak ditemukan';
          });
        }
      } catch (e) {
        setState(() {
          storeName = 'Gagal mengambil nama toko: ${e.toString()}';
          sellerName = 'Gagal mengambil nama penjual: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        storeName = 'ID toko tidak tersedia';
        sellerName = 'ID penjual tidak tersedia';
      });
    }
  }

  Future<void> addToCartFirestore(BuildContext context) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID tidak valid')),
      );
      return;
    }

    if (widget.productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product ID tidak valid')),
      );
      return;
    }

    try {
      // Ambil data produk dari Firestore
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (!productSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk tidak ditemukan')),
        );
        return;
      }

      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      CollectionReference cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items');

      DocumentSnapshot itemSnapshot = await cartRef.doc(widget.productId).get();

      if (itemSnapshot.exists) {
        // Jika produk sudah ada di keranjang, tambahkan jumlahnya
        int existingQuantity = itemSnapshot['quantity'] ?? 0;
        await cartRef.doc(widget.productId).update({
          'quantity': existingQuantity + quantity,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${productData['name']} jumlahnya diperbarui di keranjang')),
        );
      } else {
        // Jika produk belum ada, tambahkan ke keranjang
        await cartRef.doc(widget.productId).set(
          {
            'name': productData['name'] ?? 'Nama tidak tersedia',
            'price': productData['price'] ?? 0.0,
            'category': productData['category'] ?? 'Kategori tidak tersedia',
            'sellerId': productData['sellerId'] ?? 'Seller ID tidak tersedia',
            'storeId': productData['storeId'] ?? 'Store tidak tersedia',
            'quantity': quantity,
          },
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${productData['name']} telah ditambahkan ke keranjang')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Gagal menambahkan produk ke keranjang: ${e.toString()}')),
      );
    }
  }

 void navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StartChat(
          storeId: widget.storeId ?? '', // Pastikan storeId tidak kosong
          productId: widget.productId,
          sellerId: sellerId, // Pastikan sellerId sudah diambil
          productName: widget.product['name'] ?? 'Nama Produk Tidak Tersedia', initialMessages: [], seller_name: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name'] ?? 'Detail Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan gambar produk
            if (productImage != null)
              Image.memory(
                productImage!,
                fit: BoxFit.cover,
                width: double.infinity, // Lebar gambar mengikuti lebar kontainer
                height: 200, // Atur tinggi gambar sesuai kebutuhan
              ),
            SizedBox(height: 16),
            Text(
              'Harga: Rp${widget.product['price'] ?? 0}',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              widget.product['name'] ?? 'Nama Produk Tidak Tersedia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Dijual oleh: $sellerName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Nama Toko: $storeName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Kategori: $category', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            SizedBox(height: 20),
            Spacer(),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: navigateToChat, // Panggil fungsi untuk chat
                    child: Text('Chat'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      addToCartFirestore(context);
                      widget.onAddToCart(widget.product);
                    },
                    child: Text('Tambah ke Keranjang'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
