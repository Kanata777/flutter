import 'package:agro/screens/store/store_profile.dart';
import 'package:agro/screens/store/store_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';
import 'trs.dart';
import 'cart.dart';

class Mystore extends StatefulWidget {
  @override
  _MystoreState createState() => _MystoreState();
}

class _MystoreState extends State<Mystore> with SingleTickerProviderStateMixin {
  int _currentIndex = 2;

  bool hasStore = false;
  String storeId = '';
  bool isLoading = true; // Menambahkan indikator loading

  @override
  void initState() {
    super.initState();
    _checkStoreStatus(); // Memanggil fungsi untuk mengecek status toko
  }

  Future<void> _checkStoreStatus() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final String sellerId = user.uid; // Menggunakan sellerId

        // Mengecek apakah data toko ada di Firestore berdasarkan sellerId
        QuerySnapshot storeSnapshot = await FirebaseFirestore.instance
            .collection('stores')
            .where('sellerId', isEqualTo: sellerId)
            .limit(1) // Mengambil satu dokumen yang sesuai
            .get();

        setState(() {
          hasStore = storeSnapshot
              .docs.isNotEmpty; // Mengubah status toko berdasarkan hasil
          storeId = hasStore
              ? storeSnapshot.docs.first.id
              : ''; // Mengambil storeId jika toko ada
          isLoading = false; // Menghentikan loading setelah data diterima
        });
      } else {
        print("Pengguna belum login.");
        setState(() {
          isLoading =
              false; // Menghentikan loading meskipun pengguna belum login
        });
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toko Saya'),
        backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasStore
              ? StoreProfile(
                  storeId: storeId) // Menampilkan profil toko jika ada
              : _buildNoStoreView(context),
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
            label: 'Transaksi',
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
            onPressed: _navigateToStoreSettings,
            child: Text('Ayo Buat Tokomu'),
          ),
        ],
      ),
    );
  }

  void _navigateToStoreSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreSettings(
          onStoreSaved: _onStoreSaved,
        ),
      ),
    );
  }

  void _onStoreSaved(String storeId) {
    setState(() {
      this.storeId = storeId;
      hasStore = true;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StoreProfile(storeId: storeId),
      ),
    );
  }

  void _onProductAdded() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StoreProfile(storeId: storeId),
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
                  )),
        );
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Cart(userId: '',
                    )));
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
    super.dispose();
  }
}
