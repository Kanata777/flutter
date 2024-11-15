import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agro/screens/mystore.dart';

class AddProduct extends StatefulWidget {
  final String storeId;
  final Function onProductAdded;

  AddProduct({
    required this.storeId,
    required this.onProductAdded,
  });

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _productDescription = '';
  double _productPrice = 0.0;
  String? _productCategory;
  File? _productImage;
  String? _productImageBase64;
  String? _storeName;
  String? _sellerName;

  final List<String> categories = [
    'Buah',
    'Sayuran',
    'Hasil Ternak',
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImage = File(pickedFile.path);
      });

      // Konversi gambar ke base64 untuk disimpan di Firestore
      final bytes = await _productImage!.readAsBytes();
      _productImageBase64 = base64Encode(bytes);
    }
  }

  Future<void> _getStoreAndSellerNames() async {
    // Ambil data store berdasarkan storeId
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeId)
        .get();
    if (storeSnapshot.exists) {
      setState(() {
        _storeName = storeSnapshot[
            'store_name']; // Ganti dengan field yang sesuai di koleksi stores
        _sellerName = storeSnapshot[
            'seller_name']; // Ambil seller_name dari koleksi stores
      });
    }
  }

  void _addProduct() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Simpan data produk ke Firebase
      DocumentReference productRef =
          await FirebaseFirestore.instance.collection('products').add({
        'name': _productName,
        'description': _productDescription,
        'price': _productPrice,
        'category': _productCategory,
        'storeId': widget.storeId,
        'sellerId': user.uid,
        'productImage':
            _productImageBase64, // Simpan gambar produk sebagai base64
        'store_name': _storeName, // Tambahkan store_name
        'seller_name': _sellerName, // Tambahkan seller_name
      });

      // Menyimpan productId ke dalam dokumen produk
      await productRef
          .update({'productId': productRef.id}); // Menyimpan productId

      widget.onProductAdded();

      // Arahkan pengguna ke halaman StoreProfile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Mystore(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getStoreAndSellerNames(); // Ambil store_name dan seller_name saat widget diinisialisasi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk'),
        backgroundColor: Color.fromRGBO(168, 207, 69, 1),
      ),
      body: SingleChildScrollView(
        // Tambahkan SingleChildScrollView di sini
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _productImage != null
                        ? FileImage(_productImage!)
                        : null,
                    child: _productImage == null
                        ? Icon(Icons.camera_alt, size: 50)
                        : null,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tambahkan Gambar Produk',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nama Produk'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama produk tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) => _productName = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Deskripsi Produk'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) => _productDescription = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Harga Produk'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan harga yang valid';
                    }
                    return null;
                  },
                  onSaved: (value) => _productPrice = double.parse(value!),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Kategori Produk'),
                  value: _productCategory,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Kategori tidak boleh kosong';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _productCategory = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addProduct,
                  child: Text('Simpan Produk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
