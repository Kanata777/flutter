// trs.dart
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'mystore.dart';
import 'cart.dart';
import 'package:agro/screens/model/payment.dart';

class Trs extends StatefulWidget {
  @override
  _TrsState createState() => _TrsState();
}

class _TrsState extends State<Trs> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pembayaran'),
        backgroundColor: const Color.fromARGB(255, 42, 226, 42),
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
                itemCount: PaymentModel.payments.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(PaymentModel.payments[index]['productName']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Harga: Rp ${PaymentModel.payments[index]['price']}'),
                          Text('Tanggal: ${PaymentModel.payments[index]['date']}'),
                          Text('Status: ${PaymentModel.payments[index]['isPaid'] ? 'Sukses' : 'Belum Dibayar'}'),
                        ],
                      ),
                      trailing: Icon(
                        Icons.check_circle,
                        color: PaymentModel.payments[index]['isPaid'] ? Colors.green : Colors.red,
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
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pesanan',
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Toko Saya',
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Riwayat Transaksi',
            backgroundColor: Color.fromARGB(255, 42, 226, 42),
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
            context, MaterialPageRoute(builder: (context) => Dashboard(products: [], storeName: '',)));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Cart(cartItems: [],)));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Mystore()));
        break;
      case 3:
        // Halaman Trs sudah ada, jadi tidak perlu navigasi lagi
        break;
    }
  }
}
