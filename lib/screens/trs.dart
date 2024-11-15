import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'mystore.dart';
import 'cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class Trs extends StatefulWidget {
  @override
  _TrsState createState() => _TrsState();
}

class _TrsState extends State<Trs> {
  int _currentIndex = 3;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final buyerId = FirebaseAuth.instance.currentUser?.uid;

      // Ambil data transaksi sebagai pembeli
      QuerySnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('buyerId', isEqualTo: buyerId)
          .get();

      // Ambil data transaksi sebagai penjual
      QuerySnapshot sellerSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('sellerId', isEqualTo: buyerId)
          .get();

      List<Map<String, dynamic>> transactions = [];

      // Proses transaksi sebagai pembeli
      for (var paymentDoc in paymentSnapshot.docs) {
        Map<String, dynamic> paymentData =
            paymentDoc.data() as Map<String, dynamic>;

        transactions.add(_mapTransaction(paymentData, true));
      }

      // Proses transaksi sebagai penjual
      for (var paymentDoc in sellerSnapshot.docs) {
        Map<String, dynamic> paymentData =
            paymentDoc.data() as Map<String, dynamic>;

        transactions.add(_mapTransaction(paymentData, false));
      }

      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Map<String, dynamic> _mapTransaction(
      Map<String, dynamic> paymentData, bool isBuyer) {
    // Ambil status transaksi dari field status
    String status = paymentData['status'] ?? 'Status Tidak Diketahui';

    // Ambil data produk dan timestamp
    double totalPrice = (paymentData['totalPrice'] ?? 0).toDouble();

    // Ubah format tanggal jika ada timestamp
    String formattedDate = '';
    if (paymentData['timestamp'] != null) {
      Timestamp timestamp = paymentData['timestamp'];
      DateTime dateTime = timestamp.toDate();
      formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }

    // Tentukan apakah transaksi adalah pembelian atau penjualan
    String transactionStatus;
    if (status == 'success') {
      transactionStatus = isBuyer ? 'Pembelian Sukses' : 'Penjualan Sukses';
    } else {
      transactionStatus = status; // Status lainnya
    }

    return {
      'id': paymentData['id'],
      'status': transactionStatus,
      'date': formattedDate,
      'totalPrice': totalPrice,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pembayaran'),
        backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Riwayat Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  var transaction = _transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${transaction['status']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaction['status'].contains('Sukses')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          Text(
                              'Total Harga: Rp ${transaction['totalPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                          Text(
                              'Tanggal: ${transaction['date'] ?? 'Tidak Tersedia'}'),
                        ],
                      ),
                      trailing: Icon(
                        Icons.check_circle,
                        color: transaction['status'].contains('Sukses')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            label: 'Riwayat Transaksi',
            backgroundColor: Color.fromRGBO(168, 207, 69, 1),
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.blueGrey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          _navigateToPage(index);
        },
      ),
    );
  }

  void _navigateToPage(int index) {
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
            builder: (context) => Cart(
              userId: '',
            ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Mystore()),
        );
        break;
      case 3:
        // Tetap di halaman Riwayat Transaksi
        break;
    }
  }
}
