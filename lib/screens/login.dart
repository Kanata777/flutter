import 'package:agro/consts/gambar.dart';
import 'package:flutter/material.dart';
import 'package:agro/screens/register.dart';
import 'package:agro/screens/forgotpass.dart';
import 'dashboard.dart';


class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final String validUsername = "admin";

  final String validPassword = "password123";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(168, 207, 69, 1),
        title: Text(
          'Login',
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 1),
            Image.asset(
              Cthproduk,
              width: 100,
              height: 100, 
            ),
            SizedBox(height: 20), 
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Nama User')
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                prefixIconColor: Colors.black 
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Password')
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                prefixIconColor: Colors.black
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPass()),
                    );
                    },
                  child: Text('Lupa Password?',
                  style: TextStyle(
                    color: Colors.black
                  ),),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                String username = nameController.text;
                String password = passwordController.text;
                // Validasi login
                if (username.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap isi semua kolom')),
                  );
                } else if (username == validUsername && password == validPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login Berhasil')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard(storeName: '', products: [],)),
                  );
                } else if (username != validUsername) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Username tidak terdaftar')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password salah')),
                  );
                }
              }, 
              child: Text('Masuk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(105, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ), 
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Register()),
                );
              },
              child: Text('Belum Punya Akun? Daftar',style: TextStyle(
                color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}

