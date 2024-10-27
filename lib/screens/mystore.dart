import 'package:agro/screens/store/manage_store.dart';
import 'package:agro/screens/store/product.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'trs.dart';
import 'cart.dart';

class Mystore extends StatefulWidget {
  @override
  _MystoreState createState() => _MystoreState();
}

class _MystoreState extends State<Mystore> with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late TabController _tabController;

  bool hasStore = false; // Kondisi apakah penjual sudah memiliki toko

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toko Saya'),
        backgroundColor: const Color.fromARGB(255, 42, 226, 42),
        automaticallyImplyLeading: false,
        bottom: hasStore // Periksa apakah toko sudah ada atau belum
            ? TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Atur Toko'),
                  Tab(text: 'Tambah Produk'),
                ],
              )
            : null,
      ),
      body: hasStore
          ? TabBarView(
              controller: _tabController,
              children: [
                StoreSettings(),
                AddProduct(),
              ],
            )
          : _buildNoStoreView(context), // Tampilkan tampilan alternatif jika toko belum ada
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
            label: 'Transaksi',
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

  // Widget untuk menampilkan pesan ketika belum memiliki toko
  Widget _buildNoStoreView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Kamu belum mempunyai toko sekarang',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Mengubah kondisi hasStore menjadi true
                hasStore = true;
                // Mengubah tabController ke tab pertama (Atur Toko)
                _tabController.index = 0;
              });
            },
            child: Text('Ayo Buat Tokomu'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Dashboard(
                      products: [],
                      storeName: '',
                    )));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Cart(cartItems: [])));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Mystore()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Trs()));
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
