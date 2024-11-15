import 'package:agro/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageAddress extends StatefulWidget {
  @override
  _ManageAddressState createState() => _ManageAddressState();
}

class _ManageAddressState extends State<ManageAddress> {
  final TextEditingController _addressController = TextEditingController();
  String _currentAddress = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _loadCurrentAddress();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  Future<void> _loadCurrentAddress() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .get();

    if (snapshot.exists && snapshot['address'] != null) {
      setState(() {
        _currentAddress = snapshot['address'];
        _addressController.text = _currentAddress;
      });
    }
  }

  Future<void> _saveAddress() async {
    if (_addressController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'address': _addressController.text});

      setState(() {
        _currentAddress = _addressController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alamat berhasil disimpan'),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alamat tidak boleh kosong'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }

  Future<void> _deleteAddress() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .update({'address': FieldValue.delete()});

    setState(() {
      _currentAddress = '';
      _addressController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alamat berhasil dihapus'),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Alamat'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(168, 207, 69, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks Informasi Alamat Saat Ini
            Text(
              'Alamat Saat Ini:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            // Menampilkan alamat yang ada
            if (_currentAddress.isNotEmpty)
              Text(
                _currentAddress,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            SizedBox(height: 10),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alamat baru...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            // Tombol Hapus dan Simpan dengan ukuran lebih kecil
            ElevatedButton.icon(
              onPressed: _deleteAddress,
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text('Hapus Alamat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveAddress,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text('Simpan Alamat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(168, 207, 69, 1),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
