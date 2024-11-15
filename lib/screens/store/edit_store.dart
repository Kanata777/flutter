import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditStorePage extends StatefulWidget {
  final String storeId;

  EditStorePage({required this.storeId});

  @override
  _EditStorePageState createState() => _EditStorePageState();
}

class _EditStorePageState extends State<EditStorePage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = true;
  File? _storeImage;
  String? _storeImageBase64;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      final store = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .get();

      if (store.exists) {
        _storeNameController.text = store['store_name'] ?? '';
        _sellerNameController.text = store['seller_name'] ?? '';
        _descriptionController.text = store['description'] ?? '';
        _storeImageBase64 = store['profilestore']; // Ambil data gambar base64 dari 'profilestore'
      }
    } catch (e) {
      print("Error loading store data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      setState(() {
        _storeImage = imageFile;
        _storeImageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _updateStore() async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .update({
        'store_name': _storeNameController.text,
        'seller_name': _sellerNameController.text,
        'description': _descriptionController.text,
        'profilestore':
            _storeImageBase64, // Simpan data gambar dalam 'profilestore'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informasi toko berhasil diperbarui!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui informasi toko: $e')),
      );
    }
  }

  Future<void> _deleteStore() async {
    try {
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toko berhasil dihapus!')),
      );
      Navigator.pop(context); // Kembali ke halaman sebelumnya setelah penghapusan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus toko: $e')),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Toko'),
          content: Text('Apakah Anda yakin ingin menghapus toko ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _deleteStore(); // Panggil fungsi untuk menghapus toko
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Informasi Toko')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _storeImage != null
                          ? FileImage(_storeImage!)
                          : (_storeImageBase64 != null
                              ? MemoryImage(base64Decode(_storeImageBase64!))
                              : null),
                      child: _storeImage == null && _storeImageBase64 == null
                          ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                          : null,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('Ubah Gambar Toko',
                      style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 20),
                  TextField(
                    controller: _storeNameController,
                    decoration: InputDecoration(labelText: 'Nama Toko'),
                  ),
                  TextField(
                    controller: _sellerNameController,
                    decoration: InputDecoration(labelText: 'Nama Penjual'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Deskripsi Toko'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateStore,
                    child: Text('Simpan Perubahan'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _confirmDelete,
                    child: Text('Hapus Toko'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
    );
  }
}
