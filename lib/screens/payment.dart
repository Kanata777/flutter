// payment.dart
import 'package:flutter/material.dart';
import 'package:agro/screens/model/payment.dart';

class Payment extends StatefulWidget {
  final double totalPrice;
  final String productName; // Tambahkan nama produk

  Payment({required this.totalPrice, required this.productName}); // Tambahkan parameter

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String _selectedPaymentMethod = 'Transfer Bank';

  void _confirmPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Pembayaran'),
        content: Text('Metode Pembayaran: $_selectedPaymentMethod\nTotal Pembayaran: Rp ${widget.totalPrice.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Simpan data pembayaran ke model
              PaymentModel.addPayment(widget.productName, widget.totalPrice, DateTime.now().toString().split(' ')[0], true);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pembayaran Berhasil Dikonfirmasi')),
              );
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
            child: Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
        backgroundColor: const Color.fromARGB(255, 42, 226, 42),
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
            ListTile(
              title: Text('Transfer Bank'),
              leading: Radio<String>(
                value: 'Transfer Bank',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('Kartu Kredit/Debit'),
              leading: Radio<String>(
                value: 'Kartu Kredit/Debit',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('E-Wallet'),
              leading: Radio<String>(
                value: 'E-Wallet',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('COD (Cash on Delivery)'),
              leading: Radio<String>(
                value: 'COD',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total Pembayaran: Rp ${widget.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _confirmPayment,
                child: Text('Lanjutkan Pembayaran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
