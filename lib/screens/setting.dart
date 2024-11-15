import 'package:agro/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agro/setting_components/manage_address.dart';
import 'package:agro/setting_components/manage_acc.dart';

class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  File? _image;
  String _name = "";
  String _username = "";
  String _bio = "Bio Default";
  String userId = '';
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ??
          FirebaseAuth.instance.currentUser?.uid ??
          '';

      if (userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _name = userDoc['name'] ?? 'Nama belum diatur';
            _username = userDoc['username'] ?? '';
            _bio = userDoc['bio'] ?? 'Bio Default';
            _profileImageBase64 = userDoc[
                'profileImageBase64']; // Ambil data base64 dari Firestore
          });
        } else {
          print('Dokumen pengguna tidak ditemukan.');
        }
      } else {
        print('User ID kosong.');
      }
    } catch (e) {
      print('Error mengambil data pengguna: $e');
    }
  }

  Future<void> _navigateAndEditAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageAcc(
          name: _name,
          username: _username,
          bio: _bio,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _name = result['name'];
        _username = result['username'];
        _bio = result['bio'];
      });

      if (userId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'name': _name,
            'username': _username,
            'bio': _bio,
          });
          print('Data berhasil disimpan ke Firestore');
        } catch (e) {
          print('Error menyimpan data ke Firestore: $e');
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Mengonversi gambar ke base64 dan menyimpannya di Firestore
      final bytes = await _image!.readAsBytes();
      String base64Image = base64Encode(bytes);

      if (userId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'profileImageBase64':
                base64Image, // Simpan data gambar base64 ke Firestore
          });
          setState(() {
            _profileImageBase64 = base64Image; // Perbarui data gambar di state
          });
          print('Gambar berhasil disimpan ke Firestore');
        } catch (e) {
          print('Error menyimpan gambar ke Firestore: $e');
        }
      }
    }
  }

  Future<void> _logout() async {
    // Konfirmasi sebelum logout
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Keluar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmLogout) {
      try {
        await FirebaseAuth.instance.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('userId'); // Menghapus userId dari SharedPreferences

        // Navigasi ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Login()), // Gantilah dengan halaman login Anda
        );
      } catch (e) {
        print('Error logging out: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
        backgroundColor: Color.fromRGBO(168, 207, 69, 1),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 80,
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
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : null,
                  backgroundColor: Colors.grey[300],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            _name.isNotEmpty ? _name : 'Nama belum diatur',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            _username.isNotEmpty ? _username : 'Username belum diatur',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 5),
          Text(
            _bio,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Atur Akun Anda'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _navigateAndEditAccount,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home_outlined),
            title: Text('Ubah Alamat Pengantaran Default'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageAddress()),
              );
            },
          ),
          Divider(),
          // Tambahkan tombol logout di bawah
          SizedBox(height: 20),
          TextButton(
            onPressed: _logout,
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
