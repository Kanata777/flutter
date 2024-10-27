import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String productName = '';
  String productDescription = '';
  String productPrice = '';
  List<File?> _productImages = List.generate(4, (index) => null); // Daftar untuk menyimpan 4 gambar
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _productImages[index] = File(pickedFile.path);
      }
    });
  }

  void _addProduct() {
    if (productName.isNotEmpty &&
        productPrice.isNotEmpty &&
        productDescription.isNotEmpty &&
        _productImages.any((image) => image != null)) { // Memastikan setidaknya ada satu gambar
      // Logika untuk menambahkan produk
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk ditambahkan!')),
      );
      // Reset form setelah menambahkan produk
      setState(() {
        productName = '';
        productPrice = '';
        productDescription = '';
        _productImages = List.generate(4, (index) => null); // Reset gambar
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi semua data produk terlebih dahulu!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Produk',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(height: 20),
              // Menampilkan thumbnail gambar sebagai tombol
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _productImages.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () => _pickImage(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Warna latar belakang
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _productImages[index] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _productImages[index]!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.black54),
                              SizedBox(height: 10),
                              Text(
                                'Gambar ${index + 1}\n${_productImages[index] == null ? 'Pilih Gambar' : 'Ganti Gambar'}',
                                style: TextStyle(color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  );
                },
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    productName = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Harga Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    productPrice = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Deskripsi Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.greenAccent),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    productDescription = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _addProduct,
                child: Text('Tambahkan Produk', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
