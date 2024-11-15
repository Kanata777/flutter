import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // Untuk konversi ke base64
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAcc extends StatefulWidget {
  final String name;
  final String username;
  final String bio;

  ManageAcc({required this.name, required this.username, required this.bio});
  @override
  State<ManageAcc> createState() => _ManageAccState();
}

class _ManageAccState extends State<ManageAcc> {
  File? _image;
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _usernameController = TextEditingController(text: widget.username);
    _bioController = TextEditingController(text: widget.bio);
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _profileImageBase64 = doc['profileImageBase64'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Metode untuk mengonversi gambar ke format base64
  Future<String?> _convertImageToBase64(File image) async {
    try {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print("Gagal mengonversi gambar: $e");
      return null;
    }
  }

  Future<void> _saveToFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print("User ID: ${user.uid}");
        CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');

        String? profileImageBase64;
        if (_image != null) {
          profileImageBase64 =
              await _convertImageToBase64(_image!); // Konversi gambar ke base64
        }

        await usersCollection.doc(user.uid).set({
          'name': _nameController.text,
          'username': _usernameController.text,
          'bio': _bioController.text,
          'profileImageBase64': profileImageBase64 ?? '', // Simpan data base64
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perubahan berhasil disimpan')),
        );

        Navigator.pop(context, {
          'name': _nameController.text,
          'username': _usernameController.text,
          'bio': _bioController.text,
        });

        setState(() {
          _profileImageBase64 = profileImageBase64; // Update URL gambar
        });
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan perubahan')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Akun'),
        backgroundColor: Color.fromRGBO(168, 207, 69, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : _profileImageBase64 != null
                            ? MemoryImage(base64Decode(
                                _profileImageBase64!)) // Decode base64 menjadi gambar
                            : null,
                    child: (_image == null && _profileImageBase64 == null)
                        ? Text(
                            'Belum ada foto',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : null,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        _image == null
                            ? 'Tambahkan Foto Profil'
                            : 'Ubah Foto Profil',
                        style: TextStyle(
                          color: Color.fromRGBO(168, 207, 69, 1),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveToFirebase,
              child: Text('Simpan Perubahan'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
