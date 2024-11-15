import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // Untuk konversi ke base64
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_product.dart';

class StoreSettings extends StatefulWidget {
  final Function(String) onStoreSaved;

  StoreSettings({required this.onStoreSaved});

  @override
  _StoreSettingsState createState() => _StoreSettingsState();
}

class _StoreSettingsState extends State<StoreSettings> {
  final _formKey = GlobalKey<FormState>();
  String _storeName = '';
  String _sellerName = '';
  String _storeDescription = '';
  File? _storeImage;
  String? _storeImageBase64;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _storeImage = File(pickedFile.path);
      });

      // Konversi gambar ke base64 untuk disimpan di Firestore
      final bytes = await _storeImage!.readAsBytes();
      _storeImageBase64 = base64Encode(bytes);
    }
  }

  void _saveStore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Pengguna belum terautentikasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Simpan data toko ke Firebase Firestore
        DocumentReference storeRef =
            await FirebaseFirestore.instance.collection('stores').add({
          'store_name': _storeName,
          'seller_name': _sellerName,
          'description': _storeDescription,
          'sellerId': user.uid, // Menyimpan sellerId dengan ID pengguna yang sedang login
          'profilestore':
              _storeImageBase64, // Menyimpan gambar sebagai base64 di field 'profilestore'
          'storeId': '', // Tambahkan storeId dengan placeholder
        });

        // Mengupdate storeId setelah dokumen dibuat
        await storeRef.update({'storeId': storeRef.id});

        // Simpan sellerId, buyerId, dan storeId di koleksi users
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'sellerId': user.uid, // Pastikan sellerId sama dengan ID pengguna
            'buyerId': user.uid,
            'storeId': storeRef.id, // Menambahkan storeId ke pengguna
          },
          SetOptions(merge: true),
        );

        // Beri tahu bahwa toko berhasil disimpan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Toko berhasil disimpan!')),
        );

        // Arahkan ke halaman tambah produk dengan storeId setelah sedikit delay
        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddProduct(
              storeId: storeRef.id,
              onProductAdded: () {},
            ),
          ),
        );
      } catch (e) {
        // Tampilkan pesan kesalahan jika penyimpanan gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan toko: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atur Toko'),
        backgroundColor: Color.fromRGBO(168, 207, 69, 1)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _storeImage != null ? FileImage(_storeImage!) : null,
                  child: _storeImage == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : null,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Tambahkan Gambar Toko',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Toko'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama toko tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _storeName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Penjual'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama penjual tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _sellerName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deskripsi Toko'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) => _storeDescription = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStore,
                child: Text('Simpan Toko'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
