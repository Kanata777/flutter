import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SoldPage extends StatelessWidget {
  final String storeId;

  SoldPage({required this.storeId});

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        print('User not found!');
        return {};
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final String sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Produk Terjual'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('sellerId', isEqualTo: sellerId)
            .where('status', isEqualTo: 'success')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan!'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Belum ada produk yang terjual.'));
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final String buyerId = transaction['buyerId'];
              final List items = transaction['items'];
              final double total = transaction['totalPrice'] ?? 0.0;

              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserData(buyerId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasError) {
                    return Center(child: Text('Gagal memuat data pembeli.'));
                  }

                  if (userSnapshot.data == null || userSnapshot.data!.isEmpty) {
                    return ListTile(
                      title: Text('Pembeli tidak ditemukan'),
                    );
                  }

                  final userData = userSnapshot.data!;
                  final String buyerName = userData['name'] ?? 'Nama Pembeli';
                  final String buyerAddress = userData['address'] ?? 'Alamat tidak tersedia';

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pembeli: $buyerName',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Alamat: $buyerAddress',
                            style: TextStyle(fontSize: 16),
                          ),
                          Divider(height: 20, color: Colors.grey),
                          Text(
                            'Daftar Barang:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Column(
                            children: items.map((item) {
                              final String itemName = item['name'] ?? 'Nama Barang';
                              final double itemPrice = item['price'] ?? 0.0;
                              final int itemQuantity = item['quantity'] ?? 1;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(itemName),
                                subtitle: Text('Harga: Rp ${itemPrice.toStringAsFixed(2)}'),
                                trailing: Text('Jumlah: $itemQuantity'),
                              );
                            }).toList(),
                          ),
                          Divider(height: 20, color: Colors.grey),
                          Text(
                            'Total: Rp ${total.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
