import 'package:agro/screens/mystore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditProduct extends StatefulWidget {
  final String productId;

  EditProduct({required this.productId});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _productImage; // Menambahkan variabel untuk gambar produk
  String? _productImageBase64; // Menyimpan gambar dalam format base64

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Pengguna terautentikasi, muat data produk
      await _loadProductData();
    } else {}
  }

  Future<void> _loadProductData() async {
    try {
      final product = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();

      if (product.exists) {
        _nameController.text = product['name'] ?? '';
        _priceController.text = product['price'].toString();
        _descriptionController.text = product['description'] ?? '';
        _productImageBase64 =
            product['productImage']; // Mengambil gambar produk

        // Mengkonversi gambar dari base64 dan menampilkannya
        if (_productImageBase64 != null) {
          setState(() {
            _productImage = null; // Kosongkan gambar dari file
          });
        }
      } else {
        // Tangani jika produk tidak ditemukan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk tidak ditemukan.')),
        );
      }
    } catch (e) {
      // Tangani kesalahan saat memuat data produk
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImage = File(pickedFile.path);
      });

      // Konversi gambar ke base64
      final bytes = await _productImage!.readAsBytes();
      _productImageBase64 = base64Encode(bytes);
    }
  }

  Future<void> _updateProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text,
        'productImage': _productImageBase64, // Memperbarui gambar produk
      });

      // Beri umpan balik kepada pengguna dan kembali ke halaman sebelumnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil diperbarui')),
      );

      // Kembali ke halaman toko
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Mystore()),
      );
      // Ganti '/toko' dengan rute yang sesuai
    } catch (e) {
      // Tangani kesalahan saat memperbarui produk
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // Mengganti gambar produk ketika diklik
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _productImage != null
                    ? FileImage(_productImage!)
                    : _productImageBase64 != null
                        ? MemoryImage(base64Decode(_productImageBase64!))
                        : null,
                child: _productImage == null && _productImageBase64 == null
                    ? Icon(Icons.camera_alt, size: 50)
                    : null,
                backgroundColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Klik untuk mengganti gambar produk',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Harga Produk'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Deskripsi Produk'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }
}
