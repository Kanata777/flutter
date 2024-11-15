import 'dart:convert';

import 'package:agro/screens/store/add_product.dart';
import 'package:agro/screens/store/delete_product.dart';
import 'package:agro/screens/store/edit.dart';
import 'package:agro/screens/store/edit_store.dart';
import 'package:agro/screens/store/sold_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class StoreProfile extends StatelessWidget {
  final String storeId;

  StoreProfile({required this.storeId});

  Future<Uint8List?> _getImageFromBase64(String base64String) async {
    try {
      return Base64Decoder().convert(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Toko'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStorePage(storeId: storeId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('stores').doc(storeId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan!'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Toko tidak ditemukan.'));
          }

          final storeData = snapshot.data!;
          final String storeName = storeData['store_name'] ?? 'Nama Toko';
          final String sellerName = storeData['seller_name'] ?? 'Nama Penjual';
          final String storeDescription =
              storeData['description'] ?? 'Deskripsi tidak tersedia';
          final String? base64Image =
              storeData['profilestore']; // Ambil string Base64

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: base64Image != null && base64Image.isNotEmpty
                          ? FutureBuilder<Uint8List?>(
                              future: _getImageFromBase64(base64Image),
                              builder: (context, imageSnapshot) {
                                if (imageSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                if (imageSnapshot.hasError ||
                                    imageSnapshot.data == null) {
                                  return Center(
                                      child: Text('Gambar tidak tersedia'));
                                }
                                return Image.memory(
                                  imageSnapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Center(child: Text('Gambar tidak tersedia')),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeName,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            sellerName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text(
                            storeDescription,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SoldPage(
                              storeId: storeId,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.shopping_bag),
                      label: Text('Produk Terjual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(168, 207, 69, 1),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProduct(
                              storeId: storeId,
                              onProductAdded: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Produk berhasil ditambahkan!')),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.add),
                      label: Text('Tambah Produk'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('storeId', isEqualTo: storeId)
                      .snapshots(),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (productSnapshot.hasError) {
                      return Center(
                          child: Text('Terjadi kesalahan saat memuat produk.'));
                    }

                    if (!productSnapshot.hasData ||
                        productSnapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text('Tidak ada produk yang ditambahkan.'));
                    }

                    final products = productSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final String productName =
                            product['name'] ?? 'Nama Produk';
                        final double productPrice =
                            product['price']?.toDouble() ?? 0.0;
                        final String? base64Image =
                            product['productImage']; // Ambil string Base64

                        return ListTile(
                          leading: Container(
                            width: 50, // Sesuaikan ukuran lebar
                            height: 50, // Sesuaikan ukuran tinggi
                            decoration: BoxDecoration(
                              color: Colors.grey[
                                  300], // Warna latar jika tidak ada gambar
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: base64Image != null && base64Image.isNotEmpty
                                ? FutureBuilder<Uint8List?>(
                                    future: _getImageFromBase64(
                                        base64Image), // Fungsi untuk mendekode Base64
                                    builder: (context, imageSnapshot) {
                                      if (imageSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (imageSnapshot.hasError ||
                                          imageSnapshot.data == null) {
                                        return Center(
                                            child: Icon(Icons.image,
                                                color: Colors.grey));
                                      }
                                      return Image.memory(
                                        imageSnapshot.data!,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(Icons.image,
                                        color: Colors
                                            .grey)), // Ikon jika tidak ada gambar
                          ),
                          title: Text(productName),
                          subtitle: Text(
                              'Harga: Rp ${productPrice.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProduct(
                                        productId: product.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DeleteProductDialog(
                                      productId: product.id,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
