import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agro/setting_components/manage_address.dart';
import 'package:agro/setting_components/manage_acc.dart';
import 'dart:io';

class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  File? _image;

  // Variabel untuk menyimpan nama, username, dan bio
  String _name = "Nama Default";
  String _username = "Username Default";
  String _bio = "Bio Default";

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  
      });
    }
  }

  // Fungsi untuk navigasi ke halaman ManageAcc dan menerima hasil edit
  Future<void> _navigateAndEditAccount() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageAcc(
        name: _name,
        username: _username,
        bio: _bio,
      )),
    );

    if (result != null) {
      setState(() {
        _name = result['name'];
        _username = result['username'];
        _bio = result['bio'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
        backgroundColor: Colors.green,
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
                      : null,
                  child: _image == null
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

          // Menampilkan Nama, Username, dan Bio di bawah lingkaran foto
          Text(
            _name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            _username,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 5),
          Text(
            _bio,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          
          SizedBox(height: 20), 

          // Daftar menu pengaturan
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Atur Akun Anda'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _navigateAndEditAccount,  // Navigasi ke halaman edit akun
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
          
          ListTile(
            leading: Icon(Icons.notification_add),
            title: Text('Notifikasi'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Aksi untuk pengaturan notifikasi
            },
          ),
          Divider(),
          
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Informasi Aplikasi'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Aksi untuk melihat informasi aplikasi
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
