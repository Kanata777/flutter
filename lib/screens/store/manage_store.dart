import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StoreSettings extends StatefulWidget {
  @override
  _StoreSettingsState createState() => _StoreSettingsState();
}

class _StoreSettingsState extends State<StoreSettings> {
  File? _storeImage;
  final ImagePicker _picker = ImagePicker();
  String storeName = '';

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _storeImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar tidak dipilih!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat mengambil gambar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(200),
                splashColor: Colors.greenAccent.withOpacity(0.2),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(200),
                    image: _storeImage != null
                        ? DecorationImage(
                            image: FileImage(_storeImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _storeImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.black54),
                            SizedBox(height: 10),
                            Text(
                              'Pilih Gambar Toko',
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Atur Toko Anda',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Nama Toko'),
              onChanged: (value) {
                setState(() {
                  storeName = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (storeName.isNotEmpty && _storeImage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Toko disimpan!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Isi semua data terlebih dahulu!')),
                  );
                }
              },
              child: Text('Simpan Toko'),
            ),
          ],
        ),
      ),
    );
  }
}
