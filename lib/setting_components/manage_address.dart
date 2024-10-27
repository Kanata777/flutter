import 'package:flutter/material.dart';

class ManageAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atur Alamat Pengantaran'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Tambah Alamat Baru'),
            trailing: Icon(Icons.add),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAddressPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Alamat Utama: Jl. Merpati No. 123'),
            trailing: Icon(Icons.edit),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditAddressPage()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Hapus Alamat'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Konfirmasi'),
                    content: Text('Apakah Anda yakin ingin menghapus alamat ini?'),
                    actions: [
                      TextButton(
                        child: Text('Batal'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Hapus'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}

class AddAddressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Alamat Baru'),
      ),
      body: Center(
        child: Text('Form Tambah Alamat di sini'),
      ),
    );
  }
}

class EditAddressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Alamat'),
      ),
      body: Center(
        child: Text('Form Edit Alamat di sini'),
      ),
    );
  }
}
