import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _usernameController = TextEditingController(text: widget.username);
    _bioController = TextEditingController(text: widget.bio);
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
        backgroundColor: Colors.green,
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
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
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
                          color: Colors.green,
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan Nama',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Username',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan Username',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan Bio',
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        String name = _nameController.text;
                        String username = _usernameController.text;
                        String bio = _bioController.text;

                        Navigator.pop(context, {
                          'name': name,
                          'username': username,
                          'bio': bio,
                        });
                      },
                      child: Text('Simpan Perubahan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              5),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
