import 'package:agro/screens/trs.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Payment extends StatefulWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> products;
  final Function onPaymentSuccess;
  final Function onClearCart;

  Payment({
    required this.totalPrice,
    required this.products,
    required this.onPaymentSuccess,
    required this.onClearCart,
  });

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String _selectedPaymentMethod = 'Transfer Bank';
  String _deliveryOption = 'Ambil Sendiri'; // Pilihan pengiriman
  bool _isProcessing = false;

  // Biaya pengiriman jika memilih 'Diantar'
  double get _deliveryFee {
    return _deliveryOption == 'Diantar' ? 10000.0 : 0.0;
  }

  // Menghitung total harga dengan menambahkan biaya pengiriman
  double get _totalPriceWithDelivery {
    return widget.totalPrice + _deliveryFee;
  }

  @override
  void initState() {
    super.initState();
    _loadPaymentPreferences();  // Muat preferensi saat halaman dibuka
  }

  // Fungsi untuk memuat preferensi yang disimpan
  Future<void> _loadPaymentPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPaymentMethod = prefs.getString('paymentMethod') ?? 'Transfer Bank';
      _deliveryOption = prefs.getString('deliveryOption') ?? 'Ambil Sendiri';
    });
  }

  // Fungsi untuk menyimpan pilihan pengiriman dan metode pembayaran
  Future<void> _savePaymentPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('paymentMethod', _selectedPaymentMethod);
    await prefs.setString('deliveryOption', _deliveryOption);
  }

  Future<void> _confirmPayment() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda harus login terlebih dahulu.')),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pembayaran'),
        content: Text(
          'Metode Pembayaran: $_selectedPaymentMethod\n'
          'Metode Pengiriman: $_deliveryOption\n'
          'Total Pembayaran: Rp ${_totalPriceWithDelivery.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _savePaymentData(userId);

      // Simpan status pembayaran berhasil
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('paymentSuccess', true);

      // Kosongkan keranjang dan tunggu hingga selesai
      widget.onClearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran berhasil!')),
      );

      // Arahkan ke halaman transaksi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Trs()), // Ganti dengan halaman transaksi Anda
      );
    }

    // Simpan preferensi pengiriman dan metode pembayaran setelah konfirmasi pembayaran
    await _savePaymentPreferences();

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _savePaymentData(String userId) async {
    try {
      // Ambil semua item dari subkoleksi 'items' dalam dokumen pengguna di koleksi 'carts'
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      // Buat daftar untuk menyimpan item yang akan dimasukkan ke transaksi
      List<Map<String, dynamic>> items = [];

      double totalAmount = 0.0; // Untuk menghitung total harga semua barang

      for (var cartDoc in cartSnapshot.docs) {
        final cartData = cartDoc.data() as Map<String, dynamic>;

        // Ambil informasi yang diperlukan dari cartData
        String productName = cartData['name'] ?? 'Nama tidak tersedia';
        String sellerId = cartData['sellerId'] ?? 'unknown';
        String category = cartData['category'] ?? 'unknown';
        String storeId = cartData['storeId'] ?? 'unknown';
        double price =
            (cartData['price'] is num) ? cartData['price'].toDouble() : 0.0;
        int quantity = (cartData['quantity'] is int) ? cartData['quantity'] : 1;

        // Tambahkan item ke daftar
        items.add({
          'productName': productName,
          'category': category,
          'sellerId': sellerId,
          'storeId': storeId,
          'quantity': quantity,
          'price': price,
        });

        // Hitung total untuk semua item
        totalAmount += price * quantity;
      }

      // Simpan data pembayaran ke koleksi 'transactions' sebagai satu transaksi
      await FirebaseFirestore.instance.collection('transactions').add({
        'buyerId': userId,
        'sellerId': items.isNotEmpty
            ? items[0]['sellerId']
            : 'unknown', // Ambil sellerId dari item pertama
        'cartId':
            userId, // Simpan userId atau bisa menggantinya sesuai kebutuhan
        'items': items, // Simpan daftar item
        'totalPrice': totalAmount + _deliveryFee, // Tambahkan biaya pengiriman
        'paymentMethod': _selectedPaymentMethod,
        'deliveryOption': _deliveryOption, // Menyimpan pilihan pengiriman
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Data pembayaran berhasil disimpan.');
    } catch (e) {
      print('Error saat menyimpan data pembayaran: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menyimpan pembayaran.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
        backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ..._buildPaymentMethodRadios(),
            SizedBox(height: 16),
            Text(
              'Pilih Metode Pengiriman',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._buildDeliveryOptionRadios(), // Menambahkan pilihan pengiriman
            SizedBox(height: 16),
            Text(
              'Total Pembayaran: Rp ${_totalPriceWithDelivery.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _confirmPayment,
                child: Text('Lanjutkan Pembayaran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPaymentMethodRadios() {
    List<String> paymentMethods = [
      'COD (Cash on Delivery)',
    ];
    return paymentMethods.map((method) {
      return ListTile(
        title: Text(method),
        leading: Radio<String>(
          value: method,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value!;
            });
          },
        ),
      );
    }).toList();
  }

  // Menambahkan pilihan pengiriman
  List<Widget> _buildDeliveryOptionRadios() {
    List<String> deliveryOptions = [
      'Ambil Sendiri',
      'Diantar',
    ];
    return deliveryOptions.map((option) {
      return ListTile(
        title: Text(option),
        leading: Radio<String>(
          value: option,
          groupValue: _deliveryOption,
          onChanged: (value) {
            setState(() {
              _deliveryOption = value!;
            });
          },
        ),
      );
    }).toList();
  }
}
